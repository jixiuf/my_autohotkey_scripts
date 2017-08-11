; -*-coding:utf-8 -*-
; This is a complete solution to map the CapsLock key to Control and Escape without losing the ability to toggle CapsLock
; We use two tools here - any remapping software to map CapsLock to LControl and AutoHotkey to execute the following script
; This has been tested with MapKeyboard (by Inchwest)

; This will allow you to
;  * Use CapsLock as Escape if it's the only key that is pressed and released within 300ms (this can be changed below)
;  * Use CapsLock as LControl when used in conjunction with some other key or if it's held longer than 300ms
;  * Toggle CapsLock by pressing LControl/CapsLock + RControl

~*LControl::
if !State {
  State := (GetKeyState("Alt", "P") || GetKeyState("Shift", "P") || GetKeyState("LWin", "P") || GetKeyState("RWin", "P"))
  ; For some reason, this code block gets called repeatedly when LControl is kept pressed.
  ; Hence, we need a guard around StartTime to ensure that it doesn't keep getting reset.
  ; Upon startup, StartTime does not exist thus this if-condition is also satisfied when StartTime doesn't exist.
  if (StartTime = "") {
    StartTime := A_TickCount
  }
}
return

$~LControl Up::
elapsedTime := A_TickCount - StartTime
if (  !State
   && (A_PriorKey = "LControl")
   && (elapsedTime <= 300)) {
  Send {Esc}
}
State     := 0
; We can reset StartTime to 0. However, setting it to an empty string allows it to be used right after first run
StartTime := ""
return

; Toggle CapsLock if both LControl+RControl are pressed
~LControl & RControl::Send {CapsLock Down}