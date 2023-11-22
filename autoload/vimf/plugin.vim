" Autoloaded plugin-related functions.

" True if plugin named `name` is enabled (i.e., not disabled via
" `g:pathogen_disabled`).
function! vimf#plugin#enabled(name)
    return index(g:pathogen_disabled, a:name) < 0
endfunction

function! vimf#plugin#enable(name)
    call filter(g:pathogen_disabled, 'v:val != a:name')
endfunction

function! vimf#plugin#disable(name)
    if vimf#plugin#enabled(a:name)
        call add(g:pathogen_disabled, a:name)
    endif
endfunction
