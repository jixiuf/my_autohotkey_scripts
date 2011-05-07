
;;#NoTrayIcon
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


#IfWinActive ahk_class ExploreWClass|CabinetWClass
    ; create new folder
    ;
    ^!n::Send !fwf

    ; create new text file
    ;
    ^!t::Send !fw{Up}{Up}{Up}{Return}

    ; open 'cmd' in the current directory
    ;
    ^!c::
        OpenCmdInCurrent()
    return
#IfWinActive

; Opens the command shell 'cmd' in the directory browsed in Explorer.
; Note: expecting to be run when the active window is Explorer.
;
OpenCmdInCurrent()
{
    WinGetText, full_path, A  ; This is required to get the full path of the file from the address bar

    ; Split on newline (`n)
    StringSplit, word_array, full_path, `n
    full_path = %word_array1%   ; Take the first element from the array

    ; Just in case - remove all carriage returns (`r)
    StringReplace, full_path, full_path, `r, , all  

    IfInString full_path, \
    {
        Run, cmd /K cd /D "%full_path%"
    }
    else
    {
        Run, cmd /K cd /D "C:\ "
    }
}