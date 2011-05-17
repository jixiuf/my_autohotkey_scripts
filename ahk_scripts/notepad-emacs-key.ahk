#NoTrayIcon
#SingleInstance force
SetKeyDelay 0


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


