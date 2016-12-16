; -*-coding:utf-8 -*-
; qq快速加群工具
; 使用方法
; 手动点击开 查找->找群->并输入关键字后
; 会出现一系列的群，
; 然后启动此脚本后，在qq加群窗口上按下ctrl-return 来触发点击页面上加群按钮
#SingleInstance,Force

SetTitleMatchMode RegEx
SetTitleMatchMode, slow

addQun(x,y)
{
    MouseClick, left, x,y
    sleep, 1000
    ; MouseClick, left, 345,345      ;
    ; sleep, 1000
    MouseClick, left, 406,340      ;
}
click3(y)
{
    addQun(266,y)
    addQun(560,y)
    addQun(854,y)
}
click6(y)
{
    click3(y)
    click3(y+170)
}
doOneLoop(n)
{
    diff :=0                    ; 每一次循环导致的像素偏差
    click6(340-diff)
    Send {Down 9}
    click6(320-diff)
    Send {Down 9}
    click6(300-diff)
    Send {Down 9}
    click6(280-diff)
    Send {Down 3}

}
doIt()
{
    Loop,10{
        doOneLoop(A_Index)
        sleep, 1000
    }
}

^Return::doIt()
