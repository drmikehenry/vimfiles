" "multi-path" functions (for `$PATH`, `$PYTHONPATH`, etc.).
"
" `mpath` is a coined term meaning multiple paths.  An `mpath` is a string
" builds from multiple normal directory paths. These are joined with a separator
" (`:` on Unix, `;` on Windows) into a single string that represents all of
" these multiple paths.

" Separator character for `$PATH`-like things.
" - On Unix, this is ':'.
" - On Windows, this is ';'.
function! vimf#mpath#sep()
    if has('win32')
        let sep = ';'
    else
        let sep = ':'
    endif
    return sep
endfunction

" Split `mpath` at `vimf#mpath#sep()`.
" E.g., on Unix, splitting `/bin:/usr/bin' yields `['/bin', '/usr/bin']`.
function! vimf#mpath#split(mpath)
    return split(a:mpath, vimf#mpath#sep())
endfunction

" Join `pathParts` with `vimf#mpath#sep()`.
" E.g., on Unix, joining `['/bin', '/usr/bin']` yields `/bin:/usr/bin'.
function! vimf#mpath#join(pathParts)
    return join(a:pathParts, vimf#mpath#sep())
endfunction

" Remove `toRemove` from `mpath`.
" - `mpath` is a string of mpath parts joined by `vimf#mpath#sep()`.
" E.g., on Unix, `remove('/p:/bin:/usr/bin/', '/bin')` yields `'/p:/usr/bin'`.
function! vimf#mpath#remove(mpath, toRemove)
    if has('win32')
        let pred = 'tolower(v:val) != tolower(a:toRemove)'
    else
        let pred = 'v:val != a:toRemove'
    endif
    let parts = vimf#mpath#split(a:mpath)
    call filter(parts, pred)
    return vimf#mpath#join(parts)
endfunction
