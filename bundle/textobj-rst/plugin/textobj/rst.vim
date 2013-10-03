" ============================================================================
" File:         rst.vim
" Description:  Text objects for reStructuredText
" Maintainer:   John Szakmeister <john@szakmeister.net>
" Version:      0.2.0
" License:      Same license as Vim.
" ============================================================================

if exists('g:loaded_textobj_rst')
  finish
endif

let s:sectionOrdering = {
            \ '#': 0,
            \ '*': 1,
            \ '=': 2,
            \ '-': 3,
            \ '^': 4,
            \ '"': 5,
            \ }

let s:REGEXP_OVERLINE_HEADING =     '^'
            \               .       '\([#*=\-^"]\)\+\s*\n'
            \               .       '\S.*\n'
            \               .       '\1\+\s*\_.'

let s:REGEXP_UNDERLINE_HEADING =    '^'
            \               .       '\S.*\n'
            \               .       '\([#*=\-^"]\)\+\s*\_.'

let s:REGEXP_ALL_HEADINGS =     '\%(' . s:REGEXP_OVERLINE_HEADING
            \               .   '\|'
            \               .           s:REGEXP_UNDERLINE_HEADING
            \               .   '\)'


function! s:isSectionHeading()
    " We're either at something like this:
    "   #######
    "   Section     or      Section
    "   #######             #######
    let savePos = getpos('.')

    let ret = search(s:REGEXP_ALL_HEADINGS, 'Wnc', line('.'))
    if ret && line('.') != 1
        " Search a line behind the current, just to make sure we aren't
        " partially matching a section heading.
        call cursor(line('.')-1, 0)
        let m = search(s:REGEXP_ALL_HEADINGS, 'Wnc', line('.'))
        call setpos('.', savePos)
        if m
            return 0
        endif
    endif
    call setpos('.', savePos)
    return ret != 0
endfunction


function! s:sectionHeadingType()
    if !s:isSectionHeading()
        return ''
    endif

    let lines = join(getline('.', line('.')+2), "\n")
    let results = matchlist(lines, s:REGEXP_ALL_HEADINGS)

    if !empty(results)
        if empty(results[1])
            return results[2]
        endif
        return results[1]
    endif
    return ''
endfunction


function! s:compareSectType(a, b)
    let aPrecedence = s:sectionOrdering[a:a]
    let bPrecedence = s:sectionOrdering[a:b]

    if aPrecedence < bPrecedence
        return -1
    elseif aPrecedence > bPrecedence
        return 1
    else
        return 0
    endif
endfunction


function! s:searchForHeading(direction)
    let lineNr = search(s:REGEXP_ALL_HEADINGS, 'W' . (a:direction ? "" : "b"))

    if lineNr == 0
        return 0
    endif

    if a:direction == 0 && lineNr > 1
        " Check to see if the can match an overline heading
        call cursor(lineNr - 1, 0)
        if s:isSectionHeading()
            let lineNr = lineNr - 1
        else
            call cursor(lineNr, 0)
        endif
    endif

    return lineNr
endfunction


function! s:findSectionHeader(direction)
    let curPos = getpos('.')

    call setpos('.', [curPos[0], curPos[1], 0, 0])

    " Prevent matching an overline heading twice.
    if a:direction == 1 && s:isSectionHeading()
        call cursor(line('.') + 1, 0)
    endif

    let lineNr = s:searchForHeading(a:direction)

    if lineNr == 0
        call setpos('.', curPos)
        return 0
    endif

    normal zz
    return 1
endfunction


function! s:select_a_section()
    if !s:isSectionHeading() && !s:findSectionHeader(0)
        return 0
    endif

    let b = getpos('.')

    let sectType = s:sectionHeadingType()

    if search(s:REGEXP_ALL_HEADINGS, 'W') == 0
        let currentSectType = ''
    else
        let currentSectType = s:sectionHeadingType()
    endif

    if currentSectType == sectType
        " End the match on the previous line.
        normal k
    elseif !empty(currentSectType)
        " Consume matches while headings are less precedence than the one we
        " started with.
        let endOfFile = 0

        while s:compareSectType(sectType, currentSectType) < 0
            if search(s:REGEXP_ALL_HEADINGS, 'W') == 0
                let endOfFile = 1
                break
            endif
            let currentSectType = s:sectionHeadingType()
        endwhile

        " If we reach the end of the file, just select everything
        " up to the end.  Otherwise, we hit another heading... don't include it.
        if endOfFile
            normal G
        else
            normal k
        endif
    else
        normal G
    endif

    let e = getpos('.')

    " Did we select anything?
    if 1 < e[1] - b[1]
        return ['V', b, e]
    else
        return 0
    endif
endfunction


function! s:select_i_section()
    let result = s:select_a_section()
    if type(result) != type([])
        return 0
    endif

    let b = result[1]
    let e = result[2]

    let startLine = b[1]
    if getline(startLine) == getline(startLine+2)
        call cursor(startLine+3, 0)
    else
        call cursor(startLine+2, 0)
    endif

    if line('.') == line('$')
        return 0
    endif

    call search('^.\+$', 'W')

    let b = getpos('.')

    " Did we select anything?
    if 1 < e[1] - b[1]
        return ['V', b, e]
    else
        return 0
    endif
endfunction


function! s:move_n()
    call s:findSectionHeader(1)
endfunction


function! s:move_N()
    let lineNr = line('.')

    if s:findSectionHeader(1)
        if lineNr == line('.') - 1
            if s:findSectionHeader(1)
                normal k$zz
            else
                normal G$zz
            endif
        else
            normal k$zz
        endif
    else
        normal G$zz
    endif
endfunction


function! s:move_p()
    call s:findSectionHeader(0)
endfunction


function! s:move_P()
    if s:isSectionHeading()
        silent! normal k$zz
        return
    endif

    let savePos = getpos('.')

    if s:findSectionHeader(0) && s:findSectionHeader(0) && s:findSectionHeader(1)
        silent! normal k$zz
        return
    endif

    call setpos('.', savePos)
endfunction


function! s:counted_move_n()
    for i in range(v:count1)
        call s:move_n()
    endfor
endfunction


function! s:counted_move_N()
    for i in range(v:count1)
        call s:move_N()
    endfor
endfunction


function! s:counted_move_p()
    for i in range(v:count1)
        call s:move_p()
    endfor
endfunction


function! s:counted_move_P()
    for i in range(v:count1)
        call s:move_P()
    endfor
endfunction

" Prevent textobj-user from inserting global mappings.
let g:textobj_rst_no_default_key_mappings = 1

call textobj#user#plugin('rst', {
            \       'sections': {
            \           '*sfile*': expand('<sfile>:p'),
            \           'select-a': 'as',
            \           '*select-a-function*': 's:select_a_section',
            \           'select-i': 'is',
            \           '*select-i-function*': 's:select_i_section',
            \       },
            \   })


function! s:setupTextobjRstMappings()
    let cmd = 'silent! %snoremap ' .
                \ '<Plug>(textobj-rst-sections-%s) ' .
                \ ':<C-U>call <SID>counted_move_%s()<CR>'
    for m in ['n', 'x', 'o']
        for n in ['n', 'N', 'p', 'P']
            execute printf(cmd, m, n, n)
        endfor
    endfor
endfunction
call s:setupTextobjRstMappings()


let g:loaded_textobj_rst = 1
