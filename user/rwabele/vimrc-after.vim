" Make Y work the way I expect it to: yank to the end of the line.
nnoremap Y y$

" Shortcut for clearing CtrlP caches
nnoremap <Leader><Leader>r :<C-U>CtrlPClearAllCaches<CR>

" Allow . to work over visual ranges.
vnoremap . :normal .<CR>

" Make splits appear on the right.
set splitright

" Make line numbers appear relative to the cursor postion.
set relativenumber

"Toggle relative and normal numbering
function! NumberToggle()
    if(&relativenumber == 1)
        set number
    else
        set relativenumber
    endif
endfunction

nnoremap <C-n> :call NumberToggle()<cr>

nmap <leader><leader>a :Ack 

" Shortcuts for moving between windows.
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

set background=dark
colorscheme base16-eighties

" Enable basic mouse behavior such as resizing buffers.
set mouse=a
if exists('$TMUX')  " Support resizing in tmux
  set ttymouse=xterm2
endif

nmap <leader><leader>t :TagbarToggle<CR>

" Blank line below current line
nnoremap zj o<Esc>
" Blank line above current line
nnoremap zk O<Esc>

" Bells are bad
set noerrorbells

" Setup Neocomlete
" Plugin key-mappings.
inoremap <expr><C-g>     neocomplete#undo_completion()
inoremap <expr><C-l>     neocomplete#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return neocomplete#close_popup() . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? neocomplete#close_popup() : "\<CR>"
endfunction
" <TAB>: completion.
"inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><C-y>  neocomplete#close_popup()
inoremap <expr><C-e>  neocomplete#cancel_popup()

" Get rid of all the annoying window borders in gvim
set guioptions=

" Very magic regex
nnoremap / /\v
cnoremap %s/ %s/\v

set guifont=Source\ Code\ Pro\ Light
