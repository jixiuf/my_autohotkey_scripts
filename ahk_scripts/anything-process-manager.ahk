;;; anything-process-manager.ahk -- Process Manager 

; source is hosted on
; https://github.com/jixiuf/my_autohotkey_scripts/tree/master/ahk_scripts
; and you can find the forum here
; http://www.autohotkey.com/forum/viewtopic.php?t=72833
; Documention:
; http://jixiuf.github.com/autohotkey/anything-doc.html

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;how to use `anything-process-manager.ahk'
;        #include anything.ahk
;        #include anything-process-manager.ahk
;        f2::
;        anything(anything_process_manager_source)
;        return

; 2  if you also have other anything-sources ,
;     you just need add 
;         anything_process_manager_source
;     to the sources
;    for example :
;        #include anything.ahk
;        #include anything-process-manager.ahk
;        #include anything-services.ahk
;         ^f4::
;          sources:=Array()
;          sources.Insert(anything_services_source)
;          sources.Insert(anything_process_manager_source)  ;         <--------- here.
;          anything_multiple_sources(sources)
;         return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ComVar(Type=0xC)
; {
;     static base := { __Get: "ComVarGet", __Set: "ComVarSet", __Delete: "ComVarDel" }
;     ; Create an array of 1 VARIANT.  This method allows built-in code to take
;     ; care of all conversions between VARIANT and AutoHotkey internal types.
;     arr := ComObjArray(Type, 1)
;     ; Lock the array and retrieve a pointer to the VARIANT.
;     DllCall("oleaut32\SafeArrayAccessData", "ptr", ComObjValue(arr), "ptr*", arr_data)
;     ; Store the array and an object which can be used to pass the VARIANT ByRef.
;     return { ref: ComObjParameter(0x4000|Type, arr_data), _: arr, base: base }
; }

; ComVarGet(cv, p*) { ; Called when script accesses an unknown field.
;     if p.MaxIndex() = "" ; No name/parameters, i.e. cv[]
;         return cv._[0]
; }

; ComVarSet(cv, v, p*) { ; Called when script sets an unknown field.
;     if p.MaxIndex() = "" ; No name/parameters, i.e. cv[]:=v
;         return cv._[0] := v
; }

; ComVarDel(cv) { ; Called when the object is being freed.
;     ; This must be done to allow the internal array to be freed.
;     DllCall("oleaut32\SafeArrayUnaccessData", "ptr", ComObjValue(cv._))
; }
; ; the the owner of a process
; anything_process_get_owner(process)
; {
;     UserName := ComVar(),	UserDomain:= ComVar()
;     process.GetOwner(UserName.ref, UserDomain.ref)
;     return UserName[]
; }



;=============================================================================================================
;http://www.autohotkey.com/forum/topic48621.html ; 
; Func: GetProcessMemory_Private
; Get the number of private bytes used by a specified process.  Result is in K by default, but can also be in
; bytes or MB.
;
; Params:
;   pid    - ProcessId of Process 
;   Units       - Optional Unit of Measure B | K | M.  Defaults to K (Kilobytes)
;
; Returns:
;   Private bytes used by the process
;-------------------------------------------------------------------------------------------------------------
GetProcessMemory_Private(pid, Units="K") {
    ; get process handle
    hProcess := DllCall( "OpenProcess", UInt, 0x10|0x400, Int, false, UInt, pid )

    ; get memory info
    PROCESS_MEMORY_COUNTERS_EX := VarSetCapacity(memCounters, 44, 0)
    DllCall( "psapi.dll\GetProcessMemoryInfo", UInt, hProcess, UInt, &memCounters, UInt, PROCESS_MEMORY_COUNTERS_EX )
    DllCall( "CloseHandle", UInt, hProcess )

    SetFormat, Float, 0.0 ; round up K

    PrivateBytes := NumGet(memCounters, 40, "UInt")
    if (Units == "B")
        return PrivateBytes
    if (Units == "K")
        Return PrivateBytes / 1024
    if (Units == "M")
        Return PrivateBytes / 1024 / 1024
}

GetProcessMemory_Private_As_String(pid,Units="K")
{
    mem := GetProcessMemory_Private(pid,Units)
    return  mem . Units
}

; GetProcessTimes( PID=0, IndexValue=1 )   
; {
;    global
;    hProc := DllCall("OpenProcess", "Uint", 0x400, "int", 0, "Uint", pid)
;    DllCall("GetProcessTimes", "Uint", hProc, "int64P", CreationTime, "int64P", ExitTime, "int64P", newKrnlTime, "int64P", newUserTime)
;    DllCall("CloseHandle", "Uint", hProc)
;    PROCESSCPUUSAGE :=  (newKrnlTime - oldKrnlTime%IndexValue% + newUserTime - oldUserTime%IndexValue%)/10000000 * 100
;    oldKrnlTime%IndexValue% := newKrnlTime
;    oldUserTime%IndexValue% := newUserTime
;    Return PROCESSCPUUSAGE
; } 

; GetProcessTimes(pid)    ; Individual CPU Load of the process with pid
; {
;    Static oldKrnlTime, oldUserTime
;    Static newKrnlTime, newUserTime

;    oldKrnlTime := newKrnlTime
;    oldUserTime := newUserTime

;    hProc := DllCall("OpenProcess", "Uint", 0x400, "int", 0, "Uint", pid)
;    DllCall("GetProcessTimes", "Uint", hProc, "int64P", CreationTime, "int64P", ExitTime, "int64P", newKrnlTime, "int64P", newUserTime)
;    DllCall("CloseHandle", "Uint", hProc)
;    Return (newKrnlTime-oldKrnlTime + newUserTime-oldUserTime)/10000000 * 100   ; 1sec: 10**7
; }

anything_process_candidates()
{
    global anything_properties
    global anything_process_icons
    candidates:= Object()
    anything_process_icons:=IL_Create(15,5,anything_properties["anything_use_large_icon"])       ; init 5 icon ,incremnt by 5 each time, 
    
    for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process")
    {
        if ( (process.Name != "System Idle Process") and(process.Name != "System")) 
        {
            candidate:=Array()
            Name:=anything_make_string(process.Name,25)
            Mem :=  anything_make_string(GetProcessMemory_Private_As_String(process.ProcessId),8,"true")
            candidate.Insert( Name . Mem) ; display ,candidate[1]
            candidate.Insert(process)     ; process object candidate[2]
            candidates.Insert(candidate)
            
            anything_add_icon(process.ExecutablePath, anything_process_icons,anything_properties["anything_use_large_icon"])
        }
    }
    return candidates
}

anything_process_on_select(candidate)
{
    process := candidate[2]
    anything_statusbar(process.CommandLine)
    anything_tooltip_header("[Enter] to kill,[Ctrl-j] to change the priority of the selected process")
}
anything_process_kill(candidate)
{
    process := candidate[2]
    ProcessId:= process.ProcessId
    Process, Close, %ProcessId%,
}
anything_processId_to_be_changed=0
anything_process_change_priority(candidate)
{
    global anything_processId_to_be_changed
    global anything_process_manager_priority_source
    anything_exit()
    process := candidate[2]
    anything_processId_to_be_changed:= process.ProcessId
    anything(anything_process_manager_priority_source)

}

; this is a private anything_source ,don't add it to your anything_sources
anything_process_manager_priority_source:=Object()
anything_process_manager_priority_source["name"] :="priority"
anything_process_manager_priority_source["candidate"] :=Array( "Realtime","High","AboveNormal","Normal","BelowNormal","Low")
anything_process_manager_priority_source["action"] :="anything_process_change_priority_action"
anything_process_change_priority_action(candidate_level)
{
    global anything_processId_to_be_changed
    Process, priority, %anything_processId_to_be_changed%, %candidate_level%
}

    
anything_process_icons=
 
    ; get icon from cmd file 
anything_process_manager_get_icons()
{
    global anything_process_icons
    return anything_process_icons
}
    
    
anything_process_manager_source:=Object()
anything_process_manager_source["name"] :="Proc"
anything_process_manager_source["candidate"] :="anything_process_candidates"
anything_process_manager_source["icon"] :="anything_process_manager_get_icons" 
anything_process_manager_source["action"] :=Array("anything_process_kill","anything_process_change_priority" )
anything_process_manager_source["action_desc"] :=Array("Kill Process","Change Process Priority" )
anything_process_manager_source["onselect"] :="anything_process_on_select" 
