;;;;;;;;alt+tab
WheelDown::AltTab
WheelUp::ShiftAltTab
F1::Send {Alt down}{tab} ; 
!F1::Send {Alt up}
~*Escape::
IfWinExist ahk_class #32771
    Send {Escape}{Alt up}  ; Cancel the menu without activating the selected window.
return
;;;;;;;;;;;;;;


