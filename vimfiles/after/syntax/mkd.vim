" Correctly recognise inline code ending with a Windows backslash.
" Example: `%LOCALAPPDATA%\SupportPortal\`
syntax match mkdCode /`[^`\r\n]*\\`/ oneline
highlight default link mkdCode mkdCode

" Do not treat intra-word underscores (snake_case, Increase_decrease,
" optimization_id) as italic delimiters. The stock rule starts an italic region
" at any "_" followed by a space later on the line, and that region swallows
" any `code span` opening inside it, so the code highlight only began at the
" closing backtick.
" An underscore opens italics only at line start or after a non-word character,
" and closes only when not followed by a word character.
"
" Bold and bold-italic are redefined after italic (unchanged patterns): at the
" same position the item defined last wins, so they must stay behind italic as
" in the stock syntax file, otherwise "**" and "__" would turn italic.
syntax clear htmlItalic htmlBold htmlBoldItalic
syntax region htmlItalic start="\\\@<!\*\S\@=" end="\S\@<=\\\@<!\*" keepend oneline
syntax region htmlItalic start="\(^\|[^[:alnum:]_\\]\)\@<=_\S\@=" end="\S\@<=_\w\@!" keepend oneline
syntax region htmlBold start="\S\@<=\*\*\|\*\*\S\@=" end="\S\@<=\*\*\|\*\*\S\@=" keepend oneline
syntax region htmlBold start="\S\@<=__\|__\S\@=" end="\S\@<=__\|__\S\@=" keepend oneline
syntax region htmlBoldItalic start="\S\@<=\*\*\*\|\*\*\*\S\@=" end="\S\@<=\*\*\*\|\*\*\*\S\@=" keepend oneline
syntax region htmlBoldItalic start="\S\@<=___\|___\S\@=" end="\S\@<=___\|___\S\@=" keepend oneline
