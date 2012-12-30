" vim:tw=80:ts=4:sts=4:sw=4:et:ai

" Enable vi-incompatible Vim extensions (redundant since .vimrc exists).
set nocompatible

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

" Set environment variable to directory containing this vimrc.
" Expect absolute directory $HOME/.vim on Unix ($HOME/vimfiles on Windows).
" Note: using an environment variable instead of normal Vim variable
" because environment variables are expanded in values used with
" setting 'runtimepath' later.
let $VIMFILES=expand("<sfile>:p:h")

" If local customizations directory exists, it takes precedence.
call RtpPrepend($VIMFILES . "/local")

" Provide for per-user hook points before and after common vimrc.
" User may supply a "-before.vim" hook that runs before the main contents
" of this vimrc file, and a "-after.vim" hook that runs afterward.
" The "-before.vim" hook is useful for changing things like <Leader>
" so that it will be used by mappings below.  Settings which override those
" given below fit better in "-after.vim".
"
" Given a user named "someuser", the hooks default to:
"
"   ~/.vim/user/someuser-before.vim
"   ~/.vim/user/someuser-after.vim
"
" They are adjustable by setting the following environment variables
" either outside of vim or in the ~/.vimrc file before executing this
" vimrc file.

" VIMUSERFILES points to directory where per-user overrides live.
" To avoid accidental name collisions based on arbitrary user names, it should
" point to an otherwise empty directory.  It may live beneath $VIMFILES (in
" which case it may live as a branch of vimfiles), or it may live elsewhere
" to be separately source-controlled.
if $VIMUSERFILES == ""
    let $VIMUSERFILES=expand("$VIMFILES/user")
endif

" VIMUSER defaults to the logged-in user, but may be overridden to allow
" multiple user to share the same overrides (e.g., to let "root" share settings
" with another user).
if $VIMUSER == ""
    let $VIMUSER=expand("$USER")
endif

" VIMRC_BEFORE points directly to the "-before.vim" script to execute.
if $VIMRC_BEFORE == ""
    let $VIMRC_BEFORE=expand("$VIMUSERFILES/$VIMUSER-before.vim")
endif

" VIMRC_AFTER points directly to the "-after.vim" script to execute.
if $VIMRC_AFTER == ""
    let $VIMRC_AFTER=expand("$VIMUSERFILES/$VIMUSER-after.vim")
endif

" VIMRC_BUNDLE points to the user's bundle area.
if $VIMRC_BUNDLE == ""
    let $VIMRC_BUNDLE=expand("$VIMUSERFILES/$VIMUSER/bundle")
endif

" Prepend per-user directory to runtimepath (provides the highest priority).
call RtpPrepend($VIMUSERFILES . "/" . $VIMUSER)

" If it exists, source the specified "-before.vim" hook.
if filereadable($VIMRC_BEFORE)
    source $VIMRC_BEFORE
endif

" -------------------------------------------------------------
" Pathogen plugin management
" -------------------------------------------------------------
runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()

" Bundles in the "pre-bundle" directories will come earlier in the path
" than those in "bundle" directories.
call pathogen#infect('pre-bundle')

" A bundle area specific to a user.
if isdirectory($VIMRC_BUNDLE)
    call pathogen#infect($VIMRC_BUNDLE)
endif

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
set timeoutlen=3000

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
" Note: 120 words per minute ==> 10 character per second ==> 100 ms between,
" and 150 ms ==> 80 words per minute.
set ttimeoutlen=150

" Configure special terminal keys.
runtime termsupport.vim

" Disallow octal numbers for increment/decrement (CTRL-A/CTRL-X).
set nrformats-=octal

" =============================================================
" File settings
" =============================================================

" Where file browser's directory should begin:
"   last    - same directory as last file browser
"   buffer  - directory of the related buffer
"   current - current directory (pwd)
"   {path}  - specified directory
set browsedir=buffer

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

" =============================================================
" Display settings
" =============================================================

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

" =============================================================
" Menu settings
" =============================================================

anoremenu 10.332 &File.Close\ All<Tab>:%bdelete :%bdelete<CR>
anoremenu 10.355 &File.Save\ A&ll<Tab>:wall :wall<CR>

" Configure the use of the Alt key to access menus.
"   no - never use Alt key for menus; all Alt-key combinations are mappable.
"   yes - always use Alt key for menus; cannot map Alt-key combinations.
"   menu - Alt-key combinations not used by menus are mappable.
set winaltkeys=no

" =============================================================
" Key settings
" =============================================================

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

" Signal fifo using fifosignal script.
nnoremap <F12> :wall<bar>call system("fifosignal")<CR>
inoremap <F12> <ESC>:wall<bar>call system("fifosignal")<CR>

function! GotoPrev()
    if &diff
        normal [czz
    else
        botright copen
        wincmd p
        try
            cprev
            normal zz
        catch
            echo "No previous QuickFix messages"
        endtry
    endif
endfunction

function! GotoNext()
    if &diff
        normal ]czz
    else
        botright copen
        wincmd p
        try
            cnext
            normal zz
        catch
            echo "No more QuickFix messages"
        endtry
    endif
endfunction

" Setup message browsing using F4/Shift-F4.  If the current
" window is in diff mode, does diff next/prev; otherwise,
" does :cnext/:cprev for QuickFix messages, opening the
" QuickFix window if necessary.
" Automatically scrolls the message to the center of the window.
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

command! Qf2Args call s:Qf2Args()

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
command! StripTrailingWhitespace  call StripTrailingWhitespace()

nnoremap <Leader><Leader>$  :StripTrailingWhitespace<CR>

" Remap Q from useless "Ex" mode to "gq" re-formatting command.
nnoremap Q gq
xnoremap Q gq
onoremap Q gq

" Rewrap a paragraph of text via Meta-Q or <Leader>q (emulates Emacs's Meta-Q
" and TextMate's Ctrl-Q).
nnoremap <M-q>      gqip
nnoremap <Leader>q  gqip
xnoremap <M-q>      gq
xnoremap <Leader>q  gq
inoremap <M-q>      <ESC>gqipA

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

" Command-line editing.
" To match Bash, setup Emacs-style command-line editing keys.
" This loses some Vim functionality.  The original functionality can
" be had by pressing CTRL-O followed by the original key.  E.g., to insert
" all matching filenames (originally <C-A>), do <C-O><C-A>.
cnoremap <C-A>      <Home>
cnoremap <C-B>      <Left>
cnoremap <C-D>      <Del>
cnoremap <C-F>      <Right>
cnoremap <C-G>      <C-F>
cnoremap <C-N>      <Down>
cnoremap <C-P>      <Up>
cnoremap <M-b>      <S-Left>
cnoremap <M-f>      <S-Right>

cnoremap <C-O><C-A> <C-A>
cnoremap <C-O><C-B> <C-B>
cnoremap <C-O><C-D> <C-D>
cnoremap <C-O><C-F> <C-F>
cnoremap <C-O><C-N> <C-N>
cnoremap <C-O><C-P> <C-P>

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
nnoremap <silent> <C-L> :nohlsearch<BAR>call ResetGuiFont()<CR><C-L>

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
            \,*.plg,*.elf,cscope.out,*.ecc,*.exe,*.ilk,*.pyc
            \,export,build,_build

" Make sure Command-T ignores some java-related bits.
set wildignore+=*.class,classes/**,*.jar

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
if v:version >= 703
    set undofile
    set undodir=$VIMFILES/.undo
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

" =============================================================
" begin "inspired by mswin.vim"
" =============================================================

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

" =============================================================
" end "inspired by mswin.vim"
" =============================================================

" Put from most recent yank instead of scratch register.
vnoremap P "0P

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
command! MatchScratch     call SetSearch(MakeSearchString(@"))
command! MatchScratchWord call SetSearch("\\<".MakeSearchString(@")."\\>")

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

" Folding all but matching lines.
" Taken from Wiki tip http://vim.wikia.com/wiki/VimTip282.

nnoremap <silent> <leader>z :setlocal foldexpr=(getline(v:lnum)=~@/)?
            \0:(getline(v:lnum-1)=~@/)\\|\\|(getline(v:lnum+1)=~@/)?
            \1:2 foldmethod=expr foldlevel=0 foldcolumn=0<CR>


" ==============================================================
" Buffer manipulation
" =============================================================

" Allow buffers to be hidden even if they have changes.
set hidden

" =============================================================
" Paste setup
" =============================================================

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
fun! InvertPasteAndMouse()
    if &mouse == ''
        set mouse=a | set nopaste
        echo "mouse mode on, paste mode off"
    else
        set mouse= | set paste
        echo "mouse mode off, paste mode on"
    endif
endfunction

" =============================================================
" Tags
" =============================================================

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
command! Ctags :wall|silent! !gentags

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

" =============================================================
" Cscope
" =============================================================

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

    nnoremap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>:bot copen<CR>
    nnoremap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>:bot copen<CR>
    nnoremap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>:bot copen<CR>
    nnoremap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
    nnoremap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
    nnoremap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>:bot copen<CR>
    nnoremap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>:bot copen<CR>
    nnoremap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>:bot copen<CR>
endif

" =============================================================
" Window manipulation
" =============================================================

" Return buffer number of quickfix buffer (or zero if not found).
function! s:quickFixBufNum()
    let qfBufNum = 0
    for i in range(1, bufnr('$'))
        if getbufvar(i, '&buftype') == 'quickfix'
            let qfBufNum = i
            break
        endif
    endfor
    return qfBufNum
endfunction

" Return window number of quickfix buffer (or zero if not found).
function! s:quickFixWinNum()
    let qfWinNum = 0
    let qfBufNum = s:quickFixBufNum()
    if qfBufNum > 0
        let qfWinNum = bufwinnr(qfBufNum)
    endif
    return qfWinNum
endfunction

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
    let qfWinNum = s:quickFixWinNum()
    if qfWinNum > 0
        execute qfWinNum . "wincmd w"
        execute "wincmd J"
        execute "10wincmd _"
        execute "wincmd p"
    endif

    " Make windows equally large.
    execute "normal \<C-W>="
endfunction
command! -nargs=? L call s:L(<f-args>)

" Make 1-column-wide layout.
command! L1 call s:L(1)

" Make 2-column-wide layout.
command! L2 call s:L(2)

" Make 3-column-wide layout.
command! L3 call s:L(3)

" Make 4-column-wide layout.
command! L4 call s:L(4)

" Make 5-column-wide layout.
command! L5 call s:L(5)

" Toggle quickfix window.
function! QuickFixWinToggle()
    if s:quickFixBufNum() > 0
        cclose
    else
        botright copen
    endif
endfunction
nnoremap <silent> <C-Q><C-Q> :call QuickFixWinToggle()<CR>
command! QuickFixWinToggle :call QuickFixWinToggle()

" Like windo but restore the current window.
function! WinDo(command)
    let currwin=winnr()
    execute 'windo ' . a:command
    execute currwin . 'wincmd w'
endfunction
com! -nargs=+ -complete=command Windo call WinDo(<q-args>)

" Like bufdo but restore the current buffer.
function! BufDo(command)
    let currBuff=bufnr("%")
    execute 'bufdo if &bt==""|set ei-=Syntax|' . a:command . '|endif'
    execute 'buffer ' . currBuff
endfunction
com! -nargs=+ -complete=command Bufdo call BufDo(<q-args>)

" Like tabdo but restore the current tab.
function! TabDo(command)
    let currTab=tabpagenr()
    execute 'tabdo ' . a:command
    execute 'tabn ' . currTab
endfunction
com! -nargs=+ -complete=command Tabdo call TabDo(<q-args>)

" =============================================================
" Diff-related
" =============================================================

" Taken from :help :DiffOrig.  Shows unsaved differences between
" this buffer and original file.
command! DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
            \ | wincmd p | diffthis

" =============================================================
" Plugins
" =============================================================

" -------------------------------------------------------------
" BufExplorer
" -------------------------------------------------------------
let g:bufExplorerShowRelativePath = 1

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
" bufmru
" -------------------------------------------------------------
" Set to 1 to pre-load the number marks into buffers.
" Set to 0 to avoid this pre-loading.
let g:bufmru_nummarks = 0

" -------------------------------------------------------------
" Command-T
" -------------------------------------------------------------

" Maximum number of files to find (default 10000).
let g:CommandTMaxFiles=30000

" Set to 1 to anchor match window at the top.
let g:CommandTMatchWindowAtTop = 1

" Quick-access (default \t is mapped by Align plugin).
nnoremap <Leader><Leader>t :CommandT<CR>

" Launch relative to current buffer.
nnoremap <Leader><Leader>r :CommandT %:h<CR>

" Launch fuzzy search over buffers.
nnoremap <Leader><Leader>b :CommandTBuffer<CR>

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

" :C [path]  ==> :CtrlP [path]
command! -n=? -com=dir C CtrlP <args>

" :CD [path]  ==> :CtrlPDir [path]
command! -n=? -com=dir CD CtrlPDir <args>

nnoremap <C-P><C-B> :<C-U>CtrlPBookmarkDir<CR>
nnoremap <C-P>c     :<C-U>CtrlPChange<CR>
nnoremap <C-P>C     :<C-U>CtrlPChangeAll<CR>
nnoremap <C-P><C-D> :<C-U>CtrlPDir<CR>
nnoremap <C-P><C-F> :<C-U>CtrlP %:h<CR>
nnoremap <C-P><C-L> :<C-U>CtrlPLine<CR>
nnoremap <C-P><C-M> :<C-U>CtrlPMRU<CR>
nnoremap <C-P>m     :<C-U>CtrlPMixed<CR>

" Mnemonic: "open files"
nnoremap <C-P><C-O> :<C-U>CtrlPBuffer<CR>
nnoremap <C-P><C-P> :<C-U>CtrlP<CR>
nnoremap <C-P><C-Q> :<C-U>CtrlPQuickfix<CR>
nnoremap <C-P><C-R> :<C-U>CtrlPRoot<CR>
nnoremap <C-P><C-T> :<C-U>CtrlPTag<CR>
nnoremap <C-P>t     :<C-U>CtrlPBufTag<CR>
nnoremap <C-P>T     :<C-U>CtrlPBufTagAll<CR>
nnoremap <C-P><C-U> :<C-U>CtrlPUndo<CR>

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
" EnhancedCommentify
" -------------------------------------------------------------

" 'g:EnhCommentifyRespectIndent'    string (default 'No')
" Respect the indent of a line. The comment leader is inserted correctly
" indented, not at the beginning of the line.
let g:EnhCommentifyRespectIndent = 'Yes'

" 'g:EnhCommentifyPretty'           string (default: 'No')
" Add a whitespace between comment strings and code.
let g:EnhCommentifyPretty = 'Yes'

" 'g:EnhCommentifyMultiPartBlocks'  string (default: 'No')
" When using a language with multipart-comments commenting a visual
" block will result in the whole block commented in unit, not line
" by line.
let g:EnhCommentifyMultiPartBlocks = 'Yes'

" 'g:EnhCommentifyBindInInsert'
" Add keybindings in insert mode
let g:EnhCommentifyBindInInsert = 'No'

" -------------------------------------------------------------
" fswitch
" -------------------------------------------------------------
augroup local_fswitch
    autocmd!
    " There are lots more options - :help fswitch.
    autocmd BufEnter *.h let b:fswitchdst = 'c,cpp'
    autocmd BufEnter *.h let b:fswitchlocs =
                \ 'reg:/pubinc/src/'
                \.',reg:/include/src/'
                \.',reg:/include.*/src/'
                \.',ifrel:|/include/|../src|'
    autocmd BufEnter *.c,*.cpp let b:fswitchdst = 'h'
    autocmd BufEnter *.c,*.cpp let b:fswitchlocs =
                \ 'reg:/src/pubinc/'
                \.',reg:/src/include/'
                \.',reg:|src|include/**|'
                \.',ifrel:|/src/|../include|'
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
command! A FSHere

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
" netrw
" -------------------------------------------------------------
nmap <silent> <Leader>fe :Explore<CR>

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
" RunView
" -------------------------------------------------------------

" Setup Bash as default view to run.
let g:runview_filtcmd="bash"

" -------------------------------------------------------------
" surround
" -------------------------------------------------------------

xmap <Leader>s <Plug>Vsurround

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

nnoremap <silent> <S-F8>        :TagbarToggle<CR>
nnoremap <silent> <C-Q><C-T>    :TagbarToggle<CR>
nnoremap <silent> <C-Q>t        :TagbarToggle<CR>

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

" Use \s for vcscommand sets.  Avoids conflict with EnhancedCommentify's \c
" and feels more like "svn".
let VCSCommandMapPrefix = '<Leader>s'

" When doing diff, force two-window layout with old on left.
nmap <silent> <Leader>sv <C-W>o<Plug>VCSVimDiff<C-W>H<C-W>w

" -------------------------------------------------------------
" winmanager
" -------------------------------------------------------------

" :nnoremap <C-W><C-T>   :WMToggle<CR>
" :nnoremap <C-W><C-F>   :FirstExplorerWindow<CR>
" :nnoremap <C-W><C-B>   :BottomExplorerWindow<CR>

" =============================================================
" Language setup
" =============================================================

set spelllang=en_us

" =============================================================
" Highlight setup
" =============================================================

" Define a nice highlighting color for matches.
" From Nuvola:
" highlight NonText gui=BOLD guifg=#4000FF guibg=#EFEFF7
"highlight HG_Background gui=BOLD guibg=#EFEFF7

function! HighlightDefineGroups()
    hi HG_Subtle ctermfg=yellow  ctermbg=lightgray guibg=#efeff7
    hi HG_Warning ctermfg=yellow ctermbg=lightgray guibg=#ffffdd
    hi HG_Error   ctermfg=red    ctermbg=lightgray guibg=#ffe0e0
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

" Adjust 'spell' setting for file (see g:SpellMap for details).
" Generally called from autocmd on filetype change.
function! SetSpell()
    " Bail out if 'spell' setting is globally disabled.
    if ! g:Spell
        return
    endif

    " Track keys we've seen before.
    let l:sawKey = {}

    if has_key(g:SpellMap, &filetype)
        let key = &filetype
    elseif exists("b:SpellType")
        let key = b:SpellType
    else
        let key = "<*>"
    endif

    while has_key(g:SpellMap, key)
        if has_key(l:sawKey, key)
            echoerr "Loop in g:SpellMap for key:" key
            return
        endif
        let l:sawKey[key] = 1
        let key = g:SpellMap[key]
    endwhile

    if key == "<on>"
        setl spell
    elseif key == "<off>"
        setl nospell
    endif
endfunction

" -------------------------------------------------------------
" Setup for mail.
" -------------------------------------------------------------
function! SetupMail()
    " Use the 'w' flag in formatoptions to setup format=flowed editing.
    " The 'w' flag causes problems for wrapping when manual editing strips
    " out a trailing space.  Better to avoid the flag...
    " set formatoptions+=w
    setlocal tw=64 sw=2 sts=2 et ai
endfunction
command! SetupMail call SetupMail()
let g:SpellMap["mail"] = "<on>"

" -------------------------------------------------------------
" Setup for plain text.
" -------------------------------------------------------------
function! SetupText()
    setlocal tw=80 ts=2 sts=2 sw=2 et ai
    let b:SpellType = "<text>"
endfunction
command! SetupText call SetupText()
let g:SpellMap["<text>"] = "<on>"

" -------------------------------------------------------------
" Setup for general source code.
" -------------------------------------------------------------
function! SetupSource()
    setlocal tw=80 ts=4 sts=4 sw=4 et ai
    Highlight longlines tabs trailingspace
    let b:SpellType = "<source>"
endfunction
command! SetupSource call SetupSource()
let g:SpellMap["<source>"] = "<on>"

" -------------------------------------------------------------
" Setup for markup languages like HTML, XML, ....
" -------------------------------------------------------------
function! SetupMarkup()
    setlocal tw=80 ts=2 sts=2 sw=2 et ai
    runtime scripts/closetag.vim
    runtime scripts/xml.vim
    let b:SpellType = "<markup>"
endfunction
command! SetupMarkup call SetupMarkup()
let g:SpellMap["<markup>"] = "<on>"

" -------------------------------------------------------------
" Setup for Markdown.
" -------------------------------------------------------------
function! SetupMarkdown()
    call SetupMarkup()
endfunction
command! SetupMarkdown call SetupMarkdown()

" -------------------------------------------------------------
" Setup for reStructuredText.
" -------------------------------------------------------------
function! SetupRstSyntax()
    " Layout embedded source as follows:
    " .. code-block:: lang
    "     lang-specific source code here.
    " ..
    function! l:EmbedSourceAs(lang, asLang)
        let cmd  = 'syntax region embedded_' . a:lang
        let cmd .= ' matchgroup=embeddedSyntax'
        let cmd .= ' start="^\z(\s*\)\.\.\s\+code-block::\s\+'
        let cmd .= a:lang . '\s*$"'
        " @todo Don't forget to highlight :options: lines
        " such as :linenos:
        let cmd .= ' skip="\n\z1\s\|\n\s*\n"'
        let cmd .= ' end="$"'
        let cmd .= ' contains=@embedded_' . a:asLang
        execute cmd
        hi link embeddedSyntax SpecialComment
    endfunction
    " NOTE: Embedding java causes spell checking to be disabled, because
    " the syntax file for java monkeys with the spell checking settings.
    for lang in split("cpp html python")
        call SyntaxInclude('embedded_' . lang, lang)
        call l:EmbedSourceAs(lang, lang)
    endfor
    " Special-case C because Vim's syntax highlighting for cpp
    " is based on the C highlighting, and it doesn't like to
    " have both C and CPP active at the same time.
    call l:EmbedSourceAs('c', 'cpp')
endfunction
command! SetupRstSyntax call SetupRstSyntax()

function! SetupRst()
    setlocal tw=80 ts=2 sts=2 sw=2 et ai
endfunction
command! SetupRst call SetupRst()
let g:SpellMap["rst"] = "<on>"

" -------------------------------------------------------------
" Setup for Wikipedia.
" -------------------------------------------------------------
function! SetupWikipedia()
    setlocal tw=0 ts=2 sts=2 sw=2 et ai
    " Setup angle brackets as matched pairs for '%'.
    setlocal matchpairs+=<:>
endfunction
command! SetupWikipedia call SetupWikipedia()
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
command! SetupBashFixcommand call SetupBashFixcommand()

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
    call SetupSource()
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

    " Setup formatoptions:
    "   c - auto-wrap comments to textwidth.
    "   r - automatically insert comment leader when pressing <Enter>.
    "   o - automatically insert comment leader after 'o' or 'O'.
    "   q - allow formatting of comments with 'gq'.
    "   l - long lines are not broken in insert mode.
    "   n - recognize numbered lists.
    setlocal formatoptions=croqln

    " Map CTRL-O_CR to append ';' to the end of line, then do CR.
    inoremap <buffer> <C-O><CR> <C-\><C-N>A;<CR>
    vnoremap <buffer> <C-O><CR> <C-\><C-N>A;<CR>
endfunction
command! SetupC call SetupC()

" -------------------------------------------------------------
" Setup for C++ code.
" -------------------------------------------------------------
function! SetupCpp()
    call SetupC()
endfunction
command! SetupCpp call SetupCpp()

" -------------------------------------------------------------
" Setup for general Clojure code.
" -------------------------------------------------------------
function! SetupClojure()
    call SetupSource()
    setlocal ts=2 sts=2 sw=2
endfunction
command! SetupClojure call SetupClojure()

" -------------------------------------------------------------
" Setup for D code.
" -------------------------------------------------------------
function! SetupD()
    call SetupC()
endfunction
command! SetupD call SetupD()

" -------------------------------------------------------------
" Setup for JavaScript.
" -------------------------------------------------------------
function! SetupJavaScript()
    call SetupSource()

    " Map CTRL-O_CR to append ';' to the end of line, then do CR.
    inoremap <buffer> <C-O><CR> <C-\><C-N>A;<CR>
    vnoremap <buffer> <C-O><CR> <C-\><C-N>A;<CR>
endfunction
command! SetupJavaScript call SetupJavaScript()

" -------------------------------------------------------------
" Setup for Python.
" -------------------------------------------------------------
function! SetupPython()
    call SetupSource()

    " Python always thinks tabs are 8 characters wide.
    setlocal ts=8

    " Follow PEP-recommended alignment of parentheses
    setlocal cinoptions+=(0

    " Map CTRL-O_CR to append ':' to the end of line, then do CR.
    inoremap <buffer> <C-O><CR> <C-\><C-N>A:<CR>
    vnoremap <buffer> <C-O><CR> <C-\><C-N>A:<CR>
endfunction
command! SetupPython call SetupPython()

" -------------------------------------------------------------
" Setup for VHDL.
" -------------------------------------------------------------
function! SetupVhdl()
    call SetupSource()

    setlocal comments=b:--

    " Setup formatoptions:
    "   c - auto-wrap comments to textwidth.
    "   r - automatically insert comment leader when pressing <Enter>.
    "   o - automatically insert comment leader after 'o' or 'O'.
    "   q - allow formatting of comments with 'gq'.
    "   l - long lines are not broken in insert mode.
    "   n - recognize numbered lists.
    setlocal formatoptions=croqln

    " Map CTRL-O_CR to append ';' to the end of line, then do CR.
    inoremap <buffer> <C-O><CR> <C-\><C-N>A;<CR>
    vnoremap <buffer> <C-O><CR> <C-\><C-N>A;<CR>

    " Convert a port into a port map.
    xnoremap <buffer> <leader>pm :s/^\(\s*\)\(\w\+\)\(\s*\)\(=>\<bar>:\).*
                \/\1\2\3=> \2,/<CR>
endfunction
command! SetupVhdl call SetupVhdl()

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

" Spell-check autocmd group.
augroup local_spell
    " First, remove all autocmds in this group.
    autocmd!
    autocmd FileType * call SetSpell()
augroup END

" Put these in an autocmd group, so that we can delete them easily.
augroup local_vimrc
    " First, remove all autocmds in this group.
    autocmd!

    " Show diffs when writing commit messages for git.
    autocmd FileType gitcommit
                \ DiffGitCached | wincmd J | wincmd p |
                \ resize 15

    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid or when inside an event
    " handler (happens when dropping a file on gvim).
    "
    " Keep this before the other BufReadPost autocmds, otherwise it will
    " take precedence over them.
    autocmd BufReadPost *
                \ if line("'\"") > 0 && line("'\"") <= line("$") |
                \   exe "normal g`\"" |
                \ endif

    " Make sure we start at the top of the commit message when doing
    " a git commit.
    autocmd BufReadPost COMMIT_EDITMSG exe "normal! gg"

    " Do the same for Subversion.
    autocmd BufReadPost svn-commit.tmp exe "normal! gg"

    " Set the text width for commit messages in Subversion.  It turns out
    " that Vim has a file type mapping for Subversion commits: svn.  Set it
    " to the same width as Git commit messages, 72.
    autocmd FileType svn setlocal tw=72

    " Use tabs in gitconfig and .gitconfig.
    autocmd FileType gitconfig setlocal noexpandtab
    autocmd FileType .gitconfig setlocal noexpandtab

    " By default, when Vim switches buffers in a window, the new buffer's
    " cursor position is scrolled to the center (as if 'zz' had been
    " issued).  This fix restores the buffer's position.
    if v:version >= 700
            autocmd BufLeave * let b:winview = winsaveview()
            autocmd BufEnter * if (!&diff && exists('b:winview')) |
                        \call winrestview(b:winview) |
                        \endif
    endif

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

" =============================================================
" Status line
" =============================================================

" Function used to display syntax group.
function! SyntaxItem()
    return synIDattr(synID(line("."),col("."),1),"name")
endfunction

" Function used to display utf-8 sequence.
fun! ShowUtf8Sequence()
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

" =============================================================
" Color schemes
" =============================================================

" The &background variable uses the environment variable COLORFGBG to determine
" whether the background is dark or light.  After changing the background color
" in the terminal emulator, it's necessary to either restart the shell or update
" the environment variable accordingly.

if $TERM == 'cygwin'
    set background=light
endif

" Choose a light color scheme only for light-background environments.
if &background == 'light' || has("gui_running")
    colorscheme nuvola
endif
" colorscheme nuvola    " nice, light, pretty (Matt Gilbert pick)
" colorscheme habilight " modified nuvola, some new features
" colorscheme ps_color  " somewhat dark
" colorscheme darkblue2 " somewhat dark

" =============================================================
" GUI Setup
" =============================================================

if has("gui_running")
    " 'T' flag controls the toolbar (we don't need it).
    set guioptions-=T

    " 'a' is for Autoselect mode, in which selections will automatically be
    " added to the clipboard (on Windows) or the primary selection (on Unix).
    set guioptions-=a

    " Number of lines of text overall.
    set lines=50

    " Setup nice fonts.
    if has("gui_gtk2")

        " The documentation for 'guifont' claims that fonts can be
        " comma-separated, and that the first font to be found will
        " be used.  This doesn't seem to be the case for me.  When
        " the first font isn't available, no other fonts are tried,
        " and Vim falls back to a default font.  So, this ugly
        " hack lets me try PragmataPro at home but still have reasonable
        " fonts elsewhere.
        " TODO: Find a better solution fallback fonts.
        if len(glob($HOME . "/.fonts/p/PragmataPro*.ttf"))
            set guifont=PragmataPro\ 12
        else
            set guifont=DejaVu\ Sans\ Mono\ 12
            "set guifont=Bitstream\ Vera\ Sans\ Mono\ 12
            "set guifont=Inconsolata\ Medium\ 13
        endif

    elseif has("x11")
        set guifont=-*-lucidatypewriter-medium-r-normal-*-*-100-*-*-m-*-*

    elseif has("win32")
        try
            set guifont=Bitstream_Vera_Sans_Mono:h12:cANSI
        catch
            set guifont=Lucida_Console:h12:cDEFAULT
        endtry
    else
        " Non-X11 GUIs including Windows.
        set guifont=Lucida_Console:h12:cDEFAULT
    endif
endif

" If it exists, source the specified "-after.vim" hook.
if filereadable($VIMRC_AFTER)
    source $VIMRC_AFTER
endif
