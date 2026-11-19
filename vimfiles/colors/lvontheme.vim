" Vim color file
" Maintainer: Thorsten Maerz <info@netztorte.de>
" Last Change: 2001 Jul 23
" grey on black
" optimized for TFT panels

set background=dark
highlight clear
if exists("syntax_on")
  syntax reset
endif
"colorscheme default
let g:colors_name = "lvontheme"

" GUI & console
highlight Normal        guifg=#c0c0c0 guibg=#000000                 ctermfg=gray      ctermbg=black
highlight Search        guifg=#b0fff5 guibg=#406080                 ctermfg=cyan      ctermbg=blue  cterm=underline term=underline
highlight ErrorMsg      guifg=#ffffff guibg=#287eff                 ctermfg=white     ctermbg=lightblue
highlight Todo          guifg=#d14a14 guibg=#1248d1                 ctermfg=red       ctermbg=darkblue
highlight IncSearch     guifg=#b0ffff guibg=#2050d0                 ctermfg=darkblue  ctermbg=gray

highlight SpecialKey    guifg=cyan                                  ctermfg=darkcyan
highlight Directory     guifg=cyan                                  ctermfg=cyan
highlight Title         guifg=magenta                     gui=none  ctermfg=magenta                     cterm=bold
highlight WarningMsg    guifg=red                                   ctermfg=red
highlight WildMenu      guifg=yellow  guibg=black                   ctermfg=yellow    ctermbg=black     cterm=none      term=none
highlight ModeMsg       guifg=#22cce2                               ctermfg=lightblue
highlight MoreMsg                                                   ctermfg=darkgreen
highlight Question      guifg=green gui=none                        ctermfg=green                       cterm=none
highlight NonText       guifg=#0030ff                               ctermfg=darkblue

highlight StatusLine    guifg=blue    guibg=darkgray     gui=none   ctermfg=blue      ctermbg=gray      cterm=none      term=none
highlight StatusLineNC  guifg=black   guibg=darkgray     gui=none   ctermfg=black     ctermbg=gray      cterm=none      term=none
highlight VertSplit     guifg=black   guibg=darkgray     gui=none   ctermfg=black     ctermbg=gray      cterm=none      term=none

highlight Folded        guifg=#808080 guibg=#000000                 ctermfg=darkgrey  ctermbg=black     cterm=bold      term=bold
highlight FoldColumn    guifg=#808080 guibg=#000000                 ctermfg=darkgrey  ctermbg=black     cterm=bold      term=bold
highlight LineNr        guifg=#90f020                               ctermfg=green                       cterm=none

highlight DiffAdd                     guibg=darkblue                                  ctermbg=darkblue  cterm=none      term=none
highlight DiffChange                  guibg=darkmagenta                               ctermbg=magenta   cterm=none
highlight DiffDelete    guifg=Blue    guibg=DarkCyan     gui=bold   ctermfg=blue      ctermbg=cyan
highlight DiffText                    guibg=Red          gui=bold                     ctermbg=red       cterm=bold
highlight Pmenu         guifg=black   guibg=LightBlue
highlight PmenuSel      guifg=White   guibg=DarkBlue                ctermfg=White     ctermbg=DarkBlue

highlight Cursor        guifg=black   guibg=yellow                  ctermfg=black     ctermbg=yellow
highlight lCursor       guifg=black   guibg=white                   ctermfg=black     ctermbg=white

highlight Comment       guifg=#80a0ff                               ctermfg=darkgrey
highlight Constant      guifg=#ffa0a0                               ctermfg=magenta                     cterm=none
highlight Special       guifg=Orange                      gui=none  ctermfg=brown                       cterm=none
highlight Identifier    guifg=#40ffff                               ctermfg=cyan                        cterm=none
highlight Statement     guifg=#ffff60                     gui=none  ctermfg=yellow                      cterm=none
highlight PreProc       guifg=#ff80ff                     gui=none  ctermfg=magenta                     cterm=none
highlight type          guifg=#60ff60                     gui=none  ctermfg=green                       cterm=none
highlight Underlined                                                                                    cterm=underline term=underline
highlight Ignore        guifg=bg                                    ctermfg=bg
