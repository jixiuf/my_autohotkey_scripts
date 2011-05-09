#SingleInstance force
#NoTrayIcon

;;;在Explorer.exe 程序中定义以下快捷键
;;Alt+1 复制 选中的文件名到剪切板
;;Alt+2 复制地址栏中路径到剪切板
;;Alt+3 复制选中文件的全路径到剪切板
;;Ctrl+Alt+n  新建一个文件夹
;;Ctrl+Alt+t 新建一个文本
;;Ctrl+Alt+c 在此处打开Cmd.exe(在另一个脚本cmd2msys.ahk中，
;;           定义了在cmd.exe窗口中按下Ctrl+Return键，转换成 msys.bat环境)
;;
;;Ctrl+l 定位到地址栏





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

;;;Ctrl+L 定位在地址栏
#IfWinActive ahk_class ExploreWClass|CabinetWClass
^l::Send {F4}{Escape}
#IfWinActive


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;在资源管理器中，在隐与不隐间切换（隐藏文件）
;;主要通过修改注册表
toggle_hide_file_in_explore(){

;------------------------------------------------------------------------
; Show hidden folders and files in Windows XP
;------------------------------------------------------------------------
; User Key: [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
; Value Name: Hidden
; Data Type: REG_DWORD (DWORD Value)
; Value Data: (1 = show hidden, 2 = do not show)
    RegRead, ShowHidden_Status, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden
    if ShowHidden_Status = 2
    RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 1
    Else
    RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 2
    WinGetClass, CabinetWClass
    PostMessage, 0x111, 28931,,, A
    Return
}
;;将Ctrl+alt+h 绑定到 toggle_hide_file_in_explore
^!h::toggle_hide_file_in_explore()
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
