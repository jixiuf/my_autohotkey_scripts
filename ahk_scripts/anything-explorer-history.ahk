;;; anything-explorer-history.ahk record and visit explorer.exe history using anything.ahk           
; when you click directory in your explorer , anything-explorer-history.ahk
; will remember the directories you have vistied, and 'Anyting' will use it 
; as candidates ,you can visited again easyly.
; source is hosted on
; https://github.com/jixiuf/my_autohotkey_scripts/tree/master/ahk_scripts
; and you can find the forum here
; http://www.autohotkey.com/forum/viewtopic.php?t=72833

;;how to use `anything-explorer-history.ahk'
;1 
; if you only have one anything-source :
;         anything_explorer_history_source  (defined in this file )
; you can use it like this :
;
;     #include anything.ahk
;     #include anything-explorer-history.ahk
;     f3::anything(anything_explorer_history_source)
;
; 2  if you also have other anything-sources ,
;     you just need add 
;         anything_explorer_history_source
;     to the sources
;    for example :
;
;    f3::
;    sources:=Array()
;    sources.insert(anything_explorer_history_source)
;    sources.insert(anything_favorite_directories_source)
;    sources.insert(anything_cmd_source)
;    anything_multiple_sources(sources)
;    return



#Persistent
;;#include anything.ahk
;;SetWorkingDir %A_ScriptDir%
directory_history:=Array()
;;init history when first run this script 
IfExist, anything-explorer-history.ini
{
IniRead, history_line, anything-explorer-history.ini, main, history
Loop, Parse,  history_line,,
   {
     if A_LoopField <>
     {
       directory_history.insert(A_LoopField)
     }
   }
}
;;every 5 minute ,save history to disk 
SetTimer, writeAnythingExpHist2Desk, 60000 

;;source for anything .
anything_explorer_history_source:=Object()
anything_explorer_history_source["candidate"]:= directory_history
anything_explorer_history_source["action"]:=Array("visit_directory","delete_from_directory_history" ,"delete_all_directory_history")
anything_explorer_history_source["name"]:="ExpHist"


SetTitleMatchMode Regex ;
#IfWinActive ahk_class ExploreWClass|CabinetWClass
~LButton::
  if (A_PriorHotkey <> "~LButton" or A_TimeSincePriorHotkey > 200)
  {
    ; Too much time between presses, so this isn't a double-press.
    anything_explorer_history_address:=getExplorerAddressPath()
    KeyWait, LButton
   SetTimer, addressChangeTimer, 200 
   return
  }
return
#IfWinActive

  return
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
addressChangeTimer:
  SetTimer, addressChangeTimer ,off
  if WinActive(  "ahk_class ExploreWClass|CabinetWClass")
  {
     newAddr:= getExplorerAddressPath()
     if (anything_explorer_history_address <> newAddr)
      {
        ;;add to history list 
        updateHistory(newAddr)
;;        writeHistory2Disk()
      }
  }
return



writeAnythingExpHist2Desk:
  writeHistory2Disk()
return

writeHistory2Disk()
{
  global directory_history
  directory_text=
  for key ,directory in directory_history
  {
    directory_text=%directory_text%%directory%
  }
  IniWrite,%directory_text%,anything-explorer-history.ini, main, history
}

updateHistory(newAddr)
{
  global directory_history
  for key ,directory in directory_history
  {
    if (directory = newAddr)
    {
      directory_history.remove(key)
      Break
    }
  }
  directory_history.insert(1,newAddr)
  if (directory_history.maxIndex()>100)
  {
    directory_history.remove(51)
  }
}

getExplorerAddressPath()
{
  ; WinGetText, full_path, A  ; 
  ; StringSplit, word_array, full_path, `n     ;;
  ; full_path = %word_array1%   ; Take the first element from the array
  ; StringReplace, full_path, full_path, `r, , all   ; 
  ;;return full_path
  ControlGetText, ExplorePath, Edit1, A
  return ExplorePath
}

delete_all_directory_history(unused_candidate)
{
  global directory_history
  maxIndex:=directory_history.maxIndex()
  Loop , %maxIndex%
  {
    directory_history.remove(1)
    maxIndex-=1
  }
;;   writeHistory2Disk()
}

delete_from_directory_history(candidate)
{
  global directory_history
  for key ,directory in directory_history
  {
    if (directory = candidate)
    {
      directory_history.remove(key)
      Break
    }
  }
 ;;writeHistory2Disk()
}
visit_directory( candidate_directory)
{
  WinGet, active_id, ID, A
;;  global active_id 
  WinGetClass, activeWinClass ,ahk_id %active_id%
  updateHistory(candidate_directory)
  ;;writeHistory2Disk()
  if (activeWinClass ="ExploreWClass" or activeWinClass= "CabinetWClass")
  {
		ControlSetText, Edit1, %candidate_directory%, ahk_id %active_id%
		; Tekl reported the following: "If I want to change to Folder L:\folder
		; then the addressbar shows http://www.L:\folder.com. To solve this,
		; I added a {right} before {Enter}":
		ControlSend, Edit1, {Right}{Enter}, ahk_id %active_id%
        sleep 500
        ControlFocus, SysListView321,A
        Send {Home} ;;selected first file dired
        

		return
  }else if (activeWinClass="ConsoleWindowClass"){
         WinGetTitle, title ,ahk_id %active_id%
         WinActivate, ahk_id %active_id% 
         SetKeyDelay, 0
         if ( InStr(title ,"MINGW32:",true))
         {
           candidate_directory:= win2msysPath(candidate_directory)
           SendInput, cd "%candidate_directory%"{Enter}
         }else
         {
           SendInput, cd /d "%candidate_directory%"{Enter}
         }
  }else if (activeWinClass="Emacs"){
 ;  	WinActivate, ahk_id %active_id% 
 ;    SetKeyDelay, 0 
 ; SendInput, {Esc 3}^g^g!xdired{return}%candidate_directory%{tab}{return}
    dired_cmd:="emacsclientw  --eval ""(dired \""" . win2posixPath(candidate_directory) . "\"")"" "
    Run ,%dired_cmd% ,,UseErrorLevel  ;  don't display dialog if it fails.
    if ErrorLevel = ERROR
    {
       MsgBox ,Please add you Emacs/bin path  to your Path ,and add (server-start) to you .emacs 
    }
 }else{
      Run explorer.exe   /n`, /e`,  "%candidate_directory%"
      WinWait ahk_class (CabinetWClass|ExploreWClass) 
      WinActivate
      sleep 300
      ControlFocus, SysListView321,A
      Send {Home}
   }
}



;;Windows Path to msys Path 
;; for example d:\a\b\ to /d/a/b
win2msysPath(winPath){
   msysPath:= RegExReplace(winPath, "^([a-zA-Z]):"  ,"$1" )
   StringReplace, msysPath2, msysPath, \ , /, All
   msysPath3 = /%msysPath2%
   return %msysPath3%
}

;;d:\a\b -->d:/a/b
win2posixPath(winPath)
{
   StringReplace, posixPath, winPath, \ , /, All
   Return posixPath  
}
