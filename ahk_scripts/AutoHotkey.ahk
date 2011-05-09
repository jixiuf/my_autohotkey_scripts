;;我习惯于Win+Esc 关闭窗口,而不是Alt+F4
SetKeyDelay 0
#Esc::Send !{F4}
^n::SendInput {Down}
^p::SendInput {Up}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;注意下面会出现很多分号，表示注释
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

;;设置窗口的匹配模式
;;One of the following digits or the word RegEx:
;;1: A window's title must start with the specified WinTitle to be a match.
;;2: A window's title can contain WinTitle anywhere inside it to be a match.
;;3: A window's title must exactly match WinTitle to be a match.
SetTitleMatchMode 2
DetectHiddenWindows, On
DetectHiddenText, On
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Eclipse 中Ctrl+PageUP Ctrl+pagedown在打开的编辑器中切换
;;但是它硬编辑到代码中了,没法进行配置,这里将Ctrl+alt+n 按下时等效于Ctrl+pageDown
#IfWinActive ahk_class SWT_Window0
^!n::Send ^{PgDn}
#IfWinActive ahk_class SWT_Window0
^!p::Send ^{PgUp}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;在Eclipse 中使用Emacs键绑定时C-n C-p为光标移动到下(上)一行.
;;而此处Alt+n 相当于按下5次C-n
;;     Alt+p 相当于按下5次C-p
#IfWinActive ahk_class SWT_Window0
!n::Send {Down}{Down}{Down}{Down}
#IfWinActive ahk_class SWT_Window0
!p::Send {Up}{Up}{Up}{Up}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


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




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;对notapad进行简单增强(模拟Emacs的键绑定)
;;你可能会发现Emacs很多按键并不那么好按,那是因为Ctrl位于键盘的角落,
;;最简单的解法办法就是将Ctrl键与CapsLK 键进行交换，网上有很多并于如何通过修改注册表交换这
;;两个键的办法
;;Ctrl+q         跳到行首(默认Emacs是Ctrl+a 跳到行首,但是我将CapsLK键与Ctrl键交换后，
;;Ctrl(原来的大小写切换键)与a距离太近，不太好按，所以我将Ctrl+q 也绑定为跳转到行首)
;;Ctrl+a         跳到行首
;;Ctrl+e         跳到行末
;;Ctrl+n         下一行
;;Ctrl+p         上一行


;;Ctrl+bacespace 删除一个单词
;;Alt+bacespace 删除一个单词
;;Alt+f        前进一个单词
;;Ctrl+m        复制并粘贴当前行
;;Ctrl+d        删除一个字符
;;Ctrl+h        向后删除一个字符
;;Ctrl+f        向前移动光标
;;Ctrl+b        向后移动光标
;;Alt+s          search

;;Ctrl+w         剪切
;;Alt +w         复制
;;Ctrl+y         粘贴
;;Ctrl+i         选中当前单词
;;Ctrl+u        删除光标到行首的内容(bash 里的绑定)
;;Ctrl+k        删除光标到行末的内容,k 是kill的缩写,在Emacs 中cut 不叫cut ，叫kill
;;Ctrl+/         undo
;;Ctrl+j          回车(一般的操作是Ctrl+e,Ctrl+j) 在下一行添加窄
;;Ctrl+o          在上面添加一个空行，并将光标移动到空行上(一般是Ctrl+a ,跳转到行首，然后Ctrl+o)


#IfWinActive ahk_class Notepad
^BS::Send ^+{Left}{Del}
!BS::Send ^+{Left}{Del}
^u::Send +{Home}^c{Del}
^k::Send +{End}^c{Del}
!d::Send ^+{Right}^c{Del}
^q::send {Home}
^a::send {Home}
^e::send  {end}
^m::Send {Home}+{End}^c{End}{Enter}^v ; Duplicate the current line, like R#
^i::Send ^{Left}^+{Right}       ; Select the current word
!w::Send ^c
^w::Send ^x
^y::Send ^v
^d::Send {Del}
^/::Send ^z
^j::Send {Enter}
^o::Send {Enter}{Up}

^p::send {Up}
^n::send {Down}
^f::Send {Right}
!f::Send ^{Right}
^b::Send {Left}
!b::Send ^{Left}
+!<::Send ^{Home}
+!>::Send ^{End}
!<::Send ^{Home}
!>::Send ^{End}

!s::Send ^f
^h::Send {BackSpace}
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


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

 
 
