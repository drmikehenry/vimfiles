" Vim global plugin to extend simple numbered and bulleted lists
" License: Distributed under Vim's |license|; see |extend_list.txt| for details.

if exists('g:loaded_extend_list')
    finish
endif
let g:loaded_extend_list = 1

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:extend_list_default_new')
    let g:extend_list_default_new = '1. '
endif

" Seek forward until we find either an empty line, or a line containing only
" whitespace.
" Return: line number of the first empty line.
function! s:FindBlankLine(lnum)
    let blank_line_pattern = '\v^\s*$'
    let lnum = a:lnum

    while lnum <= line('$')
        " On a completely empty file, line('.') == line('$') == 1.
        " But getline(beyond_eof_lnum) == '', so it works for our case.
        let ln = getline(lnum)
        if ln =~ blank_line_pattern
            return lnum
        endif
        let lnum = lnum + 1
    endwhile
    return line('$')
endfunction

" Based upon the previous list item, create the next item. This will match the
" amount of indentation before the numeral and will increment the numeral.
function! s:BuildNextNumberListLine(ln, pattern)
    let matches = matchlist(a:ln, a:pattern)
    if matches[0] != ''
        let next_num = matches[2] + 1
        let newline = matches[1] . next_num . matches[3] . matches[4]
    else
        let newline = ''
    endif
    return newline
endfunction

" Based upon the previous list item, create the next item. This will match the
" amount of indentation before the numeral and the type of bullet.
function! s:BuildNextBulletListLine(ln, pattern)
    let matches = matchlist(a:ln, a:pattern)
    if matches[0] != ''
        let bullet = matches[2]
        let newline = matches[1] . bullet . matches[3]
    else
        let newline = ''
    endif
    return newline
endfunction

" Generate the next list line, based upon the preceding list.
" If there is no preceding list, start a new numbered list.
function! s:GetNextListLine(lnum)
    let bullet_pattern = '\v^(\s*)([-*o])(\s+)'
    let number_pattern = '\v^(\s*)(\d+)([.)])(\s+)'
    let newline = g:extend_list_default_new
    let lnum = a:lnum

    " Find the previous list element, extract the relevant parts
    while lnum > 0
        let ln = getline(lnum)
        let lnum = lnum - 1

        if ln =~ bullet_pattern
            let newline = s:BuildNextBulletListLine( ln, bullet_pattern )
        elseif ln =~ number_pattern
            let newline = s:BuildNextNumberListLine( ln, number_pattern )
        else
            continue
        endif
        break
    endwhile
    return newline
endfunction

" Extend the list preceding the cursor.
"
" * If the cursor is in a list, the list will be extended and the cursor placed
"   at the end.
" * If the cursor is not at a list, the next list item will be created at next
"   blank line at or following the cursor.
function! extend_list#extend_list()
    let orig_lnum = line('.')

    " If on non-blank, scan forward to first blank line.

    let blank_lnum = s:FindBlankLine(orig_lnum)

    if getline(blank_lnum) !~ '\v^\s*$'
        let blank_lnum = blank_lnum + 1
    endif

    " Generate the next line for the preceding list
    let new_list_line = s:GetNextListLine(blank_lnum)

    " Print out the new line at the next blank line
    call append(blank_lnum - 1, new_list_line)

    execute 'normal! ' . blank_lnum . 'G'
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
