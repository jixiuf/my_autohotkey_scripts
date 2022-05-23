; -*-coding:utf-8 -*-
#SingleInstance force
#NoTrayIcon
;Author: Autohotkey forum user RHCP
;http://www.autohotkey.com/board/topic/103174-dual-function-control-key/
; https://stackoverflow.com/questions/53067999/autohotkey-remap-win-key-when-pressed-alone
; 此脚本实现 单独按下 lwin 相当于发送  space，lwin与其他键组合用时，其依然是 lwin，如 lwin+e 打开iexplorer
;    与bin/keyboard_switch_win_space_alt_caps_ctrl.reg  配合后 （space变成了 lwin）
;也就是说  space单按还是 space，space+e则打开 iexplorer，space+r 则打开“运行”窗口 
 

 
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
