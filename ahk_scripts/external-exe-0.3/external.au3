; external.au3
;
; Author: Ben Collerson <benc at bur dot st>
; Contributor: Felix Klee <felix.klee@inka.de>
; Last Modified: 22 Apr 2011
; Version: 0.3
;
; This is an application to allow an external editor to be used 
; from Windows applications. 
;
; This program was developed using the scripting language, AutoIt. See
; http://www.autoitscript.com/autoit3/
;
; Note: this program is written to be run as a "compiled" executable, it
;       will not run properly as a script.
;
; Copyright (C) 2005, 2011 Ben Collerson <benc at bur dot st>, 
;   Felix E. Klee <felix.klee@inka.de>
;
; This file is part of External.exe.
;
; External.exe is free software: you can redistribute it and/or modify it under
; the terms of the GNU General Public License as published by the Free Software
; Foundation, either version 3 of the License, or (at your option) any later
; version.
;
; This program is distributed in the hope that it will be useful, but WITHOUT
; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
; FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
; details.
;
; You should have received a copy of the GNU General Public License along with
; this program. If not, see <http://www.gnu.org/licenses/>.
;
; Additional permission under GNU GPL version 3 section 7
;
; If you modify this Program, or any covered work, by linking or combining it
; with AutoIt components, containing parts covered by the terms of the AutoIt
; EULA, the licensors of this Program grant you additional permission to convey
; the resulting work.
;
; Changelog:
; 22 Apr 2011 - fixed issues with stuck modifier keys, enabled UTF-8 support
;               with the FileOpen function.
; 26 Jan 2005 - fixed some problems with AppList functions.
; 23 Jan 2005 - added some error checking: if original window is not
;               found or paste is unsuccessful then the editor window 
;               can be restored.
; 19 Jan 2005 - external.exe created
;------------------------------------------------------------------------------

; Global variables

; these are used for the extra binding options
; $maxbindings should be set to the same number as the number of DoAction 
; functions below
Global $maxbindings = 10
Global $action[$maxbindings]

; some timing variables
Global $pollWait = 250
Global $shortWait = 10

Global $editor = ''

;------------------------------------------------------------------------------

; Replacement for "Send". Avoids stuck modifier keys, also in combination with
; "HotKeySet". Based on code from:
;
; http://www.autoitscript.com/wiki/FAQ#Keys_virtually_stuck

#include <Misc.au3>

; Sends the string $ss after certain modifier keys are released. Optionally
; gives a warning after 1 sec if any of those keys still down.
Func _SendEx($ss, $warn = "")
	Local $iT = TimerInit()
 
	; Key codes: http://msdn.microsoft.com/en-us/library/ms645540
	While _IsPressed("10") Or _IsPressed("11") Or _IsPressed("12") Or _
        _IsPressed("5B") Or _IsPressed("5C")
		If $warn <> "" And TimerDiff($iT) > 1000 Then
			MsgBox(262144, "Warning", $warn)
		EndIf
		Sleep(50)
	Wend
	Send($ss)
EndFunc


;------------------------------------------------------------------------------

; Reads the ini file.

Func PollInit()
    $shortWait = IniRead("external.ini","Behaviour","ShortWait",10)
    $pollWait = IniRead("external.ini","Behaviour","PollWait",100)
    Opt("TrayIconHide",IniRead("external.ini","Behaviour","TrayIconHide",1))

;    Global $editor = IniRead("external.ini","Bindings","Editor","notepad.exe")

    $editorBinding = IniRead("external.ini","Bindings","EditorBinding","#v")
    HotKeySet($editorBinding,"DoEdit")

    $exitBinding = IniRead("external.ini","Bindings","ExitBinding","")
    If $exitBinding <> '' Then
        HotKeySet($exitBinding,"DoExit")
    EndIf

    $restartBinding = IniRead("external.ini","Bindings","RestartBinding","")
    If $restartBinding <> '' Then
        HotKeySet($restartBinding,"DoRestart")
    EndIf

    ; an unlikely key sequence used so child can tell parent process to
    ; clean $appList of unused files. -- should have no effect otherwise
    $hiddenBinding = IniRead("external.ini","Bindings","HiddenBinding",'+!#~')
    HotKeySet($hiddenBinding, "AppListClean")

    For $index = 1 to $maxbindings
        $key = IniRead("external.ini","Bindings","Binding" & $index,"")
        $act = IniRead("external.ini","Bindings","Action" & $index,"")
        If $key <> '' Then
            If $act <> '' Then
                HotKeySet($key,"DoAction" & $index)
                $action[$index] = $act
            Else 
                HotKeySet($key)
                $action[$index] = ''
            Endif
        EndIf
    Next
    
    ; this binding is used so child processes can tell parent to 
    ; clean out the appList
EndFunc

Func EditInit()
    $shortWait = IniRead("external.ini","Behaviour","ShortWait",10)
    $shortWait = IniRead("external.ini","Behaviour","ShortWait",10)
    Global $bufferSize = IniRead("external.ini","Behaviour","BufferSize",512)
    Opt("TrayIconHide",1) ; always hide icon

    Global $hiddenBinding = IniRead("external.ini","Bindings","HiddenBinding",'+^!#~')
    Global $editor = IniRead("external.ini","Bindings","Editor","notepad.exe")
EndFunc

;------------------------------------------------------------------------------

; The standard builtin bindings.

Func DoExit()
    Exit
EndFunc

Func DoRestart()
    Run(@ScriptName)
    Exit
EndFunc
    
Func DoEdit()
    $app = WinGetTitle('')
    ; if there is a previously active edit window then activate that
    ; otherwise create a new one
    If AppListHasApp($app) Then
        $file = AppListGetFile($app)
        Opt("WinTitleMatchMode", 2) ; match any substring
        WinActivate($file)
        Sleep($shortWait)
        $isActive = WinActive($file)
        Opt("WinTitleMatchMode", 1) ; default matching
        If ($isActive) Then
            Return
        Endif
    Endif

    $file = MakeTempfile()

    ; get the filename without the path
    $parts = StringSplit($file,"\")
    $name = $parts[$parts[0]]
    AppListAddPair($app,$name)

    Run(@ScriptName & " " & $file)
;    Sleep(1000)
;    AppListClean()
EndFunc
    
;------------------------------------------------------------------------------

; These functions are used for miscellaneous other hotkey bindings.
; HotKeySet does not allow parameters to be passed which is why these
; have been cut and pasted.
; To increase the number of extra bindings cut, paste and fix the numbering
; also set $maxbindings (above) to the number of DoAction functions you have

Func DoAction1()
    Run($action[1])
EndFunc

Func DoAction2()
    Run($action[2])
EndFunc

Func DoAction3()
    Run($action[3])
EndFunc

Func DoAction4()
    Run($action[4])
EndFunc

Func DoAction5()
    Run($action[5])
EndFunc

Func DoAction6()
    Run($action[6])
EndFunc

Func DoAction7()
    Run($action[7])
EndFunc

Func DoAction8()
    Run($action[8])
EndFunc

Func DoAction9()
    Run($action[9])
EndFunc

Func DoAction10()
    Run($action[10])
EndFunc

;------------------------------------------------------------------------------

; These functions are used to match up "files" and "applications".
; This allows the program to reactivate an editor which is editing a file 
; associated with a particular application rather than starting a 
; duplicate editor.

; note: the logic here is to build something vaguely similiar to a hash 
; table, a really slow hash table. :-)

; needs to be a cleaning subroutine, run periodically..

; $appList is used to store pairs of applications and files
Global $appList = ''

; The following were chosen as they are unlikely characters 
; to be in a window title.
Global $appDelim = @LF

Func AppListHasApp($app)
    Return (StringInStr($appList,$app & $appDelim) <> 0)
EndFunc

Func AppListGetFile($app)
    $appArray = StringSplit($appList,$appDelim)
    For $index = 1 to ($appArray[0] - 2) Step 2
        if $app == $appArray[$index] Then
            Return $appArray[$index + 1]
        Endif
    Next
    Return ''
EndFunc

Func AppListAddPair($app,$file)
    If $app <> '' And $file <> '' Then
        If AppListHasApp($app) Then
            $oldFile = AppListGetFile($app)
            $appList = StringReplace($appList,$oldFile & $appDelim,$file & $appDelim)
        Else
            $appList = $appList & $app & $appDelim & $file & $appDelim
        Endif
    Endif
EndFunc

Func AppListClean()
    $appArray = StringSplit($appList,$appDelim)
    For $index = 2 to ($appArray[0] - 1) Step 2 
        If Not FileExists(@TempDir & "\" & $appArray[$index]) Then
            $appArray[$index] = ''
            $appArray[$index - 1] = ''
        Endif 
    Next
    $newList = ''
    For $index = 1 to ($appArray[0] - 1)
        If $appArray[$index] <> '' Then
           $newList = $newList & $appArray[$index] & $appDelim
        Endif
    Next
    $appList = $newList
EndFunc

;------------------------------------------------------------------------------

; Utility functions for transfering text out-of and into the application.

Global $cliptemp

; backs up a copy of the clipboard
Func SaveClip()
    ; Backup clipboard before we use it
    Global $cliptemp = ClipGet()
    If @error == 1 Then $cliptemp = ""
EndFunc


; restores the clipboard from back up
Func RestoreClip()
    ClipPut($cliptemp)
EndFunc


; copyies the text out of a window
; returns the copied text
Func GetText()
    SaveClip()
    ClipPut('')  ; in case there is nothing to copy
    ; Ctrl-A doesn't work on single line fields! 
    _SendEx("^{END}^+{HOME}^c^{HOME}")
    Sleep($shortWait)
    $text = ClipGet()
    If @error == 1 Then $text = ""
    RestoreClip()
    return $text
EndFunc

; pastes text into a window
; returns true if paste passes a verification
;         false if paste fails verification
Func PutText($text)
    SaveClip()
    ClipPut($text)
    _SendEx("^{END}^+{HOME}^v")

    ; Note: after pasting the text, we copy it again to check
    ; that it pasted okay. 
    ClipPut('')  ; in case there is nothing to copy
    _SendEx("^{END}^+{HOME}^c^{HOME}")
    Sleep($shortWait)
    $check = ClipGet()
    RestoreClip()

    ; Lotus Notes and WinWord don't paste final newline  so strip all 
    ; trailing whitespace before comparison to stop error message.
    $text = StringStripWS($text,2)
    $check = StringStripWS($check,2)

    Return ($check == $text)
EndFunc

;------------------------------------------------------------------------------

; Utility function to make a tempfile.

Func MakeTempfile()
    $tempPrefix = 'X'
    Do 
        $filename = @TempDir & '\' & $tempPrefix & StringFormat("%.3f",Random()*1000000)
    Until Not FileExists($filename)
    Return $filename
EndFunc

;------------------------------------------------------------------------------

; Launches an external editor, transfers text, handles errors, etc.

Func Edit($tempfile)
    $filemarker = '~f'
    $titlemarker = '~t'

    If WinGetTitle('') == '' Then
        ; no active window so nothing to do.
        FileDelete($tempfile)
        _SendEx($hiddenBinding)
        Exit
    EndIf

    $text = GetText()

    $file = FileOpen($tempfile,258)
    FileWrite($file,$text)
    FileClose($file)

    $title = WinGetTitle('')

    $command = ''

    If StringInStr($editor,$filemarker) Then
        ; inserts filename at position requested
        $command = StringReplace($editor,$filemarker,$tempfile)
    Else
        ; otherwise insert filename at end
        $command = $editor & ' ' & $tempfile
    EndIf

    ; todo: remove quote chars from title before putting it into
    ; the command
    $command = StringReplace($command,$titlemarker,$title )

    ; runs the editor command 
    $editflag = 1
    While $editflag
;       label edit
        $checkflag = 1

        RunWait($command)

        ; copy file into variable $text
        $file = FileOpen($tempfile,256)
        $text = ''
        While 1
            $char = FileRead($file,$bufferSize)
            If @error == -1 Then ExitLoop
            $text = $text & $char 
        Wend
        FileClose($file)

        While $checkflag
            WinActivate($title)
            Sleep($shortWait)
            If Not WinActive($title) Then
                $sel = MsgBox(4098, "External.exe: Cannot find window", _
                      "Abort: recover text" & @CRLF _
                    & "Retry: look for window again" & @CRLF _
                    & "Ignore: discard text") 
                If $sel == 3 Then      ; abort
;                  goto edit
                   $checkflag = 0
;               ElseIf $sel == 4 Then  ; retry 
;                  nothing to do
                Elseif $sel == 5 Then  ; ignore
;                  goto end
                   $editflag = 0
                   $checkflag = 0
                Endif
            Elseif Not PutText($text) Then
                $sel = MsgBox(4098, "External.exe: Cannot transfer text", _
                      "Abort: recover text" & @CRLF _
                    & "Retry: attempt to transfer test" & @CRLF _
                    & "Ignore: discard text") 
                If $sel == 3 Then      ; abort
;                  goto edit
                   $checkflag = 0
;               ElseIf $sel == 4 Then  ; retry 
;                  nothing to do
                Elseif $sel == 5 Then  ; ignore
;                  goto end
                   $editflag = 0
                   $checkflag = 0
                Endif
            Else                      ; success!
;              goto end
               $editflag = 0
               $checkflag = 0
            EndIf
        Wend
    Wend
;   label end

    FileDelete($tempfile)
    _SendEx($hiddenBinding)
    Exit
EndFunc

;------------------------------------------------------------------------------

; Keeps the application running in background while waiting for a keystroke.

Func Poll()
    While 1
        Sleep($pollWait)
    Wend
EndFunc

;------------------------------------------------------------------------------

; Start execution here

If @Compiled <> 1 Then
    MsgBox(4096, "External.au3", _
           "Error: This program must be run " & @CRLF _
         & "as a compiled executable")
    Exit
Endif

If $CmdLine[0] == 0 Then
    PollInit()
    Poll()
Else
    ; the only command line argument is the tempfile to be edited --
    ; The tempfile is created by the polling system
    EditInit()
    Edit($CmdLine[1])
EndIf

;------------------------------------------------------------------------------
