

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
; 

html:=_post("http://translate.google.com/translate_a/t","hl=zh-CN&sl=auto&tl=zh-CN&multires=1&otf=2&ssel=0&tsel=0&uptl=zh-CN&sc=1&client=t&text=hello" ,"http://translate.google.com",1)
MsgBox % html

; http://translate.google.com/translate_a/t?client=t&text=helloword&hl=zh-CN&sl=auto&tl=zh-CN&multires=1&otf=2&ssel=0&tsel=0&uptl=zh-CN&sc=1
; http://translate.google.com/translate_a/t?client=t&text=hell&hl=zh-CN&sl=auto&tl=ja&multires=1&otf=2&ssel=0&tsel=4&uptl=ja&alttl=zh-CN&sc=1
