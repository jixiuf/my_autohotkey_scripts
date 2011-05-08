;DoOver.ahk
; Record and playback keyboard and mouse actions.
; Press Ctrl-F12 to start and stop recording.
; Press Ctrl-F5 to playback.
;Skrommel @2005    www.donationcoders.com/skrommel


#SingleInstance,Force
SetBatchLines,-1
AutoTrim,Off
CoordMode,Mouse,Relative

applicationname=DoOver

modifiers=LCTRL,RCTRL,LALT,RALT,LSHIFT,RSHIFT,LWIN,RWIN,LButton,RButton,MButton,XButton1,XButton2
recording=0
playing=0
Gosub,READINI
Gosub,TRAYMENU
SetTimer,CURRENTWIN,500
Return


CURRENTWIN:
WinGet,currentid,ID,A
WinGetClass,class,ahk_id %currentid%
If currentid=
  currentid=%oldcurrentid%
If class=Shell_TrayWnd
  currentid=%oldcurrentid%
If currentid=AutoHotkey
  currentid=%oldcurrentid%
oldcurrentid=%currentid%
Return


MACROREC:
If recording=0
{
  GetKeyState,state,LShift,P
  If state=d
  Loop
  {
    GetKeyState,state,LShift,P
    If state=U
      Break
  }
  GetKeyState,state,LCtrl,P
  If state=d
  Loop
  {
    GetKeyState,state,LCtrl,P
    If state=U
      Break
  }
  GetKeyState,state,LAlt,P
  If state=d
  Loop
  {
    GetKeyState,state,LAlt,P
    If state=U
      Break
  }
  GetKeyState,state,LWin,P
  If state=d
  Loop
  {
    GetKeyState,state,LWin,P
    If state=U
      Break
  }
  recording=1
  ToolTip,Recording... 
  Gosub,RECORD
  ToolTip,Recording finished
  IniWrite,%keys%,DoOver.ini,Settings,macro
  Loop
  {
    GetKeyState,state,LCtrl,P
    If state=U
      Break
  }
  Sleep,1000
  ToolTip,
  recording=0
}
Else
  recording=0

Return


MACROPLAY:
If playing=0
{
  GetKeyState,state,LShift,P
  If state=d
  Loop
  {
    GetKeyState,state,LShift,P
    If state=U
      Break
  }
  GetKeyState,state,LCtrl,P
  If state=d
  Loop
  {
    GetKeyState,state,LCtrl,P
    If state=U
      Break
  }
  GetKeyState,state,LAlt,P
  If state=d
  Loop
  {
    GetKeyState,state,LAlt,P
    If state=U
      Break
  }
  GetKeyState,state,LWin,P
  If state=d
  Loop
  {
    GetKeyState,state,LWin,P
    If state=U
      Break
  }
  playing=1
  ToolTip,Playback...
  IniRead,macro,DoOver.ini,Settings,macro
  If movemouseafter=1
  {
    CoordMode,Mouse,Screen
    MouseGetPos,origx,origy
    CoordMode,Mouse,Relative
  }
  Gosub,PLAYBACK
  If movemouseafter=1
  {
    CoordMode,Mouse,Screen
    MouseMove,%origx%,%origy%,0
    CoordMode,Mouse,Relative
  }
  ToolTip,
  playing=0
}
Return


PLAYBACK:
id=
Loop
{
  GetKeyState,state,Esc,P
  If state=d
    Break
  StringGetPos,pos1,macro,{MouseClick
  StringGetPos,pos2,macro,{Window
  If pos1=-1
  If pos2=-1
  {
    Send,%macro%
    Break
  }
  If pos2>-1
  If pos2<%pos1%
    Goto,WINDOW

  MOUSE:
  StringGetPos,pos1,macro,{MouseClick
  If pos1=-1
    Goto,WINDOW
  StringGetPos,pos2,macro,},,%pos1%
  StringLeft,playback,macro,%pos1%
  StringTrimLeft,macro,macro,%pos1%
  pos2-=%pos1%
  StringLeft,mouse,macro,%pos2%
  pos2+=1
  StringTrimLeft,macro,macro,%pos2%
  Send,%playback%
  StringSplit,mouse_,mouse,`,
  MouseClick,%mouse_2%,%mouse_3%,%mouse_4%,%mouse_5%,%mouse_6%,%mouse_7%
  Continue

  WINDOW:
  StringGetPos,pos1,macro,{Window
  If pos1=-1
    Continue
  StringGetPos,pos2,macro,},,%pos1%
  StringLeft,playback,macro,%pos1%
  StringTrimLeft,macro,macro,%pos1%
  pos2-=%pos1%
  StringLeft,title,macro,%pos2%
  pos2+=1
  StringTrimLeft,macro,macro,%pos2%
  Send,%playback%
  StringSplit,title_,title,`,
  WinWait,%title_2%,,2
  WinActivate,%title_2%
  WinWaitActive,%title_2%,,2
;  WinWaitNotActive,ahk_id %id%,,2
;  WinGet,id,ID,A
}
Return


RECORD:
SetTimer,MODIFIERS,50
oldid=
keys=
Loop
{
  Input,key,M B C V I L1 T1,{BackSpace}{Space}{WheelDown}{WheelUp}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{F13}{F14}{F15}{F16}{F17}{F18}{F19}{F20}{F21}{F22}{F23}{F24}{ENTER}{ESCAPE}{TAB}{DELETE}{INSERT}{UP}{DOWN}{LEFT}{RIGHT}{HOME}{END}{PGUP}{PGDN}{CapsLock}{ScrollLock}{NumLock}{APPSKEY}{SLEEP}{Numpad0}{Numpad0}{Numpad1}{Numpad2}{Numpad3}{Numpad4}{Numpad5}{Numpad6}{Numpad7}{Numpad8}{Numpad9}{NumpadDot}{NumpadEnter}{NumpadMult}{NumpadDiv}{NumpadAdd}{NumpadSub}{NumpadDel}{NumpadIns}{NumpadClear}{NumpadUp}{NumpadDown}{NumpadLeft}{NumpadRight}{NumpadHome}{NumpadEnd}{NumpadPgUp}{NumpadPgDn}{BROWSER_BACK}{BROWSER_FORWARD}{BROWSER_REFRESH}{BROWSER_STOP}{BROWSER_SEARCH}{BROWSER_FAVORITES}{BROWSER_HOME}{VOLUME_MUTE}{VOLUME_DOWN}{VOLUME_UP}{MEDIA_NEXT}{MEDIA_PREV}{MEDIA_STOP}{MEDIA_PLAY_PAUSE}{LAUNCH_MAIL}{LAUNCH_MEDIA}{LAUNCH_APP1}{LAUNCH_APP2}{PRINTSCREEN}{CTRLBREAK}{PAUSE}
  endkey=%ErrorLevel%
  WinGet,id,ID,A
  If id<>%oldid%
  {
    WinGetTitle,title,ahk_id %id%
    If title<>
    If title<>Program Manager
      keys=%keys%{Window,%title%}
    oldid=%id%
  }
  IfInString,endkey,EndKey:
  {
    StringTrimLeft,key,endkey,7
    key={%key%}
  }
  keys=%keys%%key%
  StringReplace,endrecord,record,},%A_Space%Down}
  IfInString,keys,%endrecord%
  {
    StringLen,length,endrecord
    StringTrimRight,keys,keys,%length%
    recording=0
  }
  If recording=0
  {
    SetTimer,MODIFIERS,Off
    Break
  }
}
Return


MODIFIERS:
Loop,Parse,modifiers,`,
{
  GetKeyState,state,%A_LoopField%,P
  If (state="d" And state%A_Index%="")
  {
    state%A_Index%=d
    IfInString,A_LoopField,Button
    {
      StringReplace,button,A_LoopField,Button,
      WinGet,id,ID,A
      If id<>%oldid%
      {
        WinGetTitle,title,ahk_id %id%
        If title<>
          keys=%keys%{Window,%title%}
        oldid=%id%
      }
      WinGet,idd,ID,A
      MouseGetPos,xd,yd
      CoordMode,Mouse,Screen
      MouseGetPos,sdx,sdy
      CoordMode,Mouse,Relative
      keys=%keys%{MouseClick,%button%,%xd%,%yd%,1,0,D}
    }
    Else
      keys=%keys%{%A_LoopField% Down}
  }
  GetKeyState,state,%A_LoopField%,P
  If (state="u" And state%A_Index%="d") 
  {
    IfInString,A_LoopField,Button
    {
      StringReplace,button,A_LoopField,Button,
      WinGet,idu,ID,A
      MouseGetPos,xu,yu
      CoordMode,Mouse,Screen
      MouseGetPos,sux,suy
      CoordMode,Mouse,Relative
      If(idd<>idu)
      {
        xd:=xd+sux-sdx
        yd:=yd+suy-sdy
        keys=%keys%{MouseClick,%button%,%xd%,%yd%,1,0,U}
      }
      Else
        keys=%keys%{MouseClick,%button%,%xu%,%yu%,1,0,U}
    }
    Else
      keys=%keys%{%A_LoopField% Up}
    state%A_Index%=
  }
}
If keys={LShift Up}
  keys=
If keys={LCtrl Up}
  keys=
If keys={LAlt Up}
  keys=
If keys={LWin Up}
  keys=
StringRight,tooltip,keys,100
ToolTip,%tooltip%
Return


TRAYMENU:
Menu,Tray,NoStandard 
Menu,Tray,DeleteAll 
Menu,Tray,Add,DoOver,TRAYPLAYBACK
Menu,Tray,Add,
Menu,Tray,Add,&Playback,TRAYPLAYBACK
Menu,Tray,Add,&Record,TRAYRECORD
Menu,Tray,Add,
Menu,Tray,Add,&Settings...,SETTINGS
Menu,Tray,Add,R&eload settings,RELOAD
Menu,Tray,Add,
Menu,Tray,Add,&About...,ABOUT
Menu,Tray,Add,E&xit,EXIT
Menu,Tray,Default,DoOVer
Return


TRAYPLAYBACK:
WinActivate,ahk_id %currentid%
WinWaitActive,ahk_id %currentid%,,2
Gosub,MACROPLAY
Return


TRAYRECORD:
WinActivate,ahk_id %currentid%
WinWaitActive,ahk_id %currentid%,,2
Gosub,MACROREC
Return


SETTINGS:
Gosub,READINI
Run,DoOver.ini
Return


RELOAD:
Reload


READINI:
IfNotExist,DoOver.ini
{
ini=;DoOver.ini
ini=%ini%`n;[Settings]
ini=%ini%`n;record={LCtrl}{F12}   `;hotkey to start and stop recording  {LShift}{LCtrl}{LAlt}{LWin}{F1}...123...ABC...
ini=%ini%`n;playback={LCtrl}{F5}  `;hotkey to start playback
ini=%ini%`n;keydelay=10           `;ms to wait after sending a keypress
ini=%ini%`n;windelay=100          `;ms to wait after activating a window
ini=%ini%`n;movemouseafter=1      `;move the mouse to original pos after playback  1=yes 0=no
ini=%ini%`n
ini=%ini%`n[Settings]
ini=%ini%`nrecord={LCtrl}{F12}
ini=%ini%`nplayback={LCtrl}{F5}
ini=%ini%`nkeydelay=10
ini=%ini%`nwindelay=100
ini=%ini%`nmovemouseafter=1
ini=%ini%`nmacro=
FileAppend,%ini%,DoOver.ini
ini=
}
IniRead,record,DoOver.ini,Settings,record
hkrecord=%record%
StringReplace,hkrecord,hkrecord,{LCtrl},^
StringReplace,hkrecord,hkrecord,{RCtrl},^
StringReplace,hkrecord,hkrecord,{LShift},+
StringReplace,hkrecord,hkrecord,{RShift},+
StringReplace,hkrecord,hkrecord,{LAlt},!
StringReplace,hkrecord,hkrecord,{RAlt},!
StringReplace,hkrecord,hkrecord,{LWin},#
StringReplace,hkrecord,hkrecord,{RWin},#
StringReplace,hkrecord,hkrecord,{,
StringReplace,hkrecord,hkrecord,},
Hotkey,%hkrecord%,MACROREC
IniRead,playback,DoOver.ini,Settings,playback
hkplayback=%playback%
StringReplace,hkplayback,hkplayback,{LCtrl},^
StringReplace,hkplayback,hkplayback,{RCtrl},^
StringReplace,hkplayback,hkplayback,{LShift},+
StringReplace,hkplayback,hkplayback,{RShift},+
StringReplace,hkplayback,hkplayback,{LAlt},!
StringReplace,hkplayback,hkplayback,{RAlt},!
StringReplace,hkplayback,hkplayback,{LWin},#
StringReplace,hkplayback,hkplayback,{RWin},#
StringReplace,hkplayback,hkplayback,{,
StringReplace,hkplayback,hkplayback,},
IniRead,keydelay,DoOver.ini,Settings,keydelay
IniRead,windelay,DoOver.ini,Settings,windelay
Hotkey,%hkplayback%,MACROPLAY
SetKeyDelay,%keydelay%
SetWinDelay,%windelay%
IniRead,movemouseafter,DoOver.ini,Settings,movemouseafter
Return


ABOUT:
Gui,99:Destroy
Gui,99:Margin,20,20
Gui,99:Add,Picture,xm Icon1,%applicationname%.exe
Gui,99:Font,Bold
Gui,99:Add,Text,x+10 yp+10,%applicationname% v1.0
Gui,99:Font
Gui,99:Add,Text,y+10,Record and playback keyboard and mouse actions.
Gui,99:Add,Text,y+10,- Press %record% to start and stop recording.
Gui,99:Add,Text,y+10,- Press %playback% to playback.
Gui,99:Add,Text,y+10,- To edit the last macro or change hotkeys or other settings
Gui,99:Add,Text,y+5 ,like playback speed, choose Settings in the tray menu.
Gui,99:Add,Text,y+10,- Remember to save the settings and restart using Reload.

Gui,99:Add,Picture,xm y+20 Icon5,%applicationname%.exe
Gui,99:Font,Bold
Gui,99:Add,Text,x+10 yp+10,1 Hour Software by Skrommel
Gui,99:Font
Gui,99:Add,Text,y+10,For more tools, information and donations, please visit 
Gui,99:Font,CBlue Underline
Gui,99:Add,Text,y+5 G1HOURSOFTWARE,www.1HourSoftware.com
Gui,99:Font

Gui,99:Add,Picture,xm y+20 Icon7,%applicationname%.exe
Gui,99:Font,Bold
Gui,99:Add,Text,x+10 yp+10,DonationCoder
Gui,99:Font
Gui,99:Add,Text,y+10,Please support the contributors at
Gui,99:Font,CBlue Underline
Gui,99:Add,Text,y+5 GDONATIONCODER,www.DonationCoder.com
Gui,99:Font

Gui,99:Add,Picture,xm y+20 Icon6,%applicationname%.exe
Gui,99:Font,Bold
Gui,99:Add,Text,x+10 yp+10,AutoHotkey
Gui,99:Font
Gui,99:Add,Text,y+10,This tool was made using the powerful
Gui,99:Font,CBlue Underline
Gui,99:Add,Text,y+5 GAUTOHOTKEY,www.AutoHotkey.com
Gui,99:Font

Gui,99:Show,,%applicationname% About
hCurs:=DllCall("LoadCursor","UInt",NULL,"Int",32649,"UInt") ;IDC_HAND
OnMessage(0x200,"WM_MOUSEMOVE") 
Return

1HOURSOFTWARE:
  Run,http://www.1hoursoftware.com,,UseErrorLevel
Return

DONATIONCODER:
  Run,http://www.donationcoder.com,,UseErrorLevel
Return

AUTOHOTKEY:
  Run,http://www.autohotkey.com,,UseErrorLevel
Return

99GuiClose:
  Gui,99:Destroy
  OnMessage(0x200,"")
  DllCall("DestroyCursor","Uint",hCur)
Return

WM_MOUSEMOVE(wParam,lParam)
{
  Global hCurs
  MouseGetPos,,,,ctrl
  If ctrl in Static12,Static16,Static20
    DllCall("SetCursor","UInt",hCurs)
  Return
}
Return


EXIT:
ExitApp
