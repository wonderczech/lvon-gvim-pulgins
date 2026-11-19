" Vim color file - VS2026Theme
"
" Visual Studio 2026 "Dark" theme (theme {1DED0138-47CE-435E-84EF-9EC1F439B749}).
" Editor colors were read from screenshots of Tools > Options > Environment > Fonts and
" Colors > Text Editor (swatch pixel values of the items listed below); the settings file
" itself has no customised editor colors.
" Measured: Plain Text #dcdcdc on #1e1e1e, Keyword #569cd6, Keyword - Control #d8a0df,
" Comment #57a64a, String #d69d85, Number #b5cea8, Operator #b4b4b4, Punctuation #dcdcdc,
" Preprocessor Keyword #9b9b9b, XML Doc Comment #57a64a, Line Number (Current) #e0e0e0,
" Classes/Delegates #4ec9b0, Interfaces/Enums/Type Parameters #b8d7a3, Structures #86c691,
" Method #dcdcaa, Parameters/Locals #9cdcfe, Fields/Properties #dcdcdc.
" Everything that Visual Studio does not define (status line, tabs, popup menu, diff,
" folds, search, messages, ...) is re-used from vstudioDark.vim.
"
" Use:  :colorscheme VS2026Theme
" If you changed colors in Visual Studio, export them (Tools > Import and Export Settings >
" Export > Fonts and Colors) and the values here can be adjusted to match.

set background=dark

" base: everything not overridden below comes from vstudioDark
runtime colors/vstudioDark.vim

" --- Plain text, selection, line numbers -----------------------------------------
hi Normal       guifg=#dcdcdc guibg=#1e1e1e gui=NONE
hi LineNr       guifg=#2b91af guibg=#1e1e1e gui=NONE
hi CursorLineNr guifg=#e0e0e0 guibg=#1e1e1e gui=NONE
hi Visual       guifg=NONE    guibg=#264f78 gui=NONE
hi VisualNOS    guifg=NONE    guibg=#3f3f46 gui=NONE
hi MatchParen   guifg=NONE    guibg=#313f31 gui=bold

" --- Code classifications --------------------------------------------------------
hi Comment      guifg=#57a64a guibg=NONE gui=NONE
hi SpecialComment guifg=#57a64a guibg=NONE gui=NONE
hi Identifier   guifg=#dcdcdc guibg=NONE gui=NONE
hi Function     guifg=#dcdcaa guibg=NONE gui=NONE

hi Constant     guifg=#569cd6 guibg=NONE gui=NONE
hi String       guifg=#d69d85 guibg=NONE gui=NONE
hi Character    guifg=#d69d85 guibg=NONE gui=NONE
hi Number       guifg=#b5cea8 guibg=NONE gui=NONE
hi Float        guifg=#b5cea8 guibg=NONE gui=NONE
hi Boolean      guifg=#569cd6 guibg=NONE gui=NONE

hi Statement    guifg=#569cd6 guibg=NONE gui=NONE
hi Keyword      guifg=#569cd6 guibg=NONE gui=NONE
hi Conditional  guifg=#d8a0df guibg=NONE gui=NONE
hi Repeat       guifg=#d8a0df guibg=NONE gui=NONE
hi Exception    guifg=#d8a0df guibg=NONE gui=NONE
hi Label        guifg=#d8a0df guibg=NONE gui=NONE
hi Operator     guifg=#b4b4b4 guibg=NONE gui=NONE

hi Type         guifg=#569cd6 guibg=NONE gui=NONE
hi StorageClass guifg=#569cd6 guibg=NONE gui=NONE
hi Structure    guifg=#569cd6 guibg=NONE gui=NONE
hi Typedef      guifg=#569cd6 guibg=NONE gui=NONE

hi PreProc      guifg=#9b9b9b guibg=NONE gui=NONE
hi Include      guifg=#9b9b9b guibg=NONE gui=NONE
hi Define       guifg=#9b9b9b guibg=NONE gui=NONE
hi Macro        guifg=#9b9b9b guibg=NONE gui=NONE
hi PreCondit    guifg=#9b9b9b guibg=NONE gui=NONE

hi Special      guifg=#ffd68f guibg=NONE gui=NONE
hi SpecialChar  guifg=#ffd68f guibg=NONE gui=NONE
hi Delimiter    guifg=#dcdcdc guibg=NONE gui=NONE
hi Tag          guifg=#569cd6 guibg=NONE gui=NONE

" --- XML / XML documentation comments --------------------------------------------
hi xmlTag       guifg=#808080 guibg=NONE gui=NONE
hi xmlEndTag    guifg=#569cd6 guibg=NONE gui=NONE
hi xmlTagName   guifg=#569cd6 guibg=NONE gui=NONE
hi xmlAttrib    guifg=#92caf4 guibg=NONE gui=NONE
hi xmlString    guifg=#c8c8c8 guibg=NONE gui=NONE
hi xmlEqual     guifg=#808080 guibg=NONE gui=NONE
hi xmlComment   guifg=#57a64a guibg=NONE gui=NONE
hi csXmlComment guifg=#57a64a guibg=NONE gui=NONE
hi csXmlTag     guifg=#808080 guibg=NONE gui=NONE

" --- Semantic highlighting from the language server (vim-lsp) --------------------
" Only used when  let g:lsp_semantic_enabled = 1  is set in _vimrc. Vim's own C# syntax
" cannot tell user types or methods from plain words; csharp-ls can.
"   measured values as listed in the header; enum members and events were not measured
"   (enum members use the Enums color, events the plain text color)
hi LspSemanticType          guifg=#4ec9b0 guibg=NONE gui=NONE
hi LspSemanticClass         guifg=#4ec9b0 guibg=NONE gui=NONE
hi LspSemanticStruct        guifg=#86c691 guibg=NONE gui=NONE
hi LspSemanticTypeParameter guifg=#b8d7a3 guibg=NONE gui=NONE
hi LspSemanticInterface     guifg=#b8d7a3 guibg=NONE gui=NONE
hi LspSemanticEnum          guifg=#b8d7a3 guibg=NONE gui=NONE
hi LspSemanticEnumMember    guifg=#b8d7a3 guibg=NONE gui=NONE
hi LspSemanticMethod        guifg=#dcdcaa guibg=NONE gui=NONE
hi LspSemanticFunction      guifg=#dcdcaa guibg=NONE gui=NONE
hi LspSemanticParameter     guifg=#9cdcfe guibg=NONE gui=NONE
hi LspSemanticVariable      guifg=#9cdcfe guibg=NONE gui=NONE
hi LspSemanticProperty      guifg=#dcdcdc guibg=NONE gui=NONE
hi LspSemanticEvents        guifg=#dcdcdc guibg=NONE gui=NONE
hi LspSemanticNamespace     guifg=#dcdcdc guibg=NONE gui=NONE

" Tokens where the normal syntax colors are better: csharp-ls sends ONE token type for all
" keywords, which would turn if/for/return (purple, Keyword - Control) blue. These groups
" set no color, so the text property (it is combined with the syntax highlight) leaves the
" syntax color alone.
hi LspSemanticKeyword       guifg=NONE guibg=NONE gui=NONE
hi LspSemanticModifier      guifg=NONE guibg=NONE gui=NONE
hi LspSemanticComment       guifg=NONE guibg=NONE gui=NONE
hi LspSemanticString        guifg=NONE guibg=NONE gui=NONE
hi LspSemanticNumber        guifg=NONE guibg=NONE gui=NONE
hi LspSemanticOperator      guifg=NONE guibg=NONE gui=NONE
hi LspSemanticRegexp        guifg=NONE guibg=NONE gui=NONE
hi LspSemanticMacro         guifg=NONE guibg=NONE gui=NONE
hi LspSemanticDecorator     guifg=NONE guibg=NONE gui=NONE
hi LspSemanticStringEscapeCharacter guifg=NONE guibg=NONE gui=NONE

let g:colors_name = "VS2026Theme"
