" Set up some variables that can be overridden by a machine specific
" configuration file.
let g:SZAK_FONT_SIZE = 14

if $VIMMACHINE == ""
    let $VIMMACHINE=hostname()
endif

let s:VIMMACHINE_CONFIG = $VIMUSERFILES . "/" . $VIMUSER .
    \ "/machine/" . $VIMMACHINE . ".vim"

" If a machine local config exists, source it.
if filereadable(s:VIMMACHINE_CONFIG)
    execute "source " . s:VIMMACHINE_CONFIG
endif

if has("macunix")
    let Tlist_Ctags_Cmd='/Users/jszakmeister/.local/bin/ctags'
    let g:tagbar_ctags_bin = '/Users/jszakmeister/.local/bin/ctags'
endif

if filereadable(expand("$HOME/.local/bin/git"))
    let g:fugitive_git_executable = expand("$HOME/.local/bin/git")
    let g:Gitv_GitExecutable = g:fugitive_git_executable
endif

" Gitv
let g:Gitv_WipeAllOnClose = 1
let g:Gitv_OpenHorizontal = 1
let g:Gitv_OpenPreviewOnLaunch = 1

" Some reminders of the tag-related shortcuts, since I tend to check my
" configuration first.
" C-] - go to definition
" C-T - Jump back from the definition.
" C-W C-] - Open the definition in a horizontal split

" C-\ - Open the definition in a new tab
" A-] - Open the definition in a vertical split
map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>

" Tunn off the scrollbars... I don't need them.
if has("gui_running")
    set guioptions-=R
    set guioptions-=r
    set guioptions-=L
    set guioptions-=l
endif

colorscheme szakdark

if !has("gui_running")
    if has("macunix") && $TERM_PROGRAM == "iTerm.app"
        " This works only in iTerm... but that's what I use on the Mac.
        " Set the cursor to a vertical line in insert mode.
        let &t_SI = "\<Esc>]50;CursorShape=1\x7"
        let &t_EI = "\<Esc>]50;CursorShape=0\x7"
    elseif $COLORTERM == "gnome-terminal"
        if &t_Co <= 16
            set t_Co=256
        endif
    endif
endif

function! SetFont()
    " Turn on fancy symbols on the status line
    if has("gui_running")
        let fontname=["Droid Sans Mono", "Inconsolata"]

        if filereadable(expand("~/Library/Fonts/DroidSansMonoSlashed-Powerline.ttf")) ||
           \ filereadable(expand("~/.fonts/DroidSansMonoSlashed-Powerline.ttf"))
            let fontname=["Droid Sans Mono Slashed for Powerline"]
            let g:Powerline_symbols = 'fancy'
        endif

        if has("macunix")
            let fontstring=join(map(
                        \ copy(fontname), 'v:val . ":h" . g:SZAK_FONT_SIZE'), ",")
        else
            let fontstring=join(map(
                        \ copy(fontname), 'v:val . " " . g:SZAK_FONT_SIZE'), ",")
        endif

        let &guifont=fontstring
    endif
endfunction
command! SetFont call SetFont()

SetFont

if has("gui_macvim")
    set macmeta
endif

set nowrap

" Use ack for grep
if executable('ack')
    set grepprg=ack
    set grepformat=%f:%l:%m
endif

" Be compatible with both grep on Linux and Mac
let Grep_Xargs_Options = '-0'

" Add a method to switch to the scratch buffer
function! ToggleScratch()
    if expand('%') == g:ScratchBufferName
        quit
    else
        Sscratch
    endif
endfunction

map <leader>s :call ToggleScratch()<CR>

" The next several entries are taken from:
"     <http://stevelosh.com/blog/2010/09/coming-home-to-vim/>

" Split the window vertically, and go to it.
nnoremap <leader>w <C-w>v<C-w>l

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

" I often want to close a buffer without closing the window.  Using
" :BW also drops the associated metadata.
nnoremap <leader><leader>d :BW<CR>

function! SetupManPager()
    setlocal nonu nolist
    nnoremap <Space> <PageDown>
    nnoremap b <PageUp>
    nnoremap q :quit<CR>
endfunction
command! SetupManPager call SetupManPager()

augroup jszakmeister_vimrc
    autocmd!
    autocmd FileType man call setpos("'\"", [0, 0, 0, 0])|exe "normal! gg"
augroup END

" Ignore some Clojure/Java-related files.
set wildignore+=target/**,asset-cache

" I regularly create tmp folders that I don't want searched
set wildignore+=tmp,.lein-*,*.egg-info,.*.swo

" Shortcut for clearing CtrlP caches
nnoremap <Leader><Leader>r :<C-U>CtrlPClearAllCaches<CR>

" Add some mappings for Regrep since I don't use the function keys.
vnoremap <expr> <Leader><Leader>g VisualRegrep()
nnoremap <expr> <Leader><Leader>g NormalRegrep()

" Add a mapping for the Quickfix window.  Unfortunately, C-Q doesn't appear to
" work in a terminal.
nnoremap <Leader><Leader>q :call QuickFixWinToggle()<CR>

" On remote systems, I like to chnge the background color so that I remember I'm
" on a remote system. :-)  This does break when you sudo su to root though.
if !empty($SSH_TTY)
    hi Normal guibg=#0d280d
endif

" Powerline

if !exists("g:Powerline_loaded")
    " Add back in a few segments...
    call Pl#Theme#InsertSegment('mode_indicator', 'after', 'paste_indicator')
    call Pl#Theme#InsertSegment('filetype', 'before', 'scrollpercent')
    call Pl#Theme#InsertSegment('fileformat', 'before', 'filetype')

    call Pl#Theme#InsertSegment('ws_marker', 'after', 'lineinfo')

    if !has("gui_running")
        let g:Powerline_symbols_override = {
            \ 'BRANCH': [0x2442],
            \ }
    endif
endif

function! ShowHighlightGroup()
    echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
        \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
        \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"
endfunction
command! ShowHighlightGroup call ShowHighlightGroup()

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
command! ShowAvailableColors call ShowAvailableColors()

" Set colorcolumn, if available
if exists('+colorcolumn')
    " This sets it to textwidth+1
    set colorcolumn=+1
endif

" Size for the big screen.
function! BigScreenTv()
    set columns=120
    set lines=36
    let &guifont = substitute(&guifont, ':h\([^:]*\)', ':h25', '')
endfunction
command! BigScreenTv call BigScreenTv()
