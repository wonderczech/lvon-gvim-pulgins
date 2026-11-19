# gVim setup — cheat sheet

Reference for the mappings and commands defined in [`_vimrc`](_vimrc). Line numbers
refer to `_vimrc` at the time of writing (backups: `_vimrc.bak-*`).

- Vim 8.2 in `vim82\`, plugins and colors in `vimfiles\`
- Colorscheme `vstudioDark`, font Cascadia Code 8, UTF-8
- `mswin.vim` + `behave mswin` are loaded first, so the usual Windows shortcuts work
  (Ctrl+C/X/V, Ctrl+S, Ctrl+Z/Y, Ctrl+A, Ctrl+Q = visual block, Ctrl+F4 = close window)
- Leader key is the default `\`

> **Tip:** to see what a key does and where it was defined, run `:verbose map <key>`.
> To list everything: `:map`.

## How the word-style mappings work

Many mappings below are *words* (`grep`, `rep`, `sex`, ...), not key chords. Type them
quickly in **Normal mode**, no `:` and no Enter. They are defined with `:map`, so they
also fire in Visual and Operator-pending mode. Because they start with real Vim commands
(`s`, `c`, `e`, `f`, `m`...), a lone first letter waits for `timeoutlen` (1 s by default)
before acting.

---

## Function keys

| Key | Mode | Action |
|---|---|---|
| `F1` | n, i | Open Vim help for the word under the cursor in a new tab |
| `F2` | n, i | Save (`:w`) |
| `Shift+F2` | n, i | Force save (`:w!`) |
| `F3` | n, i | Toggle NERDTree (file explorer) and jump to the current file |
| `Shift+F3` | n, i | New tab, then open NERDTree in it |
| `F4` | n, i | Toggle line numbers |
| `Ctrl` + mouse wheel | n, i, v | Font size larger / smaller (6-32 pt, whole gVim); `Ctrl` + middle button resets it |
| `Shift+F4` | n, i | New empty tab |
| `F5` | n | `:DBExecSQLUnderCursor` (needs the **dbext** plugin, see *Not working*) |
| `F5` | i, s | `:DBExecVisualSQL` (dbext) |
| `Ctrl+F5` | n, i | `:diffupdate`, refresh diff highlighting after edits |
| `F6` | n, i | Save session to `C:\Users\vondracl\appdata\Local\gVim\session.vimsession` |
| `F10` | n, i | Quit (`:q`) |
| `Shift+F10` | n, i | Quit without saving (`:q!`) |
| `Ctrl+F3` | n, i | `:TlistToggle` tag explorer (needs the **taglist** plugin, see *Not working*) |
| `Ctrl+Enter` | n | Maximize the gVim window |
| `Alt+F1` | n | Toggle the menu bar |
| `Alt+F2` | n | Toggle the toolbar |

## Tabs and windows

| Key | Action |
|---|---|
| `Ctrl+Tab` | Next tab |
| `Ctrl+Shift+Tab` | Next **window** (see *Gotchas*: previous-tab mapping is overridden) |
| `sex` | NERDTree toggle, then jump to the current file's entry |
| `comp` | Starts `:vert diffsplit ` and waits for you to type the other file |
| `ss` | `:tearoff Plugin.dbext` (dbext menu) |

## Search, replace, quickfix

| Type | Action |
|---|---|
| `grep` | Prompts for a pattern and a file mask (`**` for subdirectories, e.g. `**/*.cs`, empty = `*`), runs `:vimgrep` and opens the quickfix list |
| `cn` | Next quickfix result (`:cn`) |
| `cp` | Previous quickfix result (`:cN`) |
| (quickfix paths) | File names in quickfix and location lists are shown relative to the git repository (`.\eqlineartrader\...\File.cs`). `let g:qf_root_markers = ['*.sln', '*.slnx']` makes them relative to the solution folder, `[]` shows full paths |
| `find` | List all lines containing the word under the cursor (`[I`) |
| `rep` | Prompts for a pattern and replacement, runs `:%s/pattern/replacement` over the whole file. `gdefault` is on, so every match on a line is replaced |
| `eol` | Remove trailing whitespace in the whole file |
| `fold` | Fold away every line that does not match the current search (`\z`) |
| `unfold` | Open all folds (`zR`) |
| `\z` | Same as `fold` |

## Editing

| Key | Mode | Action |
|---|---|---|
| `Q` | n | Format text (`gq`), not Ex mode |
| `L` | n | Lowercase the word under the cursor (replaces built-in `L`) |
| `L` | v | Lowercase the selection |
| `U` | n | Uppercase the word under the cursor (replaces built-in line-undo `U`) |
| `U` | v | Uppercase the selection |
| `Tab` / `Shift+Tab` | v | Indent / unindent the selection and keep it selected |
| `Ctrl+Left` / `Ctrl+Right` | n, i | Jump one word back / forward |
| `Ctrl+Del` | n, i | Delete to the end of the word |
| `Ctrl+NumPad+` / `Ctrl+NumPad-` | n | Increment / decrement the number under the cursor |
| `Ctrl+U` | i | Delete to line start, but undo-able in one step |
| `cx` | n | Toggle a Markdown checkbox `[ ]` / `[x]`. The cursor must be on the three characters of the checkbox |
| `NumPad / / /` | i, `*.cs` only | Insert a C# XML doc comment (`<summary>`, `<param>`, `<returns>`) for the function below |
| Arrow keys | v | Move the cursor (`h` `j` `k` `l`) |

## Syntax and encoding

On the Czech keyboard the unshifted number row starts `+` `ě` `š`, so these are the keys `1`, `2`, `3`.

| Type | Action |
|---|---|
| `s+` (`s` `1`) | SQL syntax: SQL Server |
| `sě` (`s` `2`) | SQL syntax: PL/SQL |
| `sš` (`s` `3`) | SQL syntax: Oracle SQL |
| `e+` (`e` `1`) | Set encoding to `cp1250` |
| `eě` (`e` `2`) | Set encoding to `utf-8` |
| `eš` (`e` `3`) | Reload the file as UTF-16LE |

## Build

Run from any file inside the repo. The project is searched upwards from the current file, then up to
6 levels below its folder (so it also works from the repo root). The build runs in that project's folder
**in the background**: Vim stays usable and the output streams live into the quickfix window
(`cn` / `cp`, `Enter` jumps to an error). When it ends, the command line shows the exit code and the
number of errors and warnings. Extra arguments are passed through to the tool.

| Command | Runs | Examples |
|---|---|---|
| `:Msbuild [args]` | `msbuild /nologo /v:m /property:GenerateFullPaths=true default.proj [args]` (nearest `default.proj`) | `:Msbuild`, `:Msbuild /t:EfsUnitTests`, `:Msbuild /t:EfsSystemTests`, `:Msbuild /t:EfsDownloadNuget` |
| `:Dotnet [args]` | `dotnet [args]` in the folder of the nearest `*.sln` / `*.slnx`; no args = `build` | `:Dotnet`, `:Dotnet test -m:1`, `:Dotnet run --project <csproj>` |
| `:BuildStop` | Stop the running build | |

Starting a new build stops the previous one. Nothing is saved automatically: write your buffers first
(`F2`, or `:wa`). Pass `/v:n` to `:Msbuild` for more output. Output with national characters may be
garbled (console code page). The old `make` / `F9` mapping (nmake) was removed.

## Git (fugitive)

| Command | Action |
|---|---|
| `:Gtabdiff` / `:Gtd` | Open the current file in a new tab and diff it against the index (`tabnew % \| Gdiffsplit`) |
| `:Gtab` / `:Gt` | Open the current file in a new tab with the fugitive status window (`tabnew % \| Git`) |

## Commands (`:`)

| Command | Action |
|---|---|
| `:ReloadClear` | Remove the green/amber marks left by auto-reload highlighting (below) |
| `:XmlFormat` | Pretty-print the XML buffer through `xmllint.exe` (must be on `PATH`) |
| `:DiffOrig` | Diff the buffer against the file on disk (see what you changed) |
| `:DirDiff dirA dirB` | Directory diff (dirdiff plugin; excluded: `*.exe`, `*.dll`, `*.pdb`, ...) |

## Auto-reload with change highlighting

1. Type `auto` in Normal mode. This sets `autoread` and runs `:checktime` on every
   `CursorHold`, so externally modified files reload by themselves (logs, tail-like use).
2. After a reload, lines that were **added** get a green `+` mark and lines that were
   **changed** get an amber `~` mark.
3. Marks stay until the next reload. `:ReloadClear` removes them early.

Details and limits:

- Uses `git diff --no-index`, so `git` has to be on `PATH`. Without it only lines appended at
  the end are marked.
- Only works when the buffer has no unsaved edits; otherwise Vim shows its normal
  "file changed" prompt.
- The snapshot is taken on first load and after every save. A manual `:e!` does not refresh it,
  so the next auto-reload may mark more than the latest change.
- Files over 50 000 lines are skipped.
- Colors are the `ReloadAdd` and `ReloadChange` highlight groups at the top of the reload block in `_vimrc` (after the `auto` mapping).

## Gotchas

- **`Ctrl+Shift+Tab`**: first defined as "previous tab" (lines 296–298), then redefined as
  "next window" (lines 406–407). The later `map` wins in Normal/Visual mode; only Insert mode
  still goes to the previous tab.
- **`L`, `U`, `Q`** replace the built-in commands (`L` bottom of window, `U` undo line, `Q` Ex mode).
- **`cn` / `cp`** shadow `c` + motion combos that begin with `n` / `p`.
- **`LoadSessionGUI()`** exists (line 449) but nothing calls it. `F6` only saves sessions. To
  restore one: `:source C:\Users\vondracl\appdata\Local\gVim\session.vimsession`
  (or `:call LoadSessionGUI()`).
- **`MyGrepGUI()`** exists but is unused.
- **`_vimrc` is not pure UTF-8**: the `sě`, `sš`, `eě`, `eš` mappings are stored as cp1250 bytes
  and the file uses CRLF line endings. Edit it with gVim itself (or a byte-safe tool).
  Editors or scripts that re-encode it will corrupt those four mappings.

## Not working (plugin missing)

`F5` and `ss` need **dbext**, and `Ctrl+F3` needs **taglist**. (`Ctrl+F5` is fine, it is built-in
diff.) Neither plugin is in `vimfiles\plugin` (only the taglist help file is), so those keys
raise an error until the plugins are installed. The `dbext_profiles.vim` line in `_vimrc` is
commented out as well.

Installed plugins: NERDTree, dirdiff, fugitive, openbrowser, vim-markdown (`mkd`), a
Visual Studio helper (`visual_studio.vim`).

Plugin manager **vim-plug** (`vimfiles\autoload\plug.vim`): plugins listed in the `plug#begin` block of
`_vimrc` are installed into `vimfiles\plugged` with `:PlugInstall`, updated with `:PlugUpdate`
(review with `:PlugDiff`), removed with `:PlugClean`. Currently: `vim-lsp`, `asyncomplete.vim`,
`asyncomplete-lsp.vim`.

### C# IntelliSense (LSP)

Server: `csharp-ls` (`dotnet tool install -g csharp-ls`). Project root = nearest folder above the file
with a `*.sln` / `*.slnx` (else `*.csproj`). Check with `:LspStatus`; the first load of a big solution
takes a while.

| Key / command | Action |
|---|---|
| `Ctrl+X Ctrl+O` (or typing) | Completion popup |
| `gd` or `F12` / `gr` or `Shift+F12` | Go to definition / list references |
| `Ctrl+F12` | Go to definition; opens a new split if the file is not already shown in a window |
| `Ctrl+Shift+F12` | References without test code: leaves out files in directories or with names ending in `Test`/`Tests` (`Foo.Tests`, `FooTests.cs`); the list shows how many were hidden |
| Side mouse buttons (back / forward) | Jump back / forward in the jump list (`Ctrl+O` / `Ctrl+I`); `Ctrl+T` returns along the tag stack |
| `K` | Hover (type and docs) |
| `\rn` | Rename symbol |
| `[g` / `]g` | Previous / next diagnostic |
| `:LspStatus` | Show server status |

## Settings worth remembering

- Backups, swap and views go to `C:\Users\vondracl\appdata\Local\gVim\{backup,swap,view}`
- `autochdir`: the working directory follows the current file
- `ignorecase`, `gdefault`, 4-space tabs (`tabstop=shiftwidth=4`), `cindent`
- On start, files from the argument list open in separate tabs (`tab all`), up to 100
- Bell is disabled; tab labels show only the file name plus a `+` when modified
