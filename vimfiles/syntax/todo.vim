" Vim syntax file
" Language:	"todo.txt" files
" Maintainer:	Ladislav Vondracek (ladislav.vondracek@centrum.cz)
" URL: none
" Last Change:	2010 Feb 02

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif


" shut case off
syn case ignore

" todo strings:
syn keyword todoTodo            TODO FIX NOTE
syn keyword todoTodo            contained TODO FIX NOTE
syn region  todoComment         start="/\*"  end="\*/" contains=todoTodo
syn match   todoComment         "//.*$" contains=todoTodo
syn region  todoImportant       start="/!"  end="!/"
syn match   todoImportant       ".*(!!)$"
syn region  todoIssue           start="/?"  end="?/"
syn match   todoIssue           "\S.*(??)$"
syn match   todoIssue           "\S*\s*(??)"
syn match   todoBullet          "^\s*- "
syn match   todoBullet          "^\s*\d\+)"
syn match   todoBullet          "^\s*\(\d\+\.\)\+\d)"
syn match   todoTopic           "^\s*\* .*$"
syn match   todoTopic           "^\s*--\+$"
syn match   todoTopic           "^\s*==\+$"
syn match   todoDone            ".*(ok)"
syn match   todoDone            "^\s*-\([^-]*\n\)\+[^-]\+(ok)"

" The default highlightning
hi def link todoTodo			              Todo
hi def link todoComment			            Comment
hi def link todoImportant               WarningMsg
hi def link todoIssue                   ModeMsg
hi def link todoBullet                  Keyword
hi def link todoTopic                   Keyword
hi def link todoDone                    Comment

map kk $a (ok)<Esc>:echo "ukol splnen"<CR>
" TODO: plneni ukolu ve visual bloku
map !! $a (!!)<Esc>:echo "ukol oznacen jako kriticky"<CR>
