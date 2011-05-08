;FastNavKeys.ahk
; Speeds up navigation keys (or any other keys)
;Skrommel @2007


#SingleInstance,Force
#NoEnv
SetBatchLines,-1
SetKeyDelay,-1
SendMode,Event

applicationname=FastNavKeys

Gosub,INIREAD
Gosub,TRAYMENU

StringSplit,hotkey_,keys,`,
Loop,% hotkey_0
{
  hotkey:=hotkey_%A_Index%
  Hotkey,$~%hotkey%,DOWN,On B0
  Hotkey,$~+%hotkey%,DOWN,On B0
  Hotkey,$~^%hotkey%,DOWN,On B0
  Hotkey,$~!%hotkey%,DOWN,On B0
  Hotkey,*~%hotkey% Up,UP,On B0
}
down=0
Return


DOWN:
StringTrimLeft,hotkey,A_ThisHotkey,2
StringLeft,modifier,hotkey,1
If modifier In +,^,!
  StringTrimLeft,hotkey,hotkey,1
Else
  modifier=
If down=0
{
  down=1
  counter=0
  Gosub,SEND
}
Return


UP:
down=0


SEND:
Loop
{
  counter+=1
  If counter=1
    Sleep,% delay1
  Else
  If delay2=0
    Sleep,-1
  Else
    Sleep,% delay2/(A_Index*factor+1)
  If down=0
    Break
  Send,%modifier%{%hotkey%}
}
Return 


TRAYMENU:
Menu,Tray,NoStandard 
Menu,Tray,DeleteAll
Menu,Tray,Add,%applicationname%,ABOUT
Menu,Tray,Add,
Menu,Tray,Default,%applicationname%
Menu,Tray,Add,&Settings...,SETTINGS 
Menu,Tray,Add,&About...,About 
Menu,Tray,Add,E&xit,EXIT
Menu,Tray,Tip,%applicationname% 
Return 


SETTINGS:
Gui,Destroy
Gui,Margin,20

Gui,Add,GroupBox,xm-10 y+10 w420 h120,&Speed
Gui,Add,Edit,xm yp+20 w100 vvdelay1
Gui,Add,UpDown, Range0-999,%delay1%
Gui,Add,Text,x+10 yp+5,Delay before autorepeating (ms)

Gui,Add,Edit,xm y+10 w100 vvdelay2
Gui,Add,UpDown,Range0-999,%delay2%
Gui,Add,Text,x+10 yp+5,Delay between repetitions (ms)

Gui,Add,Edit,xm y+10 w100 vvfactor,%factor%
Gui,Add,Text,x+10 yp+5,How fast to increase repetiton speed 
Gui,Add,Text,xp y+5,(Range: 0.0-999.9    0.0=No increase)

Gui,Add,GroupBox,xm-10 y+20 w420 h130,&Keys
Gui,Add,Edit,xm yp+20 w400 h80 vvkeys,%keys%
Gui,Add,Text,xm y+10,Default: PgUp,PgDn,Left,Right,Up,Down

Gui,Add,Button,xm y+30 w75 gSETTINGSOK Default,&OK
Gui,Add,Button,x+5 yp w75 gSETTINGSCANCEL,&Cancel

Gui,Show,w440,%applicationname% Settings
Return

SETTINGSOK:
Gui,Submit
If vkeys<>
  keys:=vkeys
delay1:=vdelay1
delay2:=vdelay2
factor:=vfactor
Gosub,INIWRITE
Gosub,SETTINGSCANCEL
Return

SETTINGSCANCEL:
Gui,Destroy
Return

GuiClose:
Gosub,SETTINGSCANCEL
Return

EXIT:
ExitApp


INIREAD:
IfNotExist,%applicationname%.ini 
{
  delay1=90
  delay2=0
  factor=0.0
  keys=Left,Right,Up,Down
  Gosub,INIWRITE
  Gosub,ABOUT
}
IniRead,delay1,%applicationname%.ini,Settings,delay1
IniRead,delay2,%applicationname%.ini,Settings,delay2
IniRead,factor,%applicationname%.ini,Settings,factor
IniRead,keys,%applicationname%.ini,Settings,keys

If (delay1="Error" or delay1="")
  delay1=90
If (delay2="Error" or delay2="")
  delay2=0
If (factor="Error" or factor="")
  factor=0.0
If (keys="Error" or keys="")
  keys=Left,Right,Up,Down
Gosub,INIWRITE
Return


INIWRITE:
IniWrite,%delay1%,%applicationname%.ini,Settings,delay1
IniWrite,%delay2%,%applicationname%.ini,Settings,delay2
IniWrite,%factor%,%applicationname%.ini,Settings,factor
IniWrite,%keys%,%applicationname%.ini,Settings,keys
Return


ABOUT:
Gui,99:Destroy
Gui,99:Margin,20,20
Gui,99:Add,Picture,xm Icon1,%applicationname%.exe
Gui,99:Font,Bold
Gui,99:Add,Text,x+10 yp+10,%applicationname% v1.0
Gui,99:Font
Gui,99:Add,Text,y+10,Speed up the navigation keys (or any other keys).
Gui,99:Add,Text,y+10,- To change the settings, choose Settings in the tray menu.
Gui,99:Add,Text,y+10,- Warning! It will make all other computers seem slow!

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
  If ctrl in Static9,Static13,Static17
    DllCall("SetCursor","UInt",hCurs)
  Return
}
Return

