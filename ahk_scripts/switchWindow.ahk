; -*-coding:utf-8 -*-
;;;; switchWindow.ahk -- switch to your favourate window
;;;;@author jixiuf@gmail.com
;;;,此脚本因为含有中文，所以在保存此文本的时候必须保存为utf-8编码，
;;; 其他如gbk的编码应该不可以(未测试)
;;
;;;;这个脚本用于快速定位到特定的窗口
;;;以Win+1键为例
;;;如果没有启动eclipse，按下Win+1键后，会启动一个eclipse,
;;;如果已经有一个启动的eclipse,则按下Win+1键会有两种情况发生
;; 如果eclipse已经获得焦点，则最小化eclipse窗口
;; 如果eclipse没有获得焦点，则最大化之，并聚焦


; #NoTrayIcon
; #SingleInstance force

ToggleWinMinimizeOrRun(TheWindowTitle,Cmd:="", TitleMatchMode := "2")
{
    SetTitleMatchMode,%TitleMatchMode%
    ; SetTitleMatchMode, RegEx
    DetectHiddenWindows, Off
     ; DetectHiddenWindows, On

    ; WinGetPos, winWidth, winHeight, , , ahk_class XLMAIN
    ;  Msgbox %  winWidth  . " "  .  winHeight
    ; 或者根据 最小化之后的窗口宽高来判断
    ; win7 winWidth=-32000, winHeight=-32000
    IfWinActive, %TheWindowTitle%
    {
    
    
        ; WinRestore,  %TheWindowTitle%
        WinMinimize, %TheWindowTitle%
        ; WinMinimizeAll
        ; WinMinimizeAllUndo
        Send {Alt down}{tab}{Escape}{Alt up}  ; Cancel the menu without activating the selected window.


        ; ; ; 有时因为焦点问题， 激活窗口无效
        ; WinGet, id, list, , , Program Manager
        ; WinActivate ,ahk_id %id1%
        ; ; WinGetTitle ,t,ahk_id %id1%
        ; ; Tooltip , %t%
        ; ; ; 有时因为焦点问题， 激活窗口无效
        ; ; ; just click something on desktop for focus
        ; ; ; The following method may improve reliability and reduce side effects:
        ; SetControlDelay -1
        ; ControlClick, SysListView321, ahk_class Progman,,,, NA x1 y1  ; Clicks in NA mode at coordinates that are relative to a named control.
    }
    Else
    {
        IfWinExist, %TheWindowTitle%
        {
            ; WinActivate,  ahk_class Progman
            ; ; 有时因为焦点问题， 激活窗口无效
            ; ; just click something on desktop for focus
            ; SetControlDelay -1
            ; ControlClick, SysListView321, ahk_class Progman,,,, NA x10 y10  ; Clicks in NA mode at coordinates that are relative to a named control.
            ;  有时激活窗口无效
            ; WinMinimizeAll
            WinGet, winid, ID, %TheWindowTitle%
            DllCall("SwitchToThisWindow", "UInt", winid, "UInt", 1)

            ; WinWaitActive,%TheWindowTitle%, , 2
            ; if ErrorLevel
            ; {
            ;     MsgBox, WinWait timed out.
            ;     return
            ; }
            Send {Alt down}{tab}{Escape}{Alt up}
            ; Send {Escape}{Alt up}  ; Cancel the menu without activating the selected window.


        }
        else
        {
            if (Cmd != ""){
              run, %Cmd%
            }
        }
    }
    Return
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;注意，eclipse命令必须在Path 环境变量中,
;;以下用到的程序，除了加了绝对路径的均须如此，
#1::ToggleWinMinimizeOrRun("ahk_class SWT_Window0","eclipse -nl en_US")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;Win+1  VS
; #1::ToggleWinMinimizeOrRun("Microsoft Visual Studio","devenv")
;VBA
; #1::ToggleWinMinimizeOrRun("ahk_class wndclass_desked_gsk","")

; bash 
#5::ToggleWinMinimizeOrRun("ahk_class mintty","C:\Git\git-bash.exe --cd-to-home","RegEx")
; #d::ToggleWinMinimizeOrRun("ahk_class PuTTY", "putty")
#d::ToggleWinMinimizeOrRun("ahk_class VirtualConsoleClass", "C:\cmder\Cmder.exe")

#b::ToggleWinMinimizeOrRun("ahk_class TXGuiFoundation","C:\Program Files (x86)\Tencent\QQ\Bin\QQ.exe","RegEx")

;;Win+f chrome
; #f::ToggleWinMinimizeOrRun("ahk_class Chrome_WidgetWin_1|MozillaUIWindowClass|MozillaWindowClass","C:\Program Files (x86)\Google\Chrome\Application\chrome.exe","RegEx")
;;Win+f toggle Firefox
#f::ToggleWinMinimizeOrRun("ahk_class MozillaUIWindowClass|MozillaWindowClass","firefox","RegEx")

;;;;;;;;;;;Win+i ,toggle IE
#i::ToggleWinMinimizeOrRun("ahk_class IEFrame",A_ProgramFiles . "\Internet Explorer\iexplore.exe")

;;;;;;;;;;Win+A ,toggle.Eamcs
#e::ToggleWinMinimizeOrRun("ahk_class Emacs","runemacs")

;;;;;;Win+q  toggle Excel
; #q::ToggleWinMinimizeOrRun("ahk_class XLMAIN", "excel")

;;;;;;Win+3 toggle word
#3::ToggleWinMinimizeOrRun("ahk_class OpusApp", "winword")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; win+4 pdf
#4::ToggleWinMinimizeOrRun("ahk_class AcrobatSDIWindow", "C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroRd32.exe")

; ;;;;;;Win+o  toggle OutLook
; #o::ToggleWinMinimizeOrRun("ahk_class rctrl_renwnd32", "outlook")
; ;;;;;;;;;;Win+g ,toggle Gtalk
; #g::ToggleWinMinimizeOrRun("ahk_class Google Talk - Google Xmpp Client GUI Window",A_ProgramFiles . "\Google\Google Talk\googletalk.exe")
; #b::ToggleWinMinimizeOrRun("ahk_class Chat View",A_ProgramFiles . "\Google\Google Talk\googletalk.exe")
; ;;;;;;;;;;Win+c ,toggle Pl/sql
; #c::ToggleWinMinimizeOrRun("ahk_class TPLSQLDevForm","C:\Prog\PLSQL\plsqldev.exe")
;;;;;;;;;;Win+c ,toggle Toad
; #c::ToggleWinMinimizeOrRun("ahk_class WindowsForms10.Window.8.app.0.33c0d9d","c:\usr\toad\toad.exe")
; #c::ToggleWinMinimizeOrRun("SQL Manager","c:\usr\mysql_manager\MyManager.exe")

;; remote desk
; #n::ToggleWinMinimizeOrRun("远程桌面连接", "mstsc")



;;;Win+e 启动资源管理器，

;;与默认的Win+e的不同之处在于,如果已经有一个启动的资源管理器，但是它并
;;没被激活的话，不必重新启动一个，只须激活之，
;;有时资源管理器，需要启动多个，所以，如果当前聚集的窗口已经是一个资源管理器了
;;我们认为用户想重新启用一个资源管理器，为方便计，把目录定位到与这个窗口相同的目录
#g::
MyFavorateDir:="c:\"
SetTitleMatchMode, RegEx
IfWinExist,ahk_class (CabinetWClass|ExploreWClass)
{
  If WinActive("ahk_class (CabinetWClass|ExploreWClass)"){
     ControlGetText, ExplorePath, Edit1, A
;;之所以不用这条命令，是因为当地址栏里为“我的电脑”四个字时，用这条命令提示找不到路径
    run, explorer.exe /n`, /e`, "%ExplorePath%" ,,
  }else{
    WinActivate ,ahk_class  (CabinetWClass|ExploreWClass)
    WinWaitActive
    ControlGetFocus, focusedControl,A
;;    Tooltip ,%focusedControl%
    if (focusedControl <> "SysListView321")
    {
     ;;选中第一个文件
      ControlFocus, SysListView321,A
      Send {Home}
    }
  }
}else{
    run, explorer.exe  /n`, /e`, %MyFavorateDir%
    WinWait ahk_class (CabinetWClass|ExploreWClass)
    WinActivate
    ;;选中第一个文件
    sleep 50
    ControlFocus, SysListView321,A
    Send {Home}
}
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; #Tab::Send {Alt down}{tab}{Alt up}


; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ; 炒股相关设置
; ;F12 toggle 招商证券软件 （只在大智慧等股票软件窗口上启用）
; SetTitleMatchMode RegEx
; ; 下面的窗口类依次为：桌面、Win+D后的桌面、我的电脑、资源管理器、另存为等
; #IfWinActive  ahk_class Afx:00400000:8:00010011:00000000:00090205|Afx:00400000:8:00010011:00000000:000B07E9
; ; 激活
; F12::
; IfWinExist , ahk_class TdxW_MainFrame_Class
; {                               ; 如果如商证券交易软件已经打开 ，直接激活窗口
;   WinActivate , ahk_class TdxW_MainFrame_Class
; }else{                          ; 使用大智慧的F12快捷键，打开委托软件
;   Send  {F12}
; }
; return

; #IfWinActive

; ; 如果当前窗口是招商证券 F12 ,则为隐藏 招商证券窗口
; #IfWinActive ahk_class TdxW_MainFrame_Class
; F12:: WinMinimize ahk_class TdxW_MainFrame_Class
; #IfWinActive
; ; 默认F12激活炒股软件
; F12::WinActivate , ahk_class Afx:00400000:8:00010011:00000000:00090205
; ; end of 炒股相关
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
