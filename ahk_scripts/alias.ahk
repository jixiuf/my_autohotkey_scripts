; #NoTrayIcon
; #SingleInstance force
SetKeyDelay 0

;; "^" 表示Cntrl键  "!" 表示Alt, "+" 表示Shift键
::ftpje::explorer ftp://jyszwsr:zhao2170____@jixiuf.dasfree.com
::ftpj::ftp://jyszwsr:zhao2170____@jixiuf.dasfree.com
::liuxjs::\\172.20.68.32
::lihts::\\172.20.68.55   
::wanglins::\\172.20.68.51
::wangls::\\172.20.68.51
::kanban::http://172.20.68.243:8080

;;;Ctrl+鼠标中键关闭窗口
;;;;EasyWindowDrag_(KDE).ahk 中定义了Alt +Alt+鼠标左中右键进行最小化关闭最大化三个操作
;; 分别是按下Alt 松开,然后再按下Alt不松开,然后点击左中右键即可
#IfWinActive
^MButton::
    SendInput {Alt Down}{F4}{Alt Up}
    Return
#IfWinActive


;;我习惯于Win+Esc 关闭窗口,而不是Alt+F4
#Esc::Send !{F4}
