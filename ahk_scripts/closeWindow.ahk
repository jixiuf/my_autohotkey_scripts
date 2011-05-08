#NoTrayIcon
;;;Ctrl+鼠标中键关闭窗口        
#IfWinActive  
^MButton::
    SendInput {Alt Down}{F4}{Alt Up}
    Return
#IfWinActive  
