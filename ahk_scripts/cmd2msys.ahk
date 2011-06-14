; #NoTrayIcon
; #SingleInstance force
; SetWorkingDir %A_ScriptDir%

;;在cmd.exe 的窗口中Ctrl+Return ,会启用msys ,并将路径定位在相同的目录
;;前提是msys.bat 在Path 路径下，及msys的相应bin 路径也在Path下
startMsysHere(){
send, pwd >%A_Temp%\pwd `n
sleep 150
send msys `n
FileReadLine,msysPath,%A_Temp%\pwd ,1
sleep 300
send cd %msysPath% `n
send clear`n
}

;;;;;;;;;;;;;;;;;;
#IfWinActive ,ahk_class ConsoleWindowClass
^Return::startMsysHere()
#IfWinActive
