; -*-coding:utf-8 -*-
#SingleInstance force
#NoTrayIcon
;Author: Autohotkey forum user RHCP
;http://www.autohotkey.com/board/topic/103174-dual-function-control-key/
; https://stackoverflow.com/questions/53067999/autohotkey-remap-win-key-when-pressed-alone

 

 
~LWin::__Disable_LWin()
            __Disable_LWin() {
                Send, {Blind}{vkFF}
                if (TickCount_When_LWinPressedDown = 0) {
                    TickCount_When_LWinPressedDown := A_TickCount
                }
            }
LWin Up::__Enable_LWin_ForShortPress()
            __Enable_LWin_ForShortPress() { 
                if (A_PriorKey == "LWin") {
                    if (A_TickCount - TickCount_When_LWinPressedDown < 800) {
                       ; Send, {Blind}{LWin} ; 禁用单按下lwin 弹窗 ，即什么也不做
	        send {space}  ； 单按下 lwin 发送 space，
                    }
                }
                TickCount_When_LWinPressedDown := 0
            }
