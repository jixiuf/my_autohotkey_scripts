;;; anything-process-manager.ahk -- Process Manager 

; source is hosted on
; https://github.com/jixiuf/my_autohotkey_scripts/tree/master/ahk_scripts
; and you can find the forum here
; http://www.autohotkey.com/forum/viewtopic.php?t=72833

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;how to use `anything-process-manager.ahk'
; f2::
; anything(anything_process_manager_source)
; return
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
    ;    current_anything_pid := DllCall("GetCurrentProcessId") ;
    candidates:= Object()
    for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process")
    {
        if ( (process.Name != "System Idle Process") and(process.Name != "System")) 
        {
            candidate:=Array()
            Name:=anything_make_string(process.Name,25)
            Mem :=  anything_make_string(GetProcessMemory_Private_As_String(process.ProcessId),8,"true")
            candidate.Insert( Name . Mem)
            candidate.Insert(process)
            candidates.Insert(candidate)
        }
    }
    return candidates
}

anything_process_on_select(candidate)
{
    process := candidate[2]
    anything_statusbar(process.CommandLine)
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


    
anything_process_manager_source:=Object()
anything_process_manager_source["name"] :="Proc"
anything_process_manager_source["candidate"] :="anything_process_candidates"
anything_process_manager_source["action"] :=Array("anything_process_kill","anything_process_change_priority" )
anything_process_manager_source["onselect"] :="anything_process_on_select" 
