; 自动关闭某些窗口
#Persistent
#NoTrayIcon
#SingleInstance force
SetWorkingDir %A_ScriptDir%

SetTimer, autocloseWin, 250
return

autocloseWin:
;;qq 广靠窗口
;;WinClose, ahk_class TXGuiFoundation
return
