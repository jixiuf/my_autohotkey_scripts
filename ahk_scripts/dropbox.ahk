; -*- coding:gbk-dos  -*-
 ; dropbox 在中国并没有完全解封
 ; 主要的问题，就在即时下载更新上。A机器上更新了文件，B机器上已经开着Dropbox的
 ; 却不会即时更新；放到共享文件夹里的文件，其它共享用户有时会即时下载，有时又没
 ; 有任何反应。一切只有等到下次重启Dropbox时，更新才会开始，而这个也一般只有电
 ; 脑重启时才会发生。而如果是笔记本用户，平时从不关机或者只习惯待机，可能电脑用
 ; 了很久，也完全不会及时察觉原来有文件可以更新了。
#Persistent
#NoTrayIcon
#SingleInstance force

; 60min 重启一次dropbox
SetTimer, auto_restart_dropbox, 360000
return


auto_restart_dropbox:
  Process,Close, Dropbox.exe
  Run, %A_AppData%\Dropbox\bin\Dropbox.exe,,UseErrorLevel
  RefreshTray()
return

 ; 刷新右下角区域，
 RefreshTray() {
	WM_MOUSEMOVE := 0x200

	ControlGetPos, xTray,, wTray,, ToolbarWindow321, ahk_class Shell_TrayWnd
	endX := xTray + wTray
	x := 5
	y := 12

	Loop
	{
		if (x > endX)
			break
		point := (y << 16) + x
		PostMessage, %WM_MOUSEMOVE%, 0, %point%, ToolbarWindow321, ahk_class Shell_TrayWnd
		x += 18
	}
}
