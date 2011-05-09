#NoTrayIcon
#SingleInstance force
SetKeyDelay 0

;; "^" 表示Cntrl键  "!" 表示Alt, "+" 表示Shift键
;;这部分是缩写 在任何地方,你输入ie 然后回车或空格或者TAB都会被替换为iexplore

::ie::iexplore
::ftpje::explorer ftp://jyszwsr:zhao2170____@jixiuf.dasfree.com
::ftpj::ftp://jyszwsr:zhao2170____@jixiuf.dasfree.com
::liuxjs::\\172.20.68.32
::lihts::\\172.20.68.55
::wanglins::\\172.20.68.51
::wangls::\\172.20.68.51
::kanban::http://172.20.68.243:8080

;;下面是为画图添加的代码:
;;在画图程序，保存时，按下Ctrl+f 会自动保存到d:\shot目录下，并将格式选为png
;;其实任何类型的保存对话框在按下Ctrl+f时都会进行以上操作，只是没有意义而已
;;#32770表示对话框
#IfWinActive ahk_class #32770
^f::
;; The P is for PNG
clipboard =D:\image
Send !T{Down}P{Enter}!N{Home}+{End}{Del}^v!S{Del}
return



