; by sfufoet
; v 0.3
; 修复 win7 bug，by 蜃
#NoTrayIcon
#SingleInstance force

GroupAdd, WinGroup, ahk_class Progman
GroupAdd, WinGroup, ahk_class WorkerW
GroupAdd, WinGroup2, ahk_class ExploreWClass
GroupAdd, WinGroup2, ahk_class CabinetWClass

; 当 Everything 窗口处于非激活状态，自动关闭它。by 峄峰 http://yefoenix.ws/
#Persistent
	SetTimer,ClsEvthn,30000
return

ClsEvthn:
	IfWinExist,ahk_class EVERYTHING
	{
		IfWinNotActive,ahk_class EVERYTHING
		{
			IfWinNotActive, Everything 选项
				WinClose,ahk_class EVERYTHING
			Return
		}
		else
		return
	}
	else
return
; 代码结束

#s::
send #^+!P
return

 #IfWinActive ahk_group WinGroup
; ; 双击 Ctrl 运行 Everything
; ;   * 第一次按下 LCtrl，用 KeyWait 读取键盘输入，如果 0.5 秒内不是按 LCtrl 则结束
; ;   * 如果 0.5 秒内按了 LCtrl，则再读第二个按键，若为 LCtrl 则发送快捷键，
; ;   * 若第二个按键不为 LCtrl 则结束
; ~LCtrl::
; Keywait, LCtrl, , t0.5
; if errorlevel = 1
; return
; else
; Keywait, LCtrl, d, t0.1
; if errorlevel = 0
; {
; 	FilePath=%A_Desktop%
; 	send #^+!P
; 	WinWaitActive, Everything
; 	sleep 150
; 	ControlSetText, Edit1, "%FilePath%"%A_space%, A
; 	sleep 150
; 	send {end}
; }
; return
; ; 代码结束

^s::
	FilePath=%A_Desktop%
	send #^+!P
	WinWaitActive, Everything
	sleep 150
	ControlSetText, Edit1, "%FilePath%"%A_space%, A
	sleep 150
	send {end}
return

#IfWinActive ahk_group WinGroup2
; 双击 Ctrl 运行 Everything
;   * 第一次按下 LCtrl，用 KeyWait 读取键盘输入，如果 0.5 秒内不是按 LCtrl 则结束
;   * 如果 0.5 秒内按了 LCtrl，则再读第二个按键，若为 LCtrl 则发送快捷键，
;   * 若第二个按键不为 LCtrl 则结束
; ~LCtrl::
; Keywait, LCtrl, , t0.5
; if errorlevel = 1
; return
; else
; Keywait, LCtrl, d, t0.1
; if errorlevel = 0
; {
; 	ControlGetText, FilePath, ToolbarWindow322, A
; 	stringreplace, FilePath, FilePath, 地址:%A_space%, , All
; 	if FilePath =
; 		ControlGetText, FilePath, Edit1, A
; 	; msgbox, %FilePath%
; 	if FilePath=桌面
; 		FilePath=%A_Desktop%
; 	if FilePath=库\文档
; 		FilePath=%A_MyDocuments%
; 	if FilePath in 网上邻居,控制面板,回收站,计算机, 控制面板\所有控制面板项
; 		return
; 	send #^+!P
; 	WinWaitActive, Everything
; 	sleep 150
; 	ControlSetText, Edit1, "%FilePath%"%A_space%, A
; 	sleep 150
; 	send {end}
; }
; return
; ; 代码结束

^s::
	ControlGetText, FilePath, ToolbarWindow322, A
	stringreplace, FilePath, FilePath, 地址:%A_space%, , All
	if FilePath = 
		ControlGetText, FilePath, Edit1, A
	; msgbox, %FilePath%
	if FilePath=桌面
		FilePath=%A_Desktop%
	if FilePath=库\文档
		FilePath=%A_MyDocuments%
	if FilePath in 网上邻居,控制面板,回收站,计算机, 控制面板\所有控制面板项
		return
	send #^+!P
	WinWaitActive, Everything
	sleep 150
	ControlSetText, Edit1, "%FilePath%"%A_space%, A
	sleep 150
	send {end}
return
