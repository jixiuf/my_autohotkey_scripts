;;; anything-explorer-history.ahk record and visit explorer.exe history using anything.ahk           
#include anything.ahk
SetTitleMatchMode Regex ;可以使用正则表达式对标题进行匹配
active_id=
directory_history:=Array()
IfExist, anything-explorer-history.ini
{
IniRead, history_line, anything-explorer-history.ini, main, history
Loop, Parse,  history_line,,
   {
     if A_LoopField <>
     {
       directory_history.insert(A_LoopField)
     }
   }
}
f3::
  WinGet, active_id, ID, A
   source:=Object()
   source["candidate"]:= directory_history
   source["action"] :="visit_directory"
   anything(source)
return

#IfWinActive ahk_class ExploreWClass|CabinetWClass
~LButton::
MouseGetPos,,,,control
  address := getExplorerAddressPath()
  SetTimer, addressChangeTimer, 400
return
#IfWinActive 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
addressChangeTimer:
  SetTimer, addressChangeTimer ,off
  if WinActive(  "ahk_class ExploreWClass|CabinetWClass")
  {
     newAddr:= getExplorerAddressPath()
     if (address <> newAddr)
      {
        ;;add to history list 
        for key ,directory in directory_history
        {
          if (directory = newAddr)
          {
            directory_history.remove(key)
            Break
          }
        }
        directory_history.insert(1,newAddr)
        if (directory_history.maxIndex()>50)
        {
          directory_history.remove(51)
        }
        goSub,saveHistory2File
      }
}
return
saveHistory2File:
directory_text=
for key ,directory in directory_history
{
directory_text=%directory_text%%directory%
}
IniWrite,%directory_text%,anything-explorer-history.ini, main, history
return 
  

getExplorerAddressPath()
{
  WinGetText, full_path, A  ; 取到地址栏里的路径
  StringSplit, word_array, full_path, `n     ;;因为取到的路径中有换行符，需要却掉它
  full_path = %word_array1%   ; Take the first element from the array
  StringReplace, full_path, full_path, `r, , all   ; 以防万一将尝试却掉回车符returns (`r)
  return full_path
}
  

visit_directory( candidate_directory)
{
  global active_id
  WinGetClass, activeWinClass ,ahk_id %active_id%
  if (activeWinClass ="ExploreWClass" or activeWinClass= "CabinetWClass")
{
		ControlSetText, Edit1, %candidate_directory%, ahk_id %active_id%
		; Tekl reported the following: "If I want to change to Folder L:\folder
		; then the addressbar shows http://www.L:\folder.com. To solve this,
		; I added a {right} before {Enter}":
		ControlSend, Edit1, {Right}{Enter}, ahk_id %active_id%
		return
  }else if (activeWinClass="ConsoleWindowClass"){
  	WinActivate, ahk_id %active_id% 
	SetKeyDelay, 0 
	SendInput, cd /d %candidate_directory%{Enter}
   }else{
     Run explorer.exe   "%candidate_directory%"
   }
}


