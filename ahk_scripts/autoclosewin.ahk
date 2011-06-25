; -*- coding:utf-8  -*-        
; 自动关闭某些窗口
#Persistent
#NoTrayIcon
#SingleInstance force
SetWorkingDir %A_ScriptDir%

SetTimer, autocloseWin, 250
return

autocloseWin:
;;qq 广告窗口
WinClose, 腾讯网 - 我的资讯
WinClose, 安全沟通 - 为您提供全面的QQ安全保护
return
