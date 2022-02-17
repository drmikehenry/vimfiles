" License: Distributed under Vim's |license|; see |extend_list.txt| for details.

inoremap <silent> <plug>(extend_list) <ESC>:call extend_list#extend_list()<CR>A
xnoremap <silent> <plug>(extend_list) <ESC>:call extend_list#extend_list()<CR>A

if !exists('g:extend_list_map_keys')
    let g:extend_list_map_keys = 1
endif

if g:extend_list_map_keys
    imap <c-o>n <plug>(extend_list)
    xmap <c-o>n <plug>(extend_list)
endif
