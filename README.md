# -*-coding:utf-8 -*-
# my_autohotkey_scripts
my autohotkey scripts .
rename this directory to ahk ,and put it in c:\

http://jixiuf.github.com/my_autohotkey_scripts/


http://jixiuf.github.io/blog/anything-doc.org/

* bin/keyboard_switch_win_space_alt_caps_ctrl.reg
按键映射 参见 http://jixiuf.github.io/blog/000011-windows-keymap.html/
    - space->lwindow
    - lalt->lcontrol
    - lcontrol->capslock
    - caplock->lwindow
    - ralt->space
    
(配合ahk_scripts/space_win.ahk)实现空格键即当空格又当windows键,即单独按时产生空格，组合按时当作windows键 

ahk_scripts/switchWindow.ahk 一键最大化窗口（或恢复原状）
```
#d::ToggleWinMinimizeOrRun("ahk_class VirtualConsoleClass", "C:\cmder\Cmder.exe")
;;Win+f chrome
; #f::ToggleWinMinimizeOrRun("ahk_class Chrome_WidgetWin_1|MozillaUIWindowClass|MozillaWindowClass","C:\Program Files (x86)\Google\Chrome\Application\chrome.exe","RegEx")
;;Win+f toggle Firefox
#f::ToggleWinMinimizeOrRun("ahk_class MozillaUIWindowClass|MozillaWindowClass","firefox","RegEx")
```
