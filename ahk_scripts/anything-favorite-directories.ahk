;;; anything-favorites-directory.ahk  --- visit your favorites directories by anything.ahk

; if you use anything-favorites-directory as the only source for anything.ahk
; you just need to bind it to a key like this :

; #include anything-favorites-directory.ahk
; f1::anything(anything_favorite_directories_source)
;
; if you also use other sources ,just need add "anything_favorite_directories_source" to
; the array of sources for anything_multiple_sources(sources)
;
; 1 how to add a new Folder to your favorite-directories
; first activate "Anything" and Press <Ctrl-L> list all available actions
; select "call action: Favdirs.anything_favorite_directories_add "
;
; 2 then you can use "Anything" selected one of your favorite directory
;   it will visit it in current Explorer.exe (if current activated window is Explorer.exe)
;   it will visit it in current cmd.exe (if current activated window is cmd.exe)
;   it will visit it in current msys.bat (if current activated window is msys.bat)
;   it will visit it in current Emacs (if current activated window is Emacs.exe)


;;#include anything.ahk
;;SetWorkingDir %A_ScriptDir%
anything_favorite_directories:=Array()
;;init
IfExist, %A_MyDocuments%\anything-favorite-directories.ini
{
iniread, favorite_line, %A_MyDocuments%\anything-favorite-directories.ini, main, favorites
Loop, Parse, favorite_line,,
   {
     if A_LoopField <>
     {
        anything_favorite_directories.insert(A_LoopField)
     }
   }
}

;;source for anything .
anything_favorite_directories_source:=Object()
anything_favorite_directories_source["candidate"]:= anything_favorite_directories
anything_favorite_directories_source["action"]:=Array("anything_favorite_directories_visit","anything_favorite_directories_delete","anything_favorite_directories_add")
anything_favorite_directories_source["action_desc"]:=Array("Visit Selected Directory","Delete Selected Item" ,"Add New Directory")
anything_favorite_directories_source["onselect"]:="anything_favorite_directories_onselect"
anything_favorite_directories_source["name"]:="FavDirs"
anything_favorite_directories_source["anything-execute-action-at-once-if-one"] := "yes"
anything_favorite_directories_source["anything-execute-action-at-once-if-one-even-no-keyword"] := "no"

; onselect
anything_favorite_directories_onselect(candidate)
{
    directory := candidate
    anything_statusbar(directory)
}

;;action
anything_favorite_directories_visit(candidate_directory)
{
    global anything_previous_activated_win_id
 ; WinGet, id, list, , , Program Manager
  ; WinGet, processName, ProcessName, ahk_id %id2%
  ; WinGet, pid, PID, ahk_id %id2%
    active_id :=anything_previous_activated_win_id

    if (not  FileExist(candidate_directory))
    {
        anything_favorite_directories_delete(candidate_directory)
        anything_MsgBox("directory doesn't exists")
        return
    }

  WinGet, processName, ProcessName, ahk_id %active_id%
  WinGetClass, activeWinClass ,ahk_id %active_id%
  WinGet, pid, PID,  ahk_id %active_id%
  WinGetTitle, Title,ahk_id %active_id%
; ;;  global active_id

  ; updateHistory(candidate_directory)

  WinActivate, ahk_pid %pid%
  if (processName="werl.exe" or Title="C:\Windows\system32\cmd.exe - erl"){
      candidate_directory:=win2posixPath(candidate_directory)
      SendInput, %A_Space%cd ( "%candidate_directory%").{Enter}
  }else if (Title == "Git Bash" ){ ; msys
         WinActivate, ahk_pid %pid%
         SetKeyDelay, 0
         candidate_directory:= anything_favorite_directories_win2posixPath(candidate_directory)
         SendInput, %A_Space%cd "%candidate_directory%"{Enter}
  }else if (processName="sh.exe" or processName="bash.exe" ){ ; msys
         WinActivate, ahk_pid %pid%
         SetKeyDelay, 0
         candidate_directory:= anything_favorite_directories_win2posixPath(candidate_directory)
         SendInput, %A_Space%cd "%candidate_directory%"{Enter}
  }else if (processName="cmd.exe"){
           SendInput, cd /d "%candidate_directory%"{Enter}
  }
 ;  else if (processName="emacs.exe"){
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
           WinWait ,ahk_class CabinetWClass
           h := WinExist("ahk_class CabinetWClass")
         }
       }
         ; MsgBox % h
          ; WinActivate
          ; h :=   WinExist("A")

            For win in ComObjCreate("Shell.Application").Windows
            if   (win.hwnd=h)
              win.Navigate[candidate_directory]
            Until   (win.hwnd=h)

          sleep 50
          ControlFocus, SysListView321,A
          Send {Home}
   }
}
;;action
anything_favorite_directories_delete(candidate)
{
  global anything_favorite_directories
  for key ,directory in anything_favorite_directories
  {
    if (directory = candidate)
    {
      anything_favorite_directories.remove(key)
      Break
    }
  }
    anything_favorite_directories_write2disk()
}

add2FavoriteDirectories(candidate)
{
  global anything_favorite_directories
  for key ,directory in anything_favorite_directories
  {
    if (directory = candidate)
    {
      anything_favorite_directories.remove(key)
      Break
    }
  }
  anything_favorite_directories.insert(1,candidate)
}
;;action
anything_favorite_directories_add(unused_candidate)
{
    global
    old_value_of_quit_when_lose_focus=anything_properties["quit_when_lose_focus"]
    anything_set_property_4_quit_when_lose_focus("no")

  FileSelectFolder, newFavDir, , 3
  if newFavDir <>
  {
   add2FavoriteDirectories(newFavDir)
  }
    anything_favorite_directories_write2disk()
    anything_set_property_4_quit_when_lose_focus(old_value_of_quit_when_lose_focus=anything_properties)

}

anything_favorite_directories_write2disk()
{
  global anything_favorite_directories
  directory_text=
  for key ,directory in anything_favorite_directories
  {
    directory_text=%directory_text%%directory%
  }
  IniWrite,%directory_text%,%A_MyDocuments%\anything-favorite-directories.ini, main, favorites
}
;;Windows Path to msys Path
;; for example c:\a\b\ to /d/a/b
anything_favorite_directories_win2msysPath(winPath){
   msysPath:= RegExReplace(winPath, "^([a-zA-Z]):"  ,"$1" )
   StringReplace, msysPath2, msysPath, \ , /, All
   msysPath3 = /%msysPath2%
   return %msysPath3%
}

;;c:\a\b -->d:/a/b
anything_favorite_directories_win2posixPath(winPath)
{
   StringReplace, posixPath, winPath, \ , /, All
   Return posixPath
}
;;f1::anything(anything_favorite_directories_source)
;; anything-favorites-directory.ahk ends here.
