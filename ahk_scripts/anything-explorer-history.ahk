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
; [Candidates Var]
directory_history:=Array()
anything_explorer_max_candidate_count:=100
;;source for anything .
anything_explorer_history_source:=Object()
anything_explorer_history_source["candidate"]:= directory_history
anything_explorer_history_source["action"]:=Array("visit_directory","delete_from_directory_history" ,"delete_all_directory_history")
anything_explorer_history_source["onselect"]:="anything_explorer_history_onselect"
anything_explorer_history_source["name"]:="ExpHist"
anything_explorer_history_source["anything-execute-action-at-once-if-one"] := "yes"
anything_explorer_history_source["anything-execute-action-at-once-if-one-even-no-keyword"] := "no"



anything_directory_init()
;;every 5 minute ,save history to disk
anything_SetTimerF("write_history_2_disk",60000,Object()) ;create a timer

SetTitleMatchMode Regex ;
#IfWinActive ahk_class ExploreWClass|CabinetWClass
~LButton::
  if (A_PriorHotkey <> "~LButton" or A_TimeSincePriorHotkey > 200)
  {
    ; Too much time between presses, so this isn't a double-press.
    anything_explorer_history_address:=getExplorerAddressPath()
    KeyWait, LButton
    anything_SetTimerF("addressChangeTimer",-200,Object()) ;create a timer ,only run one time after 200ms
   return
  }
return

~Enter::
sleep ,200
 if (WinActive("ahk_class ExploreWClass") or WinActive("ahk_class CabinetWClass"))
 {
     anything_explorer_history_address:=getExplorerAddressPath()
     anything_add_directory_history(anything_explorer_history_address)
 }
return
#IfWinActive

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; when address in explorer.exe changed in 200ms after LButton down ,then
; it will add the newAddress to directory candidates
addressChangeTimer()
{
    global anything_explorer_history_address
    if (WinActive("ahk_class ExploreWClass") or WinActive("ahk_class CabinetWClass"))
    {
        newAddr:= getExplorerAddressPath()
        if (anything_explorer_history_address <> newAddr)
        {
            ;;add to history list
            anything_add_directory_history(newAddr)
        }
    }
}

;when anything-explorer-history.ahk start
; init variable "directory_history" from anything-explorer-history.ini if exists
anything_directory_init()
{
    global directory_history
    ;;anything_directory_init history when first run this script
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
}

; wriate directory candidates to disk,so even you restart
; your computer ,it can still remember your diretory history
write_history_2_disk()
{
  global directory_history
  directory_text=
  for key ,directory in directory_history
  {
    directory_text=%directory_text%%directory%
  }
  IniWrite,%directory_text%,anything-explorer-history.ini, main, history
}

; add newAddr to explorer-history candidates
anything_add_directory_history(newAddr)
{
  global directory_history
  if (newAddr =="")
  {
      return
  }
  for key ,directory in directory_history
  {
    if (directory = newAddr)
    {
      directory_history.remove(key)
      Break
    }
  }
  directory_history.insert(1,newAddr)
  if (directory_history.maxIndex()>anything_explorer_max_candidate_count)
  {
    directory_history.remove(anything_explorer_max_candidate_count+1)
  }
}

getExplorerAddressPath()
{
    WinGetText,full_path,A
    StringSplit,word_array,full_path,`n
    full_path:= word_array1
    Pos :=InStr(full_path,":\")
    if(Pos>0)
    {
        path2:= SubStr(full_path,Pos-1,1) . SubStr(full_path,Pos)
    }
    StringReplace, path2, path2, `r, , all
    return path2
}

; delete all directory history from candidates
; [Action Fun]
delete_all_directory_history(unused_candidate)
{
  global directory_history
  maxIndex:=directory_history.maxIndex()
  Loop , %maxIndex%
  {
    directory_history.remove(1)
    maxIndex-=1
  }
}

; delete selected candidate  from candidates
; [Action Fun]
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
}
; onselect
anything_explorer_history_onselect(candidate)
{
    directory := candidate
    anything_statusbar(directory)
}
; visit candidate directory in explorer.exe or cmd.exe or  bash.exe
; depend on current activated window
; [Default Action Fun]
visit_directory( candidate_directory)
{
    global anything_previous_activated_win_id
 ; WinGet, id, list, , , Program Manager
  ; WinGet, processName, ProcessName, ahk_id %id2%
  ; WinGet, pid, PID, ahk_id %id2%
    active_id :=anything_previous_activated_win_id

     if (not  FileExist(candidate_directory))
     {
         delete_from_directory_history(candidate_directory)
         anything_MsgBox( candidate_directory  . " doesn't exists")
         return
     }

  WinGet, processName, ProcessName, ahk_id %active_id%
  WinGetClass, activeWinClass ,ahk_id %active_id%
  WinGet, pid, PID,  ahk_id %active_id%
; ;;  global active_id

  anything_add_directory_history(candidate_directory)
  write_history_2_disk()

  WinActivate, ahk_pid %pid%

  if (processName="sh.exe" or processName="bash.exe" ){ ; msys
         WinActivate, ahk_pid %pid%
         SetKeyDelay, 0
         candidate_directory:= win2msysPath(candidate_directory)
         SendInput ,%A_Space%cd "%candidate_directory%"  {Enter}
  }else if (processName="cmd.exe"){
           SendInput, %A_Space%cd /d "%candidate_directory%"{Enter}
  }
 ;  Else if (processName="emacs.exe"){
 ; ;      WinActivate, ahk_id %active_id%
 ; ;    SetKeyDelay, 0
 ; ; SendInput, {Esc 3}^g^g!xdired{return}%candidate_directory%{tab}{return}
 ;    dired_cmd:="emacsclientw  --eval ""(dired \""" . win2posixPath(candidate_directory) . "\"")"" "
 ;    Run ,%dired_cmd% ,,UseErrorLevel  ;  don't display dialog if it fails.
 ;    if ErrorLevel = ERROR
 ;    {
 ;       MsgBox ,Please add you Emacs/bin path  to your Path ,and add (server-start) to you .emacs
 ;    }
 ; }
 else{
       h := WinExist("ahk_class ExploreWClass")
       if (h != 0 )
       {
         WinActivate ,ahk_class ExploreWClass
       }
       else
       {
         h := WinExist("ahk_class CabinetWClass")
         if (h != 0)
         {
           WinActivate ,ahk_class CabinetWClass
         }else
         {
           Run explorer.exe   /n`, /e`,  "%candidate_directory%"
           WinWait ,ahk_class ExploreWClass
           h := WinExist("ahk_class CabinetWClass")
         }
       }
         ; MsgBox % h
          ; WinActivate
          ; h :=   WinExist("A")
            ComObjError(false)          ; 不报com错
            For win in ComObjCreate("Shell.Application").Windows
            if   (win and  (win.hwnd=h))
              win.Navigate[candidate_directory]
            Until   (win.hwnd=h)

          sleep 50
       if A_OSVersion in WIN_7,WIN_VISTA  ; Note: No spaces around commas.
       {
           ControlFocus, DirectUIHWND3,A
       }else{
          ControlFocus, SysListView321,A
      }
          Send {Home}{Down}{Up}
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
