;;; anything-services.ahk  --- Windows Services Manager (like services.msc)

; source is hosted on
; https://github.com/jixiuf/my_autohotkey_scripts/tree/master/ahk_scripts
; and you can find the forum here
; http://www.autohotkey.com/forum/viewtopic.php?t=72833

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; an anything-source: <anything_services_source> is defined here .
;;how to use `anything-services.ahk'

; #include anything.ahk
; #include anything-services.ahk
; f4::
; anything(anything_services_source)
; return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; ;Start the Task Scheduler service by using its Service Name
; WinServ("Schedule", True) ;Returns True if started successfully.

; ;Stop the Task Scheduler service by using its Display Name
; WinServ("Task Scheduler", False) ;Returns True if stopped successfully.

; ;Start the Windows Time service silently
; WinServ("Windows time", True, True) ;No popups

; ;Start the Task Scheduler service on remote computer name ZOMBIE
; WinServ("Schedule", True, False, "ZOMBIE") ;Returns True if started successfully.

; ;Check if the WebClient service is running
; If WinServ("WebClient")
; {   MsgBox, WebClient is up & running
;    ;Do Something
; }

; ;Toggle the DNS Client service
; WinServ("DNS Client", WinServ("DNS Client") ? False : True)
/* WinServ.ahk
; http://www.autohotkey.com/forum/topic21975.html
Version         : 1.0-x64
Author         : Hardeep Singh <http://swankyleo.googlepages.com> (modification for 64-bit version by Hynek Mlnarik)
Forum Topic   : http://www.autohotkey.com/forum/viewtopic.php?t=21975
License         : You may use this code freely and without any restriction. If you find it useful, do post your feedback at the
                 above mentioned forum topic.
===============================================================================
Function         : WinServ
Description   : This function can be used to start, stop or query(running status) a windows service on local or a remote
                 computer. Dialogs provide visual feedback when starting/stopping a service or when an error occurs.

~PARAMETERS~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ServiceName   : Specify either the Service Name or the Display Name of the service.

Task            : (Optional) Specify one of the following:
                 True - Starts the service (Returns True if service is started successfully).
                 False - Stops the service (Returns True if service is stopped successfully).
                 NULL(Default) - Query service status (Returns True if service is running).

Silent         : (Optional) Specify one of the following:
                 False(Default) - Show popup dialog for the task being performed or when an error occurs.
                 True - Suppress all popup dialogs including error messages.

Computer      : (Optional) Connect to the service control manager on the specified computer.
                 NULL(Default) - Connect to the service control manager on the local computer.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Return Value   : Returns TRUE or FALSE depending on the task performed.
Notes         : Starting a service which is dependent on other services will also start those services, if not already running.
                 Stopping a service which is dependent on other services will not stop those services.
===============================================================================
*/

WinServ(ServiceName, Task="", Silent=False, Computer="")
{   Global schSCManager, schService
   Static SERVICE_QUERY_STATUS=0x4, SERVICE_START=0x10, SERVICE_STOP=0x20, SC_STATUS_PROCESS_INFO=0, SERVICE_CONTROL_STOP=0x1
   Static SERVICE_STOPPED=0x1, SERVICE_START_PENDING=0x2, SERVICE_STOP_PENDING=0x3, SERVICE_RUNNING=0x4
   VarSetCapacity(@SSP, 36), VarSetCapacity(BytesNeeded, 4), VarSetCapacity(SvcName ,256)

   If Task not in ,0,1
      Return WinServ_ErrMsg("Parameters", ServiceName, Task, False, ErrorLevel:="Invalid Task specified!")
   If !schSCManager := DllCall("Advapi32\OpenSCManagerW", "Str", Computer, "Uint", 0, "Uint", 0)
      Return WinServ_ErrMsg("OpenSCManager", ServiceName, Task, Silent)
   ServiceName := DllCall("Advapi32\GetServiceKeyNameW", "Uint", schSCManager, "Uint", &ServiceName, "Str", SvcName, "UintP", 256) ? SvcName : ServiceName
   If ErrorLevel
      Return WinServ_ErrMsg("GetServiceKeyName", ServiceName, Task, Silent)

   If !schService := DllCall("Advapi32\OpenServiceW", "Uint", schSCManager, "Uint", &ServiceName, "Uint", SERVICE_QUERY_STATUS|SERVICE_START|SERVICE_STOP)
      Return WinServ_ErrMsg("OpenService", ServiceName, Task, Silent)
   ServiceName := DllCall("Advapi32\GetServiceDisplay_NameW", "Uint", schSCManager, "Uint", &ServiceName, "Str", SvcName, "UintP", 256) ? SvcName : ServiceName

   Progress, % Task = "" || Silent ? "10:Off" : "10:ZH0 FM10 FS10 B2 H65 W200 ZX2 ZY5", %ServiceName%, % Task ? "Starting service..." : "Stopping service..."
   If (Task = True)
   {   If !DllCall("Advapi32\StartServiceW", "Uint", schService, "Uint", 0, "Uint", 0)
         Return WinServ_ErrMsg("StartService", ServiceName, Task, Silent)
   }   else
   If (Task = False)
   {   If !DllCall("Advapi32\ControlService", "Uint", schService, "Uint", SERVICE_CONTROL_STOP, "Uint", &@SSP)
         Return WinServ_ErrMsg("StopService", ServiceName, Task, Silent)
   }
   If !DllCall("Advapi32\QueryServiceStatusEx", "Uint", schService, "Uint", SC_STATUS_PROCESS_INFO, "Uint", &@SSP, "Uint", 36, "Uint", &BytesNeeded)
      Return WinServ_ErrMsg("QueryService", ServiceName, Task, Silent)
   If Task =
      Return WinServ_ErrMsg(0,0,0,True)+(NumGet(@SSP, 4, "Uint") = SERVICE_RUNNING)
   StartTickCount := A_TickCount
   OldCheckPoint := NumGet(@SSP, 20, "Uint")
   Loop
   {   If (NumGet(@SSP, 4, "Uint") != (Task ? SERVICE_START_PENDING : SERVICE_STOP_PENDING))
         Break
      WaitTime := NumGet(@SSP, 24, "Uint")/10
      Sleep % WaitTime := WaitTime < 1000 ? 1000 : WaitTime > 10000 ? 10000 : WaitTime
      If !DllCall("Advapi32\QueryServiceStatusEx", "Uint", schService, "Uint", SC_STATUS_PROCESS_INFO, "Uint", &@SSP, "Uint", 36, "Uint", &BytesNeeded)
         Return WinServ_ErrMsg("QueryService", ServiceName, Task, Silent)
      If (NumGet(@SSP, 20) > OldCheckPoint)
      {   StartTickCount := A_TickCount
         OldCheckPoint := NumGet(@SSP, 20)
      }   else
      If (A_TickCount-StartTickCount > NumGet(@SSP, 24))
         Break
   }

   If (NumGet(@SSP, 4, "Uint") != (Task ? SERVICE_RUNNING : SERVICE_STOPPED))
      Return WinServ_ErrMsg(Task ? "StartService" : "StopService", ServiceName, Task, Silent, DllCall("SetLastError", "Uint", NumGet(@SSP, 12)))
   Return WinServ_ErrMsg(0,0,0,True)+1
}

;===============================================================================
;Function      : WinServ_ErrMsg
;Description   : This function is used internally by WinServ function.
;===============================================================================
WinServ_ErrMsg(Title, ServiceName, Task="", Silent=False, Dummy="")
{   Global schSCManager, schService
   Progress, 10:Off
   If !Silent
   {   If !ErrorLevel
         VarSetCapacity(LastErrMsg, 1024), DllCall("FormatMessage", "Uint", 0x1000, "Uint", 0, "Uint", LastErrNum:=A_LastError != 123 ? A_LastError : 1060, "Uint", 0, "Str", LastErrMsg, "Uint", 1024, "Uint", 0) ;FORMAT_MESSAGE_FROM_SYSTEM=0x1000
      MsgBox, 262160, WinServ.%Title%: %ServiceName%, % "Could not " (Task = True ? "start {" : Task = False ? "stop {" : "query {") ServiceName "} service.`n`n" (!ErrorLevel ? "Error " LastErrNum ": " LastErrMsg : "Error: " ErrorLevel)
   }   DllCall("Advapi32\CloseServiceHandle", "Uint", schService), DllCall("Advapi32\CloseServiceHandle", "Uint", schSCManager)
   Return False
}

anything_services_candidates()
{
    candidates :=Array()
    Loop, HKEY_LOCAL_MACHINE, SYSTEM\CurrentControlSet\Services, 2, 0
    {
        Service_Name:=a_LoopRegName
        RegRead, ObjectName, HKEY_LOCAL_MACHINE, SYSTEM\CurrentControlSet\Services\%Service_Name%, ObjectName
        if( ErrorLevel = 0 )    ; if it has  SYSTEM\CurrentControlSet\Services\servicename. ObjectName
        {
            RegRead, Start, HKEY_LOCAL_MACHINE, SYSTEM\CurrentControlSet\Services\%Service_Name%, Start
            ; 
            ; 0 = Boot
            ; 1 = System
            ; 2 = Automatic
            ; 3 = Manual
            ; 4 = Disabled
            
            if (Start=0)
            {
                Start_Status:="Boot"
            }else if (Start=1)
            {
                Start_Status:="System"
            }else if (Start=2)
            {
                Start_Status:="Automatic"
            }else if (Start=3)
            {
                Start_Status:="Manual"
            }else if (Start=4)
            {
                Start_Status:="Disabled"
            }
            
            RegRead, Display_Name, HKEY_LOCAL_MACHINE, SYSTEM\CurrentControlSet\Services\%Service_Name%, DisplayName
            if( ErrorLevel = 1 )
            {
                Display_Name :=Service_Name
            }
            
            RegRead, Description, HKEY_LOCAL_MACHINE, SYSTEM\CurrentControlSet\Services\%Service_Name%, Description
            if( ErrorLevel = 1 )
            {
                Description:= Display_Name 
            }
            if (WinServ(Service_Name)=1) ; 
            {
                Running_Status:="Running"
            }else
            {
                Running_Status:="Stopped"
            }
            candidate:=Array()
            display:=anything_make_string(Display_Name,60) . anything_make_string(Start_Status,15) . anything_make_string(Running_Status,10)
            candidate.Insert(display) ; candidate[1]
            candidate.Insert(Start_Status) ; candidate[2] ; Boot System Automatic Manual Disabled
            candidate.Insert(Running_Status) ; candidate[3] ,Running or Stopped
            candidate.Insert(Service_Name)   ; candidate[4]
            candidate.Insert(Description)    ; candidate[5]
            candidate.Insert(Start) ; candidate[6] ; 0,1,2,3,4 
            
            
            candidates.Insert(candidate)
        }
    }
    return candidates
}
anything_services_onselect(candidate)
{
    Description:=candidate[5]
    anything_statusbar(Description)
    anything_tooltip_header("[Enter] to start a stopped service or stop a running service,[Ctrl-j] to change the StartStatus of a service. [Ctrl-m] to run services.msc")    

}

; if selected service is stopped ,then start it.
; if it is running ,then stop it .
anything_services_toggle_start_or_stop(candidate)
{
    Service_Name :=candidate[4]
    Start_Status :=candidate[2]
    Running_Status :=candidate[3]
    if (Start_Status="Disabled")
    {
        anything_MsgBox(Service_Name . " is Disabled,you can't start or stop a disabled service!!")
    }else
    {
        if (Running_Status="Running")
        {
            WinServ(Service_Name,False)
        }
        else
        {
            WinServ(Service_Name,True)
        }
    }
}

anything_services_candidate=
anything_services_status_source:=Object()
anything_services_status_source["name"]:="ServStat"
anything_services_status_source["candidate"]:=Array(Array("Boot",0),Array("System",1),Array("Automatic",2) ,Array("Manual",3),Array("Disabled",4))
anything_services_status_source["action"]:="anything_services_change_status_action"
 
; change the status of service to :Boot System Automatic Manual Disabled
anything_services_change_status_action(candidate_status)
{
    global anything_services_candidate
    Service_Name :=anything_services_candidate[4]
    ; run, sc config Service_Name start= demand
    ; * auto--a service automatically started at boot time, even if no user logs on
    ; * boot--a device driver loaded by the boot loader
    ; * demand--a service that must be manually started (the default)
    ; * disabled--a service that can't be started
    ; * system--a service started during kernel initialization
    
    
    ; candidate_status_value:=candidate_status[2]
    ; RegWrite, REG_DWORD, HKEY_LOCAL_MACHINE, SYSTEM\CurrentControlSet\Services\%Service_Name%,Start,%candidate_status_value%
    
    candidate_status:=candidate_status[1]
    if(candidate_status="Boot") 
    {
        run, sc config "%Service_Name%" start= boot
    }else    if(candidate_status="System")
    {
        run, sc config "%Service_Name%" start= system
    }else    if(candidate_status="Automatic")
    {
        run, sc config "%Service_Name%" start= auto
    }else    if(candidate_status="Manual")
    {
        run, sc config "%Service_Name%" start= demand
    }else    if(candidate_status="Disabled")
    {
        run, sc config "%Service_Name%" start= disabled
    }
 
    if (candidate_status_value)
    anything_MsgBox(Service_Name)
}

; start a new anything session to
 ; change the status of service to :Boot System Automatic Manual Disabled
anything_services_change_StartStatus(candidate)
{
    global anything_services_candidate
    global anything_services_status_source
    global anything_pre_selected_candidate_index
    
    anything_services_candidate:=candidate
    Start :=candidate[6]
    ; start a new anything session 
    anything_exit()
    anything_pre_selected_candidate_index:=Start+1 ;  
    anything(anything_services_status_source)
    anything_tooltip_header("hel")
}
anything_services_run_services_dot_msc(unused_candidate)
{
    run , services.msc
}

anything_services_source:=Object()
anything_services_source["name"]:="Services"
anything_services_source["candidate"]:="anything_services_candidates"
 anything_services_source["action"]:=Array("anything_services_toggle_start_or_stop","anything_services_change_StartStatus","anything_services_run_services_dot_msc")
anything_services_source["onselect"]:="anything_services_onselect"
