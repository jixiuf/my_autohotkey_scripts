;MouseActivate.ahk
; Automatically activates a window or a control when the mouse hovers over it.
;Skrommel @2005

#SingleInstance,Force
CoordMode,Mouse,Screen
SetBatchLines,-1
SetWinDelay,0

applicationname=MouseActivate

SysGet,dblx,36     ;SM_CXDOUBLECLK
SysGet,dbly,37     ;SM_CYDOUBLECLK

Gosub,READINI
Gosub,TRAYMENU
If startdisabled=1
  Gosub,TOGGLE

oldwinid=
oldcontrolid=
oldtitle=
disable=0
counter=0
Loop
{
  oldmx=%mx%
  oldmy=%my%
  counter+=1 
  If disableonmouseaction=1
  {  
    disable=0
    KeyWait,LButton,D T0.05
    If ErrorLevel=0
      disable=1
    KeyWait,RButton,D T0.05
    If ErrorLevel=0
      disable=1
  }
  Else
    Sleep,100
  WinGetTitle,title,ahk_id %winid%
  WinGetClass,class,ahk_id %winid%
  WinGetPos,wx,wy,ww,wh,ahk_id %winid%
  MouseGetPos,mx,my,winid,controlid
  If (mx<oldmx-dblx or mx>oldmx+dblx or my<oldmy-dbly or my>oldmy+dbly)
    counter=0

  If counter=%clickdelay% 
  If autoclick=1
  If disable=0
    MouseClick,left 

  If counter=%activatedelay%
  {
    If topleftshowdesktop=1
    If mx=0
    If my=0
    If minimized=0
    {
      minimized=1
      WinMinimizeAll
      Continue
    }
    Else
    {
      minimized=0
      WinMinimizeAllUndo
      Continue
    }

    If topedgetobottom=1
    If my=0
    {
      WinSet,Bottom,,A
      WinGet,allwinids,List,,,Program Manager
      StringTrimRight,allwinids1,allwinids1,0
      WinActivate,ahk_id %allwinids2%
      Continue
    }

    If leftedgefrombottom=1
    If mx=0
    {
      WinGet,allwinids,List,,,Program Manager
      bottomid:=allwinids%allwinids%
      StringTrimRight,bottomid,bottomid,0
      WinActivate,ahk_id %bottomid%
      Continue
    }

    If autoactivate=1
    {
      If title<>
      {
        If winid<>%oldwinid%
        {
          WinActivate,ahk_id %winid%
          oldwinid=%winid%
          oldtitle=%title%
        }

        If activatecontrols<>0
        If controlid<>
        If controlid<>%oldcontrolid%
        {
          ControlFocus,%controlid%,ahk_id %winid%
          oldcontrolid=%controlid%
        }
      }

      If (controlid="SysTabControl321" Or (controlid="ToolbarWindow322" And class="Shell_TrayWnd"))
      {
        WinGetPos,x,y,w,h,ahk_id %winid% ;ControlGetPos,x,y,w,h,%controlid%,ahk_id %winid%
        x:=mx-x
        y:=my-y
        ControlClick,X%x% Y%y%,ahk_id %winid%,,L,1
;        If disableonmouseaction=1
          counter=9999
        oldtab=%tab%
        oldcontrolid=%controlid%
        oldwinid=%winid%
        Continue
      }
    }
  }
}

READINI:
IfNotExist,%applicationname%.ini
{
ini=`;%applicationname%.ini
ini=%ini%`n`;
ini=%ini%`n`;[Settings]
ini=%ini%`n`;autoactivate=1         `;0,1  0=No 1=yes  Enable or disable autoactivation
ini=%ini%`n`;activatedelay=200      `;     Time in ms the mouse must stand still before activating a window
ini=%ini%`n`;startdisabled=0        `;0,1  0=No 1=yes  Starts %applicationname% disabled
ini=%ini%`n`;activatecontrols=1     `;0,1  0=No 1=yes  Also activates controls inside a window
ini=%ini%`n`;leftedgefrombottom=1   `;0,1  0=No 1=yes  Mouse on left screenedge brings bottommost window to the top
ini=%ini%`n`;topedgetobottom=1      `;0,1  0=No 1=yes  Mouse on top screenedge sends active windows to the bottom
ini=%ini%`n`;topleftshowdesktop=1   `;0,1  0=No 1=yes  Mouse on topleft of screen minimizes all windows
ini=%ini%`n`;autoclick=0            `;0,1  0=No 1=yes  Enable or disable autoclicking
ini=%ini%`n`;clickdelay=1000        `;     Time in ms the mouse must stand still before clicking
ini=%ini%`n`;disableonmouseaction=0 `;0,1  0=No 1=yes  Disable autoclicking when user clicks or drags   
ini=%ini%`n
ini=%ini%`n[Settings]
ini=%ini%`nautoactivate=1
ini=%ini%`nactivatedelay=200
ini=%ini%`nstartdisabled=0
ini=%ini%`nactivatecontrols=1
ini=%ini%`nleftedgefrombottom=1
ini=%ini%`ntopedgetobottom=1
ini=%ini%`ntopleftshowdesktop=1
ini=%ini%`nautoclick=0
ini=%ini%`nclickdelay=1000
ini=%ini%`ndisableonmouseaction=0
FileAppend,%ini%,%applicationname%.ini
}
IniRead,autoactivate,%applicationname%.ini,Settings,autoactivate
IniRead,activatedelay,%applicationname%.ini,Settings,activatedelay
IniRead,startdisabled,%applicationname%.ini,Settings,startdisabled
IniRead,activatecontrols,%applicationname%.ini,Settings,activatecontrols
IniRead,leftedgefrombottom,%applicationname%.ini,Settings,leftedgefrombottom
IniRead,topedgetobottom,%applicationname%.ini,Settings,topedgetobottom
IniRead,topleftshowdesktop,%applicationname%.ini,Settings,topleftshowdesktop
IniRead,autoclick,%applicationname%.ini,Settings,autoclick
IniRead,clickdelay,%applicationname%.ini,Settings,clickdelay
IniRead,disableonmouseaction,%applicationname%.ini,Settings,disableonmouseaction
activatedelay/=100
clickdelay/=100
Return

TRAYMENU:
Menu,Tray,NoStandard
Menu,Tray,DeleteAll
Menu,Tray,Add,%applicationname%,TOGGLE
Menu,Tray,Add,
Menu,Tray,Add,&Enabled,TOGGLE
Menu,Tray,Add,
Menu,Tray,Add,&Settings...,SETTINGS
Menu,Tray,Add,&About...,ABOUT
Menu,Tray,Add,E&xit,EXIT
Menu,Tray,Check,&Enabled
Menu,Tray,Default,%applicationname%
Menu,Tray,Tip,%applicationname%
Return

TOGGLE:
Menu,Tray,ToggleCheck,&Enabled
Pause,Toggle
Return

SETTINGS:
Gosub,READINI
Run,%applicationname%.ini
Return

ABOUT:
Gui,99:Destroy
Gui,99:Margin,20,20
Gui,99:Add,Picture,xm Icon1,%applicationname%.exe
Gui,99:Font,Bold
Gui,99:Add,Text,x+10 yp+10,%applicationname% v1.0
Gui,99:Font
Gui,99:Add,Text,y+10,Automatically activates a window or a control when the mouse hovers over it
Gui,99:Add,Text,y+5 ,or clicks the left button if the mouse is left in the same place for 1 second.
Gui,99:Add,Text,y+5,- Move the mouse to the upper left corner of the screen to show or hide the desktop.
Gui,99:Add,Text,y+5,- Move the mouse to the top egde of the screen to send the active window to the back.
Gui,99:Add,Text,y+5,- Move the mouse to the left egde of the screen to bring the bottommost window to the top.
Gui,99:Add,Text,y+5,- To change the settings, choose the Settings menu in the Tray.

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