;;;这个函数没用到
win2msysPath(winPath){
   msysPath:= RegExReplace(winPath, "^([a-zA-Z]):"  ,"$1" )
   StringReplace, msysPath2, msysPath, \ , /, All
   msysPath3 = /%msysPath2%
   return %msysPath3%
}


;;在cmd.exe 的窗口中Ctrl+Return ,会启用msys ,并将路径定位在相同的目录
;;前提是msys.bat 在Path 路径下，及msys的相应bin 路径也在Path下
startMsysHere(){
send, pwd >%A_Temp%\pwd `n
sleep 100
send msys `n
FileReadLine,msysPath,%A_Temp%\pwd ,1
sleep 300
send cd %msysPath% `n
send clear`n
}

;;;;;;;;;;;;;;;;;;
#IfWinActive ,ahk_class ConsoleWindowClass
^Return::startMsysHere() 
