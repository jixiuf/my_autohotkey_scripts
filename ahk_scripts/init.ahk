#SingleInstance force
#NoTrayIcon
SetWorkingDir %A_ScriptDir%

run %A_ScriptDir%\EasyWindowDrag_(KDE).ahk
; run %A_ScriptDir%\DoOver.ahk
run %A_ScriptDir%\MoveInactiveWin.ahk


run %A_ScriptDir%\autoclosewin.ahk
;; run %A_ScriptDir%\iswitchw-plus.ahk


#Include %A_ScriptDir%\anything-config.ahk

#Include %A_ScriptDir%\explorer.ahk
#Include %A_ScriptDir%\cmd2msys.ahk
#Include %A_ScriptDir%\switchWindow.ahk
; #Include %A_ScriptDir%\notepad-emacs-key.ahk
#Include %A_ScriptDir%\eclipse.ahk
#Include %A_ScriptDir%\alias.ahk
#Include %A_ScriptDir%\toggleTaskBar.ahk
#Include %A_ScriptDir%\plsql.ahk
#Include %A_ScriptDir%\toadsqlserver.ahk
#Include %A_ScriptDir%\Console.ahk
; #Include %A_ScriptDir%\diaglog.ahk
#Include %A_ScriptDir%\win-move-resize.ahk
; #Include %A_ScriptDir%\ie.ahk
; #Include %A_ScriptDir%\word-emacs-key.ahk
#Include %A_ScriptDir%\googletranslate.ahk
