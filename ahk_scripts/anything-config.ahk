#NoTrayIcon
#SingleInstance force
SetWorkingDir %A_ScriptDir%

#include anything.ahk
#include anything-run.ahk
#include anything-run-launch-plugin.ahk
#include anything-favorite-directories.ahk
#include anything-window-switch.ahk
#include anything-explorer-history.ahk

f3::
sources:=Array()
sources.insert(anything_explorer_history_source)
sources.insert(anything_favorite_directories_source)
sources.insert(anything_run_source)
anything_multiple_sources(sources)
return


#r::
my_anything_properties2:=Object()
my_anything_properties2["anything_use_large_icon"]:=1
my_anything_properties2["FontSize"]:= 15
anything_multiple_sources_with_properties(Array(anything_run_source, anything_run_launch_source),my_anything_properties2)
return


!Tab::
^Tab::                          ;  I remap CapsLock Ctrl ,Alt , so ...
my_anything_properties:=Object()
my_anything_properties["win_width"]:= 900
my_anything_properties["win_height"]:= 280
my_anything_properties["anything_use_large_icon"]:=1
my_anything_properties["FontSize"]:= 15
 
sources:=Array()
sources.insert(anything_window_switcher_with_assign_keys_source)
sources.insert(anything_window_switcher_source)
anything_multiple_sources_with_properties(sources,my_anything_properties)
return
 
