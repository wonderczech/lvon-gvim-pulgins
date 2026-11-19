" My vim mappings and setting
"
" Maintainer:  Ladislav Vondracek <ladislav.vondracek@centrum.cz>
" Last change:  2010 Mar 24
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"        for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"      for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" LVON: first load standard windows shortcuts
source $VIMRUNTIME/mswin.vim
behave mswin

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup    " do not keep a backup file, use versions instead
else
  set backup    " keep a backup file
endif
set history=50    " keep 50 lines of command line history
set ruler    " show the cursor position all the time
set showcmd    " display incomplete commands
set incsearch    " do incremental searching

" LVON: set global backup and swap directories
let s:gvim_dir = $LOCALAPPDATA . '\gVim'

" Create directories
call mkdir(s:gvim_dir . '\backup', 'p')
call mkdir(s:gvim_dir . '\swap', 'p')
call mkdir(s:gvim_dir . '\view', 'p')

let &backupdir = s:gvim_dir . '\backup'
let &directory = s:gvim_dir . '\swap'
let &viewdir = s:gvim_dir . '\view'

"set backupdir=c:\Users\ladis\appdata\Local\gVim\backup
"set dir=c:\Users\ladis\appdata\Local\gVim\swap
"set viewdir=c:\Users\ladis\appdata\Local\gVim\view

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" LVON: plugins (vim-plug); :PlugInstall / :PlugUpdate / :PlugDiff / :PlugClean
" Plugins live in vimfiles\plugged; the older ones in vimfiles\ are untouched.
" plug#end() also runs "filetype plugin indent on".
call plug#begin('c:/Program Files (x86)/Vim/vimfiles/plugged')
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'preservim/nerdtree'
Plug 'tpope/vim-fugitive'
Plug 'vim-scripts/dbext.vim'
Plug 'vim-scripts/DirDiff.vim'
Plug 'tyru/open-browser.vim'
Plug 'vim-scripts/taglist.vim'
Plug 'godlygeek/tabular'
Plug 'preservim/vim-markdown'
call plug#end()

" LVON: language server (IntelliSense) for C# via csharp-ls
" (dotnet tool install -g csharp-ls). Check with :LspStatus.
" In a buffer with a running server:
"   Ctrl+X Ctrl+O or typing   completion (popup)
"   gd / F12  definition   Ctrl+F12  definition in split   gr / Shift+F12  references   Ctrl+Shift+F12  references without tests
"   [g / ]g  previous / next diagnostic
set completeopt=menuone,noinsert,popup
" semantic highlighting from the language server (types, methods as in Visual Studio; colors are
" the LspSemantic* groups of VS2026Theme). vim-lsp needs prop_add_list(), which this Vim 8.2.1775
" lacks, so it switches on by itself only in a newer Vim.
let g:lsp_semantic_enabled = exists("*prop_add_list")
" project root for csharp-ls: nearest folder above the file with a *.sln / *.slnx,
" else a *.csproj, else the file's own folder
function! LspCsRoot() abort
  let dir = substitute(expand('%:p:h'), '[\]', '/', 'g')
  for pat in ['*.sln', '*.slnx', '*.csproj']
    let d = dir
    while 1
      if !empty(glob(d . '/' . pat, 0, 1)) | return lsp#utils#path_to_uri(d) | endif
      let p = fnamemodify(d, ':h')
      if p ==# d | break | endif
      let d = p
    endwhile
  endfor
  return lsp#utils#path_to_uri(dir)
endfunction

if executable('csharp-ls')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'csharp-ls',
        \ 'cmd': {server_info->['csharp-ls']},
        \ 'root_uri': {server_info->LspCsRoot()},
        \ 'allowlist': ['cs'],
        \ })
endif

" Ctrl+F12: go to definition; a definition in another file opens in a new split, unless that
" file is already shown in a window (then the cursor moves there). Same file: just jumps.
function! s:DefSplitDone(data) abort
  let l:res = get(get(a:data, 'response', {}), 'result', [])
  if empty(l:res)
    echo 'No definition found'
    return
  endif
  let l:loc = type(l:res) == type([]) ? l:res[0] : l:res
  let l:uri = get(l:loc, 'targetUri', get(l:loc, 'uri', ''))
  let l:rng = get(l:loc, 'targetSelectionRange', get(l:loc, 'range', {}))
  let l:path = lsp#utils#uri_to_path(l:uri)
  let [l:line, l:col] = lsp#utils#position#lsp_to_vim(l:path, l:rng['start'])
  normal! m'
  let l:buf = bufnr(l:path)
  if l:buf != -1 && l:buf == bufnr('%')
  elseif l:buf != -1 && bufwinnr(l:buf) > 0
    execute bufwinnr(l:buf) . 'wincmd w'
  else
    execute 'split ' . fnameescape(l:path)
  endif
  call cursor(l:line, l:col)
endfunction

function! s:DefSplit() abort
  let l:servers = lsp#get_allowed_servers()
  if empty(l:servers)
    echo 'No language server for this buffer'
    return
  endif
  call lsp#send_request(l:servers[0], {
        \ 'method': 'textDocument/definition',
        \ 'params': {'textDocument': lsp#get_text_document_identifier(), 'position': lsp#get_position()},
        \ 'on_notification': {data->s:DefSplitDone(data)}})
endfunction

" Ctrl+Shift+F12: find references, but leave out the ones in test code, so the list shows
" production callers only. A reference is "test code" when a directory or the file name is
" Test / Tests (alone, or after . _ - or a lower-case letter/digit: Foo.Tests, UnitTests,
" FooTests.cs, Foo_test.cs). "Latest" or "Contests" do not match. Result goes to quickfix.
function! s:IsTestPath(path) abort
  let l:p = substitute(a:path, '\', '/', 'g')
  let l:parts = split(l:p, "/")
  if !empty(l:parts)
    let l:parts[-1] = fnamemodify(l:parts[-1], ":r")
  endif
  for l:part in l:parts
    if l:part =~# '\c\(^\|[._-]\)\(unit\|integration\|acceptance\)\?tests\?$' || l:part =~# '\C[a-z0-9]Tests\?$'
      return 1
    endif
  endfor
  return 0
endfunction

function! s:RefsNoTestsDone(data) abort
  let l:res = get(get(a:data, 'response', {}), 'result', [])
  let l:all = lsp#utils#location#_lsp_to_vim_list(l:res)
  let l:list = filter(copy(l:all), '!s:IsTestPath(v:val.filename)')
  if empty(l:list)
    echo empty(l:all) ? 'No references found' : 'All ' . len(l:all) . ' references are in tests'
    return
  endif
  normal! m'
  call lsp#ui#vim#utils#setqflist(l:list, 'references')
  botright copen
  echo len(l:list) . ' references (' . (len(l:all) - len(l:list)) . ' in tests hidden)'
endfunction

function! s:RefsNoTests() abort
  let l:servers = lsp#get_allowed_servers()
  if empty(l:servers)
    echo 'No language server for this buffer'
    return
  endif
  call lsp#send_request(l:servers[0], {
        \ 'method': 'textDocument/references',
        \ 'params': {'textDocument': lsp#get_text_document_identifier(), 'position': lsp#get_position(),
        \            'context': {'includeDeclaration': v:true}},
        \ 'on_notification': {data->s:RefsNoTestsDone(data)}})
endfunction

function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  setlocal signcolumn=yes
  nmap <buffer> gd <plug>(lsp-definition)
  nmap <buffer> <F12> <plug>(lsp-definition)
  nmap <buffer> <S-F12> <plug>(lsp-references)
  nmap <buffer> <C-F12> :call <SID>DefSplit()<CR>
  nmap <buffer> <C-S-F12> :call <SID>RefsNoTests()<CR>
  nmap <buffer> gr <plug>(lsp-references)
  nmap <buffer> K <plug>(lsp-hover)
  nmap <buffer> <leader>rn <plug>(lsp-rename)
  nmap <buffer> [g <plug>(lsp-previous-diagnostic)
  nmap <buffer> ]g <plug>(lsp-next-diagnostic)
endfunction

augroup lsp_install
  au!
  au User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" Side mouse buttons: back / forward through the jump list (after F12 / gd / gr, searches, ...)
" same as Ctrl+O / Ctrl+I
nnoremap <X1Mouse> <C-O>
nnoremap <X2Mouse> <C-I>

" Quickfix / location list: show file names relative to a project root instead of the long
" absolute path:  .\eqlineartrader\...\Controllers\ExternalOrdersController.cs
" The root is the nearest folder above the file that contains one of g:qf_root_markers
" (default: the git repository). For the solution folder use  ['*.sln', '*.slnx']  instead.
" Files outside any root keep their full path. Set  g:qf_root_markers = []  to switch it off.
if !exists("g:qf_root_markers")
  let g:qf_root_markers = ['.git']
endif
let s:qf_root_cache = {}

function! QfRoot(dir) abort
  if has_key(s:qf_root_cache, a:dir)
    return s:qf_root_cache[a:dir]
  endif
  let l:d = a:dir
  let l:root = ''
  while 1
    for l:m in g:qf_root_markers
      if !empty(glob(escape(l:d, '[]{}*?') . '/' . l:m, 1, 1))
        let l:root = l:d
        break
      endif
    endfor
    let l:up = fnamemodify(l:d, ':h')
    if l:root != '' || l:up ==# l:d
      break
    endif
    let l:d = l:up
  endwhile
  let s:qf_root_cache[a:dir] = l:root
  return l:root
endfunction

function! QfRelPath(path) abort
  if empty(g:qf_root_markers) || a:path == ''
    return a:path
  endif
  let l:full = fnamemodify(a:path, ':p')
  let l:root = QfRoot(fnamemodify(l:full, ':h'))
  if l:root == ''
    return a:path
  endif
  let l:root = substitute(l:root, '[\/]\+$', '', '')
  if tolower(strpart(l:full, 0, len(l:root))) ==# tolower(l:root)
    return '.' . strpart(l:full, len(l:root))
  endif
  return a:path
endfunction

" same layout as the default list:  file|lnum col| text
function! QfText(info) abort
  if a:info.quickfix
    let l:items = getqflist({'id': a:info.id, 'items': 1}).items
  else
    let l:items = getloclist(a:info.winid, {'id': a:info.id, 'items': 1}).items
  endif
  let l:out = []
  for l:i in range(a:info.start_idx - 1, a:info.end_idx - 1)
    let l:e = l:items[l:i]
    let l:name = l:e.bufnr > 0 ? QfRelPath(bufname(l:e.bufnr)) : ''
    let l:pos = ''
    if l:e.lnum > 0
      let l:pos = l:e.lnum . (l:e.col > 0 ? ' col ' . l:e.col : '')
    endif
    call add(l:out, l:name . '|' . l:pos . '| ' . l:e.text)
  endfor
  return l:out
endfunction
set quickfixtextfunc=QfText

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " vim-markdown
  let g:vim_markdown_folding_disabled = 1

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  "autocmd BufReadPost *
  "  \ if line("'\"") > 1 && line("'\"") <= line("$") |
  "  \   exe "normal! g`\"" |
  "  \ endif
  "

  augroup END

else

  set autoindent    " always set autoindenting on

endif " has("autocmd")

" NERDTree: Backspace moves to parent directory
let NERDTreeMapUpdirKeepOpen = '<BS>'
let NERDTreeMapChangeRoot = '<S-BS>'

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
"if !exists(":DiffOrig")
"  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
"      \ | wincmd p | diffthis
"endif

" LVON: Window settings
" -------------------

" au GUIEnter * simalt ~x " open gVim maximized
if has("gui_running")
  set lines=45 columns=160
endif
set guioptions+=b " open with bottom scrollbar
set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
let g:netrw_altv = 1 " open document from Explore in vertical window
set guitablabel=%t%{GuiTabLabel()} " vim tabs with file name only and 'unsaved' indicator

" LVON: status line with the git branch (vim-fugitive); always visible
" %<                      truncate here if the line is too long
" %f                      file path
" %h %m %r                help / modified [+] / read-only flags
" %{fugitive#statusline()} git branch, e.g. [Git(main)]; empty outside a repo
" %=                      switch to the right-aligned part
" %-14.(%l,%c%V%)         line, column, virtual column (the ruler part)
" %P                      percent through the file
set laststatus=2
set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P

" disable annoying beeps
" set vb t_vb=
set noeb vb t_vb=
au GUIEnter * set vb t_vb=

" LVON: Enviroment settings
" -------------------
"colorscheme vstudioDark
colorscheme VS2026Theme
"set guifont=Consolas:b:h9:cEASTEUROPE
"set guifont=Consolas:h8:cEASTEUROPE
"set guifont=Consolas:h9:cEASTEUROPE
"set guifont=Cascadia\ Mono:h9:cEASTEUROPE
set guifont=Cascadia_Code_Semibold:h10:cEASTEUROPE

" Ctrl + mouse wheel changes the font size (up = larger, down = smaller, 6-32 pt);
" Ctrl + middle button returns to the size set above. Affects the whole gVim, not one window.
let g:font_default = &guifont
function! FontZoom(delta) abort
  if !has("gui_running")
    return
  endif
  let l:size = matchstr(&guifont, ':h\zs\d\+')
  if l:size == ''
    return
  endif
  let l:new = max([6, min([32, l:size + a:delta])])
  let &guifont = substitute(&guifont, ':h\d\+', ':h' . l:new, '')
  echo 'font size ' . l:new
endfunction
nnoremap <silent> <C-ScrollWheelUp>   :call FontZoom(1)<CR>
nnoremap <silent> <C-ScrollWheelDown> :call FontZoom(-1)<CR>
inoremap <silent> <C-ScrollWheelUp>   <C-O>:call FontZoom(1)<CR>
inoremap <silent> <C-ScrollWheelDown> <C-O>:call FontZoom(-1)<CR>
vnoremap <silent> <C-ScrollWheelUp>   :<C-U>call FontZoom(1)<CR>gv
vnoremap <silent> <C-ScrollWheelDown> :<C-U>call FontZoom(-1)<CR>gv
nnoremap <silent> <C-MiddleMouse> :let &guifont = g:font_default<CR>
set linespace=0
"set encoding=cp1250
set encoding=utf-8

set so=1 " cursor context (minimum of lines before and after cursor)
set ignorecase
set gdefault " replace all instances in the line
set whichwrap=b,s,<,>,[,]
set nowrap!
set expandtab! " syntaxing format
set tabstop=4 " tab = 4 spaces
set shiftwidth=4
set cindent
set iskeyword+=192-255 " Czech characters are part of words
set autochdir " file's directory is the working directory
set nu!

let g:DirDiffExcludes = "*.exe,.*.swp,*.lnk,*.dll,*.pdb,*.cache,*.suo"

" NERDTree ignore list
let NERDTreeIgnore=['\.dll$', '\.exe$', '\.pdf$', '\.jpg$', '\.gif$', '\.png$', '\.ico$', '\.lnk$', '\.pdb$', '\.cache$', '\.suo$']
" NERDTree sort order list
let NERDTreeSortOrder=['\/$', 'makefile', '*', '\.swp$',  '\.bak$', '\~$']


" LVON: Editor settings
" -------------------

" fix wrong syntax displaying
" autocmd BufEnter * :syntax sync fromstart

" default dialect for sql
let g:sql_type_default = 'sqlserver'

set tabpagemax=100
" if (&diff==0)
"   autocmd BufReadPost * tab ball
" endif
if (&diff==0)
  silent! argument-list | silent! tab all
endif

"load dbext profiles
"source c:\Users\ladis\appdata\Local\gVim\dbext_profiles.vim
"execute 'source ' . fnameescape(s:gvim_dir . '\dbext_profiles.vim')

" TODO: set default compiler
compiler nmake
set makeprg=nmake
set makeef=errmake

" save/load folds automatically
"au BufWinLeave *.* mkview
"au BufWinEnter *.* silent loadview

au BufNewFile,BufRead *.cs
  \ imap <kDivide><kDivide><kDivide> <Esc>:call GenerateDocumentation()<CR>a

set langmenu=en_US
let $LANG = 'en_US'
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim

" LVON: user commands
" -----------------

" formats xml document file (requires Windows xmllint.exe)
:command! XmlFormat execute MyXmlFormat()

" git (fugitive): open the current file in a new tab
command! Gtabdiff tabnew % | Gdiffsplit
command! Gtd tabnew % | Gdiffsplit
command! Gtab tabnew % | Git
command! Gt tabnew % | Git

" PowerShell consoles in a terminal window
command! PS botright terminal ++rows=15 powershell
command! PS7 botright terminal ++rows=15 pwsh

" LVON: build with msbuild / dotnet; runs in the background, output streams live
" into the quickfix window (cn / cp, Enter jumps to an error)
" :Msbuild [args]  runs msbuild on the nearest default.proj above the current file
"                  :Msbuild                     msbuild default.proj
"                  :Msbuild /t:EfsUnitTests     also /t:EfsSystemTests, /t:EfsDownloadNuget
" :Dotnet [args]   runs dotnet in the folder of the nearest *.sln above the current file;
"                  without args it does "build"
"                  :Dotnet                      dotnet build
"                  :Dotnet test -m:1            :Dotnet run --project <csproj>
" :BuildStop       stops the running build
let g:build_efm = ' %#%f(%l\,%c): %t%*[a-z] %m, %#%f(%l): %t%*[a-z] %m, %m in %f:line %l'
let g:build_job = v:null

function! BuildAppend(id, msg) abort
  let line = substitute(a:msg, '\r$', '', '')
  call setqflist([], 'a', {'id': a:id, 'lines': [line], 'efm': g:build_efm})
  let w = getqflist({'id': a:id, 'winid': 0}).winid
  if w != 0 | call win_execute(w, 'normal! G') | endif
endfunction

function! BuildDone(id, code, cmd) abort
  let items = getqflist({'id': a:id, 'items': 1}).items
  let ne = len(filter(copy(items), 'v:val.valid && v:val.type ==? "e"'))
  let nw = len(filter(copy(items), 'v:val.valid && v:val.type ==? "w"'))
  call setqflist([], 'a', {'id': a:id, 'title': a:cmd . '  [exit ' . a:code . ']'})
  echo 'Build finished, exit code ' . a:code . ': ' . ne . ' errors, ' . nw . ' warnings (' . a:cmd . ')'
endfunction

function! BuildStop() abort
  if g:build_job isnot v:null && job_status(g:build_job) ==# 'run'
    call job_stop(g:build_job)
    echo 'Build stopped'
  else
    echo 'No build is running'
  endif
endfunction

function! BuildUp(pre, patterns, usefile, defargs, args) abort
  let start = substitute(expand('%:p:h'), '[\]', '/', 'g')
  if empty(start) | let start = substitute(getcwd(), '[\]', '/', 'g') | endif
  let best = ''
  " nearest match going up from the current file
  let dir = start
  while empty(best)
    for pat in a:patterns
      let m = glob(dir . '/' . pat, 0, 1)
      if !empty(m) | let best = m[0] | break | endif
    endfor
    let parent = fnamemodify(dir, ':h')
    if parent ==# dir | break | endif
    let dir = parent
  endwhile
  " nothing above (e.g. started in the repo root): look up to 6 levels below
  if empty(best)
    for d in range(1, 6)
      for pat in a:patterns
        let m = globpath(start, repeat('*/', d) . pat, 0, 1)
        if !empty(m) | let best = m[0] | break | endif
      endfor
      if !empty(best) | break | endif
    endfor
  endif
  if empty(best)
    echoerr 'No ' . join(a:patterns, ' / ') . ' found above or below ' . start
    return
  endif
  let best = fnamemodify(best, ':p')
  let args = substitute(a:args, '^\s\+\|\s\+$', '', 'g')
  let cmd = a:pre . (a:usefile ? ' ' . fnamemodify(best, ':t') : '')
        \ . ' ' . (empty(args) ? a:defargs : args)
  let wdir = fnamemodify(best, ':h')

  if g:build_job isnot v:null && job_status(g:build_job) ==# 'run'
    call job_stop(g:build_job)
  endif
  call setqflist([], ' ', {'title': cmd . '  [running in ' . wdir . ']', 'efm': g:build_efm})
  let id = getqflist({'id': 0}).id
  botright copen 10
  wincmd p
  echo 'Running: ' . cmd . '   in ' . wdir
  let g:build_job = job_start('cmd /c ' . cmd, {
        \ 'cwd': wdir, 'in_io': 'null', 'err_io': 'out',
        \ 'out_mode': 'nl', 'err_mode': 'nl',
        \ 'out_cb': {ch, msg -> BuildAppend(id, msg)},
        \ 'exit_cb': {j, code -> timer_start(200, {-> BuildDone(id, code, cmd)})}})
endfunction

command! -nargs=* Msbuild call BuildUp('msbuild /nologo /v:m /property:GenerateFullPaths=true', ['default.proj'], 1, '', <q-args>)
command! -nargs=* Dotnet  call BuildUp('dotnet', ['*.sln', '*.slnx'], 0, 'build', <q-args>)
command! BuildStop call BuildStop()

" LVON: Key maps:
" File Navigation
" -------------------

" autoread the file on change
map auto :set autoread \| au CursorHold * checktime \| call feedkeys("lh")<CR>

" Highlight lines added/changed when a buffer is reloaded by 'autoread'.
" Marks stay until the next reload; clear them with :ReloadClear.
let s:reloadhl_max_lines = 50000

function! s:ReloadHlColors() abort
  hi default ReloadAdd    guibg=#1f5f3a ctermbg=22
  hi default ReloadChange guibg=#6b5a12 ctermbg=94
endfunction

call s:ReloadHlColors()
sign define ReloadAdd    text=+ texthl=ReloadAdd    linehl=ReloadAdd
sign define ReloadChange text=~ texthl=ReloadChange linehl=ReloadChange

function! s:ReloadHlSnapshot() abort
  if line('$') <= s:reloadhl_max_lines
    let b:reloadhl_snap = getline(1, '$')
  else
    unlet! b:reloadhl_snap
  endif
endfunction

function! s:ReloadHlClear() abort
  call sign_unplace('reloadhl', {'buffer': bufnr('%')})
endfunction

function! s:ReloadHlPlace(first, count, name) abort
  for l in range(a:first, a:first + a:count - 1)
    call sign_place(0, 'reloadhl', a:name, bufnr('%'), {'lnum': l})
  endfor
endfunction

function! s:ReloadHlMark() abort
  call s:ReloadHlClear()
  if !exists('b:reloadhl_snap')
    return s:ReloadHlSnapshot()
  endif
  let new = getline(1, '$')
  if executable('git')
    let a = tempname() | let b = tempname()
    call writefile(b:reloadhl_snap, a)
    call writefile(new, b)
    let out = systemlist('git diff --no-index --no-color --unified=0 '
          \ . shellescape(a) . ' ' . shellescape(b))
    call delete(a) | call delete(b)
    for l in out
      let m = matchlist(l, '^@@ -\d\+\%(,\(\d\+\)\)\= +\(\d\+\)\%(,\(\d\+\)\)\= @@')
      if empty(m) | continue | endif
      let old_n = m[1] ==# '' ? 1 : str2nr(m[1])
      let new_n = m[3] ==# '' ? 1 : str2nr(m[3])
      if new_n > 0
        call s:ReloadHlPlace(str2nr(m[2]), new_n, old_n == 0 ? 'ReloadAdd' : 'ReloadChange')
      endif
    endfor
  elseif len(new) > len(b:reloadhl_snap)
    call s:ReloadHlPlace(len(b:reloadhl_snap) + 1, len(new) - len(b:reloadhl_snap), 'ReloadAdd')
  endif
  call s:ReloadHlSnapshot()
endfunction

augroup ReloadHighlight
  autocmd!
  " A reload fires BufReadPost too; keep the old snapshot so it can be diffed.
  autocmd BufReadPost  * if !exists('b:reloadhl_snap') | call s:ReloadHlSnapshot() | endif
  autocmd BufWritePost * call s:ReloadHlSnapshot()
  autocmd FileChangedShellPost * call s:ReloadHlMark()
  autocmd ColorScheme  * call s:ReloadHlColors()
augroup END

command! ReloadClear call s:ReloadHlClear()

" open explorer in split window
map <silent> sex :let t:this = expand("%:t")<CR>:NERDTreeToggle<CR>\|:call search(t:this)<CR>

" open help in new tab
map <F1>  yiw\|:exec ":tab h ".@0<CR>
imap <F1> <Esc>yiw\|:exec ":tab h ".@0<CR>

" open NERDTree
map <F3> sex
imap <F3> <Esc>sex

" open Explore in new tab
map <S-F3> :tabnew<CR>\|sex
imap <S-F3> <Esc>:tabnew<CR>\|sex

" open new file in new tab
map <S-F4> :tabnew\|enew<CR>
imap <S-F4> <Esc>:tabnew\|enew<CR>

" switch between tabs
map <C-Tab> :tabn<CR>
imap <C-Tab> <Esc>:tabn<CR>a
smap <C-Tab> <Esc>:tabn<CR>
map <S-C-Tab> :tabp<CR>
imap <S-C-Tab> <Esc>:tabp<CR>a
smap <S-C-Tab> <Esc>:tabp<CR>

" search pattern in files, search next, search previous
map grep :call MyGrep()<CR>
map cn :cn<CR>
map cp :cN<CR>

" tick checkbox in markdown file
map cx :call ToggleMarkdownCheckbox()<CR>

" open tag explorer
map <C-F3> :TlistToggle<CR>
imap <C-F3> <Esc>:TlistToggle<CR>a

" LVON: Key maps:
" Moves
" -------------------
" navigation keys - word jump
map <C-Right> w
map <C-Left> b
imap <C-Left> <Esc><Right>bi
imap <C-Right> <Esc><Right>wi

" navigation keys in visual mode
xmap <left> h
xmap <right> l
xmap <up> k
xmap <down> j

" LVON: Key maps:
" Editing shorcuts
" -------------------

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot. Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" delete word in insert mode
imap <C-Del> <Esc><Right>dwi

" delete word in command mode
map <C-Del> dw

" intend block with tabelator
vmap <Tab> >gv
vmap <S-Tab> <gv

" change letter case
nmap L guaw
xmap L gu
nmap U gUaw
xmap U gU

" increase and decrease numeric constant
nmap <C-kPlus> :exec ":nunmap \<C-A\>"<CR><C-A>:exec ":nmap \<C-A\> gggH\<C-O\>G"<CR>
nmap <C-kMinus> <C-X>

" folding using /search/ pattern
" \z
" This folds every line that does not contain the search pattern.
" see vimtip #282 and vimtip #108
map <silent><leader>z :set foldexpr=getline(v:lnum)!~@/ foldlevel=0 foldcolumn=0 foldmethod=expr<CR>

" LVON: Key maps:
" Macros and commands
" -------------------

" save file
map <F2> :w<CR>
imap <F2> <Esc>:w<CR>a
map <S-F2> :w!<CR>
imap <S-F2> <Esc>:w!<CR>a
" map <S-F2> :silent wa<CR>
" imap <S-F2> <Esc>:silent wa<CR>a

" close file
map <F10> :q<CR>
imap <F10> <Esc>:q<CR>

" force close file
map <S-F10> :q!<CR>
imap <S-F10> <Esc>:q!<CR>

" save session
let s:session_file = s:gvim_dir . '\session.vimsession'

" Save session using F6
execute 'nnoremap <F6> :mksession! ' . fnameescape(s:session_file) . '<CR>'
execute 'inoremap <F6> <Esc>:mksession! ' . fnameescape(s:session_file) . '<CR>a'

"map <F6> :mksession! c:\Users\ladis\appdata\Local\gVim\session.vimsession<CR>
"imap <F6> <Esc>:mksession! c:\Users\ladis\appdata\Local\gVim\session.vimsession<CR>a

" toggle line numbers
map <F4> :set nu!<CR>
imap <F4> <Esc>:set nu!<CR>a

" show all instances of the word under cursor
map find [I

" search and replace
map rep :call MySearchReplace()<CR>
vmap rep :call MySearchReplace()<CR>

" remove end of line white spaces
map eol :%s /\s\+$//<CR>

" fold into search
map fold \z
" unfold
map unfold zR

" split window
map <S-C-Tab> :wincmd w<CR>
map <S-C-Tab> <Esc>:wincmd w<CR>

" compare two documents
map comp :vert diffsplit 

" execute SQL command
map <F5> :DBExecSQLUnderCursor<CR>
imap <F5> <Esc>:DBExecVisualSQL<CR>
smap <F5> <Esc>:DBExecVisualSQL<CR>

" refresh changes
map <C-F5> :diffupdate<CR>
imap <C-F5> <Esc>:diffupdate<CR>
map ss :tearoff Plugin.dbext<CR>

" toggle SQL syntax
map s+ :set syn=sqlserver<CR>
map sě :set syn=plsql<CR>
map sš :set syn=sqloracle<CR>

" toggle encoding
map e+ :set encoding=cp1250<CR>
map eě :set encoding=utf-8<CR>
map eš :silent call OpenUtf16leFile()<CR>

" set to maximized windows
map <C-CR> :silent call SetMaxWindow()<CR>

"toggle GUI
map <A-F1> :silent call ToggleMenuBar()<CR>
map <A-F2> :silent call ToggleToolBar()<CR>

" LVON: Functions
" -------------------

function LoadSessionGUI()
  if confirm("Load saved session?", "&Yes\n&No") == 1
    " source $VIM\vimfiles\session.vimsession
    " source c:\Users\ladis\appdata\Local\gVim\session.vimsession
    execute 'source ' . fnameescape(s:session_file)
  endif
endfunction

function MyXmlFormat()
  execute ':% !xmllint.exe % --format'
  silent execute ':%s /  / '
  silent execute ':%s / \/>/\/>'
  echo 'XML formatting complete'
endfunction

function GuiTabLabel()
  let label = ''
  let bufnrlist = tabpagebuflist(v:lnum)

  " Append the number of windows in the tab page if more than one
  let wincount = tabpagewinnr(v:lnum, '$')
  if wincount > 1
    let label .= '(' . wincount . ')'
  endif

  " Add '+' if one of the buffers in the tab page is modified
  for bufnr in bufnrlist
    if getbufvar(bufnr, "&modified")
      let label = '+'
      break
    endif
  endfor

  if label != ''
    let label = ' ' . label
  endif

  " Append the buffer name
  " return bufname(bufnrlist[tabpagewinnr(v:lnum) - 1]) . label
    return label
endfunction

function MyGrep()
  let arg1 = input('Pattern to search:')
  let arg2 = input('File mask (** for subdirs):')
  if arg2 == '' | let arg2 = '*' | endif
  " TODO:
  "try
    execute ':vimgrep /'.arg1.'/'.arg2
    silent! exe 'g/'.arg1
    copen
  "catch
    "echo 'Pattern not found'
  "endtry
endfunction

function MyGrepGUI(par)
  let dir = substitute(a:par,"\\\\$","","e")
  let arg1 = inputdialog('Pattern to search:')
  if arg1 == '' | return 0 | endif
  let arg2 = inputdialog('File mask:')
  if arg2 == '' | let arg2 = '*' | endif
  try
    execute ':vimgrep /'.arg1.'/'.dir.'**\'.arg2
    copen
  catch
    echo 'Pattern not found'
  endtry
endfunction

function MySearchReplace()
  let arg1 = input('Pattern to replace:')
  let arg2 = input('Replace with:')
  try
    execute ':%s /'.arg1.'/'.arg2
  catch
    echo 'Pattern not found'
  endtry
endfunction

function GenerateDocumentation()
  " issues:
  " - does not recognize file type / language -> applies in any open file
  " - does not recognize return type need for public access methods without "()" in C#
  " - does not recognize multiline function header
  " - funcPatt matches some other constructions fe "return a.ToString();"
  let funcPatt = "^\\s*\\k\\+\\ [a-zA-Z0-9_\\ <>.]*\\i\\+\\s*(.*)\\(\\s*\\n*\\)*[{;]"
  let paramPatt = "\\<\\w*\\s*,\\|\\<\\w*\\s*)"
  let prevLine = getline(prevnonblank("."))
  let nextLine = getline(nextnonblank("."))
  let intend = repeat(" ", match(nextLine, "\\S"))
  let paramNum = 1

  "if this line is not empty
  if match(getline("."), "^\\s*/*\\s*$") < 0
    exe "normal a///"

  "if previous line is part of documentation comment
  elseif match(prevLine, "^\\s*///") > -1
    exe "normal a///"

  "if next line is a comment
  elseif match(nextLine, "^\\s*\\(//*\\**\\)") > -1
    exe "normal a///"

  else
    call setline(".", intend."/// <summary>")
    let lineList = [ intend."/// ", intend."/// </summary>"  ]

    "if next line seems to be a function header
    if match(nextLine, funcPatt) > -1
      "if there is anything between ()
      if match(nextLine, "(\\s*)") < 0
        let params = matchstr(nextLine, "(.*)")
        let param = matchstr(params, paramPatt)
        while param != ""
          echo param
          let lineList += [ intend."/// <param name=\"".matchstr(param, "\\w*")."\"></param>" ]
          let paramNum += 1
          let param = matchstr(params, paramPatt, 0, paramNum)
        endwhile
      endif

      "if the function does not return void
      if match(nextLine, "\\<void\\>.*(") < 0
        let lineList += [ intend."/// <returns></returns>" ]
      endif
    endif

    call append(".", lineList)
    call cursor(line(".") +1, len(intend) +4)
  endif
endfunction

function ConsoleEncodingChange()
  "let cur_buf = bufnr("%")
  "silent! exec bufnr("quickfix").'buffer'
  setlocal modifiable
  silent! exe 'g/^.*$/s//\=iconv(getline(".") , "cp852", &enc)'
  silent! exe 'g/$^'
  setlocal nomodified
  "silent! exec cur_buf.'buffer'
endfunction

function SetMaxWindow()
  if has("gui_running")
    simalt ~x
  endif
endfunction

function ToggleMenuBar()
  if &guioptions =~# 'm'
    silent set guioptions-=m
  else
    silent set guioptions+=m
  endif
endfunction

function ToggleToolBar()
  if &guioptions =~# 'T'
    silent set guioptions-=T
  else
    silent set guioptions+=T
  endif
endfunction

function OpenUtf16leFile()
  set encoding=utf-8
  set fileencoding=utf-16le
  edit!
endfunction

function! ToggleMarkdownCheckbox()
    let l:line = getline('.')
    let l:cursor = col('.') - 1

    " Find checkbox whose [, space/x/X, or ] is under the cursor
    let l:start = match(l:line, '\[[ xX]\]')

    if l:start >= 0
        \ && l:cursor >= l:start
        \ && l:cursor <= l:start + 2

        let l:checkbox = strpart(l:line, l:start, 3)

        if l:checkbox ==# '[ ]'
            let l:new_checkbox = '[x]'
        else
            let l:new_checkbox = '[ ]'
        endif

        call setline('.',
            \ strpart(l:line, 0, l:start)
            \ . l:new_checkbox
            \ . strpart(l:line, l:start + 3))

        return ''
    endif

    " Normal Enter behaviour
    return "\<CR>"
endfunction

if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif
