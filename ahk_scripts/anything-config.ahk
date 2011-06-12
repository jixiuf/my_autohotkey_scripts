#NoTrayIcon
#SingleInstance force
SetWorkingDir %A_ScriptDir%

#include  anything-run.ahk
#include anything-explorer-history.ahk

f3::
sources:=Array()
sources.insert(anything_cmd_source)
sources.insert(anything_explorer_history_source)
anything_multiple_sources(sources)
return
