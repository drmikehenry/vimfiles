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

if !has("gui_running")
    colorscheme elflord
endif

if has("mac") || has("macunix")
    set guifont=Droid\ Sans\ Mono:h14,Inconsolata:h16
    " let Grep_Xargs_Options = -0
endif

if has("gui_macvim")
    set macmeta
endif

set nowrap

" Use ack for grep
set grepprg=ack
set grepformat=%f:%l:%m

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

" Use a regex format that I already know well by having
" / insert a /v in front of the regex.
nnoremap / /\v
vnoremap / /\v
