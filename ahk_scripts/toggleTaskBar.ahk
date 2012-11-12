;RunAndHide.ahk
; Run to hide or show the taskbar
;Skrommel @ 2008

; #NoEnv
; #SingleInstance,Force
; #NoTrayIcon
SetWinDelay,0
Gosub, AUTOHIDE
#z::
IfWinExist,ahk_class Shell_TrayWnd
{
    WinHide,ahk_class Shell_TrayWnd
    WinHide, ahk_class Button

    Gosub, AUTOHIDE
}
Else
{
    ; WinSet,Region,,ahk_id %taskbar%
  ; Send #d
    WinShow,ahk_class Shell_TrayWnd
    WinShow, ahk_class Button
    ; WinShow, ahk_class DV2ControlHost

    Gosub, Normal
}
return


;;;启动后就隐藏任务栏，
;;为了更大得用桌面空间
;; 右键任务栏，取消选中"将任务栏保持在其它窗口的前端"
;;这样，在任务栏隐藏之后，这部分空间才能得以利用
;Stolen from SKAN at http://www.autohotkey.com/forum/topic26107.html
AUTOHIDE: ;Stolen from SKAN at http://www.autohotkey.com/forum/topic26107.html
ABM_SETSTATE    := 10
ABS_NORMAL      := 0x0          ; 正常
ABS_AUTOHIDE    := 0x1          ; 自动隐藏
ABS_ALWAYSONTOP := 0x2          ; 总在最前
VarSetCapacity(APPBARDATA,36,0)
Off:=NumPut(36,APPBARDATA)
Off:=NumPut(WinExist("ahk_class Shell_TrayWnd"),Off+0)

; NumPut(ABS_AUTOHIDE|ABS_ALWAYSONTOP, Off+24)
NumPut(ABS_NORMAL, Off+24)
DllCall("Shell32.dll\SHAppBarMessage",UInt,ABM_SETSTATE,UInt,&APPBARDATA)
Return

NORMAL:
NumPut(ABS_ALWAYSONTOP,Off+24)
DllCall("Shell32.dll\SHAppBarMessage",UInt,ABM_SETSTATE,UInt,&APPBARDATA)
Return

; AlwaysAtBottom(Child_ID)
;  {
;   WinGet, Desktop_ID, ID, ahk_class Progman
;   Return DllCall("SetParent", "uint", Child_ID, "uint", Desktop_ID)
;  }

; ;;WinSet:=AlwaysAtBottom(WinExist("A"))
; ;;让任务栏始终在下
; AlwaysAtBottom(WinExist("ahk_class Shell_TrayWnd"))
