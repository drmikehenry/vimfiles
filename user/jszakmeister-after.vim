if has("mac") || has("macunix")
    let Tlist_Ctags_Cmd='/Users/jszakmeister/.local/bin/ctags'
endif

set tags=./tags;$HOME

" You can add other tags by doing:
" set tags+=/usr/local/share/ctags/qt4

" C-] - go to definition
" C-T - Jump back from the definition.
" C-W C-] - Open the definition in a horizontal split

" Add these lines in vimrc
map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>

" C-\ - Open the definition in a new tab
" A-] - Open the definition in a vertical split

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

" Matches TextMate's ctrl-q to rewrap a paragraph of text
nnoremap <leader>q gqip

" Split the window vertically, and go to it.
nnoremap <leader>w <C-w>v<C-w>l

" Use a regex format that I already know well by having
" / insert a /v in front of the regex.
nnoremap / /\v
vnoremap / /\v

" A short cut to turn off highlighted matches
nnoremap <leader><space> :noh<cr>

" Another way to toggle the taglist
nmap <silent> <Leader>t :TlistToggle<CR>

" Another way to toggle the project listing
nmap <silent> <Leader>p <Plug>ToggleProject

" Show diffs when writing commit messages for git
autocmd FileType gitcommit DiffGitCached | wincmd J | wincmd p | resize 15

" Make sure we start at the top of the commit message when doing
" at git commit.
autocmd BufReadPost COMMIT_EDITMSG exe "normal! gg"

" Do the same for Subversion
autocmd BufReadPost svn-commit.tmp exe "normal! gg"

" Use tabs in gitconfig and .gitconfig
autocmd FileType gitconfig setlocal noexpandtab
autocmd FileType .gitconfig setlocal noexpandtab

if v:version >= 703
    set undofile
    set undodir=$VIMFILES/.undo
endif

" -------------------------------------------------------------
" Setup for general Clojure code.
" -------------------------------------------------------------
function! SetupClojure()
    call SetupSource()
endfunction
command! SetupClojure call SetupClojure()

" Make sure Command-T ignores some java-related bits
set wildignore+=*.class,classes/**,*.jar

" Keep snippets in my own area
set runtimepath+=$VIMUSERFILES/$VIMUSER
