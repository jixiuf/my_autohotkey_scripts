SetTitleMatchMode Regex ;可以使用正则表达式对标题进行匹配
list=
#IfWinActive ahk_class ExploreWClass|CabinetWClass
~LButton::
MouseGetPos,,,,control
if  control=SysListView321
{
  address := getExplorerAddressPath()
  SetTimer, addressChangeTimer, 400

;  selection := FC("explorer","","selection")
;    if (selection.len()=1)
;    {
;      ToolTip % selection[1]
; ;;     MsgBox % getExplorerAddressPath()
;      address := getExplorerAddressPath()
;      SetTimer, addressChangeTimer, 1000
     
;    }
}
if  control=SysTreeView321
{
  address := getExplorerAddressPath()
    SetTimer, addressChangeTimer, 200
}
 
return

addressChangeTimer:
  SetTimer, addressChangeTimer ,off
  if WinActive(  "ahk_class ExploreWClass|CabinetWClass")
  {
     newAddr:= getExplorerAddressPath()
     if (address <> newAddr)
      {
        list= %list%`n%newAddr%
        ToolTip ,%list%
        ;;add to history list 
      }
}

return 
  

getExplorerAddressPath()
{
  WinGetText, full_path, A  ; 取到地址栏里的路径
  StringSplit, word_array, full_path, `n     ;;因为取到的路径中有换行符，需要却掉它
  full_path = %word_array1%   ; Take the first element from the array
  StringReplace, full_path, full_path, `r, , all   ; 以防万一将尝试却掉回车符returns (`r)
  return full_path
}
  
