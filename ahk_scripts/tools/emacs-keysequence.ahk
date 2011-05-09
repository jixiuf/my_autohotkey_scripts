Input, TextEntry2, L1 T1,{Esc}{Enter}

timeout=%ErrorLevel%

entry=%TextEntry1%%TextEntry2%

if entry=cp
{
    ; Command prompt
    run cmd
}
else if entry=ca
{
    ; Calculator
    run calc
}
else if entry=ou
{
	; Outlook
	SetTitleMatchMode 2

	IfWinExist, Microsoft Outlook
	{
		WinActivate
	}
	else
	{	
		run outlook
	}

	SetTitleMatchMode 1
}
return
