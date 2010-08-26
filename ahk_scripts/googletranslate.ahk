#c::

tmp:=ClipboardAll
Clipboard=
Send,^c
ClipWait,3
IfEqual,ErrorLevel,1,Return
c:=Clipboard
Clipboard:=tmp
Gosub,tr
c=
Results=
html=
Return


tr:
If GetKeyState("CapsLock","t")=1
Gosub,Yahoo
Else
Gosub,google
ToolTip(Results,50,rxpos,rypos)
return



Google:
html:=_post("http://translate.google.com/translate_t","hl=zh-CN&ie=UTF8&sl=auto&tl=zh-CN&text=" c,"http://translate.google.com",1)
nel=(?<=dir="ltr">).+?(?=</div></td></tr><tr><td class=submitcell>)
RegExMatch(html,nel,Results)
StringReplace,Results,Results,<br>,,All
Return


Yahoo:
html:=_post("http://fanyi.cn.yahoo.com/translate_txt","lp=en_zh&trtext=" c)
nel=(?<=<div id="pd" class="pd">).+?(?=</div>)
RegExMatch(html,nel,Results)
StringReplace,Results,Results,<br/>,`n`r,All
Return



ToolTip(Text,time,ByRef rxpos,ByRef rypos){
  ToolTip % Text
  MOUSEGETPOS,rxpos,rypos
  SetTimer,rtipS,%time%
}

rtipS:
MOUSEGETPOS,rxpos2,rypos2
if (rxpos<>rxpos2 or rypos<>rypos2)
{
ToolTip
SetTimer,rtipS,Off
}
Return



_post(url,Send,Referer="",UserAgent=""){
        COM_Init()
        WebRequest := COM_CreateObject("WinHttp.WinHttpRequest.5.1")
        COM_Invoke(WebRequest, "Open", "POST", url, "False")
        COM_Invoke(WebRequest, "setRequestHeader", "Content-Type", "application/x-www-form-urlencoded")
    If Referer<>
        COM_Invoke(WebRequest, "setRequestHeader","Referer", Referer)
        If UserAgent
        COM_Invoke(WebRequest, "setRequestHeader","User-Agent", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)")
        COM_Invoke(WebRequest, "Send", Send)
        ResponseText := COM_Invoke(WebRequest, "ResponseText")
        COM_Release(WebRequest)
        COM_Term()
        Return ResponseText
}
