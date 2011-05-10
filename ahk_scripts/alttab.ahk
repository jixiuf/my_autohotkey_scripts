;; #NoTrayIcon
;; #SingleInstance force

;; ;;;按下F1相当于按下Alt+Tab
;; ;;;然后可以用鼠标滚轮选择程序，
;; ;;;再次按下F1完成选择
;; ;;;Escape 取消上述操作
;; ;;;;;;;;alt+tab
;; WheelDown::AltTab
;; WheelUp::ShiftAltTab
;; F1::Send {Alt down}{tab} ;
;; !F1::Send {Alt up}
;; ~*Escape::
;; IfWinExist ahk_class #32771
;;     Send {Escape}{Alt up}  ; Cancel the menu without activating the selected window.
;; return
;; ;;;;;;;;;;;;;;


