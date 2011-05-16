#NoTrayIcon
#SingleInstance force   
SetKeyDelay 0
;;Eclipse 中Ctrl+PageUP Ctrl+pagedown在打开的编辑器中切换
;;但是它硬编辑到代码中了,没法进行配置,这里将Ctrl+alt+n 按下时等效于Ctrl+pageDown
#IfWinActive ahk_class SWT_Window0
^!n::Send ^{PgDn}
^!p::Send ^{PgUp}
;;而此处Alt+n 相当于按下5次{Down
;;     Alt+p 相当于按下5次Up
!n::SendInput {Down 4} 
!p::SendInput {Up 4}
#IfWinActive ahk_class SWT_Window0

;;对于Ctrl+Shift+r ,open resource
;;按下空格相当于按下*
;;而输入a-z任何一个字符，先将焦点移到Edit上，然后再输入相应的字符
#IfWinActive Open Resource
space::SendInput *
a::
ControlFocus ,Edit1
SendInput a
return
b::
ControlFocus ,Edit1
SendInput b
return
c::
ControlFocus ,Edit1
SendInput c
return
d::
ControlFocus ,Edit1
SendInput d
return
e::
ControlFocus ,Edit1
SendInput e
return
f::
ControlFocus ,Edit1
SendInput f
return
g::
ControlFocus ,Edit1
SendInput g
return
h::
ControlFocus ,Edit1
SendInput h
return
i::
ControlFocus ,Edit1
SendInput i
return
j::
ControlFocus ,Edit1
SendInput j
return
k::
ControlFocus ,Edit1
SendInput k
return
l::
ControlFocus ,Edit1
SendInput l
return
m::
ControlFocus ,Edit1
SendInput m
return
n::
ControlFocus ,Edit1
SendInput n
return
o::
ControlFocus ,Edit1
SendInput o
return
p::
ControlFocus ,Edit1
SendInput p
return
q::
ControlFocus ,Edit1
SendInput q
return
r::
ControlFocus ,Edit1
SendInput r
return
s::
ControlFocus ,Edit1
SendInput s
return
t::
ControlFocus ,Edit1
SendInput t
return
u::
ControlFocus ,Edit1
SendInput u
return
v::
ControlFocus ,Edit1
SendInput v
return
w::
ControlFocus ,Edit1
SendInput w
return
x::
ControlFocus ,Edit1
SendInput x
return
y::
ControlFocus ,Edit1
SendInput y
return
z::
ControlFocus ,Edit1
SendInput z
return
1::
ControlFocus ,Edit1
SendInput 1
return
2::
ControlFocus ,Edit1
SendInput 2
return
3::
ControlFocus ,Edit1
SendInput 3
return
4::
ControlFocus ,Edit1
SendInput 4
return
5::
ControlFocus ,Edit1
SendInput 5
return
6::
ControlFocus ,Edit1
SendInput 6
return
7::
ControlFocus ,Edit1
SendInput 7
return
8::
ControlFocus ,Edit1
SendInput 8
return
9::
ControlFocus ,Edit1
SendInput 9
return
.::
ControlFocus ,Edit1
SendInput .
return
#IfWinActive 



