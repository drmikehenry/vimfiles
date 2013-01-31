" Unmap the <Esc> sequence.  It gets in the way of terminal usage when you
" change buffers and then hit an arrow key.  Unmap 'y' as well, as I see no use
" for the feature, and occasionally gets in the way when yanking text.
let s:seq = maparg('<space>', 'n')
if s:seq =~# '.*idxz.*'
    let s:seq = matchstr(s:seq, '<SNR>\d\+_m_')
    execute "silent! nunmap " . s:seq . "<Esc>"
    execute "silent! nunmap " . s:seq . "y"
endif

unlet s:seq
