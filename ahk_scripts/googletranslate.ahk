#SingleInstance force
;; need COM.AHK
#w::
    c := get_selection()
    display :=c
    display:= display . "`n======================English===================================`n" . google_2(c, "en-US")
    display:= display . "`n======================Japanese===================================`n" . google_2(c ,"ja")
    display:= display . "`n======================Chinese===================================`n" . google_2(c , "zh-CN")
    ToolTip(display ,50,rxpos,rypos)
return

;;http post method
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

;; google_2(text "en")
;; google_2(text "zh-CN")
;; google_2(text "ja")

google_2(text, dest_language)
{
  html:=_post("http://translate.google.com/translate_a/t","client=t&hl=" . dest_language .  "&sl=auto&tl="  . dest_language . "&multires=1&otf=2&ssel=0&tsel=4&uptl=" . dest_language .  "&alttl=zh-CN&sc=1&text=" . text ,"http://translate.google.com",1)
  StringReplace,html,html,[[[`",,All
  StringReplace,html,html,]]`,,,All
  RegExMatch(html,"^(.*?)" ,html)
  StringReplace,html,html,[[[`",,All
  StringReplace,html,html,`",,All
  html := RegExReplace(html,",.*?$" ,"")
  return html
}

get_selection()
{
tmp:=ClipboardAll
Clipboard=
  WinGet, active_id, ID, A
  WinGetClass, activeWinClass ,ahk_id %active_id%
  if (activeWinClass="Emacs"){
    Send !w
  } else if (activeWinClass="MozillaWindowClass"){
    Send !w
  }
  else
  {
  Send,^c
  }
ClipWait,3
IfEqual,ErrorLevel,1,Return
c:=Clipboard
Clipboard:=tmp
return c
}



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

; http://translate.google.com/translate_a/t
; http://translate.google.com/translate_a/t?client=t&text=hell&hl=zh-CN&sl=auto&tl=ja&multires=1&otf=2&ssel=0&tsel=4&uptl=ja&alttl=zh-CN&sc=1
