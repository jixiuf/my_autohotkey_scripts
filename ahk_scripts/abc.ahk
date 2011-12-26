#NoTrayIcon
#SingleInstance force
SetWorkingDir %A_ScriptDir%

#include anything.ahk
#include anything-run.ahk
#r::
sources:=Array()
sources.insert(anything_run_source)
anything_multiple_sources(sources)
return
