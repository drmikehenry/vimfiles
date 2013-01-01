" On my Dvorak keyboard, I much prefer the use of , as the leader.
let mapleader=","

" -------------------------------------------------------------
" localvimrc
" -------------------------------------------------------------

" Store all decisions
set viminfo+=!
let g:localvimrc_persistent=2

" Don't ask for now.  This works around an issue where localvimrc doesn't
" actually persist all decisions when localvimrc_persistent=2.
let g:localvimrc_ask=0

" Don't sandbox
" let g:localvimrc_sandbox=0
