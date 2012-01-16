" external.vim: A vim script assisting with filetype recognition when using
"               the external.exe program.
"
" Author: Ben Collerson (benc at bur dot st)
" Last Change: 26 Jan 2005
" Created: 19 Jan 2005
" Requires: Vim-6, exed (external program)
" Version: 0.1
" Licence:
"     This file is part of External.exe.
"
"     External.exe is free software: you can redistribute it and/or modify it
"     under the terms of the GNU General Public License as published by the
"     Free Software Foundation, either version 3 of the License, or (at your
"     option) any later version.
"
"     This program is distributed in the hope that it will be useful, but 
"     WITHOUT ANY WARRANTY; without even the implied warranty of 
"     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
"     Public License for more details.
"
"     You should have received a copy of the GNU General Public License along
"     with this program. If not, see <http://www.gnu.org/licenses/>.
"
" Usage:
"     This should normally be used only in the context of having external 
"     start a vim session. 
"     
"     The function External() can be modified to allow matching of other 
"     window titles and filetypes as required.
"
" Installation:
"     Drop this file in your plugin directory.

function s:External(title)
  let windowTitle = a:title

  if windowTitle =~? 'mail\|new memo\|compose'
    setfiletype mail
  elseif windowTitle =~? 'sql\|microsoft access'
    setfiletype sql
  elseif windowTitle =~? 'sigma'
    setfiletype rw
  elseif windowTitle =~? 'edit page'
    setfiletype html
  else
    setfiletype text
  endif

  " reset EnhancedCommentify.vim
  if exists("b:ECdidBufferInit")
    unlet b:ECdidBufferInit
    call EnhancedCommentifyInitBuffer()
  endif

endf

command! -nargs=1 External :call <SID>External(<args>)

