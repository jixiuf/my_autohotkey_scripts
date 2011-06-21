#NoTrayIcon
#SingleInstance force
SetWorkingDir %A_ScriptDir%

#include anything.ahk
#include anything-run.ahk
#include anything-favorite-directories.ahk
#include anything-window-switch.ahk
#include anything-explorer-history.ahk

f3::
sources:=Array()
sources.insert(anything_explorer_history_source)
sources.insert(anything_favorite_directories_source)
sources.insert(anything_cmd_source)
sources.insert(anything_window_switcher_source)
anything_multiple_sources(sources)
return

#r::
sources:=Array()
sources.insert(anything_cmd_source)
sources.insert(anything_explorer_history_source)
sources.insert(anything_favorite_directories_source)
sources.insert(anything_window_switcher_source)
anything_multiple_sources(sources)
return

;;
!Tab::
^Tab:: 
sources:=Array()
sources.insert(anything_window_switcher_source)
sources.insert(anything_cmd_source)
sources.insert(anything_explorer_history_source)
sources.insert(anything_favorite_directories_source)
anything_multiple_sources(sources)
return

