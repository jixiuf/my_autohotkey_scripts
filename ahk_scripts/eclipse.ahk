#NoTrayIcon
#SingleInstance force
SetKeyDelay 0
#IfWinActive ahk_class #32770
^n::SendInput {Down}
#IfWinActive ahk_class #32770
^p::SendInput {Up}

;;Eclipse 中Ctrl+PageUP Ctrl+pagedown在打开的编辑器中切换
;;但是它硬编辑到代码中了,没法进行配置,这里将Ctrl+alt+n 按下时等效于Ctrl+pageDown
#IfWinActive ahk_class SWT_Window0
^!n::Send ^{PgDn}
#IfWinActive ahk_class SWT_Window0
^!p::Send ^{PgUp}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;而此处Alt+n 相当于按下5次{Down
;;     Alt+p 相当于按下5次Up
#IfWinActive ahk_class SWT_Window0
!n::Send {Down}{Down}{Down}{Down}
#IfWinActive ahk_class SWT_Window0
!p::Send {Up}{Up}{Up}{Up}



