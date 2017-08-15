; -*-coding:utf-8 -*-
#SingleInstance force
#NoTrayIcon
;Author: Autohotkey forum user RHCP
;http://www.autohotkey.com/board/topic/103174-dual-function-control-key/

; $~*LWin::
; if !state
;     state :=  (GetKeyState("Shift", "P") ||  GetKeyState("Alt", "P") || GetKeyState("LCtrl", "P") || GetKeyState("RCtrl", "P"))
; return

$~LWin up::
if (StrLen(A_PriorKey)==0 || instr(A_PriorKey, "LWin") ){
    send {space} 
}
; state := 0
return

