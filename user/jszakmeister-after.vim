if has("mac") || has("macunix")
    let Tlist_Ctags_Cmd='/Users/jszakmeister/.local/bin/ctags'
endif

" Some reminders of the tag-related shortcuts, since I tend to check my
" configuration first.
" C-] - go to definition
" C-T - Jump back from the definition.
" C-W C-] - Open the definition in a horizontal split

" C-\ - Open the definition in a new tab
" A-] - Open the definition in a vertical split
map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>

" Emulate SlickEdit w/Emacs bindings: Use Ctrl-. and Ctrl-,
" to pop in and out of the tags
"nnoremap <C-.> :tag
"nnoremap <C-,> :pop

colorscheme szakdark

if !has("gui_running")
    if (has("mac") || has("macunix")) && $TERM_PROGRAM == "iTerm.app"
        " This works only in iTerm... but that's what I use on the Mac.
        " Set the cursor to a vertical line in insert mode.
        let &t_SI = "\<Esc>]50;CursorShape=1\x7"
        let &t_EI = "\<Esc>]50;CursorShape=0\x7"
    endif

    if &t_Co > 255
        " The highlighting scheme sucks for spelling errors.  Tweak them
        " to be more readable.  Only do this for terminals that have
        " 256 colors or better... which happens to be most of mine.
        hi SpellBad   ctermbg=52
        hi SpellRare  ctermbg=53
        hi SpellLocal ctermbg=23
        hi SpellCap   ctermbg=17

        " The highlighting for going past the rightmost column is also
        " hard to read (or to harsh to read) in a black terminal.  Tweak
        " them too.
        hi HG_Subtle        ctermfg=yellow ctermbg=52
        hi HG_Warning       ctermfg=yellow ctermbg=52
        hi HG_Error         ctermfg=red    ctermbg=195
        hi Highlight_tabs   ctermbg=236
    endif
endif

if has("mac") || has("macunix")
    " Turn on fancy symbols on the status line
    if has("gui_running")
        if filereadable(expand("~/Library/Fonts/DroidSansMonoSlashed-Powerline.ttf"))
            set guifont=Droid\ Sans\ Mono\ Slashed\ for\ Powerline:h14
            let g:Powerline_symbols = 'fancy'
        else
            set guifont=Droid\ Sans\ Mono:h14,Inconsolata:h16
        endif
    endif
    " let Grep_Xargs_Options = -0
endif

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

" I keep my nailgun client in ~/.local/bin.  If it's there, then let
" VimClojure know.
if executable(expand("~/.local/bin/ng"))
    let g:vimclojure#NailgunClient=expand("~/.local/bin/ng")
endif

" I often want to close a buffer without closing the window
nnoremap <leader><leader>d :BD<CR>

function! SetupManPager()
    setlocal nonu nolist
    nnoremap <Space> <PageDown>
    nnoremap b <PageUp>
    nnoremap q :quit<CR>
endfunction
command! SetupManPager call SetupManPager()

augroup jszakmeister_vimrc
    autocmd FileType man call setpos("'\"", [0, 0, 0, 0])|exe "normal! gg"
augroup END

" Make Command-T ignore some Clojure/Java-related bits.
set wildignore+=target/**,asset-cache

" I regularly create tmp folders that I don't want searched
set wildignore+=tmp
