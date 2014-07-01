" vim:tw=80:ts=4:sts=4:sw=4:et:ai

" =============================================================
" Early Setup
" =============================================================

" Enable vi-incompatible Vim extensions (redundant since .vimrc exists).
set nocompatible

" Use utf-8 encoding for all content.
set encoding=utf-8

" 'fileencodings' contains a list of possible encodings to try when reading
" a file.  When 'encoding' is a unicode value (such as utf-8), the
" value of fileencodings defaults to ucs-bom,utf-8,default,latin1.
"   ucs-bom  Treat as unicode-encoded file if and only if BOM is present
"   utf-8    Use utf-8 encoding
"   default  Value from environment LANG
"   latin1   8-bit encoding typical of DOS
" Setting this value explicitly, though to the default value.
set fileencodings=ucs-bom,utf-8,default,latin1

" Leaving 'fileencoding' unset, as it defaults to the value of 'encoding'.
" May set 'fileencoding' before writing a file to force a new encoding.
" May also set 'bomb' to force use of a BOM (Byte Order Mark).
" set fileencoding=

" Set environment variable to directory containing this vimrc.  Expect absolute
" directory $HOME/.vim on Unix or %USERPROFILE%\vimfiles on Windows.
let $VIMFILES = expand("<sfile>:p:h")

" -------------------------------------------------------------
" runtimepath manipulation
" -------------------------------------------------------------

function! RtpPrepend(path)
    if isdirectory(a:path)
        let &runtimepath = a:path . "," . &runtimepath
        if isdirectory(a:path . '/after')
            let &runtimepath = &runtimepath . "," . a:path . "/after"
        endif
    endif
endfunction

" -------------------------------------------------------------
" Pathogen plugin management (part one)
" -------------------------------------------------------------

" A couple of bundles must be initialized early for use in |VIMRC_BEFORE|
" scripts.

runtime bundle/pathogen/autoload/pathogen.vim

" The calls to expand() below launder the slashes to backslashes
" on Windows as well as expand environment variables.  This is
" helpful to ensure that pathogen does not re-infect these plugins
" (since pathogen doesn't normalize the slashes during comparisons).

" We'd like to detect fonts in |VIMRC_BEFORE|.
call pathogen#surround(expand("$VIMFILES/bundle/fontdetect"))

" We'd like to set colorschemes in |VIMRC_BEFORE|.
call pathogen#surround(expand("$VIMFILES/bundle/colorsamplerpack"))

" Now restore $VIMFILES area to surround the other bundles, giving it higher
" priority than the added bundles.
call pathogen#surround($VIMFILES)

" -------------------------------------------------------------
" Customizing environment variables
" -------------------------------------------------------------

" NOTE: Several environment variables follow that may be customized.
" See doc/notes.txt in the |notes_customizations| section for details about
" these variables.
"
" Environment variables are used instead of Vim variables to allow
" configuration at the operating-system level outside of Vim.

" If local customizations directory exists, it takes precedence.
call RtpPrepend($VIMFILES . "/local")

" Setup an environment variable for cache-related bits.  This follows
" XDG_CACHE_HOME by default, but can be overridden by the user.
if $VIM_CACHE_DIR == ""
    if $XDG_CACHE_HOME != ""
        let $VIM_CACHE_DIR = expand("$XDG_CACHE_HOME/vim")
    else
        if has("win32")
            let $VIM_CACHE_DIR = expand("$USERPROFILE/.cache/vim")
        else
            let $VIM_CACHE_DIR = expand("$HOME/.cache/vim")
        endif
    endif
endif

" VIMUSER defaults to the logged-in user, but may be overridden to allow
" multiple user to share the same overrides (e.g., to let "root" share settings
" with another user).
if $VIMUSER == ""
    let $VIMUSER = expand("$USER")
endif

" By default, don't permit old-style $VIMUSER-before.vim and $VIMUSER-after.vim.
let s:allowOldVimuserScripts = 0

" Probe for per-user directories.  To allow them to be separately
" source-controlled, check outside $VIMFILES tree first, then inside.
if $VIMUSERFILES == ""
    let $VIMUSERFILES  = fnamemodify($VIMFILES, ":h")
    if has("win32")
        let $VIMUSERFILES .= "/_vimuser"
    else
        let $VIMUSERFILES .= "/.vimuser"
    endif
    if !isdirectory($VIMUSERFILES)
        let $VIMUSERFILES = expand("$VIMFILES/user/$VIMUSER")
        " For backward compatibility, allow old-style $VIMUSER-before.vim and
        " $VIMUSER-after.vim scripts.
        let s:allowOldVimuserScripts = 1
    endif
endif

" VIMRC_BEFORE points directly to the script to execute.
if $VIMRC_BEFORE == ""
    let $VIMRC_BEFORE = expand("$VIMUSERFILES/vimrc-before.vim")
    " For backward compatibility:
    if !filereadable($VIMRC_BEFORE) && s:allowOldVimuserScripts
        let $VIMRC_BEFORE = expand("$VIMFILES/user/$VIMUSER-before.vim")
    endif
endif

" VIMRC_AFTER points directly to the script to execute.
if $VIMRC_AFTER == ""
    let $VIMRC_AFTER = expand("$VIMUSERFILES/vimrc-after.vim")
    " For backward compatibility:
    if !filereadable($VIMRC_AFTER) && s:allowOldVimuserScripts
        let $VIMRC_AFTER = expand("$VIMFILES/user/$VIMUSER-after.vim")
    endif
endif

" Prepend per-user directory to runtimepath (provides the highest priority).
call RtpPrepend($VIMUSERFILES)

" If it exists, source the specified |VIMRC_BEFORE| hook.
if filereadable($VIMRC_BEFORE)
    source $VIMRC_BEFORE
endif

" -------------------------------------------------------------
" Pathogen plugin management (part two)
" -------------------------------------------------------------

" Infect all remaining bundles.
call pathogen#infect()

" Bundles in the "pre-bundle" directories will come earlier in the path
" than those in "bundle" directories.
call pathogen#infect('pre-bundle/{}')

" -------------------------------------------------------------
" Python path management
" -------------------------------------------------------------

" Setup Python's sys.path to include any "pylib" directories found
" as immediate children of paths in Vim's 'runtimepath'.  This allows
" for more easily sharing Python modules.

if has('python')
function! AugmentPythonPath()
python << endpython
import vim
import os
for p in vim.eval("pathogen#split(&runtimepath)"):
    libPath = os.path.join(p, "pylib")
    if os.path.isdir(libPath) and libPath not in sys.path:
        sys.path.append(libPath)
endpython
endfunction
call AugmentPythonPath()
endif

" =============================================================
" Color schemes
" =============================================================

" Setup a color scheme early for better visibility of errors and to nail down
" 'background' (which changes when a new colorscheme is selected).

" If a user sets up a colorscheme in his |VIMRC_BEFORE| script (or early in his
" ~/.vimrc file), the varible g:colors_name will be set and no default
" colorscheme selection will take place.  To use no colorscheme at all, set
" g:colors_name to the empty string.

" If the user hadn't chosen a colorscheme, we setup a default.  Because in
" general there is no good way to reliably detect console background color, we
" default to assuming a dark background.  Vim does try to use the environment
" variable COLORFGBG to guess the background color, but that variable is not
" always set properly (especially after ``sudo`` or ``ssh``).

" Provide a default colorscheme.
if !exists("g:colors_name")
    if !has("gui_running") && &t_Co <= 8
        " With only a few colors, it's better to use a simple colorscheme.
        colorscheme elflord
    else
        " Dark scheme maintained by John Szakmeister.
        colorscheme szakdark
    endif
endif

" Provide a default Powerline colorscheme.
if !exists("g:Powerline_colorscheme")
    if &background == "dark"
        let g:Powerline_colorscheme = 'szakdark'
    else
        " At present, we don't have complete support for light backgrounds
        " (though 'nuvola' is a start at it).
    endif
endif

" =============================================================
" GUI Setup
" =============================================================

if !exists("g:DefaultFontFamilies")
    let g:DefaultFontFamilies = []
endif
let g:DefaultFontFamilies += [
            \ "PragmataPro for Powerline",
            \ "PragmataPro",
            \ "DejaVu Sans Mono for Powerline",
            \ "Droid Sans Mono for Powerline",
            \ "Consolas for Powerline",
            \ "DejaVu Sans Mono",
            \ "Droid Sans Mono",
            \ "Consolas",
            \]

" Font Families matching the regex patterns below have known-good Unicode
" symbols for use with Powerline.
if !exists("g:GoodUnicodeSymbolFontFamilyPatterns")
    let g:GoodUnicodeSymbolFontFamilyPatterns = []
endif
let g:GoodUnicodeSymbolFontFamilyPatterns += [
            \ '^PragmataPro\>',
            \ '^DejaVu Sans Mono\>',
            \ '^Droid Sans Mono\>',
            \]

" Return type of Powerline symbols to use for given font family.
" Value will be one of "fancy", "unicode", or "compatible".
function! PowerlineSymbolsForFontFamily(family)
    if a:family =~# ' Powerline$'
        return "fancy"
    endif
    for pattern in g:GoodUnicodeSymbolFontFamilyPatterns
        if a:family =~# pattern
            return "unicode"
        endif
    endfor
    return "compatible"
endfunction

function! SetFont()
    if !has("gui_running")
        return
    endif
    if !exists("g:FontFamily")
        let g:FontFamily = fontdetect#firstFontFamily(g:DefaultFontFamilies)
    endif
    if !exists("g:FontSize")
        let g:FontSize = 14
    endif
    if g:FontFamily != "" && g:FontSize > 0
        if has("gui_gtk2")
            let font = g:FontFamily . " " . g:FontSize
        else
            let font = g:FontFamily . ":h" . g:FontSize
        endif
        let &guifont = font
        let g:Powerline_symbols = PowerlineSymbolsForFontFamily(g:FontFamily)
    endif
endfunction
command! -bar SetFont call SetFont()

if has("gui_running")
    " 'T' flag controls the toolbar (we don't need it).
    set guioptions-=T

    " 'a' is for Autoselect mode, in which selections will automatically be
    " added to the clipboard (on Windows) or the primary selection (on Unix).
    set guioptions-=a

    " 'L' causes a left-side scrollbar to automatically appear when a
    " vertical split is created.  Unfortunately, there is a timing bug of
    " some kind in Vim that sometimes prevents 'columns' from being
    " properly maintained when the comings and goings of the scrollbar
    " change the width of the GUI frame.  The right-side scrollbar still
    " functions properly for the active window, so there's no need for the
    " left-side scrollbar anyway.
    set guioptions-=L

    SetFont

    " Number of lines of text overall.
    set lines=45
endif

" MacVim-specific setup.  MacVim has a gvimrc setup that alters some bindings.
" We want to keep our M-Left, M-Right, M-Up, and M-Down bindings, so let's
" disable the MacVim setup, and only map the ones that don't collide with other
" mappings we make.
if has("gui_running") && has("gui_macvim")
    if !exists("macvim_skip_cmd_opt_movement")
        let macvim_skip_cmd_opt_movement = 1

        noremap   <D-Left>       <Home>
        noremap!  <D-Left>       <Home>

        noremap   <D-Right>      <End>
        noremap!  <D-Right>      <End>

        noremap   <D-Up>         <C-Home>
        inoremap  <D-Up>         <C-Home>

        noremap   <D-Down>       <C-End>
        inoremap  <D-Down>       <C-End>

        imap      <M-BS>         <C-w>
        imap      <D-BS>         <C-u>
    endif
endif

" =============================================================
" General setup
" =============================================================

" Number of lines of VIM history to remember.
set history=500

" Automatically re-read files that have changed as long as there
" are no outstanding edits in the buffer.
set autoread

" Setup print options for hardcopy command.
set printoptions=paper:letter,duplex:off

" Configure mapping timeout in milliseconds (default 1000).
" Controls how long Vim waits for partially complete mapping
" before timing out and using prefix directly.
set timeout timeoutlen=3000

" Configure keycode timeout in milliseconds (default -1).
" Controls how long Vim waits for partially complete
" keycodes (such as <ESC>OH which is the <Home> key).
" If negative, uses 'timeoutlen'.
" Note that in insert mode, there is a special-case hack in the Vim
" source that checks for <Esc> and if there are no additional characters
" immediately waiting, Vim pretends to leave insert mode immediately.
" But Vim is still waiting for 'ttimeoutlen' milliseconds for keycodes,
" so if in insert mode you press <Esc>OH in console Vim (on Linux) within
" 'ttimeoutlen' milliseconds, you'll get <Home> instead of opening a new
" line above and inserting "H".
" Note: The previous value of 50 ms proved to be much too long once
" support for Alt+letter mappings were added by the fixkey plugin.
" Problems cropped up when pressing <Esc> to leave insert mode followed
" too quickly by j or k as cursor movements.  With a long ttimeoutlen,
" these were being interpreted as Alt-j and Alt-k.  Experimentally,
" it seems that ttimeoutlen=5 is short enough to avoid this error
" without causing other problems.
set ttimeout ttimeoutlen=5

" Disallow octal numbers for increment/decrement (CTRL-A/CTRL-X).
set nrformats-=octal

" -------------------------------------------------------------
" File settings
" -------------------------------------------------------------

" Where file browser's directory should begin:
"   last    - same directory as last file browser
"   buffer  - directory of the related buffer
"   current - current directory (pwd)
"   {path}  - specified directory
set browsedir=buffer

" -------------------------------------------------------------
" Display settings
" -------------------------------------------------------------

" Show "ruler" at bottom (cursor position et al.).
set ruler

" Show initial characters of pending incomplete command.
set showcmd

" Use a taller command line to reduce need for pressing ENTER.
set cmdheight=2

" Show a visual bell instead of beeping.
set visualbell

" What to do when opening a new buffer. May be empty or may contain
" comma-separated list of the following words:
"   useopen   - use existing windows if possible.
"   usetab    - like useopen but also checks other tabs
"   split     - split current window before loading a buffer
" 'useopen' may be useful for re-using QuickFix window.
set switchbuf=

" -------------------------------------------------------------
" Setup wrapping for long lines
" -------------------------------------------------------------

" Enable wrapping of long lines.
set wrap

" Use the prompt ">   " for wrapped lines.
let &showbreak="    "

" Break lines at reasonable places instead of mid-word.
set linebreak

" The 'breakat' variable determines good places to break.
" Defaults to line below:
" set breakat=\ \^I!@*-+;:,./?

" How far to scroll sideways when wrapping is off (:set nowrap).
" When zero (the default), will scroll to the middle of the screen.
" May use a small non-zero number for fast terminals.
set sidescroll=0

" Enable 'list' mode (:set list) to see non-visibles a la "reveal codes"
" in the old Word Perfect.  In list mode, 'listchars' indicates
" what to show.  Defaults to "eol:$", but has lots of features
" (see :help 'listchars).
" The "trail" setting means trailing whitespace.
" The feature is too disconcerting to leave on, but pre-configure
" listchars so :set list will do the right thing.
" set list
set listchars=trail:·,nbsp:·,extends:>,precedes:<,eol:$

" -------------------------------------------------------------
" Menu settings
" -------------------------------------------------------------

anoremenu 10.332 &File.Close\ All<Tab>:%bdelete :%bdelete<CR>
anoremenu 10.355 &File.Save\ A&ll<Tab>:wall :wall<CR>

" Configure the use of the Alt key to access menus.
"   no - never use Alt key for menus; all Alt-key combinations are mappable.
"   yes - always use Alt key for menus; cannot map Alt-key combinations.
"   menu - Alt-key combinations not used by menus are mappable.
set winaltkeys=no

" -------------------------------------------------------------
" Key settings
" -------------------------------------------------------------

" Avoid the following key settings for maximum portability across terminal
" types.  "No codes" means the terminal generates nothing for the given keys.
" "Aliased code" means the key generates the same code as another key, making
" the two keys indistinguishable (and the aliased key useless).
"
" gnome-terminal (TERM=xterm, COLORTERM=gnome-terminal):
" - No codes:
"   <F10>       (reserved for menu)
"   <S-F10>     (reserved for context menu)
"   <S-Home>    (reserved for scrollback)
"   <S-End>     (reserved for scrollback)
"
" Linux console (TERM=linux):
" - No codes:
"   <S-F9>
"   <S-F10>
"   <S-F11>
"   <S-F12>
" - Aliased codes:
"   <S-Home>    (same as <Home>)
"   <S-End>     (same as <End>)
"
" PuTTY (all except "SCO" mode) (TERM=putty, TERM=putty-256color):
" - Aliased codes:
"   <S-F1>      (same as <F11>)
"   <S-F2>      (same as <F12>)
"   <S-F11>     (same as <F11>)
"   <S-F12>     (same as <F12>)
"   <S-Home>    (same as <Home>)
"   <S-End>     (same as <End>)
"
" PuTTY "SCO" mode (TERM=putty-sco):
" - Aliased codes:
"   <Delete>    (same as <Backspace>)
"   <S-Home>    (same as <Home>)
"   <S-End>     (same as <End>)
"
" rxvt (TERM=rxvt, TERM=rxvt-unicode):
" - No codes:
"   <S-Home>    (reserved for scrollback for rxvt-unicode only)
"   <S-End>     (reserved for scrollback for rxvt-unicode only)
" - Aliased codes:
"   <S-F1>      (same as <F11>)
"   <S-F2>      (same as <F12>)

" Undo compiled-in mappings
silent! unmap <C-x>
silent! unmap <C-Del>
silent! unmap <S-Del>
silent! unmap <C-Insert>
silent! unmap <S-Insert>
silent! unmap! <S-Insert>

" Execute "make" in current directory.
nnoremap <F9> :wall<bar>make<CR>
inoremap <F9> <ESC>:wall<bar>make<CR>

" Execute current buffer.
nnoremap <F5> :wall<bar>! %:p<CR>
inoremap <F5> <ESC>:wall<bar>! %:p<CR>

" Return escaped path of directory containing current file.
function! EscapedFileDir()
    return shellescape(expand("%:p:h"))
endfunction

" Signal fifo using fifosignal script.
nnoremap <F12> :wall<bar>call system("fifosignal " . EscapedFileDir())<CR>
inoremap <F12> <ESC>:wall<bar>call system("fifosignal " . EscapedFileDir())<CR>

" -------------------------------------------------------------
" Support routines
" -------------------------------------------------------------

" Return last selected text (as defined by `< and `>).
function! SelectedText()
    let regA = getreg("a")
    let regTypeA = getregtype("a")
    silent execute 'normal! `<v`>"ay'
    let text = @a
    call setreg("a", regA, regTypeA)
    return text
endfunction

" Return true if line is blank (i.e., contains only whitespace).
function! IsBlank(line)
    return a:line =~# '^\s*$'
endfunction

" Indent function that leaves things unchanged.
" Existing (i.e., non-blank) lines keep their current indentation.
" New (blank) lines keep the indentation level of the previous non-blank line.
" Use via:
"   set indentexpr=StatusQuoIndent()
function! StatusQuoIndent()
    " Leave non-blank lines alone at their current indentation.
    let thisLine = getline(v:lnum)
    if !IsBlank(thisLine)
        return indent(thisLine)
    endif

    let lnum = prevnonblank(v:lnum - 1)
    if lnum == 0
        return -1
    endif

    return indent(getline(lnum))
endfunction

" -------------------------------------------------------------
" QuickFix/Location List support
" -------------------------------------------------------------

" Open QuickFix window using standard position and height.
command! -bar Copen  execute "botright copen " . g:QuickFixWinHeight

" Open Location List window using standard height.
command! -bar Lopen  execute "lopen " . g:LocListWinHeight

" Return 1 if current window is the QuickFix window.
function! IsQuickFixWin()
    if &buftype == "quickfix"
        " This is either a QuickFix window or a Location List window.
        " Try to open a location list; if this window *is* a location list,
        " then this will succeed and the focus will stay on this window.
        " If this is a QuickFix window, there will be an exception and the
        " focus will stay on this window.
        try
            lopen
        catch /E776:/
            " This was a QuickFix window.
            return 1
        endtry
    endif
    return 0
endfunction

" Return 1 if current window is a Location List window.
function! IsLocListWin()
    return (&buftype == "quickfix" && !IsQuickFixWin())
endfunction

" Return window number of quickfix buffer (or zero if not found).
function! GetQuickFixWinNum()
    let qfWinNum = 0
    let curWinNum = winnr()
    for winNum in range(1, winnr("$"))
        execute "noautocmd " . winNum . "wincmd w"
        if IsQuickFixWin()
            let qfWinNum = winNum
            break
        endif
    endfor
    execute "noautocmd " . curWinNum . "wincmd w"
    return qfWinNum
endfunction

" Return 1 if current window's location list window is open.
function! LocListWinIsOpen()
    let curWinNum = winnr()
    let numOpenWindows = winnr("$")
    " Assume location list window is already open.
    let isOpen = 1
    try
        noautocmd lopen
    catch /E776:/
        " No location list available; nothing was changed.
        let isOpen = 0
    endtry
    if numOpenWindows != winnr("$")
        " We just opened a new location list window.  Revert to original
        " window and close the newly opened window.
        noautocmd wincmd p
        noautocmd lclose
        let isOpen = 0
    endif
    return isOpen
endfunction

" Goto previous or next QuickFix or Location List message.
"   messageType = "c" (for QuickFix) or "l" (for Location List).
"   whichMessage = "previous" or "next".
" Return 1 on successful move.
function! GotoMessage(messageType, whichMessage)
    try
        execute a:messageType . a:whichMessage
    catch /:E42:\|:E553:/
        echo "No " . a:whichMessage . " message"
        return 0
    endtry
    " Echo empty line to clear possible previous message.
    echo ""
    normal zz
    return 1
endfunction

" Goto previous "thing" (diff, Location List message, QuickFix message).
function! GotoPrev()
    if &diff
        normal [czz
    elseif LocListWinIsOpen()
        call GotoMessage("l", "previous")
    else
        Copen
        wincmd p
        call GotoMessage("c", "previous")
    endif
endfunction

" Goto next "thing" (diff, Location List message, QuickFix message).
function! GotoNext()
    if &diff
        normal ]czz
    elseif LocListWinIsOpen()
        call GotoMessage("l", "next")
    else
        Copen
        wincmd p
        call GotoMessage("c", "next")
    endif
endfunction

" Setup previous/next browsing using F4/Shift-F4.
inoremap <silent> <F4> <C-O>:call GotoNext()<CR>
nnoremap <silent> <F4>      :call GotoNext()<CR>
inoremap <silent> <S-F4> <C-O>:call GotoPrev()<CR>
nnoremap <silent> <S-F4>      :call GotoPrev()<CR>

function! s:Qf2Args()
    let l:files={}
    argdo argdelete %
    for l:lineDict in getqflist()
        if l:lineDict.bufnr > 0
            let l:files[bufname(l:lineDict.bufnr)]=1
        endif
    endfor
    for l:file in keys(l:files)
        execute "silent argadd " . l:file
    endfor
endfunction

command! -bar Qf2Args call s:Qf2Args()

" Setup n and N for browsing to next or previous search match with automatic
" scrolling to the center of the window.
nnoremap n      nzz
nnoremap N      Nzz

" Move current line up one line (called from normal mode)
function! NMoveUp()
    if line(".") > 1
        let curCol = virtcol('.')
        move .-2
        exe ':silent normal ' . curCol . '|'
    endif
endfunction

" Move current line down one line (called from normal mode)
function! NMoveDown()
    if line(".") < line("$")
        let curCol = virtcol('.')
        move .+1
        exe ':silent normal ' . curCol . '|'
    endif
endfunction

" Move visual range up one line (called from normal mode)
function! VMoveUp()
    if line("'<") > 1
        silent '<,'>move '<-2
    endif
    " restore visual selection
    silent normal! gv
endfunction

" Move visual range down one line (called from normal mode)
function! VMoveDown()
    if line("'>") < line("$")
        silent '<,'>move '>+1
    endif
    " restore visual selection
    silent normal! gv
endfunction

nnoremap <silent> <M-Up>   :call NMoveUp()<CR>
nnoremap <silent> <M-Down> :call NMoveDown()<CR>
nnoremap <silent> <M-k>    :call NMoveUp()<CR>
nnoremap <silent> <M-j>    :call NMoveDown()<CR>

inoremap <silent> <M-Up>   <C-\><C-O>:call NMoveUp()<CR>
inoremap <silent> <M-Down> <C-\><C-O>:call NMoveDown()<CR>
inoremap <silent> <M-k>    <C-\><C-O>:call NMoveUp()<CR>
inoremap <silent> <M-j>    <C-\><C-O>:call NMoveDown()<CR>

xnoremap <silent> <M-Up>   <C-C>:call VMoveUp()<CR>
xnoremap <silent> <M-Down> <C-C>:call VMoveDown()<CR>
xnoremap <silent> <M-k>    <C-C>:call VMoveUp()<CR>
xnoremap <silent> <M-j>    <C-C>:call VMoveDown()<CR>
xnoremap <silent> -        <C-C>:call VMoveUp()<CR>
xnoremap <silent> +        <C-C>:call VMoveDown()<CR>

" Invoke as:
"   WithShiftWidth(1, "normal gv<gv")
"   WithShiftWidth(1, ":'<,'>>")
function! WithShiftWidth(shiftWidth, toExec)
    let save_sw = &sw
    let &sw = a:shiftWidth
    execute a:toExec
    let &sw = save_sw
endfunction

" Derived from John Little's Vbs() function, posted in vim_use
" 9/8/2010 with Subject "Re: formating".
function! VMoveLeft()
    if visualmode() == "\<c-v>"
        let s = getpos("'<")
        let e = getpos("'>")
        let fl = min([s[1], e[1]])
        let fc = min([s[2], e[2]])
        let ll = max([s[1], e[1]])
        let lc = max([s[2] + s[3], e[2] + e[3]])
        let save_virtualedit = &virtualedit
        let &virtualedit = "all"
        call setpos(".", [0, fl, lc - (lc == 1 ? 0 : 1), 0])
        execute "normal \<c-v>"
        call setpos(".", [0, ll, lc - (lc == 1 ? 0 : 1), 0])
        normal x
        call setpos(".", [0, fl, fc - (fc == lc && fc != 1 ? 1 : 0), 0])
        execute "normal \<c-v>"
        call setpos(".", [0, ll, lc - (fc == lc && lc == 1 ? 0 : 1), 0])
        let &virtualedit = save_virtualedit
    else
        call WithShiftWidth(1, ":'<,'><")
        normal gv
    endif
endfunction

function! VMoveRight()
    if visualmode() == "\<c-v>"
        execute "normal gvI\<Space>\<esc>"
        normal gvl
    else
        call WithShiftWidth(1, ":'<,'>>")
        normal gv
    endif
endfunction

nnoremap <silent> <M-Left>     :call WithShiftWidth(1, ":<")<CR>
nnoremap <silent> <M-Right>    :call WithShiftWidth(1, ":>")<CR>
nnoremap <silent> <M-h>        :call WithShiftWidth(1, ":<")<CR>
nnoremap <silent> <M-l>        :call WithShiftWidth(1, ":>")<CR>

inoremap <silent> <M-Left>     <C-\><C-O>:call WithShiftWidth(1, ":<")<CR>
inoremap <silent> <M-Right>    <C-\><C-O>:call WithShiftWidth(1, ":>")<CR>
inoremap <silent> <M-h>        <C-\><C-O>:call WithShiftWidth(1, ":<")<CR>
inoremap <silent> <M-l>        <C-\><C-O>:call WithShiftWidth(1, ":>")<CR>

xnoremap <silent> <M-Left>     <C-C>:call VMoveLeft()<CR>
xnoremap <silent> <M-Right>    <C-C>:call VMoveRight()<CR>
xnoremap <silent> <M-h>        <C-C>:call VMoveLeft()<CR>
xnoremap <silent> <M-l>        <C-C>:call VMoveRight()<CR>
xnoremap <silent> <Backspace>  <C-C>:call VMoveLeft()<CR>
xnoremap <silent> <Space>      <C-C>:call VMoveRight()<CR>

" Remove "rubbish" whitespace (from Andy Wokula posting).

nnoremap <silent> drw :<C-U>call DeleteRubbishWhitespace()<CR>

function! DeleteRubbishWhitespace()
    " Reduce many spaces or blank lines to one.
    let saveVirtualEdit = [&virtualedit]
    set virtualedit=
    let line = getline(".")
    if line =~ '^\s*$'
        let savePos = winsaveview()
        let saveFoldEnable = &foldenable
        setlocal nofoldenable
        normal! dvip0D
        let savePos.lnum = line(".")
        let &l:foldenable = saveFoldEnable
        call winrestview(savePos)
    elseif line[col(".")-1] =~ '\s'
        normal! zvyiw
        if @@ != " "
            normal! dviwr m[
            " m[ is just to avoid a trailing space
        endif
    endif
    let [&ve] = saveVirtualEdit
    silent! call repeat#set("drw")
endfunction

function! StripTrailingWhitespace()
    let savePos = winsaveview()
    let saveFoldEnable = &foldenable
    setlocal nofoldenable
    %substitute /\s\+$//ge
    let &l:foldenable = saveFoldEnable
    call winrestview(savePos)
endfunction
command! -bar StripTrailingWhitespace  call StripTrailingWhitespace()

nnoremap <Leader><Leader>$  :StripTrailingWhitespace<CR>

" Remap Q from useless "Ex" mode to "gq" re-formatting command.
nnoremap Q gq
xnoremap Q gq
onoremap Q gq

" Paragraph re-wrapping, similar to Emacs's Meta-Q and TextMate's Ctrl-Q.
function! RewrapParagraphExpr()
    return (&tw > 0 ? "gqip" : "vip:join\<CR>") . "$"
endfunction

function! RewrapParagraphExprVisual()
    return (&tw > 0 ? "gq"   :    ":join\<CR>") . "$"
endfunction

function! RewrapParagraphExprInsert()
    " Include undo point via CTRL-G u.
    return "\<C-G>u\<Esc>" . RewrapParagraphExpr() . "A"
endfunction

nnoremap <expr> <M-q>      RewrapParagraphExpr()
nnoremap <expr> <Leader>q  RewrapParagraphExpr()
xnoremap <expr> <M-q>      RewrapParagraphExprVisual()
xnoremap <expr> <Leader>q  RewrapParagraphExprVisual()
inoremap <expr> <M-q>      RewrapParagraphExprInsert()

function! ClosestPos(positions)
    let closestLine = 0
    let closestCol = 0
    for p in a:positions
        if p[0] > 0
            if closestLine == 0 || closestLine > p[0] ||
                        \ (closestLine == p[0] && closestCol > p[1])
                let closestLine = p[0]
                let closestCol = p[1]
            endif
        endif
    endfor
    return [closestLine, closestCol]
endfunction

function! ClosestCurly()
    return searchpairpos('{', '\<break\s*\zs;', '}', 'nW')
endfunction

function! ClosestParen()
    return searchpairpos('(', '', ')', 'nW')
endfunction

function! ClosestBracket()
    return searchpairpos('[', '', ']', 'nW')
endfunction

function! MoveTo(position)
    if a:position[0] > 0
        exec "normal " . a:position[0] . "gg"
        exec "normal " . a:position[1] . "|"
    endif
endfunction

function! MoveToClosest()
    call MoveTo(ClosestPos([ClosestCurly(), ClosestParen(), ClosestBracket()]))
endfunction

" Go "out" to the next closest containing thingy.
inoremap <silent> <C-O><C-O>  <ESC>:call MoveToClosest()<CR>a
vnoremap <silent> <C-O><C-O>  <ESC>:call MoveToClosest()<CR>a

" Map CTRL-O o in visual modes to be the same as in insert mode
" (which opens a new line below this one even when currently mid-line).
vnoremap <silent> <C-O>o  <ESC>o

" Append ;<CR> to current line.
inoremap <silent> <C-O>;  <ESC>A;<CR>
vnoremap <silent> <C-O>;  <ESC>A;<CR>

" Append :<CR> to current line.
inoremap <silent> <C-O>:  <ESC>A:<CR>
vnoremap <silent> <C-O>:  <ESC>A:<CR>

" Append .<CR> to current line.
inoremap <silent> <C-O>.  <ESC>A.<CR>
vnoremap <silent> <C-O>.  <ESC>A.<CR>

" Append .<CR> to current line unless overridden by filetype-specific mapping.
inoremap <silent> <C-O><CR>  <ESC>A.<CR>
vnoremap <silent> <C-O><CR>  <ESC>A.<CR>

" To leave Visual or Select mode at start or end of selected text.
snoremap <silent> <C-O><C-H> <C-G>o<C-\><C-N>i
xnoremap <silent> <C-O><C-H>      o<C-\><C-N>i
vnoremap <silent> <C-O><C-L>       <C-\><C-N>a

" Move vertically by screen lines instead of physical lines.
" Exchange meanings for physical and screen motion keys.

" When the popup menu is visible (pumvisible() is true), the up and
" down arrows should not be mapped in order to preserve the expected
" behavior when navigating the popup menu.  See :help ins-completion-menu
" for details.

" Down
nnoremap j           gj
xnoremap j           gj
nnoremap <Down>      gj
xnoremap <Down>      gj
inoremap <silent> <Down> <C-R>=pumvisible() ? "\<lt>Down>" : "\<lt>C-o>gj"<CR>
nnoremap gj          j
xnoremap gj          j

" Up
nnoremap k           gk
xnoremap k           gk
nnoremap <Up>        gk
xnoremap <Up>        gk
inoremap <silent> <Up>   <C-R>=pumvisible() ? "\<lt>Up>" : "\<lt>C-o>gk"<CR>
nnoremap gk          k
xnoremap gk          k

" Start of line
nnoremap 0           g0
xnoremap 0           g0
nnoremap g0          0
xnoremap g0          0
nnoremap ^           g^
xnoremap ^           g^
nnoremap g^          ^
xnoremap g^          ^

" End of line
nnoremap $           g$
xnoremap $           g$
nnoremap g$          $
xnoremap g$          $

" Navigate conflict markers.
function! GotoConflictMarker(direction, beginning)
    if a:beginning
        call search('^<\{7}<\@!', a:direction ? 'W' : 'bW')
    else
        call search('^>\{7}>\@!', a:direction ? 'W' : 'bW')
    endif
endfunction

nnoremap [n :call GotoConflictMarker(0, 1)<CR>
nnoremap [N :call GotoConflictMarker(0, 0)<CR>
nnoremap ]n :call GotoConflictMarker(1, 1)<CR>
nnoremap ]N :call GotoConflictMarker(1, 0)<CR>

" Command-line editing.
" To match Bash, setup Emacs-style command-line editing keys.
" This loses some Vim functionality.  The original functionality can
" be had by pressing CTRL-O followed by the original key.  E.g., to insert
" all matching filenames (originally <C-A>), do <C-O><C-A>.
cnoremap <C-A>      <Home>
cnoremap <C-B>      <Left>
cnoremap <C-D>      <Del>
cnoremap <C-F>      <Right>
cnoremap <C-N>      <Down>
cnoremap <C-P>      <Up>
cnoremap <M-b>      <S-Left>
cnoremap <M-f>      <S-Right>

cnoremap <C-O><C-A> <C-A>
cnoremap <C-O><C-B> <C-B>
cnoremap <C-O><C-D> <C-D>
cnoremap <C-O><C-F> <C-G>
cnoremap <C-O><C-N> <C-N>
cnoremap <C-O><C-P> <C-P>

" Use CTRL-G to bring up the command-line window.
let &cedit = "<C-G>"

" Original meanings:
" <C-A>   Insert all matching filenames.
" <C-B>   <Home>.
" <C-D>   List matching names
" <C-F>   Edit command-line history.
" <C-G>   Nothing.
" <C-N>   Next match after wildchar, or recall next command-line history.
" <C-O>   Nothing.
" <C-P>   Prev. match after wildchar, or recall prev. command-line history.

" Work around bug on Fedora (resetting guifont seems to fix it).
function! ResetGuiFont()
    let &guifont=&guifont
endfunction

function! RefreshScreen()
    call ResetGuiFont()
    if &diff
        diffupdate
    endif
endfunction
command! RefreshScreen :call RefreshScreen()
nnoremap <silent> <C-L> :RefreshScreen<CR>:nohlsearch<CR><C-L>

" Work-around slow pasting to command-line; avoid a command-line
" re-draw on every character entered by turning off Arabic shaping
" (which is reportedly poorly implemented).
if has("arabic")
    set noarabicshape
endif

" =============================================================
" Behavior
" =============================================================

" Allow backspacing over everything in insert mode.
set backspace=indent,eol,start

" Use Visual mode and avoid "Select" mode.
set selectmode=

" Don't move to start-of-line on page up/down, H, M, L, gg, G, etc.
set nostartofline

" Right-click sets cursor position and pop up a menu.
set mousemodel=popup_setpos
" @todo Setup the menu that pops up.

" With 'startsel' included, shifted "special" keys (arrows, home, end,
" page up/down) start a selection.
" With 'stopsel' included, unshifted "special" keys stop a selection.
set keymodel=startsel

" 'inclusive' indicates to include the last character in a selection.
" 'exclusive' excludes the final character in a selection.
set selection=inclusive

" Allow left/right movement keys to "wrap" to the previous/next line.
" b - backspace key
" s - space key
" h - "h" (not recommended)
" l - "l" (not recommended)
" ~ - "~"
" < - left arrow  (normal and visual modes)
" > - right arrow (normal and visual modes)
" [ - left arrow  (insert and replace modes)
" ] - right arrow (insert and replace modes)
set whichwrap=b,s,<,>,[,]

" Setup command-line completion (inside of Vim's ':' command line).
" Controlled by two options, 'wildmode' and 'wildmenu'.
" `wildmode=full` completes the full word
" `wildmode=longest` completes the longest unambiguous substring
" `wildmode=list` lists all matches when ambiguous
" When more than one mode is given, tries first mode on first keypress,
" and subsequent modes thereafter.
" `wildmode=longest,list` matches longest unambiguous, then shows list
"   of matches on next keypress if match didn't grow longer.
" If wildmenu is set, it will be used only when wildmode=full.

set wildmode=longest,list

" List of extensions to ignore when using wildcard matching.
set wildignore=*.o,*.obj,*.a,*.lib,*.so,*~,*.bak,*.swp,tags,*.opt,*.ncb
            \,*.plg,*.elf,cscope.out,*.ecc,*.exe,*.ilk
            \,export,build,_build

" Ignore some Python artifacts.
set wildignore+=*.pyc,*.egg-info

" Ignore some Linux-kernel artifacts.
set wildignore+=*.ko,*.mod.c,*.order,modules.builtin

" Ignore some java-related files.
set wildignore+=*.class,classes/**,*.jar

" Ignore debug symbols on Mac OS X.
set wildignore+=*.dSYM

" Want sessionoptions to contain:
"   blank - save unnamed buffers.
"   buffers - save buffers.
"   curdir - save current directory.
"   folds - any manually set folds.
"   help - any open help windows.
"   resize - restore lines, columns.
"   slash - replace backslashes with forward slashes in file names.
"   tabpages - all tabpages at once.
"   unix - save session file in Unix line endings.
"   winpos - position of entire Vim window.
"   winsize - sizes of windows.
"
" Don't want:
"   localoptions - all local options.
"   options - all global options.
"   sesdir - change directory to that of the session file.

set sessionoptions=blank,buffers,curdir,folds,help,resize,slash
            \,tabpages,unix,winpos,winsize


" Setup undofile capability if available.
if exists("&undodir")
    set undofile

    if isdirectory(expand('$VIMFILES/.undo'))
        set undodir=$VIMFILES/.undo
    else
        " Use silent! because mkdir() can fail if the directory already exists.
        silent! call mkdir(expand('$VIM_CACHE_DIR/undo'), "p")
        set undodir=$VIM_CACHE_DIR/undo
    endif
endif

" -------------------------------------------------------------
" Completion
" -------------------------------------------------------------

" Complete longest unambigous match, show menu even if only one match.
" Include extra "preview" information in menu.
" menu - use a popup menu to show completions.
" menuone - use menu even when only one match.
" longest - only insert longest common text of matches.
" preview - use preview window to show extra information.
set completeopt=longest,menuone

" 'complete' controls which types of completion may be initiated by
" pressing CTRL-n and CTRL-p.
" . - Scans current buffer.
" w - Scans buffers from other windows.
" b - Scans loaded buffers in the buffer list.
" u - Scans unloaded buffers in the buffer list.
" U - Scans buffers not in the buffer list.
" k - Scans the files given with the 'dictionary' option.
" kspell - Use the active spell checking.
" k{dict} - Scan the file {dict}.
" s - Scan the files given with the 'thesaurus' option.
" s{tsr} - Scan the file {tsr}.
" i - Scan current and included files.
" d - Scan current and included files for a defined name or macro.
" ] - Tag completion.
" t - Same as "]".
" Default: .,w,b,u,t,i

set complete=.,w,b,u,t

" TODO Cleanup these mappings (Make them work, or remove them).
" Remap <CR> such that when popup menu is active, the current menu
" option is automatically selected (as if CTRL-y were pressed), and
" when popup is not present, normal <CR> is performed (with automatic
" breaking of undo sequence via CTRL-g u).
" inoremap <expr> <CR> pumvisible() ? "\<lt>C-y>" : "\<lt>C-g>u\<lt>CR>"

" Remap CTRL-n to simply move to next menu option if popup menu already
" visible, or to invoke omni completion and automatically press the
" down arrow to ensure a menu item is always selected.
" inoremap <expr> <C-n> pumvisible() ? "\<lt>c-n>" : "\<lt>c-n>\<lt>c-r>=pumvisible() ? \"\\<lt>down>\" : \"\"\<lt>cr>"

" inoremap <expr> <m-;> pumvisible() ? "\<lt>c-n>" : "\<lt>c-x>\<lt>c-o>\<lt>c-n>\<lt>c-p>\<lt>c-r>=pumvisible() ? \"\\<lt>down>\" : \"\"\<lt>cr>"

" -------------------------------------------------------------
" Begin "inspired by mswin.vim"
" -------------------------------------------------------------

" Backspace in Visual mode does NOT delete selection (used for
" shifting left).

" SHIFT-Del is Cut
nnoremap <S-Del>            "+dd
vnoremap <S-Del>            "+d
inoremap <S-Del>            <C-O>"+dd

" CTRL-Insert is Copy
nnoremap <C-Insert>         "+yy
vnoremap <C-Insert>         "+y
inoremap <C-Insert>         <C-O>"+yy

" SHIFT-Insert is Paste
" Pasting blockwise and linewise selections is not possible in Insert and
" Visual mode without the +virtualedit feature.  They are pasted as if they
" were characterwise instead.
" Uses the paste.vim autoload script.

nnoremap <S-Insert>         "+gP
exe 'vnoremap <script> <S-Insert>' paste#paste_cmd['v']
exe 'inoremap <script> <S-Insert>' paste#paste_cmd['i']
cnoremap <S-Insert>         <C-R>+

" CTRL-SHIFT-Insert is Paste from primary selection ("* register)
nnoremap <C-S-Insert>       "*gP
vnoremap <C-S-Insert>       "*gP
inoremap <C-S-Insert>       <C-\><C-O>"*gP
cnoremap <C-S-Insert>       <C-R>*

nnoremap <M-z>  :undo<CR>
vnoremap <M-z>  <ESC>:undo<CR>
inoremap <M-z>  <ESC>:undo<CR>
nmap <M-x>      <S-Del>
vmap <M-x>      <S-Del>
imap <M-x>      <S-Del>
nmap <M-c>      <C-Insert>
vmap <M-c>      <C-Insert>
imap <M-c>      <C-Insert>
nmap <M-v>      <S-Insert>
vmap <M-v>      <S-Insert>
imap <M-v>      <S-Insert>
noremap  <M-a>      ggVG
inoremap <M-a> <ESC>ggVG

" Mapping M-a separately for visual and select modes to always end up
" in visual mode; otherwise, with a single :vnoremap, pressing M-a in
" select mode selects all but switches back to select mode when done.
snoremap <M-a> <ESC>ggVG
xnoremap <M-a> <ESC>ggVG

" On Windows, Alt-Space brings up system menu.
if has("win32")
    nnoremap <M-Space> :simalt ~<CR>
endif

" -------------------------------------------------------------
" End "inspired by mswin.vim"
" -------------------------------------------------------------

" Put from most recent yank instead of scratch register.
xnoremap P "0P

" =============================================================
" Search-related configuration
" =============================================================

" Enable incremental searching (searching as you type).
set incsearch

" Make searching case-insensitive, but enable "smartcase" that will
" turn case sensitivity back on when uppercase letters are present.
" (Note: Use \C in pattern to force case sensitivity again.)
set ignorecase
set smartcase

" Do not wrap around buffer when searching.
set nowrapscan


" Escape passed-in string for use as a search expression.
function! MakeSearchString(str)
    return substitute(escape(a:str, '\\/.*$^~[]'), '\n', '\\n', 'g')
endfunction

" Escape passed-in string for use as an egrep expression.
function! MakeEgrepString(str)
    " @todo Can't egrep for \n.
    return substitute(escape(a:str, '\\/.*$^~[]() %#'), '\n', '\\n', 'g')
endfunction

" Initiate search of visual selection (forward '*' or backward '#').
" E.g.:
"   xnoremap <expr> * VisualSearch('*')
"   xnoremap <expr> # VisualSearch('#')
function! VisualSearch(direction)
    if a:direction == '#'
        let l:rhs = "y?"
    else
        let l:rhs = "y/"
    endif
    let l:rhs = l:rhs . "\<C-R>=MakeSearchString(@\")\<CR>\<CR>gV"
    return l:rhs
endfunction

" Setup @/ to given pattern, enable highlighting and add to search history.
function! SetSearch(pattern)
    let @/ = a:pattern
    call histadd("search", a:pattern)
    set hlsearch
    " Without redraw, pressing '*' at startup fails to highlight.
    redraw
endfunction

" Set search register @/ to unnamed ("scratch") register and highlight.
command! -bar MatchScratch     call SetSearch(MakeSearchString(@"))
command! -bar MatchScratchWord call SetSearch("\\<".MakeSearchString(@")."\\>")

" Map normal-mode '*' to just highlight, not search for next.
" Note: Yank into @a to avoid clobbering register 0 (saving and restoring @a).
nnoremap <silent> *  :let temp_a=@a<CR>"ayiw:MatchScratchWord<CR>
            \:let @a=temp_a<CR>
nnoremap <silent> g* :let temp_a=@a<CR>"ayiw:MatchScratch<CR>
            \:let @a=temp_a<CR>
xnoremap <silent> *  <ESC>:let temp_a=@a<CR>gv"ay:MatchScratch<CR>
            \:let @a=temp_a<CR>

" Setup :Regrep command to search for visual selection.
function! VisualRegrep()
    return "y:MatchScratch\<CR>" .
                \ ":Regrep \<C-R>=MakeEgrepString(@\")\<CR>"
endfunction

" Setup :Regrep command to search for complete word under cursor.
function! NormalRegrep()
    return "yiw:MatchScratchWord\<CR>" .
                \ ":Regrep \\<\<C-R>=MakeEgrepString(@\")\<CR>\\>"
endfunction

" :Regrep of visual selection or current word under cursor.
vnoremap <expr> <F3> VisualRegrep()
nnoremap <expr> <F3> NormalRegrep()

function! FoldShowExpr()
    let maxLevel = 2
    let level = 0
    while level < maxLevel
        if getline(v:lnum - level) =~ @/
            break
        endif
        if level != 0 && (getline(v:lnum + level) =~ @/)
            break
        endif
        let level = level + 1
    endwhile
    return level
endfunction

function! FoldHideExpr()
    return (getline(v:lnum) =~ @/) ? 1 : 0
endfunction

function! FoldRegex(foldExprFunc, regex)
    if a:regex != ""
        let @/=a:regex
        call histadd("search", a:regex)
    endif
    let &l:foldexpr = a:foldExprFunc . '()'
    setlocal foldmethod=expr
    setlocal foldlevel=0
    setlocal foldcolumn=0
    setlocal foldminlines=0
    setlocal foldenable

    " Return to manual folding now that folds have been applied.
    setlocal foldmethod=manual
endfunction

" Search (and "show") regex; fold everything else.
command! -nargs=? Foldsearch    call FoldRegex('FoldShowExpr', <q-args>)

" Fold matching lines ("hide" the matches).
command! -nargs=? Fold          call FoldRegex('FoldHideExpr', <q-args>)

" Fold away comment lines (including blank lines).
" TODO: Extend for more than just shell comments.
command! -nargs=? Foldcomments  Fold ^\s*#\|^\s*$

" Convert certain unicode characters to ASCII equivalents in range
" from firstLine to lastLine, included.
function! Toascii(firstLine, lastLine)
    let prefix = "silent " . a:firstLine . "," . a:lastLine . "s"

    " Spaces of non-zero width.
    execute prefix . '/[\u2000-\u200a\u202f]/ /ge'

    " Zero-width spaces and joiners.
    execute prefix . '/[\u200b-\u200d]//ge'

    " "M" dash converts to a double-dash.
    execute prefix . '/[\u2014]/--/ge'

    " Remaining hyphens and short dashes.
    execute prefix . '/[\u2010-\u2015\u2027]/-/ge'

    " Apostrophes.
    execute prefix . '/[\u2018-\u201b]/' . "'" . '/ge'

    " Double-quotes.
    execute prefix . '/[\u201c-\u201f]/"/ge'

    " Bullets.
    execute prefix . '/[\u2022-\u2023\u204c\u204d]/-/ge'

    " One-dot leader.
    execute prefix . '/[\u2024]/./ge'

    " Two-dot leader.
    execute prefix . '/[\u2025]/../ge'

    " Ellipsis.
    execute prefix . '/[\u2026]/.../ge'

    " Prime.
    execute prefix . '/[\u2032]/' . "'" . '/ge'

    " Double-prime.
    execute prefix . '/[\u2033]/' . "''" . '/ge'

    " Triple-prime.
    execute prefix . '/[\u2034]/' . "'''" . '/ge'

    " Reversed Prime.
    execute prefix . '/[\u2035]/`/ge'

    " Reversed double-prime.
    execute prefix . '/[\u2036]/``/ge'

    " Reversed triple-prime.
    execute prefix . '/[\u2037]/```/ge'

    " Caret
    execute prefix . '/[\u2038]/^/ge'

    " Left angle quotation mark.
    execute prefix . '/[\u2039]/</ge'

    " Right angle quotation mark.
    execute prefix . '/[\u203a]/>/ge'

    " Double exclamation mark.
    execute prefix . '/[\u203c]/!!/ge'

endfunction

" Convert certain unicode characters to ASCII equivalents.
command! -range=% Toascii  call Toascii(<line1>, <line2>)


" -------------------------------------------------------------
" Buffer manipulation
" -------------------------------------------------------------

" Allow buffers to be hidden even if they have changes.
set hidden

" -------------------------------------------------------------
" Paste setup
" -------------------------------------------------------------

" Setup a key to toggle "paste" mode (toggles between :set paste
" and :set nopaste by executing :set invpaste).
set pastetoggle=<S-F12>

" Change default from unnamed register ('"') to the primary selection
" register ("*") for general yank and put operations. Avoid autoselect mode.
" Inspired by Tip #21.  Notice also you can append to a register and then
" assign it to the primary selection (@*) or the clipboard (@+).  E.g.:
"   :let @*=@a
set clipboard=unnamed

" taken from tip #330 - setup sometime...
" map <F11> :call InvertPasteAndMouse()<CR>
function! InvertPasteAndMouse()
    if &mouse == ''
        set mouse=a | set nopaste
        echo "mouse mode on, paste mode off"
    else
        set mouse= | set paste
        echo "mouse mode off, paste mode on"
    endif
endfunction

" -------------------------------------------------------------
" :redir helpers
" -------------------------------------------------------------

" Redirect to register "x":
"   Redir @x
" Redirect to global variable "v":
"   Redir => v
" Disable previous redirection (any of these):
"   Redir
"   Redir end
"   Redir END
" While redirected, the 'more' option is reset to avoid the need
" to press <Space> after each screen of output.
command! -nargs=* -bar Redir
            \ if <q-args> == "" || <q-args> ==? "end" |
            \   set nomore |
            \   redir END |
            \ else |
            \   redir <args> |
            \   set nomore |
            \ endif

" -------------------------------------------------------------
" Tags
" -------------------------------------------------------------

" The semicolon gives permission to search up toward the root
" directory.  When followed by a path, the upward search terminates
" at this "stop directory"; otherwise, the search terminates at the root.
" Relative paths starting with "./" begin at Vim's current
" working directory or the directory of the currently open file.
" See :help file-searching for more details.
"
" Additional directories may be added, e.g.:
" set tags+=/usr/local/share/ctags/qt4
"
" Start at working directory or directory of currently open file
" and search upward, stopping at $HOME.  Secondly, search for a
" tags file upward from the current working directory, but stop
" at $HOME.
set tags=./tags;$HOME,tags;$HOME

" Use the following settings in a .ctags file.  With the
" --extra=+f, filenames are tags, too, so the following
" mappings will work when a file isn't in the path.
nnoremap <expr> gf empty(taglist(expand('<cfile>'))) ?
            \ "gf" : ":ta <C-r><C-f><CR>"
nnoremap <expr> <C-w>f empty(taglist(expand('<cfile>'))) ?
            \ "\<C-w>f" : ":stj <C-r><C-f><CR>"

" Convenience for building tag files in current directory.
command! -bar Ctags :wall|silent! !gentags

" The :tjump command is more convenient than :tag because it will pop up a
" menu if and only if multiple tags match.  Exchange the default meaning
" of CTRL-] and friends to use :tjump for the more convenient keystrokes,
" and to allow the old behavior via tha "g"-prefixed less-convenient keystrokes.
" Additionally, map the mouse to use the :tjump variants.

nnoremap g<C-]>   <C-]>
xnoremap g<C-]>   <C-]>
nnoremap  <C-]>  g<C-]>
xnoremap  <C-]>  g<C-]>

nnoremap g<LeftMouse>   g<C-]>
xnoremap g<LeftMouse>   g<C-]>
nnoremap <C-LeftMouse>  g<C-]>
xnoremap <C-LeftMouse>  g<C-]>

" -------------------------------------------------------------
" Cscope
" -------------------------------------------------------------

if has("cscope")
    set cscopeprg=/usr/bin/cscope
    " 0 ==> search cscope database(s) first, then tag file(s) if no matches.
    " 1 ==> search tag file(s) first, then cscope database(s) if no matches.
    set cscopetagorder=0

    " Do not set 'cscopetag'.  This option is intended to be a convenient way
    " to cause :tag, CTRL-], and "vim -t" to use the :cstag command and thus
    " consider cscope tags in addition to standard tags, but there are
    " side-effects that are hard to work around.  In particular, the :cstag
    " command behaves like :tjump, which is mostly a good thing in that a menu
    " pops up whenever there are multiple matching tags.  But this breaks the
    " ability to jump to the nth tag using ":{count}tag {ident}", and since the
    " change is hard-coded into the :tag command, there is no decent
    " work-around for certain scripts (such as the CtrlP plugin) that want to
    " programmatically select the nth tag.  Instead of setting 'cscopetag', use
    " mappings to avoid this unintentional breakage while still getting the
    " beneficial behavior of :tjump.

    " Because the system vimrc may turn on 'cscopetag', turn it off here.
    set nocscopetag

    " Turn off warnings for default cscope.out files.
    set nocscopeverbose
    " Add a database in current directory, or mentioned in CSCOPE_DB.
    if filereadable("cscope.out")
        cs add cscope.out
    elseif $CSCOPE_DB != ""
        cs add $CSCOPE_DB
    endif
    " Turn warnings back on for future "cs add" commands.
    set cscopeverbose

    " Setup which queries use the QuickFix window.
    " Flags:
    "   + Append results to QuickFix window.
    "   - Clear QuickFix window before appending results.
    "   0 Don't use QuickFix window.
    " Search types:
    " c - calls:    find all calls to the function name.
    " d - called:   find functions called by given function name.
    " e - egrep:    egrep search for text.
    " f - file:     open a filename.
    " g - global:   find global definition(s) for symbol.
    " i - includes: find files that include given filename.
    " s - symbol:   find all references to symbol.
    " t - text:     find all instances of the text.
    set cscopequickfix=c-,d-,e-,i-,s-,t-

    nnoremap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>:Copen<CR>
    nnoremap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>:Copen<CR>
    nnoremap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>:Copen<CR>
    nnoremap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
    nnoremap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
    nnoremap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>:Copen<CR>
    nnoremap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>:Copen<CR>
    nnoremap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>:Copen<CR>
endif

" -------------------------------------------------------------
" Window manipulation
" -------------------------------------------------------------

" Desired height of QuickFix window.
let g:QuickFixWinHeight = 10

" Desired height of a Location List window.
let g:LocListWinHeight = 5

" Re-layout windows in standard fashion.
" If zero arguments are passed, leaves number of columns unchanged.
" If one argument is passed, it's considered the number of window columns.
" Passing two or more arguments is illegal.
function! s:L(...)
    if a:0 > 1
        echoerr "Invalid number of columns in s:L"
        return
    elseif a:0 > 0
        let winColumns = a:1
    else
        let winColumns = 0
    endif
    if winColumns > 0
        let scrColumns = 81 * winColumns - 1
        let &columns = scrColumns
        redraw
        if &columns != scrColumns
            echoerr "Truncated; try spanning monitor boundary first"
        endif
        if winColumns == 1
            " Put current window at the top.
            wincmd K
        endif
    endif

    " Push QuickFix window (if any) to the bottom with standard size.
    let qfWinNum = GetQuickFixWinNum()
    if qfWinNum > 0
        let startedInQuickFixWin = (qfWinNum == winnr())
        if !startedInQuickFixWin
            execute qfWinNum . "wincmd w"
        endif
        wincmd J
        execute g:QuickFixWinHeight . "wincmd _"
        if !startedInQuickFixWin
            wincmd p
        endif
    endif

    " Resize any Location List windows to standard size.
    let llCmd = g:LocListWinHeight . "wincmd _"
    call WinDo("if IsLocListWin() | " . llCmd . " | endif")

    " Make other windows equally large.
    execute "normal \<C-W>="
endfunction
command! -nargs=? L call s:L(<f-args>)

" Make 1-column-wide layout.
command! -bar L1 call s:L(1)

" Make 2-column-wide layout.
command! -bar L2 call s:L(2)

" Make 3-column-wide layout.
command! -bar L3 call s:L(3)

" Make 4-column-wide layout.
command! -bar L4 call s:L(4)

" Make 5-column-wide layout.
command! -bar L5 call s:L(5)

" Toggle quickfix window.
function! QuickFixWinToggle()
    let numOpenWindows = winnr("$")
    if IsQuickFixWin()
        " Move to previous window before closing QuickFix window.
        wincmd p
    endif
    cclose
    if numOpenWindows == winnr("$")
        " Window was already closed, so open it.
        Copen
    endif
endfunction
nnoremap <silent> <C-Q><C-Q> :call QuickFixWinToggle()<CR>
command! -bar QuickFixWinToggle :call QuickFixWinToggle()

" Toggle location list window.
function! LocListWinToggle()
    let numOpenWindows = winnr("$")
    lclose
    if numOpenWindows == winnr("$")
        " Window was already closed, so open it.
        silent! Lopen
    endif
endfunction
nnoremap <silent> <C-Q><C-L> :call LocListWinToggle()<CR>
command! -bar LocListWinToggle :call LocListWinToggle()

" Like windo but restore the current window.
function! WinDo(command)
    let curWinNum = winnr()
    execute 'windo ' . a:command
    execute curWinNum . 'wincmd w'
endfunction
command! -nargs=+ -complete=command Windo call WinDo(<q-args>)

" Like bufdo but restore the current buffer.
function! BufDo(command)
    let currBuff=bufnr("%")
    execute 'bufdo if &bt==""|set ei-=Syntax|' . a:command . '|endif'
    execute 'buffer ' . currBuff
endfunction
command! -nargs=+ -complete=command Bufdo call BufDo(<q-args>)

" Like tabdo but restore the current tab.
function! TabDo(command)
    let currTab=tabpagenr()
    execute 'tabdo ' . a:command
    execute 'tabn ' . currTab
endfunction
command! -nargs=+ -complete=command Tabdo call TabDo(<q-args>)

" Force current window to be the only window (like <C-W>o).
" Avoids "Already only one window" error if only one window is showing.
function! OneWindow()
    DiffClose
    if winnr("$") > 1
        wincmd o
    endif
endfunction
command! -bar OneWindow call OneWindow()

" Avoid "Already only one window" errors.
nnoremap <silent> <C-W><C-O> :OneWindow<CR>
nnoremap <silent> <C-W>o     :OneWindow<CR>

" -------------------------------------------------------------
" Diff-related
" -------------------------------------------------------------

" Taken from :help :DiffOrig.  Shows unsaved differences between
" this buffer and original file.
command! -bar DiffOrig OneWindow | vert new | set bt=nofile |
            \ r ++edit # | 0d_ | diffthis | wincmd p | diffthis


" Return list of window numbers for all diff windows (in descending order).
function! GetDiffWinNums()
    let diffWinNums = []
    let curWinNum = winnr()
    for winNum in range(winnr("$"), 1, -1)
        execute "noautocmd " . winNum . "wincmd w"
        if &diff
            let diffWinNums += [winNum]
        endif
    endfor
    execute "noautocmd " . curWinNum . "wincmd w"
    return diffWinNums
endfunction

" Restore all diff windows and close them all except current window.
" Since folding is enabled for certain kinds of diffs, folds are
" expanded as part of restoring settings.
" Also deletes diff buffers that are known-transient.
function! DiffClose()
    for diffWinNum in GetDiffWinNums()
        let curWinNum = winnr()
        execute diffWinNum . "wincmd w"
        let name = bufname("%")
        if &modified || (curWinNum == diffWinNum)
            " Leave this window in-place, but turn off diff.
            diffoff
            normal zR
        else
            if &buftype == "nofile" || name =~# "^fugitive:"
                bwipeout
            else
                wincmd c
            endif
            if curWinNum > diffWinNum
                " Our window number decreased when we deleted the
                " smaller-numbered window.
                let curWinNum -= 1
            endif
        endif
        execute curWinNum . "wincmd w"
    endfor
endfunction
command! -bar DiffClose call DiffClose()

" Diff current window and "next" window or a newly split file.
function! Diff(filename)
    if a:filename != ""
        execute "vsplit " . a:filename
    endif
    if winnr("$") >= 2
        diffthis
        wincmd w
        diffthis
        wincmd p
    endif
endfunction
command! -bar -nargs=? Diff  call Diff(<q-args>)

" =============================================================
" Plugins
" =============================================================

" -------------------------------------------------------------
" Plugin enables
" -------------------------------------------------------------

" To disable one of the specified plugins below, define the corresponding
" g:EnableXxx variables below to be 0 (typically, this would be done in
" the per-user VIMRC_BEFORE file; see top of this file).
" For example, to disable the Powerline plugin, use the following:
"   let g:EnablePowerline = 0

if !exists("g:EnablePowerline")
    let g:EnablePowerline = 1
endif

if !exists("g:EnableUltiSnips")
    let g:EnableUltiSnips = 1
endif

" -------------------------------------------------------------
" BufExplorer
" -------------------------------------------------------------

let g:bufExplorerShowRelativePath = 1
let g:bufExplorerShowNoName = 1

" Unmap Surround plugin's "ds" mapping during BufExplorer operation.
augroup local_bufExplorer
    autocmd!
    autocmd BufEnter \[BufExplorer\] unmap ds
    autocmd BufLeave \[BufExplorer\] nmap ds <Plug>Dsurround
    autocmd BufEnter \[BufExplorer\] nunmap drw
    autocmd BufLeave \[BufExplorer\] nnoremap drw
                \ :<C-U>call DeleteRubbishWhitespace()<CR>
augroup END

" -------------------------------------------------------------
" bufkill
" -------------------------------------------------------------

" Don't define the slew of extra mappings built into this plugin.
let g:BufKillCreateMappings = 0

" -------------------------------------------------------------
" bufmru
" -------------------------------------------------------------
" Set to 1 to pre-load the number marks into buffers.
" Set to 0 to avoid this pre-loading.
let g:bufmru_nummarks = 0

function! BufmruUnmap()
    " Remove undesirable mappings, keeping the bare minimum for fast buffer
    " switching without needing the press <Enter> to exit bufmru "mode".
    let seq = maparg('<Space>', 'n')
    if seq =~# '.*idxz.*'
        let seq = matchstr(seq, '<SNR>\d\+_m_')
        execute "silent! nunmap " . seq . "e"
        execute "silent! nunmap " . seq . "!"
        execute "silent! nunmap " . seq . "<Esc>"
        execute "silent! nunmap " . seq . "y"
    endif
endfunction

augroup local_bufmru
    autocmd!
    autocmd VimEnter * call BufmruUnmap()
augroup END

" -------------------------------------------------------------
" CtrlP
" -------------------------------------------------------------

" No default mappings.
let g:ctrlp_map = ''

" Directory mode for launching ':CtrlP' with no directory argument:
"   0 - Don't manage the working directory (Vim's CWD will be used).
"       Same as ':CtrlP $PWD'.
let g:ctrlp_working_path_mode = 0

" Set to list of marker directories used for ':CtrlPRoot'.
" A marker signifies that the containing parent directory is a "root".  Each
" marker is probed from current working directory all the way up, and if
" the marker is not found, then the next marker is checked.
let g:ctrlp_root_markers = []

" Don't open multiple files in vertical splits.  Just open them, and re-use the
" buffer already at the front.
let g:ctrlp_open_multiple_files = '1vr'

" :C [path]  ==> :CtrlP [path]
command! -n=? -com=dir C CtrlP <args>

" :CD [path]  ==> :CtrlPDir [path]
command! -n=? -com=dir CD CtrlPDir <args>

" Define prefix mapping for CtrlP plugin so that buffer-local mappings
" for CTRL-P (such as in Tagbar) will override all CtrlP plugin mappings.
nmap <C-P> <SNR>CtrlP.....

" An incomplete mapping should do nothing.
nnoremap <SNR>CtrlP.....      <Nop>

nnoremap <SNR>CtrlP.....<C-B> :<C-U>CtrlPBookmarkDir<CR>
nnoremap <SNR>CtrlP.....c     :<C-U>CtrlPChange<CR>
nnoremap <SNR>CtrlP.....C     :<C-U>CtrlPChangeAll<CR>
nnoremap <SNR>CtrlP.....<C-D> :<C-U>CtrlPDir<CR>
nnoremap <SNR>CtrlP.....<C-F> :<C-U>CtrlPCurFile<CR>
nnoremap <SNR>CtrlP.....<C-L> :<C-U>CtrlPLine<CR>
nnoremap <SNR>CtrlP.....<C-M> :<C-U>CtrlPMRU<CR>
nnoremap <SNR>CtrlP.....m     :<C-U>CtrlPMixed<CR>

" Mnemonic: "open files"
nnoremap <SNR>CtrlP.....<C-O> :<C-U>CtrlPBuffer<CR>
nnoremap <SNR>CtrlP.....<C-P> :<C-U>CtrlP<CR>
nnoremap <SNR>CtrlP.....<C-Q> :<C-U>CtrlPQuickfix<CR>
nnoremap <SNR>CtrlP.....<C-R> :<C-U>CtrlPRoot<CR>
nnoremap <SNR>CtrlP.....<C-T> :<C-U>CtrlPTag<CR>
nnoremap <SNR>CtrlP.....t     :<C-U>CtrlPBufTag<CR>
nnoremap <SNR>CtrlP.....T     :<C-U>CtrlPBufTagAll<CR>
nnoremap <SNR>CtrlP.....<C-U> :<C-U>CtrlPUndo<CR>

" Transitional mappings to migrate from historical Command-T functionality.
" At first, redirect to CtrlP equivalent functionality.  Later, just
" provide an error message.  Eventually, remove this mappings.
nnoremap <leader><leader>t :<C-U>echoe "Use CTRL-P CTRL-P instead"<Bar>
            \ sleep 1<Bar>
            \ CtrlP<CR>

nnoremap <leader><leader>b :<C-U>echoe "Use CTRL-P CTRL-O instead"<Bar>
            \ sleep 1<Bar>
            \ CtrlPBuffer<CR>

" Reverse move and history binding pairs:
" - For consistency with other plugins that use <C-N>/<C-P> for moving around.
" - Because <C-J> is bound to the tmux prefix key, so it's best to map
"   that key to a less-used function.
let g:ctrlp_prompt_mappings = {
    \ 'PrtSelectMove("j")':   ['<C-N>', '<down>'],
    \ 'PrtSelectMove("k")':   ['<C-P>', '<up>'],
    \ 'PrtHistory(-1)':       ['<C-J>'],
    \ 'PrtHistory(1)':        ['<C-K>'],
    \ }

" Maximum height of filename window.
let g:ctrlp_max_height = 50

" -------------------------------------------------------------
" tcomment
" -------------------------------------------------------------

" Don't comment blank lines.
let g:tcommentBlankLines = 0

" Turn off the <c-_> and <Leader>_ mappings.
let g:tcommentMapLeader1 = ''
let g:tcommentMapLeader2 = ''

" Setup better linewise comments for Java.
let g:tcomment_types = {
            \ 'java': '// %s',
            \ }

" -------------------------------------------------------------
" fswitch
" -------------------------------------------------------------

function! SetFswitchVars(dst, locs)
    if !exists("b:fswitchdst")
        let b:fswitchdst = a:dst
    endif
    if !exists("b:fswitchlocs")
        let b:fswitchlocs = a:locs
    endif
endfunction

augroup local_fswitch
    autocmd!
    " There are lots more options - :help fswitch.  We use SetFswitchVars()
    " because we don't want to override values set by a .lvimrc file.
    autocmd BufEnter *.h call SetFswitchVars(
                \ 'c,cpp',
                \ 'reg:/pubinc/src/'
                \.',reg:/include/src/'
                \.',reg:/include.*/src/'
                \.',ifrel:|/include/|../src|')
    autocmd BufEnter *.c,*.cpp call SetFswitchVars(
                \ 'h',
                \ 'reg:/src/pubinc/'
                \.',reg:/src/include/'
                \.',reg:|src|include/**|'
                \.',ifrel:|/src/|../include|')
augroup END

" Switch to the file and load it into the current window.
nmap <silent> <Leader>of :FSHere<cr>

" Switch to the file and load it into the window on the right.
nmap <silent> <Leader>ol :FSRight<cr>

" Switch to the file and load it into a new window split on the right.
nmap <silent> <Leader>oL :FSSplitRight<cr>

" Switch to the file and load it into the window on the left.
nmap <silent> <Leader>oh :FSLeft<cr>

" Switch to the file and load it into a new window split on the left.
nmap <silent> <Leader>oH :FSSplitLeft<cr>

" Switch to the file and load it into the window above.
nmap <silent> <Leader>ok :FSAbove<cr>

" Switch to the file and load it into a new window split above.
nmap <silent> <Leader>oK :FSSplitAbove<cr>

" Switch to the file and load it into the window below.
nmap <silent> <Leader>oj :FSBelow<cr>

" Switch to the file and load it into a new window split below.
nmap <silent> <Leader>oJ :FSSplitBelow<cr>

" Compatibility for old Alternate.vim plugin.
command! -bar A FSHere

" -------------------------------------------------------------
" Grep
" -------------------------------------------------------------

let Grep_Skip_Dirs = '.svn .bzr .git .hg build bak export .undo'
let Grep_Skip_Files = '*.bak *~ .*.swp tags *.opt *.ncb *.plg ' .
    \ '*.o *.elf cscope.out *.ecc *.exe *.ilk *.out *.pyc build.out doxy.out'

" -------------------------------------------------------------
" Gundo
" -------------------------------------------------------------

nnoremap <Leader><Leader>u  :GundoToggle<CR>
let g:gundo_close_on_revert = 1

" -------------------------------------------------------------
" HiLinkTrace
" -------------------------------------------------------------

" Disable default mappings by having a pre-existing (but useless)
" mapping to <Plug>HiLinkTrace.
:nnoremap <SID>DisableHiLinkTrace <Plug>HiLinkTrace

" -------------------------------------------------------------
" indent-guides
" -------------------------------------------------------------

let g:indent_guides_enable_on_vim_startup = 0
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1
let g:IndentGuides = 0
let g:IndentGuidesMap = {}

function! AdjustIndentGuideColors()
    if hlexists("IndentGuidesEven") && hlexists("IndentGuidesOdd")
        let g:indent_guides_auto_colors = 0
    else
        let g:indent_guides_auto_colors = 1
    endif
endfunction

function! IndentGuidesForBuffer()
    if !g:IndentGuides
        return
    endif

    let key = LookupKey("b:IndentGuidesType", "g:IndentGuidesMap")

    if key == "<on>"
        call indent_guides#enable()
    else
        call indent_guides#disable()
    endif
endfunction

function! FixupIndentGuidesAutocommands()
    " We clear out the indent guides autocmds because they don't implement the
    " behavior that we desire.
    augroup indent_guides
      autocmd!
    augroup END
endfunction

augroup local_indent_guides
    autocmd!
    autocmd BufEnter * call IndentGuidesForBuffer()

    autocmd ColorScheme * call AdjustIndentGuideColors()
    autocmd VimEnter * call FixupIndentGuidesAutocommands()
augroup END

if exists("g:colors_name")
    call AdjustIndentGuideColors()
endif

" -------------------------------------------------------------
" localvimrc
" -------------------------------------------------------------

" Enable persistence of our decisions.
set viminfo+=!
let g:localvimrc_persistent = 2

" -------------------------------------------------------------
" lookupfile
" -------------------------------------------------------------

let g:LookupFile_MinPatLength = 0

" -------------------------------------------------------------
" LustyExplorer
" -------------------------------------------------------------

" g:LustyExplorerSuppressRubyWarning - if missing Ruby, don't complain
let g:LustyExplorerSuppressRubyWarning = 1

" -------------------------------------------------------------
" LustyJuggler
" -------------------------------------------------------------

" Show letters before filenames.
let g:LustyJugglerShowKeys = 'a'

" Prevents warning if Ruby not compiled in.
let g:LustyJugglerSuppressRubyWarning = 1

" Use alt-tab mode support.  Re-launching the juggler when it is already
" active will cycle through the most-recently-used list of buffers.
let g:LustyJugglerAltTabMode = 1

" Launch Lusty Juggler (also used for cycling through MRU buffers).
" This is in addition to \lj (the default mapping).
nnoremap <silent> <M-s> :LustyJuggler<CR>

" -------------------------------------------------------------
" manpageview
" -------------------------------------------------------------

" Default is "hsplit" for opening a horizontal split.
" The "reuse" option is irritating when accidentally pressing "K" in the
" window, since it forcibly closes that window after displaying the error.
"let g:manpageview_winopen = "reuse"

function! CheckManpageview()
    let isMan = maparg("\<Space>", "n") ==? "<C-F>"
    let isInfo = maparg("H", "n") =~? "manpageview"
    if isMan
        nnoremap <silent> <buffer> b           <C-B>
        nnoremap <silent> <buffer> f           <C-F>
        nnoremap <silent> <buffer> <           gg
        nnoremap <silent> <buffer> >           G
    endif
    if isMan || isInfo
        nnoremap <silent> <buffer> q           :q<CR>
    endif
endfunction

augroup local_manpageview
    autocmd!

    autocmd FileType man,info call CheckManpageview()
augroup END

" -------------------------------------------------------------
" netrw
" -------------------------------------------------------------

" Setup xdg-open as the tool to open urls whenever we can, if nothing is set up.
" This makes using 'gx' a little more sane environments outside of Gnome and
" KDE.
function! SetupBrowseX()
    if !exists("g:netrw_browsex_viewer") && executable("xdg-open")
        let g:netrw_browsex_viewer = "xdg-open"
    endif
endfunction

augroup local_netrw
    autocmd!
    autocmd VimEnter * call SetupBrowseX()
augroup END

" Get selected text in visual mode.  Taken from xolox's answer in
" <http://stackoverflow.com/a/6271254/683080>.
function! s:GetSelectedText()
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  return join(lines, "\n")
endfunction

if has("python") || has("python3")
    " Turn off netrw's gx.
    let g:netrw_nogx = 1

    function! ExtractUrl(text)
    python << endpython
import re
text = vim.eval("a:text")
vim.command("let l:result = ''")

# Regex from:
#   <http://daringfireball.net/2010/07/improved_regex_for_matching_urls>
# Updated version:
#   <https://gist.github.com/gruber/249502/>
urlRe = re.compile(
    ur"(?i)\b("
    ur"(?:[a-z][\w-]+:(?:/{1,3}|[a-z0-9%])|www\d{0,3}[.]|"
        ur"[a-z0-9.\-]+[.][a-z]{2,4}/)"
    ur"(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+"
    ur"(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|"
        ur"""[^\s`!()\[\]{};:'".,<>?\u00AB\u00BB\u201C\u201D\u2018\u2019])"""
    ur")")

m = urlRe.search(text)
if m:
    vim.command("let l:result = '" + m.group(1).replace("'", "''") + "'")
endpython

        return l:result
    endfunction

    function! s:SmartOpen(mode) range
        if a:mode ==# 'n'
            let uri = ExtractUrl(expand("<cWORD>"))
            if l:uri == ""
                return
            endif
        else
            let uri = s:GetSelectedText()
        endif

        call netrw#NetrwBrowseX(l:uri, 0)
    endfunction

    nnoremap gx :call <SID>SmartOpen('n')<CR>
    xnoremap gx <C-C>:call <SID>SmartOpen('v')<CR>
endif

nnoremap <silent> <Leader>fe :Explore<CR>

" -------------------------------------------------------------
" OmniCppComplete
" -------------------------------------------------------------

" 'OmniCpp_SelectFirstItem'
"   0 ==> initially deselects first item in the menu.
"   1 ==> initially selects first item in the menu.
" default: let OmniCpp_SelectFirstItem = 0

" Work-around for Doxygen comments.  Forces Doxygen comments to be
" skipped for Omnicompletion.
function! omni#cpp#utils#IsCursorInCommentOrString()
    let attr= '\C\<cComment\|\<cCppString\|\<cIncluded\|\<doxygen'
    return match(synIDattr(synID(line("."), col(".")-1, 1), "name"), attr) >= 0
endfunc


" -------------------------------------------------------------
" Powerline
" -------------------------------------------------------------

" Detect if Powerline-related configuration is out-of-date such that
" we need to clear the cache.

" Determine "required" version of Powerline cached information.
" This may be set in |VIMRC_BEFORE| files for a per-user tag field; if
" not, the value defaults to "none".
" If you change any Powerline-related settings, update this variable
" to ensure the stale cached data will be deleted.  For example::
"   let g:PowerlineRequiredCacheTag = "2013-11-11"
if !exists("g:PowerlineRequiredCacheTag")
    let g:PowerlineRequiredCacheTag = "none"
endif

" Append Powerline cache tag for global vimrc settings.
" Generally, this will be a colon, the date, and optionally a dot and a one-up
" sequence number appended in case of multiple changes in a single day.
" E.g.:
"   :2013-11-11
"   :2013-11-11.1
" This vimfiles-wide setting will be appended to whatever value may have been
" set via a |VIMRC_BEFORE| file.
let g:PowerlineRequiredCacheTag .= ":2013-11-14"

" This file records the current Powerline "tag".
let g:PowerlineCacheTagFile = expand('$VIM_CACHE_DIR/PowerlineCacheTag')

" Location of desired Powerline cache directory.
let g:PowerlineDesiredCacheDir = expand('$VIM_CACHE_DIR/PowerlineCache')

" Write a tag to track the "version" of the Powerline cache.
function! PowerlineCacheTagWrite(tag)
    call writefile([a:tag], g:PowerlineCacheTagFile)
endfunction

" Read back the stored Powerline tag value.
" Return "" if not found or couldn't read.
function! PowerlineCacheTagRead()
    if filereadable(g:PowerlineCacheTagFile)
        let lines = readfile(g:PowerlineCacheTagFile, "", 1)
        if len(lines) == 1
            return lines[0]
        endif
    endif
    return ""
endfunction

if g:EnablePowerline
    " Nail down directory for Powerline's cache so we know where it lives.
    if !isdirectory(g:PowerlineDesiredCacheDir)
        call mkdir(g:PowerlineDesiredCacheDir, "p")
    endif
    if isdirectory(g:PowerlineDesiredCacheDir)
        " We've got a cache directory, so tell Powerline about it.
        let g:Powerline_cache_dir = g:PowerlineDesiredCacheDir
        if PowerlineCacheTagRead() != g:PowerlineRequiredCacheTag
            " Wipe out all Powerline cache files.
            for p in split(glob(g:Powerline_cache_dir .
                        \ "/Powerline_*.cache", 1), '\n')
                silent! call delete(p)
            endfor
            call PowerlineCacheTagWrite(g:PowerlineRequiredCacheTag)
        endif
    else
        echomsg "Why is " . g:PowerlineDesiredCacheDir . " not available?"
    endif
    " Remove segments that are redundant (like "mode_indicator") or
    " which are essentially static indicators that don't warrant taking
    " up room.
    call Pl#Theme#RemoveSegment('mode_indicator')
    call Pl#Theme#RemoveSegment('fileformat')
    call Pl#Theme#RemoveSegment('fileencoding')
    call Pl#Theme#RemoveSegment('filetype')

    " Move 'fileinfo' and 'syntastic:errors' after the Truncate() to keep the
    " basename of the file visible as long as possible.  If we start using
    " the Syntastic plugin, this may have to be adjusted so that syntastic
    " output is truncated first.  This preserves the order found in Powerline's
    " autoload/Powerline/Themes/default.vim file.
    call Pl#Theme#RemoveSegment('fileinfo')
    call Pl#Theme#InsertSegment('fileinfo', 'before', 'tagbar:currenttag')
    call Pl#Theme#RemoveSegment('syntastic:errors')
    call Pl#Theme#InsertSegment('syntastic:errors', 'before',
                \               'tagbar:currenttag')

    " Add some non-default segments.

    " Indicate trailing whitespace in file.
    call Pl#Theme#InsertSegment('ws_marker', 'after', 'lineinfo')

    " Provide short forms of mode names, if a user adds back in the
    " mode_indicator.
    let g:Powerline_mode_n = 'N'
    let g:Powerline_mode_i = 'I'
    let g:Powerline_mode_R = 'R'
    let g:Powerline_mode_v = 'V'
    let g:Powerline_mode_V = 'V⋅LINE'
    let g:Powerline_mode_cv = 'V⋅BLOCK'
    let g:Powerline_mode_s = 'SELECT'
    let g:Powerline_mode_S = 'S⋅LINE'
    let g:Powerline_mode_cs = 'S⋅BLOCK'
else
    " Powerline will not load if this variable is defined:
    let g:Powerline_loaded = 1
endif

" -------------------------------------------------------------
" Project
" -------------------------------------------------------------

" 'g:proj_window_width'
"   Width of project window (default 24).
" 'g:proj_window_increment'
"   Increment by which to increase Window when pressing <space> (default 100).

" Remove 'b' flag from default 'imstb' to turn off broken browse()-based
" directory selection on Linux.
" g:proj_flags meanings (subset of flags - see help for others):
"   b - use browse() for dirs (bad on Windows, Linux).
"   c - close Project Window when selecting a file.
"   F - float Project Window.
"   g - create <F12> mapping for toggling Project Window.
"   i - display filename and working directory in command line.
"   m - modify CTRL-W_o to keep Project Window visible too.
"   s - use syntax highlighting in Project Window.
"   S - sorting for refresh and create.
"   t - toggle size of window instead of increase-only.
"   T - put subproject folds at top of fold when refreshing.
"   v - use vimgrep instead of grep.
let g:proj_flags = 'csStTv'
let g:proj_window_width = 40
nmap <silent> <F8>        <Plug>ToggleProject
nmap <silent> <C-Q><C-P>  <Plug>ToggleProject
nmap <silent> <C-Q>p      <Plug>ToggleProject

" -------------------------------------------------------------
" Rainbow Parentheses
" -------------------------------------------------------------

" Adapt rainbow parentheses colors for background color.
" TODO this is not fully dynamic; the colors become permanent when the
" plugin first loads.
function! AdaptRainbow()
    if &background == "dark"
        let g:rbpt_colorpairs = g:rbpt_colorpairs_dark
    else
        let g:rbpt_colorpairs = g:rbpt_colorpairs_light
    endif
    let g:rbpt_max = len(g:rbpt_colorpairs)
endfunction

if &t_Co >= 256 || has("gui_running")
    let g:rbpt_colorpairs_dark = [
                \ [129,         'purple'],
                \ ['magenta',   'magenta1'],
                \ [111,         'slateblue1'],
                \ ['cyan',      'cyan1'],
                \ [48,          'springgreen1'],
                \ ['green',     'green1'],
                \ [154,         'greenyellow'],
                \ ['yellow',    'yellow1'],
                \ [214,         'orange1'],
                \ ]
    " TODO Choose better light-background colors for rainbow parentheses.
    let g:rbpt_colorpairs_light = [
                \ [129,         'purple'],
                \ ['magenta',   'magenta1'],
                \ [111,         'slateblue1'],
                \ ['cyan',      'cyan1'],
                \ [48,          'springgreen1'],
                \ ['green',     'green1'],
                \ [154,         'greenyellow'],
                \ ['yellow',    'yellow1'],
                \ [214,         'orange1'],
                \ ]
else
    let g:rbpt_colorpairs_dark = [
                \ ['magenta',   'purple'],
                \ ['cyan',      'magenta1'],
                \ ['green',     'slateblue1'],
                \ ['yellow',    'cyan1'],
                \ ['red',       'springgreen1'],
                \ ['magenta',   'green1'],
                \ ['cyan',      'greenyellow'],
                \ ['green',     'yellow1'],
                \ ['yellow',    'orange1'],
                \ ]
    " TODO Choose better light-background colors for rainbow parentheses.
    let g:rbpt_colorpairs_light = [
                \ ['magenta',   'purple'],
                \ ['cyan',      'magenta1'],
                \ ['green',     'slateblue1'],
                \ ['yellow',    'cyan1'],
                \ ['red',       'springgreen1'],
                \ ['magenta',   'green1'],
                \ ['cyan',      'greenyellow'],
                \ ['green',     'yellow1'],
                \ ['yellow',    'orange1'],
                \ ]
endif
call AdaptRainbow()

" Adapt colors of rainbow parentheses when colorscheme changes.
augroup local_rainbow
    autocmd!
    autocmd ColorScheme * call AdaptRainbow()
augroup END


" -------------------------------------------------------------
" RunView
" -------------------------------------------------------------

" Setup Bash as default view to run.
let g:runview_filtcmd="bash"


" -------------------------------------------------------------
" Session
" -------------------------------------------------------------

let g:session_directory = $VIM_CACHE_DIR . '/sessions'
let g:session_autoload = 'yes'
let g:session_autosave = 'no'
let g:session_verbose_messages = 0
let g:session_command_aliases = 1

" Lifted from session.
function! s:unescape(s)
    " Undo escaping of special characters (preceded by a backslash).
    let s = substitute(a:s, '\\\(.\)', '\1', 'g')
    " Expand any environment variables in the user input.
    let s = substitute(s, '\(\$[A-Za-z0-9_]\+\)', '\=expand(submatch(1))', 'g')
    return s
endfunction

function! SaveSessionNoDefault(name, bang, command) abort
    " Normally, don't let session save to the default session, unless:
    "   * The session is already active, or
    "   * The user ran the command with '!', or
    "   * The default session already exists.
    if a:bang != '!'
        let name = s:unescape(a:name)
        if empty(name)
            let name = xolox#session#find_current_session()
        endif
        if empty(name)
            let defaultSessionFound = 0
            for session in xolox#session#get_names()
                if session ==? g:session_default_name
                    let defaultSessionFound = 1
                    break
                endif
            endfor
            if defaultSessionFound != 1
                call xolox#misc#msg#warn("Please provide a session name.")
                return
            endif
        endif
    endif

    call xolox#session#save_cmd(a:name, a:bang, a:command)
endfunction

function! OverrideSaveSession()
    command! -bar -bang -nargs=?
                \ -complete=customlist,xolox#session#complete_names
                \ SaveSession
                \ call SaveSessionNoDefault(<q-args>, <q-bang>, 'SaveSession')
    if g:session_command_aliases
        command! -bar -bang -nargs=?
                    \ -complete=customlist,xolox#session#complete_names
                    \ SessionSave
                    \ call SaveSessionNoDefault(
                    \   <q-args>, <q-bang>, 'SessionSave')
    endif
endfunction

augroup local_session
    autocmd!
    autocmd VimEnter * call OverrideSaveSession()
augroup END

" -------------------------------------------------------------
" Syntastic
" -------------------------------------------------------------

if &termencoding ==# 'utf-8' || &encoding ==# 'utf-8'
    let g:syntastic_error_symbol='✘'
    let g:syntastic_warning_symbol='⚠'
endif

let g:syntastic_enable_balloons = 1
let g:syntastic_quiet_warnings = 1
let g:syntastic_enable_highlighting = 0

function! ReplacePowerlineSyntastic()
    function! Powerline#Functions#syntastic#GetErrors(line_symbol) " {{{
        if ! exists('g:syntastic_stl_format')
            " Syntastic hasn't been loaded yet
            return ''
        endif

        " Temporarily change syntastic output format
        let old_stl_format = g:syntastic_stl_format
        if exists('g:Powerline_syntastic_stl_format')
            let g:syntastic_stl_format = g:Powerline_syntastic_stl_format
        else
            let g:syntastic_stl_format = '%E{%ee}%B{ }%W{%ww}'
        endif

        let ret = SyntasticStatuslineFlag()

        let g:syntastic_stl_format = old_stl_format

        return ret
    endfunction " }}}
endfunction

function! SyntasticFinalSetup()
    let g:syntastic_loc_list_height = g:LocListWinHeight
    call ReplacePowerlineSyntastic()
endfunction

let g:syntastic_mode_map = {
            \ 'mode': 'passive',
            \ 'active_filetypes': ['python', 'ruby'],
            \ 'passive_filetypes': []
            \ }

augroup local_syntastic
    autocmd!
    autocmd VimEnter * call SyntasticFinalSetup()
augroup END

" -------------------------------------------------------------
" surround
" -------------------------------------------------------------

" No customizations.

" -------------------------------------------------------------
" Tagbar
" -------------------------------------------------------------

" Must have ctags of some kind or keep plugin from running.
let usingTagbar = executable("ctags") || executable("ctags.exe")
if !usingTagbar
    " Tagbar doesn't actually care about the value... only the existence
    " of the variable.
    let g:loaded_tagbar = 'no'
endif

" Tagbar settings
let g:tagbar_width = 40
let g:tagbar_autoclose = 1
let g:tagbar_autofocus = 1

nnoremap <silent> <S-F8>     :TagbarToggle<CR>
nnoremap <silent> <C-Q><C-T> :TagbarToggle<CR>
nnoremap <silent> <C-Q>t     :TagbarToggle<CR>

" Support for reStructuredText, if available.
if executable("rst2ctags")
    let g:rst2ctags = 'rst2ctags'
else
    let g:rst2ctags = $VIMFILES . '/tool/rst2ctags/rst2ctags.py'
endif

" Local tagbar settings.  Assign g:tagbar_type_rst to this value to enable
" support for .rst files in tagbar.
let g:local_tagbar_type_rst = {
    \ 'ctagstype': 'rst',
    \ 'ctagsbin' : g:rst2ctags,
    \ 'ctagsargs' : '-f - --sort=yes',
    \ 'kinds' : [
        \ 's:sections',
        \ 'i:images'
    \ ],
    \ 'sro' : '|',
    \ 'kind2scope' : {
        \ 's' : 'section',
    \ },
    \ 'sort': 0,
\ }

" Enable support for .rst files in tagbar by default.  Disable if desired in
" your |VIMRC_AFTER| file via:
"   unlet g:tagbar_type_rst.
let g:tagbar_type_rst = g:local_tagbar_type_rst

" Support for markdown, if available.
if executable("markdown2ctags")
    let g:markdown2ctags = 'markdown2ctags'
else
    let g:markdown2ctags = $VIMFILES . '/tool/markdown2ctags/markdown2ctags.py'
endif

" Local tagbar settings.  Assign g:tagbar_type_markdown to this value to enable
" support for markdown files in tagbar.
let g:local_tagbar_type_markdown = {
    \ 'ctagstype': 'markdown',
    \ 'ctagsbin' : g:markdown2ctags,
    \ 'ctagsargs' : '-f - --sort=yes',
    \ 'kinds' : [
        \ 's:sections',
        \ 'i:images'
    \ ],
    \ 'sro' : '|',
    \ 'kind2scope' : {
        \ 's' : 'section',
    \ },
    \ 'sort': 0,
\ }

" Enable support for markdown files in tagbar by default.  Disable if desired in
" your |VIMRC_AFTER| file via:
"   unlet g:tagbar_type_markdown.
let g:tagbar_type_markdown = g:local_tagbar_type_markdown

" -------------------------------------------------------------
" textobj-diff
" -------------------------------------------------------------

" Don't use the many default global mappings.
let g:textobj_diff_no_default_key_mappings = 1

" Create buffer-local mappings for desired functionality.
function! CreateTextobjDiffLocalMappings()
    " Make file- and hunk-selection mappings for diffs.
    for m in ['x', 'o']
        let cmd = 'silent! ' . m . 'map <buffer> '
        execute cmd . 'adf <Plug>(textobj-diff-file)'
        execute cmd . 'idf <Plug>(textobj-diff-file)'
        execute cmd . 'adh <Plug>(textobj-diff-hunk)'
        execute cmd . 'idh <Plug>(textobj-diff-hunk)'
    endfor
    " Map ]] and friends to textobj-diff for jumping between hunks.
    for m in ['n', 'x', 'o']
        let cmd = 'silent! ' . m . 'map <buffer> '
        execute cmd . '[] <Plug>(textobj-diff-hunk-P)'
        execute cmd . ']] <Plug>(textobj-diff-hunk-n)'
        execute cmd . '[[ <Plug>(textobj-diff-hunk-p)'
        execute cmd . '][ <Plug>(textobj-diff-hunk-N)'
    endfor
endfunction


" -------------------------------------------------------------
" UltiSnips
" -------------------------------------------------------------

" Paths found earlier in runtimepath have higher snippet priority.
" In order to remove snippets distributed with UltiSnips, the
" directory "pre-bundle/clearsnippets" will be earlier in the
" runtimepath.

let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" Use a:ultiSnipsSnippetDirectories as buffer-local value for UltiSnips's
" global g:ultiSnipsSnippetDirectories.  Typically invoked from a .lvimrc
" file as:
"   call SetLocalSnippetDirectories(["UltiSnips", "UltiSnips/Project"])
" where "UltiSnips/Project" will take precedence over snippets that live
" directly in "UltiSnips" directories.
function! SetLocalSnippetDirectories(ultiSnipsSnippetDirectories)
    let b:UltiSnipsSnippetDirectories = a:ultiSnipsSnippetDirectories
endfunction

" Helper to be called from your .lvimrc.
function! AppendSnippetDirs(snippetDirs)
    if !exists("b:UltiSnipsSnippetDirectories")
        let b:UltiSnipsSnippetDirectories = copy(g:UltiSnipsSnippetDirectories)
    endif

    if type(a:snippetDirs) == type([])
        let b:UltiSnipsSnippetDirectories += a:snippetDirs
    else
        let b:UltiSnipsSnippetDirectories += [a:snippetDirs]
    endif
endfunction

function! FindSnippetTemplate()
    " Searches for a template in this order:
    "
    " - template_<filetype>.<filename>
    " - template_<filetype>.<ext>, where <ext> is successively trimmed
    "   attempting to match the most specific extension.  For example,
    "   foo.snippets.py would result in looking for template_python.snippets.py
    "   followed by template_python.py.
    " - template_<filetype>
    "
    " As soon as a match is made, the snippet name is returned.  If nothing
    " matches, an empty string is returned.
    "
    " If the buffer has no name, we'll only look for template_<filetype>.  If
    " there's no filetype set for the buffer, we'll return an empty string since
    " it doesn't make sense to try and look up a template.
    let l:snippets = UltiSnips#SnippetsInCurrentScope()
    let l:filename = expand("%:t")

    " There's no use proceeding if there's no filetype set.
    if &filetype == ""
        return ""
    endif

    if len(l:filename) != 0
        let l:start = 0
        let l:idx = 0

        while l:idx >= 0
            let l:snippetName = "template_" . &filetype .
                        \ "." . strpart(l:filename, l:idx)

            if has_key(l:snippets, l:snippetName)
                return l:snippetName
            else
                let l:start = l:idx
                let l:idx = stridx(l:filename, ".", l:start+1)
                if l:idx >= 0
                    let l:idx = l:idx + 1
                endif
            endif
        endwhile
    endif

    let l:snippetName = "template_" . &filetype
    if has_key(l:snippets, l:snippetName)
        return l:snippetName
    endif

    return ""
endfunction

function! TriggerSnippetTemplate()
    " Looks for a snippet named "template_<filetype>.<ext>", and expands it
    " if it exists.  See FindSnippetTemplate() for details about the lookup.
    " The idea here is to provide a good default template for various file
    " types.
    let l:filename = expand("%:t")

    if len(l:filename) == 0
        return 0
    endif

    let l:snippetName = FindSnippetTemplate()
    if l:snippetName != ""
        startinsert
        call feedkeys(l:snippetName .
                    \ eval('"\' . g:UltiSnipsExpandTrigger . '"'))
        return 1
    endif

    echo "No template found"
    return 0
endfunction

function! ExpandSnippetOrSkel()
    let result = UltiSnips#ExpandSnippet()
    if !g:ulti_expand_res && getline('.') == "skel"
        let curPos=getpos('.')
        call setline('.', '')

        if TriggerSnippetTemplate()
            return ""
        endif

        call setline('.', 'skel')
        call setpos('.', curPos)
    endif

    return l:result
endfunction

function! ExpandSnippetOrJumpOrSkel()
    let result = UltiSnips#ExpandSnippetOrJump()
    if !g:ulti_expand_or_jump_res && getline('.') == "skel"
        let curPos=getpos('.')
        call setline('.', '')

        if TriggerSnippetTemplate()
            return ""
        endif

        call setline('.', 'skel')
        call setpos('.', curPos)
    endif

    return l:result
endfunction

function! SetupUltiSnipsMapping()
    " Override the expand trigger mapping for UltiSnips to provide the
    " file skeleton functionality.
    if g:UltiSnipsExpandTrigger == g:UltiSnipsJumpForwardTrigger
        exec "inoremap <silent> " . g:UltiSnipsExpandTrigger .
                    \ " <C-R>=ExpandSnippetOrJumpOrSkel()<cr>"
    else
        exec "inoremap <silent> " . g:UltiSnipsExpandTrigger .
                    \ " <C-R>=ExpandSnippetOrSkel()<cr>"
    endif
endfunction

if g:EnableUltiSnips
    augroup local_ultisnips
        autocmd!

        " Store last active help buffer number when leaving the help window.
        autocmd VimEnter * call SetupUltiSnipsMapping()
    augroup END
else
    " UltiSnips will not load if this variable is defined:
    let g:did_UltiSnips_after = 1
    let g:did_UltiSnips_autoload = 1
    let g:did_UltiSnips_plugin = 1

    " The definition of UltiSnips#FileTypeChanged is in
    " after/plugin/UltiSnips.vim to prevent an error about the function name not
    " matching the script file name.
endif

" -------------------------------------------------------------
" vis
" -------------------------------------------------------------

" Enables the // command from visual block mode.
let g:vis_WantSlashSlash = 1

" -------------------------------------------------------------
" visswap
" -------------------------------------------------------------

" Change default CTRL-X to CTRL-T (for "trade") to avoid conflict
" with swapit plugin.
" @todo Consider other mappings...
xmap <silent> <C-T> <Plug>VisualSwap

" -------------------------------------------------------------
" vcscommand
" -------------------------------------------------------------

" Use \s for vcscommand sets.  This was originally done to avoid
" a conflict with EnhancedCommentify's \c and feels more like "svn".
let VCSCommandMapPrefix = '<Leader>s'

" When doing diff, force two-window layout with old on left.
nmap <silent> <Leader>sv :OneWindow<CR><Plug>VCSVimDiff<C-W>H<C-W>w

" -------------------------------------------------------------
" winmanager
" -------------------------------------------------------------

" :nnoremap <C-W><C-T>   :WMToggle<CR>
" :nnoremap <C-W><C-F>   :FirstExplorerWindow<CR>
" :nnoremap <C-W><C-B>   :BottomExplorerWindow<CR>

" =============================================================
" Language and filetype setup
" =============================================================

set spelllang=en_us

" -------------------------------------------------------------
" Highlight setup
" -------------------------------------------------------------

" Define a nice highlighting color for matches.
" From Nuvola:
" highlight NonText gui=BOLD guifg=#4000FF guibg=#EFEFF7
"highlight HG_Background gui=BOLD guibg=#EFEFF7

" Return true if groupName exists.
"   Calling hlexists() ought to suffice, but it can return true even though
"   groupName has been cleared.  At startup, hlexists() correctly returns false
"   for a groupName that has never been defined, but any time after groupName
"   has been defined, hlexists() will be permanently stuck returning true,
"   even after ``:highlight clear`` has clobbered the group's definition.
"   The problem is that after ``:highlight clear``, the group still looks
"   defined, but it now has the inactive value "xxx cleared".
function! HighlightGroupExists(groupName)
    let haveGroup = 0
    if hlexists(a:groupName)
        let regA = getreg("a")
        let regTypeA = getregtype("a")
        redir @a
        execute "silent highlight " . a:groupName
        redir END
        let groupDef = @a
        call setreg("a", regA, regTypeA)
        if groupDef !~# "xxx cleared$"
            let haveGroup = 1
        endif
    endif
    return haveGroup
endfunction

function! HighlightDefineGroups()
    if !HighlightGroupExists("HG_Subtle")
        if &background == "dark"
            hi HG_Subtle  ctermfg=brown  ctermbg=darkgray  guibg=red       guifg=white
        else
            hi HG_Subtle  ctermfg=yellow ctermbg=lightgray guibg=#efeff7
        endif
    endif
    if !HighlightGroupExists("HG_Warning")
        if &background == "dark"
            hi HG_Warning ctermfg=lightred  ctermbg=darkgray  guibg=#505000   guifg=lightgray
        else
            hi HG_Warning ctermfg=yellow ctermbg=lightgray guibg=#ffffdd
        endif
    endif
    if !HighlightGroupExists("HG_Error")
        if &background == "dark"
            hi HG_Error   ctermfg=white  ctermbg=darkred  guibg=red       guifg=white
        else
            hi HG_Error   ctermfg=red    ctermbg=lightgray guibg=#ffe0e0
        endif
    endif
endfunction

:autocmd ColorScheme * call HighlightDefineGroups()
call HighlightDefineGroups()

let g:HighlightNames = split("commas keywordspace longlines tabs trailingspace")
let g:HighlightRegex_longlines1 = '\%>61v.*\%<82v\(.*\%>80v.\)\@='
let g:HighlightRegex_longlines2 = '\%>80v.\+'
let g:HighlightRegex_tabs = '\t'
let g:HighlightRegex_commas = ',\S'
let g:HighlightRegex_keywordspace = '\(\<' . join(
            \ split('for if while switch'), '\|\<') . '\)\@<=('
let g:HighlightRegex_trailingspace = '\s\+\%#\@<!$'

" Invoke as: HighlightNamedRegex('longlines1', 'HG_Warning', 1)
" The linkedGroup comes from the highlight groups (:help highlight-groups),
" or from HighlightDefinGroups() above.
" Highlight groups to consider:
"   Error       very intrusive group with reverse-video red.
"   ErrorMsg    less intrusive, red foreground (invisible for whitespace).
"   NonText     non-intrusive, fairly subtle.
function! HighlightNamedRegex(regexName, linkedGroup, enable)
    exe "silent! syntax clear Highlight_" . a:regexName
    if a:enable
        exe "syntax match Highlight_" . a:regexName .
                    \ " /" . g:HighlightRegex_{a:regexName} . "/"
        exe "highlight link Highlight_" . a:regexName . " " . a:linkedGroup
    endif
endfunction

function! Highlight_commas(enable)
    call HighlightNamedRegex('commas', 'HG_Error', a:enable)
endfunction

function! Highlight_keywordspace(enable)
    call HighlightNamedRegex('keywordspace', 'HG_Error', a:enable)
endfunction

function! Highlight_longlines(enable)
    call HighlightNamedRegex('longlines1', 'HG_Warning', a:enable)
    call HighlightNamedRegex('longlines2', 'HG_Error', a:enable)
endfunction

function! Highlight_tabs(enable)
    call HighlightNamedRegex('tabs', 'HG_Error', a:enable)
endfunction

function! Highlight_trailingspace(enable)
    call HighlightNamedRegex('trailingspace', 'HG_Subtle', a:enable)
endfunction

function! HighlightArgs(ArgLead, CmdLine, CursorPos)
    let noNames = []
    for name in g:HighlightNames
        let noNames = add(noNames, 'no' . name)
    endfor
    return join(g:HighlightNames + noNames + ['*', 'no*'], "\n")
endfunction

function! Highlight(...)
    let i = 0
    while i < a:0
        let name = a:000[i]
        let enable = 1
        if strpart(a:000[i], 0, 2) == 'no'
            let enable = 0
            let name = strpart(name, 2)
        endif
        if name == '*'
            for f in g:HighlightNames
                call Highlight_{f}(enable)
            endfor
        else
            let funcName = 'Highlight_' . name
            if exists('*' . funcName)
                call {funcName}(enable)
            else
                echoerr "Invalid highlight option " . name
            endif
        endif
        let i = i + 1
    endwhile
endfunction
command! -nargs=* -complete=custom,HighlightArgs
            \ Highlight call Highlight(<f-args>)

" -------------------------------------------------------------
" Spell-checking.
" -------------------------------------------------------------

" 0 - Disable changing of 'spell' option for all filetypes.
" 1 - Enable changing of 'spell' option, subject to g:SpellMap below.
" Override this in per-user configuration files to disable automatic setup of
" spell-checking:
"   let g:Spell = 0
let g:Spell = 1

" Determines spell-check setting for a file.
" Starting with an initial key, the dictionary is used to map the key to a
" subsequent key until the key is not found.  Then, if the key is
" "<on>", spell-checking will be turned on for this file; if the key is
" "<off>", spell-checking will be turned off for this file; otherwise, nothing
" is done.
" Keys are either filetypes (as found in &filetype) or strings of the form
" "<group_or_directive>".  Groups are useful to allow control of similar
" filetypes.  Some expected groups are:
"
" - "<source>"      Source files
" - "<*>"           Used when &filetype is not in g:SpellMap
"
" The initial key is one of the following:
" - &filetype           (if &filetype is in g:SpellMap)
" - b:SpellType         (if b:SpellType exists)
" - "<*>"               (otherwise)
" Examples:
"   Turn off spell-checking for just "C" source code:
"     let g:SpellMap["c"] = "<off>"
"   Turn off spell-checking for the entire "<source>" group:
"     let g:SpellMap["<source>"] = "<off>"

let g:SpellMap = {}

" Implements the lookup scheme described above. varname is expected to be the
" buffer-local variable (like "b:SpellType"), and mapname is the name of the
" map used to track the mapping (e.g. "g:SpellMap").
"
" We use names instead of the actual variable so that we can check for the
" existence of varname, and so we can provide a better error if a loop is
" detected in mapname.
function! LookupKey(varname, mapname)
    let globalMap = eval(a:mapname)

    " Track keys we've seen before.
    let l:sawKey = {}

    if has_key(l:globalMap, &filetype)
        let key = &filetype
    elseif exists(a:varname)
        let key = eval(a:varname)
    else
        let key = "<*>"
    endif

    while has_key(l:globalMap, key)
        if has_key(l:sawKey, key)
            echoerr "Loop in " . mapname . " for key:" key
            return
        endif
        let l:sawKey[key] = 1
        let key = l:globalMap[key]
    endwhile

    if key == "<on>" || key == "<off>"
        return key
    endif

    return ""
endfunction

" Adjust 'spell' setting for file (see g:SpellMap for details).
" Generally called from autocmd on filetype change.
function! SetSpell()
    " Bail out if 'spell' setting is globally disabled.
    if ! g:Spell
        return
    endif

    let key = LookupKey("b:SpellType", "g:SpellMap")

    if key == "<on>"
        setl spell
    elseif key == "<off>"
        setl nospell
    endif
endfunction

" -------------------------------------------------------------
" Settings common to all filetypes.
" -------------------------------------------------------------
function! SetupCommon()
    " Setup formatoptions:
    "   c - auto-wrap comments to textwidth.
    "   q - allow formatting of comments with 'gq'.
    "   l - long lines are not broken in insert mode.
    "   n - recognize numbered lists.
    setlocal formatoptions+=cqln

    " This flag was added in Vim 7.3.541:
    "   j - remove comment leader when joining.
    " Ignore failures setting this flag.
    silent! setlocal formatoptions+=j

    " Define pattern for list items.  This helps with reformatting paragraphs
    " (e.g., via gqap) such that bulleted and numbered lines are handled
    " correctly.
    let &l:formatlistpat = '^\s*\d\+\.\s\+\|^\s*[-*+]\s\+'

    " Also treat lines consisting of optional leading whitespace and
    " a single repeated punctuation character as list items so that
    " header text will not be joined with its underline. E.g., the below
    " text will be unchanged by reformatting::
    "
    "   Some header text
    "   ================
    "
    " Unfortunately, overlines are not treated properly.  This text:
    "
    "   =================
    "   Over/under header
    "   =================
    "
    " will be reformatted badly to this::
    "
    "   ================= Over/under header
    "   =================
    "
    " But since underlined headers are the most common, this is better
    " than nothing, and it's much easier to use Vim's built-in formatting
    " logic than to write something custom.

    let &l:formatlistpat .= '\|^\s*\([-=^"#*' . "'" . ']\)\ze\1\+$'
endfunction
command! -bar SetupCommon call SetupCommon()

" -------------------------------------------------------------
" Setup for plain text (and derivatives).
" -------------------------------------------------------------
function! SetupText()
    SetupCommon
    " Auto-wrap text using textwidth:
    setlocal formatoptions+=t

    " Do not automatically insert comment leaders:
    "   r - automatically insert comment leader when pressing <Enter>.
    "   o - automatically insert comment leader after 'o' or 'O'.
    " Note: This is to avoid the unwanted side-effect that pressing <Enter>
    " on a bulleted list item indents the next line, e.g.:
    "
    "   - Pressing <Enter> on this bullet yields the below
    "     indented second line.
    setlocal formatoptions-=ro

    setlocal tw=80 ts=8 sts=2 sw=2 et ai
    let b:SpellType = "<text>"
endfunction
command! -bar SetupText call SetupText()
let g:SpellMap["<text>"] = "<on>"

" -------------------------------------------------------------
" Setup for general source code.
" -------------------------------------------------------------
function! SetupSource()
    SetupCommon
    " Disable auto-wrap for text, allowing long code lines.
    set formatoptions-=t

    " Automatically insert comment leaders:
    "   r - automatically insert comment leader when pressing <Enter>.
    "   o - automatically insert comment leader after 'o' or 'O'.
    setlocal formatoptions+=ro

    setlocal tw=80 ts=8 sts=4 sw=4 et ai
    Highlight longlines tabs trailingspace
    let b:SpellType = "<source>"
endfunction
command! -bar SetupSource call SetupSource()
let g:SpellMap["<source>"] = "<on>"

" -------------------------------------------------------------
" Setup for markup languages like HTML, XML, ....
" -------------------------------------------------------------
function! SetupMarkup()
    SetupText
    setlocal tw=80 ts=8 sts=2 sw=2 et ai
    runtime scripts/closetag.vim
    runtime scripts/xml.vim
    let b:SpellType = "<markup>"

    " Re-synchronize syntax highlighting from start of file.
    syntax sync fromstart
endfunction
command! -bar SetupMarkup call SetupMarkup()
let g:SpellMap["<markup>"] = "<on>"

" -------------------------------------------------------------
" Setup for mail.
" -------------------------------------------------------------
function! SetupMail()
    SetupText
    " Use the 'w' flag in formatoptions to setup format=flowed editing.
    " The 'w' flag causes problems for wrapping when manual editing strips
    " out a trailing space.  Better to avoid the flag...
    " set formatoptions+=w
    setlocal tw=64 sw=2 sts=2 et ai
endfunction
command! -bar SetupMail call SetupMail()
let g:SpellMap["mail"] = "<on>"

" -------------------------------------------------------------
" Setup for Markdown.
" -------------------------------------------------------------

function! DisableMarkdownSyntaxCodeList()
    if exists ("g:markdown_fenced_languages") &&
                \ len(g:markdown_fenced_languages) > 0
        echoerr "Disabling g:markdown_fenced_languages; " .
                    \ "use g:markdownEmbeddedLangs"
    endif
    let g:markdown_fenced_languages = []
endfunction

call DisableMarkdownSyntaxCodeList()

function! SetupMarkdownSyntax()
    call DisableMarkdownSyntaxCodeList()

    " We default to g:rstEmbeddedLangs.
    if !exists("g:markdownEmbeddedLangs")
        let g:markdownEmbeddedLangs = g:rstEmbeddedLangs
    endif

    let includedLangs = {}

    " The group naming convention is the same as vim-markdown's, but the logic
    " is a little different here.  Namely, we don't deal with dotted names, and
    " we have special handling for the c language.
    for lang in g:markdownEmbeddedLangs
        let synLang = lang
        if lang == "c"
            " Special-case C because Vim's syntax highlighting for cpp
            " is based on the C highlighting, and it doesn't like to
            " have both C and CPP active at the same time.  Map C highlighting
            " to CPP to avoid this problem.
            let synLang = "cpp"
        endif

        let synGroup = "markdownHighlight" . synLang
        if !has_key(includedLangs, synLang)
            call SyntaxInclude(synGroup, synLang)
            let includedLangs[synLang] = 1
        endif

        exe 'syn region ' . synGroup .
                    \ ' matchgroup=markdownCodeDelimiter start="^\s*```\s*' .
                    \ lang . '\>.*$" end="^\s*```\ze\s*$" keepend ' .
                    \ 'contains=@' . synGroup
    endfor
endfunction
command! -bar SetupMarkdownSyntax call SetupMarkdownSyntax()

function! SetupMarkdown()
    SetupMarkup

    " Setup comments so that we get proper list support.  Also taken from
    " vim-markdown's ftplugin/markdown.vim.
    setlocal comments=fb:*,fb:-,fb:+,n:> commentstring=>\ %s

    " Setup some extra highlighting for code blocks.  This matches the
    " highlighting from Ben William's syntax/mkd.vim and is a decent fallback
    " when we don't support the embedded language or the block is inline.
    hi def link markdownCode                  String
    hi def link markdownCodeBlock             String
endfunction
command! -bar SetupMarkdown call SetupMarkdown()

" -------------------------------------------------------------
" Setup LessCSS.
" -------------------------------------------------------------
function! SetupLess()
    SetupText
    setlocal tw=80 ts=8 sts=2 sw=2 et ai
endfunction
command! -bar SetupLess call SetupLess()

" Disable the embedded syntax feature of newer syntax/rst.vim for a few reasons:
" - It doesn't work with both "c" and "cpp" active simultaneously, since both
"   rely on including syntax/c.vim, and the double inclusion of this file
"   causes problems.
" - It requires a fairly new Vim, and we'd like to support older ones, too.
" - It marks the block with NoSpell, which we don't want.
" - It's easier to disable the support in syntax/rst.vim entirely than to
"   partially use it and work around its limitations.
function! DisableRstSyntaxCodeList()
    if exists ("g:rst_syntax_code_list") && len(g:rst_syntax_code_list) > 0
        echoerr "Disabling g:rst_syntax_code_list; use g:rstEmbeddedLangs"
    endif
    let g:rst_syntax_code_list = []
endfunction

call DisableRstSyntaxCodeList()

" NOTE: Embedding java causes spell checking to be disabled, because
" the syntax file for java monkeys with the spell checking settings.
let g:rstEmbeddedLangs = ["c", "cpp", "html", "python", "sh", "vim"]

" -------------------------------------------------------------
" Setup for reStructuredText.
" -------------------------------------------------------------
function! SetupRstSyntax()
    " Layout embedded source as follows:
    " .. code-block:: lang
    "     lang-specific source code here.
    " ..
    function! l:EmbedCodeBlock(lang, synGroup)
        if a:lang == ""
            let region = "rstCodeBlock"
            let regex = ".*"
        else
            let region = "rstDirective" . a:lang
            let regex = a:lang
        endif
        silent! syn clear region
        let cmd  = 'syntax region ' . region
        let cmd .= ' matchgroup=rstDirective fold'
        let cmd .= ' start="^\z(\s*\)\.\.\s\+'
        let cmd .= '\%(sourcecode\|code-block\|code\)::\s\+'
        let cmd .= regex . '\s*$"'
        " @todo Don't forget to highlight :options: lines
        " such as :linenos:
        let cmd .= ' skip="\n\z1\s\|\n\s*\n"'
        let cmd .= ' end="$"'
        if a:synGroup != ""
            let cmd .= " contains=@" . a:synGroup
        endif
        execute cmd
        execute 'syntax cluster rstDirectives add=' . region
    endfunction

    call DisableRstSyntaxCodeList()
    " Handle unspecified languages first.
    call l:EmbedCodeBlock("", "")
    let includedLangs = {}
    for lang in g:rstEmbeddedLangs
        let synLang = lang
        if lang == "c"
            " Special-case C because Vim's syntax highlighting for cpp
            " is based on the C highlighting, and it doesn't like to
            " have both C and CPP active at the same time.  Map C highlighting
            " to CPP to avoid this problem.
            let synLang = "cpp"
        endif
        let synGroup = "rst" . synLang
        if !has_key(includedLangs, synLang)
            call SyntaxInclude(synGroup, synLang)
            let includedLangs[synLang] = 1
        endif
        call l:EmbedCodeBlock(lang, synGroup)
    endfor

    " Re-synchronize syntax highlighting from start of file.
    syntax sync fromstart
endfunction
command! -bar SetupRstSyntax call SetupRstSyntax()

function! SetupRst()
    SetupText
    setlocal tw=80 ts=8 sts=2 sw=2 et ai
endfunction
command! -bar SetupRst call SetupRst()
let g:SpellMap["rst"] = "<on>"

function! SetupRstIndent()
    " The indent function shipped with Vim tries to guess the desired
    " indentation, but it guesses incorrectly often enough to make it
    " irritating.  This is mainly because after a line like this:
    "
    "   - Some bullet text
    "
    " It's not possible to guess accurately enough whether the user
    " plans to continue the bullet or start something new.  Manually
    " changing the indentation when desired seems to create a less
    " jarring experience.  Therefore, use the "Status Quo" indentation
    " function to keep the prevailing indentation level unless the user
    " changes it explicitly.
    setlocal indentexpr=StatusQuoIndent()
endfunction
command! -bar SetupRstIndent call SetupRstIndent()

" -------------------------------------------------------------
" Setup for Wikipedia.
" -------------------------------------------------------------
function! SetupWikipedia()
    SetupText
    setlocal tw=0 ts=8 sts=2 sw=2 et ai
    " Setup angle brackets as matched pairs for '%'.
    setlocal matchpairs+=<:>
endfunction
command! -bar SetupWikipedia call SetupWikipedia()
let g:SpellMap["Wikipedia"] = "<on>"

" -------------------------------------------------------------
" Setup for Bash "fixcommand" mode using "fc" command.
" -------------------------------------------------------------
function! SetupBashFixcommand()
    " Generally this mode is for "one-shot" editing using Bash's "fc"
    " command.  It won't be used for a long-running editing session
    " with multiple files, so it's OK to change the global shell defaults
    " (which is good, because this would be painful otherwise).
    unlet g:is_kornshell
    let g:is_bash=1
    setfiletype sh

    setlocal tw=0
    Highlight no*
endfunction
command! -bar SetupBashFixcommand call SetupBashFixcommand()

" -------------------------------------------------------------
" Setup for C code.
" -------------------------------------------------------------

" Use C syntax for *.h files (see filetype.vim)
let g:c_syntax_for_h = 1

" Minimum number of lines before current line to start syntax
" synchronization (default 50).
let g:c_minlines = 300

" Enable Doxygen highlighting.
let g:load_doxygen_syntax = 1

" Disable error highlighting of curly braces inside parentheses.
let g:c_no_curly_error = 1

function! IndentC()
    if v:lnum > 1 && getline(v:lnum - 1) =~ '^\s*\*//\*\*'
        return indent(v:lnum - 1) + &shiftwidth
    else
        return cindent(v:lnum)
    endif
endfunction

function! SetupC()
    SetupSource
    Highlight commas keywordspace longlines tabs trailingspace
    setlocal indentexpr=IndentC()

    " Re-indent when ending a C-style comment.
    setlocal indentkeys+=/

    setlocal comments=s:/*,mb:\ ,e-4:*/,://

    " cinoptions shift amounts ending in 's' are in units of shiftwidth.

    " Don't outdent function return types.
    setlocal cinoptions+=t0

    " No extra indentation for case labels.
    setlocal cinoptions+=:0

    " Comment bodies indented one shiftwidth.
    setlocal cinoptions+=c1s,C1s

    " No extra indentation for "public", "protected", "private" labels.
    setlocal cinoptions+=g0

    " Indent amount for unclosed parentheses (first-level).
    setlocal cinoptions+=(1s

    " Indent amount for unclosed parentheses (second-level).
    setlocal cinoptions+=u0

    " How many lines away to search for unclosed parentheses.
    setlocal cinoptions+=)30

    " Whether to respect indenting even when unclosed parenthesis is the first
    " non-white character in its line (U1 to respect, U0 to ignore).
    setlocal cinoptions+=U1

    " How many lines away to search for unclosed comments.
    setlocal cinoptions+=*100

    " Map CTRL-O_CR to append ';' to the end of line, then do CR.
    inoremap <buffer> <C-O><CR> <C-\><C-N>A;<CR>
    vnoremap <buffer> <C-O><CR> <C-\><C-N>A;<CR>
endfunction
command! -bar SetupC call SetupC()

" -------------------------------------------------------------
" Setup for C++ code.
" -------------------------------------------------------------
function! SetupCpp()
    SetupC
endfunction
command! -bar SetupCpp call SetupCpp()

" -------------------------------------------------------------
" Setup for general Clojure code.
" -------------------------------------------------------------
function! SetupClojure()
    SetupSource
    setlocal ts=8 sts=2 sw=2

    RainbowParenthesesLoadRound
    RainbowParenthesesLoadSquare
    RainbowParenthesesLoadBraces
    RainbowParenthesesActivate
endfunction
command! -bar SetupClojure call SetupClojure()

" -------------------------------------------------------------
" Setup for CMake
" -------------------------------------------------------------
function! SetupCmake()
    SetupSource
    setlocal commentstring=#\ %s
endfunction
command! -bar SetupCmake call SetupCmake()

" -------------------------------------------------------------
" Setup for D code.
" -------------------------------------------------------------
function! SetupD()
    SetupC
endfunction
command! -bar SetupD call SetupD()

" -------------------------------------------------------------
" Setup for GDB.
" -------------------------------------------------------------
function! SetupGdb()
    SetupSource
    setlocal commentstring=#\ %s
endfunction
command! -bar SetupGdb call SetupGdb()

" -------------------------------------------------------------
" Setup for Git-related files (e.g., "COMMIT_EDITMSG").
" -------------------------------------------------------------
function! SetupGit()
    SetupText
    setlocal tw=72
endfunction
command! -bar SetupGit call SetupGit()

" -------------------------------------------------------------
" Setup for Haskell.
" -------------------------------------------------------------
function! SetupHaskell()
    SetupSource

endfunction
command! -bar SetupHaskell call SetupHaskell()

" -------------------------------------------------------------
" Setup for JavaScript.
" -------------------------------------------------------------
function! SetupJavaScript()
    SetupSource

    " Use 2-space indent for knife files, since it's the Chef default.
    if match(expand("%:t"), "^knife-") != -1
        setlocal sts=2 sw=2
    endif

    " Map CTRL-O_CR to append ';' to the end of line, then do CR.
    inoremap <buffer> <C-O><CR> <C-\><C-N>A;<CR>
    vnoremap <buffer> <C-O><CR> <C-\><C-N>A;<CR>
endfunction
command! -bar SetupJavaScript call SetupJavaScript()

" -------------------------------------------------------------
" Setup for LLVM source code.
" -------------------------------------------------------------

function! SetupLlvm()
    SetupSource

    set sts=2 sw=2 expandtab

    " No extra indentation for case labels.
    setlocal cinoptions+=:0

    " No extra indentation for "public", "protected", "private" labels.
    setlocal cinoptions+=g0

    " Line up function args.
    setlocal cinoptions+=(0

    " Use a shiftwidth for argument indent, when the first parameter is not
    " on the same line as the function.
    setlocal cinoptions+=Ws

    " Aligns the curly for a case statement with the case label, rather than the
    " last statement.
    setlocal cinoptions+=l1
endfunction
command! -bar SetupLlvm call SetupLlvm()

" -------------------------------------------------------------
" Setup for Lua.
" -------------------------------------------------------------
function! SetupLua()
    SetupSource
    setlocal commentstring=--\ %s
endfunction
command! -bar SetupLua call SetupLua()

" -------------------------------------------------------------
" Setup for Moonscript.
" -------------------------------------------------------------
function! SetupMoonscript()
    SetupSource
    setlocal commentstring=--\ %s
endfunction
command! -bar SetupMoonscript call SetupMoonscript()

" -------------------------------------------------------------
" Setup for Python.
" -------------------------------------------------------------
function! SetupPython()
    SetupSource

    " Python always thinks tabs are 8 characters wide.
    setlocal ts=8

    " Follow PEP-recommended alignment of parentheses
    setlocal cinoptions+=(0

    " Map CTRL-O_CR to append ':' to the end of line, then do CR.
    inoremap <buffer> <C-O><CR> <C-\><C-N>A:<CR>
    vnoremap <buffer> <C-O><CR> <C-\><C-N>A:<CR>
endfunction
command! -bar SetupPython call SetupPython()
let g:IndentGuidesMap["python"] = "<on>"

" Default to Python version 2 syntax, if not already decided.
if !exists("g:python_version_2")
    let g:python_version_2 = 1
endif

" -------------------------------------------------------------
" Setup for Ruby.
" -------------------------------------------------------------
function! SetupRuby()
    SetupSource
endfunction
command! -bar SetupRuby call SetupRuby()

" -------------------------------------------------------------
" Setup for Subversion commit files.
" -------------------------------------------------------------
function! SetupSvn()
    SetupText
    setlocal tw=72
endfunction
command! -bar SetupSvn call SetupSvn()

" -------------------------------------------------------------
" Setup for VHDL.
" -------------------------------------------------------------
function! SetupVhdl()
    SetupSource

    setlocal comments=b:--

    " Map CTRL-O_CR to append ';' to the end of line, then do CR.
    inoremap <buffer> <C-O><CR> <C-\><C-N>A;<CR>
    vnoremap <buffer> <C-O><CR> <C-\><C-N>A;<CR>

    " Convert a port into a port map.
    xnoremap <buffer> <leader>pm :s/^\(\s*\)\(\w\+\)\(\s*\)\(=>\<bar>:\).*
                \/\1\2\3=> \2,/<CR>
endfunction
command! -bar SetupVhdl call SetupVhdl()

" -------------------------------------------------------------
" Setup for Vim C-code Source (the source code for Vim itself).
" -------------------------------------------------------------
function! SetupVimC()
    SetupCommon
    setlocal ts=8 sts=4 sw=4 tw=80

    " Don't expand tabs to spaces.
    setlocal noexpandtab

    " Enable automatic C program indenting.
    setlocal cindent

    " Use default C-style comments with leading "*" characters.
    setlocal comments&

    " Use default indentation options.
    setlocal cinoptions&
endfunction
command! -bar SetupVimC call SetupVimC()

" -------------------------------------------------------------
" Setup for Linux Kernel Sources.
" -------------------------------------------------------------
function! SetupKernelSource()
    SetupCommon
    setlocal ts=8 sts=8 sw=8 tw=80

    " Don't expand tabs to spaces.
    setlocal noexpandtab

    " Enable automatic C program indenting.
    setlocal cindent

    " Don't outdent function return types.
    setlocal cinoptions+=t0

    " No extra indentation for case labels.
    setlocal cinoptions+=:0

    " No extra indentation for "public", "protected", "private" labels.
    setlocal cinoptions+=g0

    " Line up function args.
    setlocal cinoptions+=(0
endfunction
command! -bar SetupKernelSource call SetupKernelSource()

" -------------------------------------------------------------
" Setup for Makefiles.
" -------------------------------------------------------------
function! SetupMake()
    SetupCommon
    " Vim's defaults are mostly good.
    setlocal ts=8 tw=80

    " Setup identical settings for both "##" and "#" comments.
    setlocal comments=sO:##\ -,mO:##\ \ ,b:##,sO:#\ -,mO:#\ \ ,b:#
endfunction
command! -bar SetupMake call SetupMake()

function! SetupMakeIndent()
    setlocal autoindent
    setlocal indentkeys-=<:>
endfunction
command! -bar SetupMakeIndent call SetupMakeIndent()

" -------------------------------------------------------------
" Setup for help files.
" -------------------------------------------------------------
function! SetupHelp()
    SetupText
    " This helps make it easier to jump to tags while editing help files,
    " since a number of tags contain a hyphen.
    " The "@" adds in all "alphabetic" characters, including
    " accented characters beyond ASCII a-z and A-Z.
    setlocal iskeyword=@,!-~,^*,^\|,^\",192-255
endfunction
command! -bar SetupHelp call SetupHelp()

" Last active help buffer number (0 if none).
let g:LastHelpBuf = 0
augroup local_help
    autocmd!

    " Store last active help buffer number when leaving the help window.
    autocmd WinLeave * if &bt == "help" | let g:LastHelpBuf = bufnr("%") | endif
augroup END

" Return buffer number of recent help window (0 if no help buffers).
function! FindRecentHelpBuf()
    let buf = 1
    let recentHelpBuf = 0
    while buf <= bufnr("$")
        if getbufvar(buf, "&buftype") == "help"
            let recentHelpBuf = buf
            if recentHelpBuf == g:LastHelpBuf
                break
            endif
        endif
        let buf += 1
    endwhile
    return recentHelpBuf
endfunction

" Return window number of active help window (0 if no active windows).
function! FindHelpWindow()
    let win = 1
    while win <= winnr("$")
        let buf = winbufnr(win)
        if getbufvar(buf, "&buftype") == "help"
            return win
        endif
        let win += 1
    endwhile
    return 0
endfunction

" If help window is active, close it; otherwise, re-open recent help buffer.
function! HelpToggle()
    let win = FindHelpWindow()
    let recentHelpBuf = FindRecentHelpBuf()
    if win > 0
        execute win . "wincmd w"
        wincmd c
        wincmd p
    elseif recentHelpBuf > 0
        split
        execute recentHelpBuf . "buffer"
    else
        help
    endif
endfunction
command! -bar HelpToggle call HelpToggle()

nnoremap <F1>       :<C-U>HelpToggle<CR>
nnoremap <C-Q>h     :<C-U>HelpToggle<CR>
nnoremap <C-Q><C-H> :<C-U>HelpToggle<CR>

" Get help on visual selection.
function! VisualHelp()
    execute ":help " . SelectedText()
endfunction
command! -bar VisualHelp call VisualHelp()

xnoremap <F1>       :<C-U>call VisualHelp()<CR>
xnoremap <C-Q>h     :<C-U>call VisualHelp()<CR>
xnoremap <C-Q><C-H> :<C-U>call VisualHelp()<CR>


" -------------------------------------------------------------
" Setup for C projects following the GNU Coding Standards
" -------------------------------------------------------------
function! SetupGnuSource()
    SetupSource
    " Don't expand tabs to spaces.
    setlocal noexpandtab

    " Turn off our own indent rules.  Reset it to Vim's default.
    setlocal indentexpr&

    " Taken from: http://gcc.gnu.org/wiki/FormattingCodeForGCC
    setlocal cindent

    " Don't outdent function return types.
    setlocal cinoptions=t0

    " No extra indentation for "public", "protected", "private" labels.
    setlocal cinoptions+=g0

    " Amount added after normal indent.
    setlocal cinoptions+=>2s

    " If statements without braces aren't indented as far.
    setlocal cinoptions+=n-1s

    " Opening branch are indented from if statement.
    setlocal cinoptions+={1s

    " Bring back the indentation inside a function.
    setlocal cinoptions+=^-1s

    " Indent case labels slightly.
    setlocal cinoptions+=:1s

    " Indent case statements from the case label.
    setlocal cinoptions+==1s

    " Place scope decorations in the same column as braces.
    setlocal cinoptions+=g0

    " Indent statements after scope declaration.
    setlocal cinoptions+=h1s

    " K&R-style parameter declarations get 5 spaces.
    setlocal cinoptions+=p5

    " Indent continuation lines.
    setlocal cinoptions+=+1s

    " Line up the first characters when you are continuing inside a statement
    " with parens.
    setlocal cinoptions+=(0

    " Second level of parens works the same way as above.
    setlocal cinoptions+=u0

    " If there's leading whitespace between the paren and first non-white
    " character, the ignore them when deciding where to continue.
    setlocal cinoptions+=w1

    " Line a closing paren that starts at the beginning of a line with the start
    " of the line that contains the matching opening paren.
    setlocal cinoptions+=m1

    setlocal sw=2 sts=2 tw=79
endfunction
command! -bar SetupGnuSource call SetupGnuSource()

function! SetupDiff()
    SetupText
    call CreateTextobjDiffLocalMappings()
endfunction
command! -bar SetupDiff call SetupDiff()

function! SetupAsm()
    SetupSource
endfunction
command! -bar SetupAsm call SetupAsm()

function! SetupJava()
    SetupSource
    setlocal omnifunc=javacomplete#Complete

    " Setup better linewise comments for Java.
    setlocal commentstring=//\ %s

    " [[, ]], and friends don't work well in Java.  Map them to
    " the "method" equivalents instead.
    nnoremap <buffer> [[ [m
    nnoremap <buffer> [] [M
    nnoremap <buffer> ]] ]m
    nnoremap <buffer> ][ ]M
    xnoremap <buffer> [[ [m
    xnoremap <buffer> [] [M
    xnoremap <buffer> ]] ]m
    xnoremap <buffer> ][ ]M
endfunction
command! -bar SetupJava call SetupJava()

function! SetupTmux()
    SetupSource
endfunction
command! -bar SetupTmux call SetupTmux()

function! SetupYaml()
    SetupSource
endfunction
command! -bar SetupYaml call SetupYaml()

" Source support for :Man command.
runtime ftplugin/man.vim

" =============================================================
" Autocmds
" =============================================================

" NOTE: This must be done *after* all bundles have been loaded.
" Enable syntax highlighting and search highlighting when colors available.
if &t_Co > 2 || has("gui_running")
    syntax on
    set hlsearch
endif

" Enable file type detection.
" Use the default filetype settings, so that mail gets 'tw' set to 72,
" 'cindent' is on in C files, etc.
" Also load indent files, to automatically do language-dependent indenting.
filetype plugin indent on

" Extended filetype detection by extensions is found in
" filetype.vim

function! AutoRestoreLastCursorPosition()
    " If b:startAtTop exists, jump to the top of the file; otherwise,
    " if possible, jump to last known cursor position for this file.
    " Avoid jumping if the position would be invalid for this file.
    if exists("b:startAtTop")
        normal gg
    elseif line("'\"") > 0 && line("'\"") <= line("$")
        exe "normal g`\""
    endif
endfunction

function! AutoOpenGitDiff()
    " Show diffs for this Git commit.
    " The fugitive plugin uses a previewwindow for the :Gstatus command,
    " but it sets the filetype of that windows to 'gitcommit', so don't
    " open a diff window if the gitcommit is in a previewindow.
    " Also, when using ``:Gedit :``,  the .git/index file is opened
    " in a regular window using filetype 'gitcommit', so avoid opening
    " a diff window in that case as well, as suggested by Tim Pope here:
    " https://github.com/tpope/vim-fugitive/issues/294#issuecomment-12474356
    " Note that checking for 'index' is not sufficient in itself, because
    " using :Gstatus followed by attempting a commit via ``cc`` does not
    " work properly in that event (the COMMIT_MSG window will not have
    " the correct contents).
    if ! &previewwindow && expand('%:t') !~# 'index'
        DiffGitCached
        wincmd p
        wincmd K
        resize 15
    endif
endfunction

function! AutoCloseGitDiff()
    " Close any preview window when finished with a 'gitcommit' buffer.
    " Since :DiffGitCached uses a preview window for diffs, this will
    " close out any diff window that might be hanging around.
    if &ft == 'gitcommit'
        pclose
    endif
endfunction

" Save current view settings.
function! AutoSaveWinView()
    let b:winview = winsaveview()
endfunction

" Restore current view settings.
function! AutoRestoreWinView()
    if exists('b:winview')
        if (!&diff)
            call winrestview(b:winview)
        endif
        unlet b:winview
    endif
endfunction

" Put these in an autocmd group, so that we can delete them easily.
augroup local_vimrc
    " First, remove all autocmds in this group.
    autocmd!

    " Auto-commands are done in order; however, note that FileType events
    " generally fire before BufReadPost events.

    " Start at top-of-file for Subversion commit messages.
    autocmd FileType svn SetupSvn | let b:startAtTop = 1

    " Start at top-of-file for Git-related files.
    autocmd FileType gitcommit,gitrelated,gitrebase SetupGit |
                \ let b:startAtTop = 1

    " When editing a file, jump to the last known cursor position.
    autocmd BufReadPost * call AutoRestoreLastCursorPosition()


    " Open a diff window for Git commits.
    autocmd FileType gitcommit call AutoOpenGitDiff()

    " Close diff window after a Git commit.
    autocmd BufUnload * call AutoCloseGitDiff()

    " Use tabs for gitconfig files.
    autocmd FileType gitconfig setlocal noexpandtab commentstring=#\ %s

    " By default, when Vim switches buffers in a window, the new buffer's
    " cursor position is scrolled to the center (as if 'zz' had been
    " issued).  This fix restores the buffer's position.
    autocmd BufLeave * call AutoSaveWinView()
    autocmd BufEnter * call AutoRestoreWinView()

augroup END

" Support for gpg-encrypted files.
augroup local_encrypted
    " First, remove all autocmds in this group.
    autocmd!

    " First make sure nothing is written to ~/.viminfo while editing
    " an encrypted file.
    autocmd BufReadPre,FileReadPre      *.gpg set viminfo=
    " We don't want a swap file, as it writes unencrypted data to disk
    autocmd BufReadPre,FileReadPre      *.gpg set noswapfile
    " Switch to binary mode to read the encrypted file
    autocmd BufReadPre,FileReadPre      *.gpg set bin
    autocmd BufReadPre,FileReadPre      *.gpg let ch_save = &ch|set ch=2
    autocmd BufReadPre,FileReadPre      *.gpg let shsave=&sh
    autocmd BufReadPre,FileReadPre      *.gpg let &sh='sh'
    autocmd BufReadPre,FileReadPre      *.gpg let ch_save = &ch|set ch=2
    autocmd BufReadPost,FileReadPost    *.gpg '[,']!gpg --decrypt
        \   --default-recipient-self 2> /dev/null
    autocmd BufReadPost,FileReadPost    *.gpg let &sh=shsave

    " Switch to normal mode for editing
    autocmd BufReadPost,FileReadPost    *.gpg set nobin
    autocmd BufReadPost,FileReadPost    *.gpg let &ch = ch_save|
        \   unlet ch_save
    autocmd BufReadPost,FileReadPost    *.gpg execute
        \   ":doautocmd BufReadPost " . expand("%:r")

    " Convert all text to encrypted text before writing
    autocmd BufWritePre,FileWritePre    *.gpg set bin
    autocmd BufWritePre,FileWritePre    *.gpg let shsave=&sh
    autocmd BufWritePre,FileWritePre    *.gpg let &sh='sh'
    autocmd BufWritePre,FileWritePre    *.gpg '[,']!gpg --encrypt
        \   --default-recipient-self 2>/dev/null
    autocmd BufWritePre,FileWritePre    *.gpg let &sh=shsave

    " Undo the encryption so we are back in the normal text, directly
    " after the file has been written.
    autocmd BufWritePost,FileWritePost  *.gpg   silent u
    autocmd BufWritePost,FileWritePost  *.gpg set nobin
augroup END

" Spell-check autocmd group.
" This group should come after most FileType-related auto-commands, since
" these other auto-commands might influence whether spell-checking should
" be on.
augroup local_spell
    " First, remove all autocmds in this group.
    autocmd!
    autocmd FileType * call SetSpell()
augroup END

" =============================================================
" Status line
" =============================================================

" Function used to display syntax group.
function! SyntaxItem()
    return synIDattr(synID(line("."),col("."),1),"name")
endfunction

" Function used to display utf-8 sequence.
function! ShowUtf8Sequence()
    try
        let p = getpos('.')
        redir => utfseq
        sil normal! g8
        redir End
        call setpos('.', p)
        " 12 34 56 ==> 0x12 0x34 0x56
        return substitute(matchstr(utfseq, '\x\+ .*\x'), '\<\x', '0x&', 'g')
    catch
        return '?'
    endtry
    "  ²´´
endfunction

" @todo Define User1, User2, User3, and User4 highlight groups.
if has('statusline') && version >= 700
    " Default status line:
    " set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
    set statusline =
    set statusline+=%#User1#                       " Highlighting
    set statusline+=%-3n\                          " Buffer number

    set statusline+=%#User2#                       " Highlighting
    set statusline+=%<                             " Truncate here
    set statusline+=%f\                            " File name
    set statusline+=%#User1#                       " Highlighting

    set statusline+=%h                             " [help]
    set statusline+=%m                             " [+] (modified)
    set statusline+=%r                             " [RO]
    set statusline+=%w                             " [Preview]
    set statusline+=\                              " Space

"   set statusline+=%{strlen(&ft)?&ft:'none'},     " File type
    if usingTagbar
        set statusline+=%{tagbar#currenttag('[%s]','')} " Function name
    endif
"   set statusline+=,%{SyntaxItem()}               " Syntax group under cursor
    set statusline+=\                              " Space

    set statusline+=%=                             " Separate left from right.

    set statusline+=%#User2#                       " Highlighting
"   set statusline+=%{ShowUtf8Sequence()}\         " Utf-8 sequence
    set statusline+=%#User1#                       " Highlighting

"   set statusline+=U+%04B\                        " Unicode char under cursor
    set statusline+=%-6.(%l,%c%V%)\ %P             " Position

    " Use different colors for statusline in current and non-current window.
    let g:Active_statusline=&g:statusline
    let g:NCstatusline=substitute(
                \                substitute(g:Active_statusline,
                \                'User1', 'User3', 'g'),
                \                'User2', 'User4', 'g')
    au! WinEnter * let&l:statusline = g:Active_statusline
    au! WinLeave * let&l:statusline = g:NCstatusline
endif

" When to show a statusline:
" 0 - never.
" 1 - if more than one window (default).
" 2 - always.
set laststatus=2


" If it exists, source the specified |VIMRC_AFTER| hook.
if filereadable($VIMRC_AFTER)
    source $VIMRC_AFTER
endif
