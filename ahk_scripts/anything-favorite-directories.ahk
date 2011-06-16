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


#include anything.ahk
SetWorkingDir %A_ScriptDir%
anything_favorite_directories:=Array()
;;init  
IfExist, anything-favorite-directories.ini
{
iniread, favorite_line, anything-favorite-directories.ini, main, favorites
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
anything_favorite_directories_source["name"]:="FavDirs"

;;action 
anything_favorite_directories_visit(candidate_directory)
{
   SetTitleMatchMode Regex ;

  WinGet, active_id, ID, A
;;  global active_id 
  WinGetClass, activeWinClass ,ahk_id %active_id%
  if (activeWinClass ="ExploreWClass" or activeWinClass= "CabinetWClass")
  {
		ControlSetText, Edit1, %candidate_directory%, ahk_id %active_id%
		; Tekl reported the following: "If I want to change to Folder L:\folder
		; then the addressbar shows http://www.L:\folder.com. To solve this,
		; I added a {right} before {Enter}":
		ControlSend, Edit1, {Right}{Enter}, ahk_id %active_id%
        sleep 100
        ControlFocus, SysListView321,A
        Send {Home} ;;selected first file dired
		return
  }else if (activeWinClass="ConsoleWindowClass"){
         WinGetTitle, title ,ahk_id %active_id%
         WinActivate, ahk_id %active_id% 
         SetKeyDelay, 0
         if ( InStr(title ,"MINGW32:",true))
         {
           candidate_directory:= anything_favorite_directories_win2msysPath(candidate_directory)
           SendInput, cd "%candidate_directory%"{Enter}
         }else
         {
           SendInput, cd /d "%candidate_directory%"{Enter}
         }
  }else if (activeWinClass="Emacs"){
    dired_cmd:="emacsclientw  --eval ""(dired \""" . anything_favorite_directories_win2posixPath(candidate_directory) . "\"")"" "
    Run ,%dired_cmd% ,,UseErrorLevel  ;  don't display dialog if it fails.
    if ErrorLevel = ERROR
    {
       MsgBox ,Please add you Emacs/bin path  to your Path ,and add (server-start) to you .emacs 
    }
 }else{
      Run explorer.exe   /n`, /e`,  "%candidate_directory%"
      WinWait ahk_class (CabinetWClass|ExploreWClass) 
      WinActivate
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
  FileSelectFolder, newFavDir, , 3
  if newFavDir <>
  {
   add2FavoriteDirectories(newFavDir) 
  }
    anything_favorite_directories_write2disk()
}

anything_favorite_directories_write2disk()
{
  global anything_favorite_directories
  directory_text=
  for key ,directory in anything_favorite_directories
  {
    directory_text=%directory_text%%directory%
  }
  IniWrite,%directory_text%,anything-favorite-directories.ini, main, favorites
}
;;Windows Path to msys Path 
;; for example d:\a\b\ to /d/a/b
anything_favorite_directories_win2msysPath(winPath){
   msysPath:= RegExReplace(winPath, "^([a-zA-Z]):"  ,"$1" )
   StringReplace, msysPath2, msysPath, \ , /, All
   msysPath3 = /%msysPath2%
   return %msysPath3%
}

;;d:\a\b -->d:/a/b
anything_favorite_directories_win2posixPath(winPath)
{
   StringReplace, posixPath, winPath, \ , /, All
   Return posixPath  
}
;;f1::anything(anything_favorite_directories_source)
;; anything-favorites-directory.ahk ends here. 
