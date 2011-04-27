#z::  ;测试
msgbox % ClipCopy()
return

; Functions
;ClipCopy Function
;~ 选中文本内容，按win z可以看到复制到东西，但不影响剪贴板
;~ ---------------------------------------------------------------------
;~ 你可以在之前现在mspaint中随便画个线条，复制后清除之。
;~ 然后运行我的代码
;~ 然后粘贴
ClipCopy()
{
   
   SavedClip := ClipboardAll
   Sleep, 50
   Clipboard =
   Sleep, 50
   Send ^c ;copy
   ClipWait
   Copied := Clipboard
   Sleep, 50
   Clipboard := SavedClip
   
Return Copied
}