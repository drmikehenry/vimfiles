" License: Distributed under Vim's |license|; see |bufmatch.txt| for details.

if exists('g:loaded_bufmatch')
    finish
endif
let g:loaded_bufmatch = 1

let s:save_cpo = &cpo
set cpo&vim

augroup bufmatch
    autocmd!
    autocmd BufWinEnter * call bufmatch#SyncWindow()
    autocmd WinEnter * call bufmatch#SyncWindow()
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
