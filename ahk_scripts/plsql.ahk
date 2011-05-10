#SingleInstance force
#NoTrayIcon
^n::SendInput {Down}
^p::SendInput {Up}
LAlt & `::ShiftAltTab


;;作用：在plsql中将F7影射为执行光标所在行的语句
SetBatchLines -1 ;速度最大化
#NoEnv  ; 
SendMode Input  
SetWorkingDir %A_ScriptDir%
#ifwinactive ahk_class TPLSQLDevForm
f7::
sleep,10
send,{esc}{end}+{home}{f8}
return


 
