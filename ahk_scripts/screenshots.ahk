; http://keepnote.org/boxcutter/
; usage: boxcutter [OPTIONS] [OUTPUT_FILENAME]
; Saves a screenshot to 'OUTPUT_FILENAME' if given.  Only output formats
; "*.bmp" and "*.png" are supported.  If no file name is given,
; screenshot is stored on clipboard by default.
; OPTIONS
;   -c, --coords X1,Y1,X2,Y2    capture the rectange (X1,Y1)-(X2,Y2)
;   -f, --fullscreen            capture the full screen\n\
;   -h, --help                  display help message


; 按下 printScreen Alt+PrintScreen(系统自带的功能依然有用)
; 但是增加以下功能 ，自动保存文件，并预览
~PrintScreen::screenshot_fullscreen()
~!PrintScreen::screenshot_actived_window()

#IfWinActive ahk_class Photo_Lightweight_Viewer|ShImgVw:CPreviewWnd
q::Send !{F4}
!g::Send !{F4}
esc::Send !{F4}
#IfWinActive


screenshot_fullscreen(){
    shot_dest_dir:="c:\shots\"
    if (not  FileExist(shot_dest_dir))
    {
        FileCreateDir, %shot_dest_dir%
    }
    FileName:= A_YYYY . "_" . A_MM . "_" . A_DD . "-" . A_Hour . A_Min . A_Sec . A_MSec . ".png"
    Path1 := shot_dest_dir . FileName
    Run ,boxcutter --fullscreen %Path1%
    sleep 200
    Run, %Path1%
}

screenshot_actived_window(){
    shot_dest_dir:="c:\shots\"
    if (not  FileExist(shot_dest_dir))
    {
        FileCreateDir, %shot_dest_dir%
    }
    FileName:= A_YYYY . "_" . A_MM . "_" . A_DD . "-" . A_Hour . A_Min . A_Sec . A_MSec . ".png"
    Path1 :=shot_dest_dir . FileName
    WinGetPos, X, Y, Width, Height,A
    X2:=X+Width
    Y2:=Y+ Height
    Run ,boxcutter  --coords %X%`,%Y%`,%X2%`,%Y2%  %Path1%
    sleep 200
    Run, %Path1%
}
