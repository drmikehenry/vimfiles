" License: Distributed under Vim's |license|; see |bufmatch.txt| for details.

let s:save_cpo = &cpo
set cpo&vim

" NOTE: Since `matchadd()` does not accept a window identifier and we need to
" synchronize with the window any time we modify the per-buffer settings,
" there's not much point in supporting other than the current buffer and window.

function! s:NextBufMatchId(matches)
    let buf_match_id = 1000
    while has_key(a:matches, buf_match_id)
        let buf_match_id = buf_match_id + 1
    endwhile
    return buf_match_id
endfunction

function! bufmatch#SyncWindow()
    for i in get(w:, 'bufmatch_win_match_ids', [])
        call matchdelete(i)
    endfor
    let win_match_ids = []
    for [i, args] in items(get(b:, 'bufmatch_matches', {}))
        let win_match_id = call('matchadd', args)
        call add(win_match_ids, win_match_id)
    endfor
    let w:bufmatch_win_match_ids = win_match_ids
endfunction

" Optional arguments for `...`:
"   `priority`: integer priority for `matchadd()`.
"   `dict`: dictionary of additional custom values for `matchadd()`.
function! bufmatch#MatchAdd(group, pattern, ...)
    let matches = get(b:, 'bufmatch_matches', {})
    let buf_match_id = s:NextBufMatchId(matches)
    " Prepare arguments for `matchadd(group, pattern, priority, id, dict)`.
    " Arguments `priority` and onward are optional.
    let match_args = [a:group, a:pattern]
    if a:0 >= 1
        " Optional `priority` provided.
        call add(match_args, a:000[0])
    endif
    if a:0 >= 2
        " Optional `dict` provided; must supply `-1` for a default `id`,
        " then the provided `dict`.
        call add(match_args, -1)
        call add(match_args, a:000[1])
    endif
    let matches[buf_match_id] = match_args
    let b:bufmatch_matches = matches
    call bufmatch#SyncWindow()
    return buf_match_id
endfunction

function! bufmatch#MatchDelete(buf_match_id)
    let matches = get(b:, 'bufmatch_matches', {})
    if has_key(matches, a:buf_match_id)
        unlet b:bufmatch_matches[a:buf_match_id]
        call bufmatch#SyncWindow()
    endif
endfunction

function! bufmatch#ClearMatches()
    let b:bufmatch_matches = {}
    call bufmatch#SyncWindow()
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
