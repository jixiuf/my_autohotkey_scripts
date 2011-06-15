  
Gui, Add, GroupBox, x6 y4 w230 h10 , 已安装的输入法(双击切换)
Gui, Add, ListView, r20 x6 y24 w230 h120 vListIME gSetIME ,N|键盘布局|名称
Gui, Add, Button, x6 y150 w80 h30 gPreIME, 上一输入法
Gui, Add, Button, x156 y150 w80 h30 gNextIME, 下一输入法
Gui, Add, Button, x86 y150 w70 h30 gStateIME, 当前状态
; Generated using SmartGUI Creator 4.0
Gui, Show, x397 y213 h190 w247,输入法切换
Gosub,ReadIME
Return
GuiClose:
ExitApp


ReadIME:
LV_ModifyCol(3,300)

HKLnum:=DllCall("GetKeyboardLayoutList","uint",0,"uint",0)
VarSetCapacity( HKLlist, HKLnum*4, 0 )
DllCall("GetKeyboardLayoutList","uint",HKLnum,"uint",&HKLlist)
loop,%HKLnum%
{ 
SetFormat, integer, hex
HKL:=NumGet( HKLlist,(A_Index-1)*4 ) 
StringTrimLeft,Layout,HKL,2
Layout:= Layout=8040804 ? "00000804" : Layout
Layout:= Layout=4090409 ? "00000409" : Layout

RegRead,IMEName,HKEY_LOCAL_MACHINE,SYSTEM\CurrentControlSet\Control\Keyboard Layouts\%Layout%,Layout Text
SetFormat, integer, D

LV_Add("Vis",A_Index,Layout,IMEName)
} 

Return


~Space::
StateIME:

Num:=GetIME(layout,name)
SetFormat, integer, D
Num:=Num
ToolTip 当前输入法为第[%Num%]输入法`n键盘布局：%layout%`n输入法名称：%name%
Sleep 4000
ToolTip

return


SetIME:
If (A_GuiEvent<>"DoubleClick")
{
Return
}
Gui,Submit,Nohide
LV_GetText(Layout,A_EventInfo,2)
;~ MsgBox %Layout%
SwitchIME(Layout)
Return




RCtrl Up::
NextIME:
SeekIME(1)
Return

LCtrl Up::
PreIME:
SeekIME(-1)
Return

;=========== Function SeekIME
; 
; PN : 1 NextIME ; -1 PrevIME
; 
SeekIME(PN) 
{ 
HKL:=DllCall("GetKeyboardLayout", "uint",GetThread(), "uint")
HKLnum:=DllCall("GetKeyboardLayoutList","uint",0,"uint",0)
VarSetCapacity( HKLlist, HKLnum*4, 0 )
DllCall("GetKeyboardLayoutList","uint",HKLnum,"uint",&HKLlist)
loop,%HKLnum%
{ 
if( NumGet( HKLlist, (A_Index-1)*4 ) = HKL )
{
Index:= A_Index+PN
Index:= Index=0 ? HKLnum : Index
Index:= Index=HKLnum+1 ? 1 : Index
;~ ToolTip %Index%
HKL:=NumGet( HKLlist,(Index-1)*4 ) 
break
}
} 
ControlGetFocus,ctl,A
SendMessage,0x50,0,HKL,%ctl%,A
}

;=========== Function GetIME
; 
; ByRef LayOut : the number of keyboardlayout
; ByRef ImeName : the name of current IME
; Return the serial number of IME list
;
GetIME(ByRef out_LayOut,ByRef out_ImeName)
{
SetFormat, integer, hex
HKL:=DllCall("GetKeyboardLayout","int",GetThread(),UInt) 
HKLnum:=DllCall("GetKeyboardLayoutList","uint",0,"uint",0)
VarSetCapacity( HKLlist, HKLnum*4, 0 )
DllCall("GetKeyboardLayoutList","uint",HKLnum,"uint",&HKLlist)
loop,%HKLnum%
{ 
if( NumGet( HKLlist, (A_Index-1)*4 ) = HKL )
{
SerialNum:=A_Index
}
} 

StringTrimLeft,Layout,HKL,2

Layout:= HKL=0x8040804 ? "00000804" : Layout
Layout:= HKL=0x4090409 ? "00000409" : Layout 

;~ ToolTip %Layout% %HKL%


RegRead,IMEName,HKEY_LOCAL_MACHINE,SYSTEM\CurrentControlSet\Control\Keyboard Layouts\%Layout%,Layout Text 
;~ ToolTip %IMEName%

out_ImeName:=IMEName
out_LayOut:=Layout
Return SerialNum
}

;=========== Function SwitchIME
; 
; dwLayout : the number of keyboardlayout
;
SwitchIME(dwLayout)
{
HKL:=DllCall("LoadKeyboardLayout", Str, dwLayout, UInt, 1)
ControlGetFocus,ctl,A
SendMessage,0x50,0,HKL,%ctl%,A
}

;=========== Function SwitchIME
; 
; Return the first threadID of the current window
;
GetThread()
{
ResultID:=0
hWnd:=WinExist("A")
VarSetCapacity( thE, 28, 0 )
NumPut( 28, thE )
WinGet,processID,pid,ahk_id %hWnd%
hProcessSnap := DllCall("CreateToolhelp32Snapshot","uint",4, "uint",processID)
If (DllCall("Thread32First","uint",hProcessSnap, "uint",&thE )=0)
{
Return 0
}

Loop
{
If (NumGet(thE,12) = processID)
{
DllCall("CloseHandle","uint",hProcessSnap)
ResultID:=NumGet(thE,8)
Return ResultID
}
NumPut( 28, thE )
if( DllCall("Thread32Next","uint",hProcessSnap, "uint",&thE )=0)
{ 
DllCall("CloseHandle","uint",hProcessSnap)
Return 0
}
} 
}
