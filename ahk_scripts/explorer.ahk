; #SingleInstance force
; #NoTrayIcon

;;;在Explorer.exe 程序中定义以下快捷键
;;ctrl+1 复制 选中的文件名到剪切板
;;ctrl+2 复制地址栏中路径到剪切板
;;ctrl+3 复制选中文件的全路径到剪切板
;;Ctrl+Alt+n  新建一个文件夹
;;Ctrl+Alt+t 新建一个文本
;;Ctrl+Alt+c 在此处打开Cmd.exe(在另一个脚本cmd2msys.ahk中，
;;           定义了在cmd.exe窗口中按下Ctrl+Return键，转换成 msys.bat环境)
;;
;;Ctrl+l 定位到地址栏
SetTitleMatchMode Regex ;可以使用正则表达式对标题进行匹配
; 下面的窗口类依次为：桌面、Win+D后的桌面、我的电脑、资源管理器、另存为等
#IfWinActive ahk_class Progman|WorkerW|CabinetWClass|ExploreWClass|#32770
;;ctrl+1 copy文件名
^1::
  send ^c
  sleep,300
  clipboard = %clipboard%
  SplitPath, clipboard, name
  clipboard = %name%
  return
;;ctrl+2 copy 此文件所在的路径名
^2::
  send ^c
  sleep,300
  clipboard = %clipboard%
  SplitPath, clipboard, , dir
  clipboard = %dir%
  return
;;ctrl+3 copy 此文件的全路径名
^3::
  send ^c
  sleep,300
  clipboard = %clipboard%
  return
#IfWinActive

#IfWinActive ahk_class ExploreWClass|CabinetWClass
; search
^s::Send ^f
^n::Send {Down}
^p::Send {Up}
^f::Send {Right}
^b::send {Left}
^j::ctrl_j()
^u::ctrl_u()
; win7 backspace work like xp
Backspace::back_up_dir()
;;Ctrl+, 选中第一个文件
^,::select_first_file()
;;Ctrl+. 选中最后一个文件
^.::select_last_file()

;;ctrl+; 定位到目录树
^;::focus_files()

;;ctrl+L 定位在地址栏
^l::focus_address_bar()
;"+"  like Emacs dired: create new folder
+=::Send !fwf
!^n::Send !fwf
; create new text file
;
!n::create_new_text()

;Alt-h TOGGLES FILE EXTENSIONS
!h::toggle_hide_file_ext()
^!h::toggle_hide_file_in_explore()

; open 'cmd' in the current directory
^!c::OpenCmdInCurrent()
; open with emacs
^e:: openSelectedfileWithEamcsOrEOL()
^`:: openSelectedfileWithEamcsOrEOL()
#IfWinActive

focus_address_bar(){
    if A_OSVersion in WIN_7,WIN_VISTA  ; Note: No spaces around commas.
    {
        Send {Alt Down}D{Alt Up}
    }else{
        ControlFocus, Edit1,A
    }
}
ctrl_j(){
    ComObjError(false)          ; 不报com错
    ControlGetFocus, focusedControl,A
    if A_OSVersion in WIN_7,WIN_VISTA  ; Note: No spaces around commas.
    {
        if(focusedControl="DirectUIHWND3")
        {
            h :=   WinExist("A")
            For win in ComObjCreate("Shell.Application").Windows{
                if   (win and  (win.hwnd=h))
                {
                    selectedFiles := win.Document.SelectedItems
                    ; all = win.Document.Foleer.Items
                    for file in selectedFiles{
                        win.Navigate(file.path)
                    }
                }
            }
            sleep 200
            if( WinActive("ahk_class ExploreWClass") or WinActive("ahk_class CabinetWClass"))
            {
                newExplorePath:=getExplorerAddrPath()
                ControlFocus, DirectUIHWND3,A
                Send {Home}{Down}{Up}
                ;;;这两句话，是用于更新anything-explorer-history.ahk中的变量而设
                ;;add to history list
                anything_add_directory_history(newExplorePath)
            }
        }
        else
        {
            Send {Enter}
        }
    }else
     {
         if(focusedControl="SysListView321")
         {
             h :=   WinExist("A")
             For win in ComObjCreate("Shell.Application").Windows{
                 if   (win and  (win.hwnd=h))
                 {
                     selectedFiles := win.Document.SelectedItems
                     ; all = win.Document.Foleer.Items
                     for file in selectedFiles{
                         win.Navigate(file.path)
                     }
                 }
             }
             sleep 150
             if( WinActive("ahk_class ExploreWClass") or WinActive("ahk_class CabinetWClass"))
             {
                 newExplorePath:=getExplorerAddrPath()
                 ControlFocus, SysListView321,A
                 Send {Home}
                 ;;;这两句话，是用于更新anything-explorer-history.ahk中的变量而设
                 ;;add to history list
                 anything_add_directory_history(newExplorePath)
             }
         }
         else
         {
             Send {Enter}
         }
     }
    return
}
ctrl_u(){
    ComObjError(false)          ; 不报com错
    h :=   WinExist("A")
    For win in ComObjCreate("Shell.Application").Windows
    if   (win and  (win.hwnd=h))
    {
        ; http://www.yongfa365.com/Item/Shell.Application-JiShuZiLiao.html
        ; win.Document.Folder.Items
        Path1:=win.Document.Folder.Self.path
        ; locationUrl2WinPath(win.locationUrl)
        ;
        ; Documents folder: %SystemRoot%\explorer.exe /n,::{450D8FBA-AD25-11D0-98A8-0800361B1103}
        ; Computer: %SystemRoot%\explorer.exe /E,::{20D04FE0-3AEA-1069-A2D8-08002B30309D}
        ; Recycle Bin: %SystemRoot%\explorer.exe /E,::{645FF040-5081-101B-9F08-00AA002F954E}
        ;; d:/ 是否已经在根目录了
        if(StrLen(Path1)==0){
            win.Navigate["::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"] ; 我的电脑
        }else if(StrLen(Path1)==3){
            win.Navigate["::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"]
        }else{
            SplitPath, Path1,, ParentDir
            win.Navigate[ParentDir . "\"]
            Send {Down}{UP}
            ;;;这两句话，是用于更新anything-explorer-history.ahk中的变量而设
            ;;add to history list
            anything_add_directory_history(ParentDir)
        }
    }
    Until (win.hwnd=h)
    }
back_up_dir(){
    if A_OSVersion in WIN_7,WIN_VISTA  ; Note: No spaces around commas.
    {
        ControlGet renamestatus,Visible,,Edit1,A
        ControlGetFocus focussed, A
        if(renamestatus!=1&&(focussed="DirectUIHWND3"||focussed="SysTreeView321"))
        {
            SendInput {Alt Down}{Up}{Alt Up}
        }
        else
        {
            Send {Backspace}
        }
    }else
    {
        Send {Backspace}
    }
    return
}
select_first_file(){
    if A_OSVersion in WIN_7,WIN_VISTA  ; Note: No spaces around commas.
    {
        ControlFocus, DirectUIHWND3
    }else{
        ControlFocus, SysListView321,A
    }
    Send {Home}
    return
}
select_last_file(){
    if( A_OSVersion in WIN_7,WIN_VISTA)  ; Note: No spaces around commas.
     {
         ControlFocus, DirectUIHWND3
     }else{
         ControlFocus, SysListView321,A
     }
    Send {End}
    return
}
focus_files(){                  ; 定位到右侧的目录树
    if A_OSVersion in WIN_7,WIN_VISTA  ; Note: No spaces around commas.
     {
         ControlFocus, DirectUIHWND3
     }else{
         ControlFocus, SysListView321,A
     }
    Send {Down}{UP}
    return
}
create_new_text(){
    InputBox, UserInput, New File Name?, Please enter a New File Name(.txt), , 280, 100,,,,,
    if ErrorLevel
    {
    }else
    {
        Send {Left}
        ExplorePath:=getExplorerAddrPath()
        ; ControlGetText, ExplorePath, Edit1, A
        StringRight, isEndsWithPathSeaprator, ExplorePath, 1
        if (isEndsWithPathSeaprator ="\")
        {
            newFilePath=%ExplorePath%%UserInput%
        }else
        {
            newFilePath=%ExplorePath%\%UserInput%
        }
        FileAppend,, %newFilepath%
        if A_OSVersion in WIN_7,WIN_VISTA  ; Note: No spaces around commas.
        {
            ; TODO: select created file
            ControlFocus, DirectUIHWND3,A
            SendInput {F5}%UserInput%
        }else{
            ControlFocus, SysListView321,A
            ; Switch the active window's keyboard layout/language to English:
            PostMessage, 0x50, 0, 0x4090409,, A  ; 0x50 is WM_INPUTLANGCHANGEREQUEST.
            SendInput {F5}%UserInput%
        }
    }
    return
}
toggle_hide_file_ext(){
    if A_OSVersion in WIN_7,WIN_VISTA  ; Note: No spaces around commas.
    {
        SubKey := "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        RegRead Value, HKCU, %SubKey%, HideFileExt
        ; RegWrite REG_DWORD, HKCU, %SubKey%, %ValueName%, %Value%
        if(Value){
            RegWrite REG_DWORD, HKCU, %SubKey%, HideFileExt, 0
        }else{
            RegWrite REG_DWORD, HKCU, %SubKey%, HideFileExt, 1
            }
        ; update window
        GroupAdd ExplorerWindows, ahk_class ExploreWClass|CabinetWClass|Progman
        Code := InStr("WIN_XP, WIN_2000", A_OSVERSION) ? 28931 : 41504
        WinGet WindowList, List, ahk_Group ExplorerWindows
        Loop %WindowList%
        PostMessage 0x111, %Code%, , , % "ahk_id" WindowList%A_Index%
        return
    }
    else
    {
        RegRead, HiddenFiles_Status, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt
        If HiddenFiles_Status = 1
        RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt, 0
        Else
        RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt, 1
        WinGetClass, eh_Class,A
        If (eh_Class = "#32770" OR A_OSVersion = "WIN_VISTA" or A_OSVersion = "WIN_VISTA" )
        send, {F5}
        Else PostMessage, 0x111, 28931,,, A
    }
    return
}
; Opens the command shell 'cmd' in the directory browsed in Explorer.
; Note: expecting to be run when the active window is Explorer.
;
OpenCmdInCurrent()
{
full_path:=getExplorerAddrPath()
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
    if A_OSVersion in WIN_7,WIN_VISTA  ; Note: No spaces around commas.
     {
         RegRead, ValorHidden, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden
         if ValorHidden = 2
             RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 1
         Else
             RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 2
         send {F5}
         return
       } else{                      ; xp
         RegRead, ShowHidden_Status, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden
         if ShowHidden_Status = 2
           RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 1
         Else
           RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 2
         WinGetClass, CabinetWClass
         PostMessage, 0x111, 28931,,, A
         return
    }
}

;;需要 emacsclientw 在Path路径下
; 用emacs打开选中文件，或者到行尾
openSelectedfileWithEamcsOrEOL()
{
    ComObjError(false)          ; 不报com错
    h :=   WinExist("A")
    For win in ComObjCreate("Shell.Application").Windows{
        if   (win and  (win.hwnd=h))
        {
            selectedFiles := win.Document.SelectedItems
        }
    }

    ; fullPath:=GetSelectedFileName()
    if A_OSVersion in WIN_7,WIN_VISTA  ; Note: No spaces around commas.
    {
        ControlGetFocus, focusedControl,A
        if (focusedControl="DirectUIHWND3")
        {
            for file in selectedFiles{
                FilePath:=file.path
                run , emacsclientw %FilePath%
            }
        }
        else
        {
            send {End}
        }
     }else{
        ControlGetFocus, focusedControl,A
        if (focusedControl="SysListView321")
        {
            for file in selectedFiles{
                FilePath:=file.path
               run , emacsclientw %FilePath%
            }
        }
        else
        {
            send {End}
        }
    }
}

getExplorerAddrPath()
{
    WinGetText,full_path,A
    StringSplit,word_array,full_path,`n
    full_path:= word_array1
    Pos :=InStr(full_path,":\")
    if(Pos>0)
    {
        path2:= SubStr(full_path,Pos-1,1) . SubStr(full_path,Pos)
    }
    StringReplace, path2, path2, `r, , all
    return path2
}

GetSelectedFileName()
{
   FileName =
   AlterClipboardInhalt := ClipboardAll ; sichern des Inhaltes von Clipboard
   Clipboard =
   Send ^c                              ; Kopiert die Datei
   ClipWait, 1                          ; Warte auf neuen Inhalt im Clipboard
   If (FileExist(ClipBoard))  ;
   {                                    ; Datei handelt
     FileName := ClipBoard             ; Speichern des Namens zur weiteren Verarbeitung
   }
   ClipBoard := AlterClipboardInhalt    ; Alten Inhalt des Clipboards wiederherstellen
   Return FileName
}

;;
; file:///d:/path/ -->d:\path
locationUrl2WinPath(winPath)
{
   path1:= RegExReplace(winPath, "^file:///(.*)"  ,"$1" )
   path2:= RegExReplace(path1, "%20"  ," " )
   StringReplace,path3, path2, / , \, All
    return path3
}
