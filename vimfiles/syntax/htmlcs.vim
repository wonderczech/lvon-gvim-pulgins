" Vim syntax file
" Language:    htmlcs (C# embedded in HTML)
" Maintainer:  Ladislav Vondracek <ladislav.vondracek@centrum.cz>
" Last change: 2010 March 02
" URL:
"

" Clear previous syntax settings unless this is v6 or above, in which case just
" exit without doing anything.
"
if version < 600
	syn clear
elseif exists("b:current_syntax")
	finish
endif

" The HTML syntax file included below uses this variable.
"
if !exists("main_syntax")
	let main_syntax = 'htmlcs'
endif

" First pull in the HTML syntax.
"
if version < 600
	so <sfile>:p:h/html.vim
else
	runtime! syntax/html.vim
	unlet b:current_syntax
endif

syn cluster htmlPreproc add=@htmlcsTop

" Now pull in the C# syntax.
"
if version < 600
	syn include @csTop <sfile>:p:h/cs.vim
else
	syn include @csTop syntax/cs.vim
endif

syn region htmlcsLine matchgroup=Delimiter start="^%" end="$" contains=@csTop
syn region htmlcsExpr matchgroup=Delimiter start="<%" end="%>" contains=@csTop
syn region htmlcsCs matchgroup=Delimiter start=+<script\s\+language=\"C#\"\=[^>]*>+ end=+</script>+ contains=@csTop

syn cluster htmlcsTop contains=htmlcsLine,htmlcsExpr,htmlcsCs

set foldcolumn=1

" Set up default highlighting. Almost all of this is done in the included
" syntax files.
"
if version >= 508 || !exists("did_htmlcs_syn_inits")
	if version < 508
		let did_htmlcs_syn_inits = 1
		com -nargs=+ HiLink hi link <args>
	else
		com -nargs=+ HiLink hi def link <args>
	endif

	HiLink htmlcsDoc Comment

	delc HiLink
endif

let b:current_syntax = "htmlcs"

if main_syntax == 'htmlcs'
	unlet main_syntax
endif
