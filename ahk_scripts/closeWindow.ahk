#IfWinActive  ;Close active window when mouse button 5 is pressed
 ^MButton::
    SendInput {Alt Down}{F4}{Alt Up}
    Return
#IfWinActive  