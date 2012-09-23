; -*- coding:utf-8  -*-
; 自动关闭某些窗口
#Persistent
#NoTrayIcon
#SingleInstance force
SetWorkingDir %A_ScriptDir%


SetTimer, autocloseWin, 250
SetTimer, autocloseWin3Min, 3000
return

autocloseWin:
;;qq 广告窗口
; WinClose, 提示
WinClose, 腾讯网 - 我的资讯
WinClose, 安全沟通 - 为您提供全面的QQ安全保护
WinClose, 请购买 WinRAR 许可
WinClose, 迅雷新闻
WinClose, 资讯快播
WinClose,  腾讯网迷你版
WinClose,  PPS迷你首页
WinClose,  PPS为你推荐
WinClose,  公告 1/1
WinClose,  公告 1/2
WinClose,  公告 2/2
WinClose,  公告 1/3
WinClose,  公告 2/3
WinClose,  公告 3/3
WinClose,  公告 1/4
WinClose,  公告 2/4
WinClose,  公告 3/4
WinClose,  公告 4/4
WinClose,  公告 5/5
WinClose,  风行
WinClose,  悠视资讯
WinClose,  UUSee资讯
return

autocloseWin3Min:
 WinClose,  腾讯网新闻
return
