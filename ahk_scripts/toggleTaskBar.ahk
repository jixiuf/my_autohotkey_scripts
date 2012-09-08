;RunAndHide.ahk
; Run to hide or show the taskbar
;Skrommel @ 2008

; #NoEnv
; #SingleInstance,Force
; #NoTrayIcon
SetWinDelay,0
#z::
IfWinExist,ahk_class Shell_TrayWnd
{
  ; Send #d
  WinHide,ahk_class Shell_TrayWnd
  WinHide,Start ahk_class Button
}
Else
{
  ; Send #d
  WinShow,ahk_class Shell_TrayWnd
  WinShow,Start ahk_class Button
}
return


;;;启动后就隐藏任务栏，
;;为了更大得用桌面空间
;; 右键任务栏，取消选中"将任务栏保持在其它窗口的前端"
;;这样，在任务栏隐藏之后，这部分空间才能得以利用


AlwaysAtBottom(Child_ID)
 {
  WinGet, Desktop_ID, ID, ahk_class Progman
  Return DllCall("SetParent", "uint", Child_ID, "uint", Desktop_ID)
 }

;;WinSet:=AlwaysAtBottom(WinExist("A"))
;;让任务栏始终在下
AlwaysAtBottom(WinExist("ahk_class Shell_TrayWnd"))
