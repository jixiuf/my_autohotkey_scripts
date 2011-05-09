#NoTrayIcon
#SingleInstance force
;;;Ctrl+鼠标中键关闭窗口
;;;;EasyWindowDrag_(KDE).ahk 中定义了Alt +Alt+鼠标左中右键进行最小化关闭最大化三个操作
;; 分别是按下Alt 松开,然后再按下Alt不松开,然后点击左中右键即可
#IfWinActive
^MButton::
    SendInput {Alt Down}{F4}{Alt Up}
    Return
#IfWinActive
