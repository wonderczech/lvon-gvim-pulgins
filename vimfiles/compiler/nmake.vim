" Vim compiler file
" Compiler:         Visual Studio 2008 C# Compiler
" Maintainer:       Ladislav Vondraek
" Latest Revision:  2009-07-29

if exists("current_compiler")
  finish
endif
let current_compiler = "nmake"

if exists(":CompilerSet") != 2		" older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

let s:cpo_save = &cpo
set cpo-=C

"defaulr errorformat
CompilerSet errorformat=\ %#%f(%l\\\,%c):\ %m

"default make
CompilerSet makeprg=nmake
