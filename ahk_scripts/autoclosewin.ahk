; 自动关闭某些窗口
#Persistent
SetTimer, autocloseWin, 250
return

autocloseWin:
;;qq 广靠窗口
WinClose, ahk_class TXGuiFoundation
return
