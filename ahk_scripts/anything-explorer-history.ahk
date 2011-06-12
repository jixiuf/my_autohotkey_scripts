;;; anything-explorer-history.ahk record and visit explorer.exe history using anything.ahk           
#include anything.ahk
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode Regex ;
;;global variable 
;;active_id=
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

;;source for anything .
anything_explorer_history_source:=Object()
anything_explorer_history_source["candidate"]:= directory_history
anything_explorer_history_source["action"] :=Array("visit_directory","delete_from_directory_history")
anything_explorer_history_source["name"]:="ExpHist"

; f3::
; ;;  WinGet, active_id, ID, A
;    anything(anything_explorer_history_source)
; return

#IfWinActive ahk_class ExploreWClass|CabinetWClass

~LButton::
  if (A_PriorHotkey <> "~LButton" or A_TimeSincePriorHotkey > 200)
  {
    ; Too much time between presses, so this isn't a double-press.
    address:=getExplorerAddressPath()
    KeyWait, LButton
   SetTimer, addressChangeTimer, 200 
   return
  }
return

#IfWinActive 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
addressChangeTimer:
  SetTimer, addressChangeTimer ,off
  if WinActive(  "ahk_class ExploreWClass|CabinetWClass")
  {
     newAddr:= getExplorerAddressPath()
     if (address <> newAddr)
      {
        ;;add to history list 
        updateHistory(newAddr)
        writeHistory2Disk()
      }
  }
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
  if (directory_history.maxIndex()>50)
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
 writeHistory2Disk()
}
visit_directory( candidate_directory)
{
  WinGet, active_id, ID, A
;;  global active_id 
  WinGetClass, activeWinClass ,ahk_id %active_id%
  updateHistory(candidate_directory)
  writeHistory2Disk()
  if (activeWinClass ="ExploreWClass" or activeWinClass= "CabinetWClass")
  {
		ControlSetText, Edit1, %candidate_directory%, ahk_id %active_id%
		; Tekl reported the following: "If I want to change to Folder L:\folder
		; then the addressbar shows http://www.L:\folder.com. To solve this,
		; I added a {right} before {Enter}":
		ControlSend, Edit1, {Right}{Enter}, ahk_id %active_id%
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
  	WinActivate, ahk_id %active_id% 
	SetKeyDelay, 0 
 SendInput, {Esc 3}^g^g!xdired{return}%candidate_directory%{tab}{return}
 }else{
     Run explorer.exe   "%candidate_directory%"
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

