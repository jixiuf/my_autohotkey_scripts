; #SingleInstance force
; #NoTrayIcon

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
#IfWinActive ahk_class Progman|WorkerW|CabinetWClass|ExploreWClass|#32770
;;Alt+1 copy文件名
!1::
  send ^c
  sleep,300
  clipboard = %clipboard%
  SplitPath, clipboard, name
  clipboard = %name%
  return
;;alt+2 copy 此文件所在的路径名
!2::
  send ^c
  sleep,300
  clipboard = %clipboard%
  SplitPath, clipboard, , dir
  clipboard = %dir%
  return
;;copy 此文件的全路径名
!3::
  send ^c
  sleep,300
  clipboard = %clipboard%
  return
#IfWinActive

#IfWinActive ahk_class ExploreWClass|CabinetWClass
^n::Send {Down}
^p::Send {Up}
^j::
  ControlGetFocus, focusedControl,A 
    if(focusedControl="SysListView321")
  {
    ControlGetText, oldExplorePath, Edit1, A
    Send {Enter}
        sleep 250
        if WinActive("ahk_class ExploreWClass") or WinActive("ahk_class CabinetWClass")
        {
          ControlGetText, newExplorePath, Edit1, A
          ControlFocus, SysListView321,A
            Send {Home}
          ;;;这两句话，是用于更新anything-explorer-history.ahk中的变量而设
          ;;add to history list
          updateHistory(newExplorePath)
        }
  }else
  {
    Send {Enter}
  }
return

^f::
  ControlGetFocus, focusedControl,A 
      Send {Right}

    if(focusedControl="SysTreeView321")
  {
    ;;;这两句话，是用于更新anything-explorer-history.ahk中的变量而设
    ;;add to history list 
    sleep 400
    updateHistory(getExplorerAddressPath())
  }
return

^b::send {Left}
^h::
   ControlGetFocus, focusedControl,A 
    if(focusedControl="SysTreeView321")
  {

    send {Left}
    ;;;这两句话，是用于更新anything-explorer-history.ahk中的变量而设
    ;;add to history list 
    sleep 400
    updateHistory(getExplorerAddressPath())
  }else
  {
    Send ^h
  }
return
 
^u::
   ControlGetFocus, focusedControl,A 
    if(focusedControl="SysListView321")
  {
    send     {backspace}
    ControlGetText, newExplorePath, Edit1, A
    ControlFocus, SysListView321,A
      Send {Home}
    ;;;这两句话，是用于更新anything-explorer-history.ahk中的变量而设
    ;;add to history list 
    sleep 400
    updateHistory(newExplorePath)
  }
return

;;Ctrl+, 选中第一个文件
^,::
   ControlFocus, SysListView321,A
    Send {Home}
return
;;Ctrl+. 选中最后一个文件
^.::
  ControlFocus, SysListView321,A
  Send {End}
  return
  
;;ctrl+; 定位到目录树
^;::
  ControlFocus, SysTreeView321,A
return

 ;;ctrl+L 定位在地址栏
^l:: ControlFocus, Edit1,A
;"+"  like Emacs dired: create new folder 
+=::Send !fwf

; create new text file
;
!n::
InputBox, UserInput, New File Name?, Please enter a New File Name(.txt), , 280, 100,,,,,
if ErrorLevel
{
}else
{
  Send {Left}
ControlGetText, ExplorePath, Edit1, A
StringRight, isEndsWithPathSeaprator, ExplorePath, 1
if (isEndsWithPathSeaprator ="\")
{
  newFilePath=%ExplorePath%%UserInput%
}else
{
  newFilePath=%ExplorePath%\%UserInput%
}
FileAppend,, %newFilepath%
ControlFocus, SysListView321,A
; Switch the active window's keyboard layout/language to English:
PostMessage, 0x50, 0, 0x4090409,, A  ; 0x50 is WM_INPUTLANGCHANGEREQUEST.
SendInput {F5}%UserInput%  
}
return

;Ctrl-t TOGGLES FILE EXTENSIONS
!h::
RegRead, HiddenFiles_Status, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt
If HiddenFiles_Status = 1
     RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt, 0
Else
   RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt, 1
WinGetClass, eh_Class,A
If (eh_Class = "#32770" OR A_OSVersion = "WIN_VISTA")
   send, {F5}
Else PostMessage, 0x111, 28931,,, A
Return

; open 'cmd' in the current directory
;
^!c::OpenCmdInCurrent()
^!h::toggle_hide_file_in_explore()
#IfWinActive

; Opens the command shell 'cmd' in the directory browsed in Explorer.
; Note: expecting to be run when the active window is Explorer.
;
OpenCmdInCurrent()
{
 ControlGetText, full_path, Edit1, A
 IfInString full_path, \
  {
    Run, cmd /K cd /D "%full_path%"
  }
  else
  {
    Run, cmd /K cd /D "C:\ "
  }
}

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

;;需要 emacsclientw 在Path路径下
openSelectedfileWithEamcs()
{
  ControlGetFocus, focusedControl,A
  if (focusedControl="SysListView321")
  {
    ClipSaved := ClipboardAll
    Send ^c
    sleep,300
    clipboard = %clipboard%
    fullPath=%clipboard%
    Clipboard := ClipSaved   
    run , emacsclientw %fullPath%
  }
}
#IfWinActive ahk_class ExploreWClass|CabinetWClass
^e:: openSelectedfileWithEamcs()
#IfWinActive

