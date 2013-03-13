" Set the color scheme early on, so at least I have that when other things go
" wrong.
colorscheme szakdark

" =============================================================
" Variables
" =============================================================

" Default font size.
if has("gui_win32")
    let g:SZAK_FONT_SIZE = 11
else
    let g:SZAK_FONT_SIZE = 14
endif

" =============================================================
" Detect custom exectuables
" =============================================================

if filereadable(expand("$HOME/.local/bin/ctags"))
    let Tlist_Ctags_Cmd='/Users/jszakmeister/.local/bin/ctags'
    let g:tagbar_ctags_bin = '/Users/jszakmeister/.local/bin/ctags'
endif

if filereadable(expand("$HOME/.local/bin/git"))
    let g:fugitive_git_executable = expand("$HOME/.local/bin/git")
    let g:Gitv_GitExecutable = g:fugitive_git_executable
endif

" =============================================================
" Mappings
" =============================================================

" Make Y work the way I expect it to: yank to the end of the line.
nnoremap Y y$

" Keep the block highlighted while shifting.
vnoremap < <gv
vnoremap > >gv

" Visually select the text that was last edited/pasted.
nnoremap gV `[v`]

" Some reminders of the tag-related shortcuts, since I tend to check my
" configuration first.
" C-] - go to definition
" C-T - Jump back from the definition.
" C-W C-] - Open the definition in a horizontal split

" C-\ - Open the definition in a new tab
" A-] - Open the definition in a vertical split
map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>

" The next several entries are taken from:
"     <http://stevelosh.com/blog/2010/09/coming-home-to-vim/>

" Split the window vertically, and go to it.
nnoremap <leader>w <C-w>v<C-w>l

" I often want to close a buffer without closing the window.  Using
" :BW also drops the associated metadata.
nnoremap <leader><leader>d :BW<CR>

" Shortcut for clearing CtrlP caches
nnoremap <Leader><Leader>r :<C-U>CtrlPClearAllCaches<CR>

" Add some mappings for Regrep since I don't use the function keys.
vnoremap <expr> <Leader><Leader>g VisualRegrep()
nnoremap <expr> <Leader><Leader>g NormalRegrep()

" Copies a selection to the clipboard, with 4 spaces added to the front.
" This makes it easier to paste into a markdown-enabled form, like on
" StackOverflow and on GitHub.
function! CopyForMarkdown() range
    let lines = getline(a:firstline, a:lastline)
    call map(lines, '"    " . v:val')
    let @+ = join(lines, "\n") . "\n"
endfunction
command! -range CopyForMarkdown <line1>,<line2>call CopyForMarkdown()

vnoremap <Leader><Leader>cm :CopyForMarkdown<CR>

function! UnmapUnwanted()
    " Unmap one of AlignMap's mappings... I don't use it, and it delays the above
    " mapping.
    unmap <leader>w=
endfunction

" Allow . to work over visual ranges.
vnoremap . :normal .<CR>

" =============================================================
" Options
" =============================================================

" Turn on list, and setup the listchars.
set listchars=tab:▸\ ,trail:·,extends:>,precedes:<,nbsp:·
if &termencoding ==# 'utf-8' || &encoding ==# 'utf-8'
    let &listchars = "tab:\u21e5 ,trail:\u2423,extends:\u21c9,precedes:\u21c7,nbsp:\u26ad"
    let &fillchars = "vert:\u254e,fold:\u00b7"
endif
set list

" I dislike wrapping being on by default.
set nowrap

" Ignore some Clojure/Java-related files.
set wildignore+=target/**,asset-cache

" I regularly create tmp folders that I don't want searched.
set wildignore+=tmp,.lein-*,*.egg-info,.*.swo

" Set colorcolumn, if available.
if exists('+colorcolumn')
    " This sets it to textwidth+1
    set colorcolumn=+1
endif

" Make splits appear on the right.
set splitright

" For some reason, gnome-terminal says xterm-color even though it supports
" xterm-256color.
if !has("gui_running") && $COLORTERM == "gnome-terminal" && &t_Co <= 16
    set t_Co=256
endif

" -------------------------------------------------------------
" GUI options
" -------------------------------------------------------------

" Turn off the scrollbars... I don't need them.
if has("gui_running")
    set guioptions-=R
    set guioptions-=r
    set guioptions-=L
    set guioptions-=l
endif

if has("gui_macvim")
    set macmeta
endif

" On remote systems, I like to change the background color so that I remember
" I'm on a remote system. :-)  This does break when you sudo su to root though.
if !empty($SSH_TTY)
    hi Normal guibg=#0d280d
endif

" Set the width to accommodate a full 80 column view + tagbar + some change.
if has("gui_running")
    set columns=132
endif

" -------------------------------------------------------------
" Font selection
" -------------------------------------------------------------

" Helper to aid in locating Powerline-enabled fonts in standard directory
" locations.
function! HasFont(filename)
    if has("macunix")
        let l:search_paths = ["~/Library/Fonts", "/Library/Fonts"]
    elseif has("gui_win32")
        let l:search_paths = [expand("$windir/Fonts")]
    else
        let l:search_paths = ["~/.fonts", "/usr/share/fonts"]
    endif

    for path in l:search_paths
        let path = expand(path)
        if filereadable(expand(path . "/**/" . a:filename))
            return 1
        endif
    endfor

    return 0
endfunction

" Searches for several Powerline-enabled fonts.  If it finds one, it'll choose
" it and turn on fancy symbols for Powerline.  Otherwise, fallback to a normal
" font, and use unicode symbols for Powerline.
function! SetFont()
    " Turn on fancy symbols on the status line
    if has("gui_running")
        let powerline_fonts=[
                    \   ["DejaVu Sans Mono", "DejaVuSansMono-Powerline.ttf"],
                    \   ["Droid Sans Mono", "DroidSansMonoSlashed-Powerline.ttf"],
                    \   ]
        let fontname=map(copy(powerline_fonts), 'v:val[0]')

        for font in powerline_fonts
            if HasFont(font[1])
                let fontname=[font[0] . " for Powerline"]
                let g:Powerline_symbols = 'fancy'
                break
            endif
        endfor

        if has("macunix") || has("gui_win32")
            let fontstring=join(map(
                        \ copy(fontname), 'v:val . ":h" . g:SZAK_FONT_SIZE'), ",")
        else
            let fontstring=join(map(
                        \ copy(fontname), 'v:val . " " . g:SZAK_FONT_SIZE'), ",")
        endif

        let &guifont=fontstring
    endif
endfunction
command! -bar SetFont call SetFont()

" =============================================================
" Fullscreen
" =============================================================

" Allow Vim to go fullscreen under Mac and Linux.
if has("gui_macvim")
    " grow to maximum horizontal width on entering fullscreen mode
    set fuopt+=maxhorz

    " This needs to go in a gvimrc, otherwise the macmenu defaults
    " clobber my setting.  Not sure how I want to do this just yet.
    " " free up Command-F
    " macmenu Edit.Find.Find\.\.\. key=<nop>

    " " toggle fullscreen mode
    " map <D-f> :set invfu<CR>
    nnoremap <Leader><Leader>f :set invfu<CR>
endif

if has("unix")
    let s:os = substitute(system('uname'), "\n", "", "")
    if v:version >= 703 && s:os == "Linux" && has("gui_running")
        function! ToggleFullScreen()
           call system("wmctrl -i -r ".v:windowid." -b toggle,fullscreen")
           redraw
        endfunction

        nnoremap <Leader><Leader>f call ToggleFullScreen()<CR>
    endif
endif

" =============================================================
" Setup routines
" =============================================================

function! SetupManPager()
    setlocal nonu nolist
    nnoremap <Space> <PageDown>
    nnoremap b <PageUp>
    nnoremap q :quit<CR>
endfunction
command! -bar SetupManPager call SetupManPager()

" =============================================================
" Plugin settings
" =============================================================

" -------------------------------------------------------------
" CtrlP
" -------------------------------------------------------------

nnoremap <SNR>CtrlP.....<C-s>     :<C-U>CtrlPRTS<CR>

" -------------------------------------------------------------
" Gitv
" -------------------------------------------------------------

let g:Gitv_WipeAllOnClose = 1
let g:Gitv_OpenHorizontal = 1
let g:Gitv_OpenPreviewOnLaunch = 1

" -------------------------------------------------------------
" manpageview
" -------------------------------------------------------------

" let g:manpageview_options= "-P 'cat -'"

" -------------------------------------------------------------
" Grep
" -------------------------------------------------------------

" Use ack for grep
if executable('ack')
    set grepprg=ack
    set grepformat=%f:%l:%m
endif

" Be compatible with both grep on Linux and Mac
let Grep_Xargs_Options = '-0'

" -------------------------------------------------------------
" Netrw
" -------------------------------------------------------------

let g:netrw_nogx = 1

function! SmartOpen()
    if mode() ==# 'n'
        let uri = expand("<cWORD>")
        if match(uri, "://")
            let uri = expand("<cfile>")
        endif
    else
        let uri = s:get_selected_text()
    endif

    call netrw#NetrwBrowseX(uri, 0)
endfunction
command! -bar SmartOpen call SmartOpen()

" Get selected text in visual mode.
function! s:get_selected_text()
    let save_z = getreg('z', 1)
    let save_z_type = getregtype('z')

    try
        normal! gv"zy
        return @z
    finally
        call setreg('z', save_z, save_z_type)
    endtry
endfunction

nmap gx :SmartOpen<CR>
vmap gx :SmartOpen<CR>

" -------------------------------------------------------------
" VimClojure
" -------------------------------------------------------------

" Highlight Clojure's builtins and turn on rainbow parens
let g:vimclojure#HighlightBuiltins=1
let g:vimclojure#ParenRainbow=1

" Treat forms that start with def as lispwords
let g:vimclojure#FuzzyIndent=1

" I keep my nailgun client in ~/.local/bin.  If it's there, then let
" VimClojure know.
if executable(expand("~/.local/bin/ng"))
    let g:vimclojure#NailgunClient=expand("~/.local/bin/ng")
endif

" -------------------------------------------------------------
" Powerline
" -------------------------------------------------------------

if g:EnablePowerline
    " Add back in a few segments...
    call Pl#Theme#InsertSegment('mode_indicator', 'after', 'paste_indicator')
    call Pl#Theme#InsertSegment('filetype', 'before', 'scrollpercent')

    call Pl#Theme#InsertSegment('ws_marker', 'after', 'lineinfo')

    if !has("gui_running")
        if &termencoding ==# 'utf-8' || &encoding ==# 'utf-8'
            let g:Powerline_symbols_override = {
                \ 'BRANCH': [0x2442],
                \ }
        endif
    endif

    let g:Powerline_mode_n = 'N'
    let g:Powerline_mode_i = 'I'
    let g:Powerline_mode_R = 'R'
    let g:Powerline_mode_v = 'V'
    let g:Powerline_mode_V = 'V⋅LINE'
    let g:Powerline_mode_cv = 'V⋅BLOCK'
    let g:Powerline_mode_s = 'SELECT'
    let g:Powerline_mode_S = 'S⋅LINE'
    let g:Powerline_mode_cs = 'S⋅BLOCK'

    let g:Powerline_colorscheme = 'szakdark'
endif

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

" -------------------------------------------------------------
" Tagbar
" -------------------------------------------------------------

let g:tagbar_type_rst = g:local_tagbar_type_rst

" =============================================================
" Autocommands
" =============================================================

augroup jszakmeister_vimrc
    autocmd!
    autocmd FileType man call setpos("'\"", [0, 0, 0, 0])|exe "normal! gg"
    autocmd VimEnter * call ReplacePowerlineSyntastic()
    autocmd VimEnter * call UnmapUnwanted()
augroup END

" =============================================================
" Commands
" =============================================================

function! SourceRange() range
    let l:regSave = @"
    execute a:firstline . "," . a:lastline . 'y"'
    @"
    let @" = l:regSave
endfunction
command! -range=% Source <line1>,<line2>call SourceRange()

function! ShowHighlightGroup()
    echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
        \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
        \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"
endfunction
command! -bar ShowHighlightGroup call ShowHighlightGroup()

function! ShowAvailableColors()
    " Optional: First enter ":let g:rgb_fg=1" to highlight foreground only.
    " Restore normal highlighting by typing ":call clearmatches()"
    "
    " Create a new scratch buffer:
    " - Read file $VIMRUNTIME/rgb.txt
    " - Delete lines where color name is not a single word (duplicates).
    " - Delete "grey" lines (duplicate "gray"; there are a few more "gray").
    " Add matches so each color name is highlighted in its color.
    call clearmatches()
    new
    setlocal buftype=nofile bufhidden=hide noswapfile
    0read $VIMRUNTIME/rgb.txt
    let find_color = '^\s*\(\d\+\s*\)\{3}\zs\w*$'
    silent execute 'v/'.find_color.'/d'
    silent g/grey/d
    let namedcolors=[]
    1
    while search(find_color, 'W') > 0
        let w = expand('<cword>')
        call add(namedcolors, w)
    endwhile

    for w in namedcolors
        execute 'hi col_'.w.' guifg=black guibg='.w
        execute 'hi col_'.w.'_fg guifg='.w.' guibg=NONE'
        execute '%s/\<'.w.'\>/'.printf("%-36s%s", w, w).'/g'

        call matchadd('col_'.w, '\<'.w.'\>', -1)
        " determine second string by that with large # of spaces before it
        call matchadd('col_'.w.'_fg', ' \{10,}\<'.w.'\>', -1)
    endfor
    1
    nohlsearch
endfunction
command! -bar ShowAvailableColors call ShowAvailableColors()

" Size for the big screen.
function! BigScreenTv()
    set columns=120
    set lines=36
    let &guifont = substitute(&guifont, ':h\([^:]*\)', ':h25', '')
endfunction
command! -bar BigScreenTv call BigScreenTv()

" -------------------------------------------------------------
" Toggling diffs for printing.
" -------------------------------------------------------------

" Colors used when print colors is toggled
let s:diffAddColors = ["#00ff00", "NONE"]
let s:diffDeleteColors = ["#ff0000", "NONE"]

function! s:GetFgBgColor(name)
    let l:hlId = hlID(a:name)
    let l:fgColor = synIDattr(l:hlId, 'fg#')
    let l:fgColor = empty(l:fgColor) ? "NONE" : l:fgColor
    let l:bgColor = synIDattr(l:hlId, 'bg#')
    let l:bgColor = empty(l:bgColor) ? "NONE" : l:bgColor

    return [l:fgColor, l:bgColor]
endfunction

function! TogglePrintColors()
    let l:savedColors = s:GetFgBgColor('DiffAdd')
    exe ":hi DiffAdd guifg=" . s:diffAddColors[0] . " guibg=" . s:diffAddColors[1]
    let s:diffAddColors = l:savedColors

    let l:savedColors = s:GetFgBgColor('DiffDelete')
    exe ":hi DiffDelete guifg=" . s:diffDeleteColors[0] . " guibg=" . s:diffDeleteColors[1]
    let s:diffDeleteColors = l:savedColors
endfunction
command! TogglePrintColors call TogglePrintColors()

" -------------------------------------------------------------
" PrettyXML
" -------------------------------------------------------------

" This was taken from the Vim wiki:
"   http://vim.wikia.com/wiki/Pretty-formatting_XML
"
" It requires xmllint, but that's fine by me.
function! DoPrettyXML()
    " save the filetype so we can restore it later
    let l:origft = &ft
    set ft=
    " delete the xml header if it exists. This will
    " permit us to surround the document with fake tags
    " without creating invalid xml.
    1s/<?xml .*?>//e
    " insert fake tags around the entire document.
    " This will permit us to pretty-format excerpts of
    " XML that may contain multiple top-level elements.
    0put ='<PrettyXML>'
    $put ='</PrettyXML>'
    silent %!xmllint --format -
    " xmllint will insert an <?xml?> header. it's easy enough to delete
    " if you don't want it.
    " delete the fake tags
    2d
    $d
    " restore the 'normal' indentation, which is one extra level
    " too deep due to the extra tags we wrapped around the document.
    silent %<
    " back to home
    1
    " restore the filetype
    exe "set ft=" . l:origft
endfunction
command! -bar PrettyXML call DoPrettyXML()

" -------------------------------------------------------------
" GrabGithubIssueSnippet
" -------------------------------------------------------------

python << endpython
def getIssueData(apiUrl, repo, issueNumber):
    import requests
    import json
    import types

    if apiUrl.endswith('/'):
        apiUrl = apiUrl.rstrip('/')

    r = requests.get('%s/repos/%s/issues/%s' % (apiUrl, repo, issueNumber))
    return json.loads(r.text)
endpython

function! GrabGithubIssueSnippet(repo, issueNumber)
    if exists('b:gh_api_url')
        let l:gh_api_url = b:gh_api_url
    else
        let l:gh_api_url = 'https://api.github.com/'
    endif

python << endpython
data = getIssueData(vim.eval("l:gh_api_url"),
                    vim.eval("a:repo"),
                    vim.eval("a:issueNumber"))
issueUrl = data['html_url']
title = data['title']

vim.command("let l:issueUrl = '%s'" % issueUrl)
vim.command("let l:title = '%s'" % title)
endpython

    return "#" . a:issueNumber . ": " . l:title . "\n" . "<" . l:issueUrl . ">"
endfunction

function! GrabIssueSnippetFromCurrentRepo(issueNumber)
    if !exists("b:gh_repo")
        echoerr "You must define 'b:gh_repo' first!"
    endif
    return GrabGithubIssueSnippet(b:gh_repo, a:issueNumber)
endfunction
command! -nargs=1 GrabGithubIssueSnippet
            \ :execute "normal! a" . GrabIssueSnippetFromCurrentRepo(<args>)

" -------------------------------------------------------------
" GrabMap
" -------------------------------------------------------------

function! GrabMap()
    let l:save_a = @a
    let @a = ''
    redir @A
    map
    redir END
    enew
    set buftype=nofile
    set bufhidden=hide
    setlocal noswapfile
    execute 'normal 0"ap'
    let @a = l:save_a
endfunction
command! GrabMap :call GrabMap()

" =============================================================
" Machine Specific Settings
" =============================================================

if $VIMMACHINE == ""
    let $VIMMACHINE=hostname()
endif

let s:VIMMACHINE_CONFIG = $VIMUSERFILES . "/" .
    \ "/machine/" . $VIMMACHINE . ".vim"

" If a machine local config exists, source it.
if filereadable(s:VIMMACHINE_CONFIG)
    execute "source " . s:VIMMACHINE_CONFIG
endif

" This needs to happen here so that the Powerline variables are set correctly
" before the plugin loads.  It needs to come after the machine scripts, so that
" they have an opportunity to adjust the desired font size.
SetFont
