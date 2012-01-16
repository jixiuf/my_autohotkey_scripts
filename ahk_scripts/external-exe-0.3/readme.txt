External.exe
============

External.exe is a program which allows an external text editor to
be run from any application using a single keystroke.

web: http://bur.st/~benc/?p=external

Installation and Configuration
==============================

After downloading and unzipping external.zip put external.exe and
external.ini in a directory together.

Open external.ini in a text editor and set the options "Editor"
and "EditorBinding" as explained in the comments in the file.

The program can be started by manually running the external.exe
command. But once you get a configuration you like you may want to
place a shortcut in your Start/Programs/Startup folder so it will
be automatically executed.

Tip: When configuring external.exe it can be useful to use the
Restart (Shift-Ctrl-Alt-R) and Exit (Shift-Ctrl-Alt-X) bindings to
reconfigure your program.


Usage
=====

To use the program, once it is configured and running, move the
cursor to the text area of an application and type your EditorBinding
keystroke (Windows-V, for example)


Filetypes in Vim
================

Also provided with the program is a vim script "external.vim". This
file can be installed by putting it in your vim plugin folder. With
an appropriately configured Editor option in external.ini vim will
be able to recognise the filetype of the text you are editing by
using the application window title as a clue.

external.vim has only been tested on a small number of applications
and filetypes, but it should be relatively easy to add new filetypes
by modifying the External() function in the script.

==
Author: Ben Collerson <benc at bur dot st>
Contributor: Felix E. Klee <felix.klee@inka.de>
Last Modified: 22 Apr 2011
Version: 0.3
Logo: Based on http://en.wikipedia.org/wiki/File:External.svg
      License: public domain

Copyright (C) 2005, 2011 Ben Collerson <benc at bur dot st>, 
  Felix E. Klee <felix.klee@inka.de>

This file is part of External.exe.

External.exe is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see <http://www.gnu.org/licenses/>.
