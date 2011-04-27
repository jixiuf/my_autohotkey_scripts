#SingleInstance Force
#NoTrayIcon
SetTitleMatchMode Regex ;可以使用正则表达式对标题进行匹配
; 下面的窗口类依次为：桌面、Win+D后的桌面、我的电脑、资源管理器、另存为等
#IfWinActive, ahk_class (Progman|WorkerW|CabinetWClass|ExploreWClass|#32770)
;;Alt+1 copy文件名
!1::
send ^c
sleep,200
clipboard = %clipboard%
SplitPath, clipboard, name
clipboard = %name%
return
;;alt+2 copy 此文件所在的路径名
!2::
send ^c
sleep,200
clipboard = %clipboard%
SplitPath, clipboard, , dir
clipboard = %dir%
return
;;copy 此文件的全路径名
!3::
send ^c
sleep,200
clipboard = %clipboard%
return