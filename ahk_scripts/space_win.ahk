; -*-coding:utf-8 -*-
; #SingleInstance force
; #NoTrayIcon

; https://gist.github.com/kshenoy/6cce6537030f088dc95c

; window键单按时为空格 ，组合按时仍然是window键
; 想实现的功能 是空格键即可以是空格 ，又可以是window键 
; SetTitleMatchMode Regex ;可以使用正则表达式对标题进行匹配
; 需要借助别的工具来先把让space具有window键的功能，这个改注册表就可以实现 ，
                  
 
~*LWin::
if !State {
  State := (GetKeyState("Alt", "P") || GetKeyState("Shift", "P") || GetKeyState("LControl", "P") || GetKeyState("RControl", "P"))
  ; For some reason, this code block gets called repeatedly when LWin is kept pressed.
  ; Hence, we need a guard around StartTime to ensure that it doesn't keep getting reset.
  ; Upon startup, StartTime does not exist thus this if-condition is also satisfied when StartTime doesn't exist.
  if (StartTime = "") {
    StartTime := A_TickCount
  }  
}
return

$~LWin Up::
elapsedTime := A_TickCount - StartTime
if (  !State
   && (A_PriorKey = "LWin")
   && (elapsedTime <= 300)) {
  Send {Space}
}
State     := 0
; We can reset StartTime to 0. However, setting it to an empty string allows it to be used right after first run
StartTime := ""
return

; ; 防止 意外 按下windows键
; ~LWin Up:: return
