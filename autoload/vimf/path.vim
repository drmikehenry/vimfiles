" path functions.

" Turns `path` into an absolute path, normalized for the platform.
" On Windows, paths with `/` become paths with `\`.

function! vimf#path#absolute(path)
    let p = fnamemodify(a:path, ':p')
    if has('win32')
        let minLen = len('C:\')
        " Replace slashes with backslashes on Windows.
        let p = substitute(p, '/', '\', '')
    else
        let minLen = len('/')
    endif
    if len(p) >= minLen
        " Remove any trailing slash that `fnamemodify()` may have added.
        let p = substitute(p, '[\\/]$', '', '')
    endif
    return p
endfunction

function! vimf#path#parent(path)
    return  fnamemodify(a:path, ':h')
endfunction
