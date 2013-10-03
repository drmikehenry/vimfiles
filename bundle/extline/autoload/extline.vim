" Autoloads for Vim extline plugin.

if exists("autoloaded_extline")
    finish
endif
let autoloaded_extline = 1

" Save 'cpoptions' and set Vim default to enable line continuations.
let s:save_cpoptions = &cpoptions
set cpoptions&vim

function! extline#lstrip(s)
    return substitute(a:s, '^\s*', '', '')
endfunction

function! extline#rstrip(s)
    return substitute(a:s, '\s*$', '', '')
endfunction

function! extline#strip(s)
    return extline#lstrip(extline#rstrip(a:s))
endfunction

function! extline#leadingWhitespace(s)
    return substitute(a:s, '^\s*\zs\(.*\)$', '', '')
endfunction

function! extline#getMonochar(s)
    let monochar = substitute(extline#strip(a:s), '^\(\S\)\1*$', '\1', '')
    if len(monochar) > 1
        let monochar = ''
    endif
    return monochar
endfunction

" Return monochar that is non-alphanumeric.
function! extline#getPuncMonochar(s)
    let monochar = extline#getMonochar(a:s)
    if match(monochar, '[:alnum:]') >= 0
        let monochar = ''
    endif
    return monochar
endfunction

function! extline#firstNonEmpty(strings)
    for s in a:strings
        if s != ''
            return s
        endif
    endfor
    return a:strings[0]
endfunction

function! extline#probeTitle(titleLineNum)
    let titleText = getline(a:titleLineNum)
    let title = extline#strip(titleText)
    let titlePrefix = extline#leadingWhitespace(titleText)
    if extline#getPuncMonochar(title) != ''
        " Title cannot be a line of monochar punctuation characters.
        let title = ''
    endif
    " Title Group
    let tg = {
                \ 'titleLineNum': a:titleLineNum,
                \ 'title': title,
                \ 'titlePrefix': titlePrefix,
                \ 'overChar': '',
                \ 'underChar': '',
                \ }

    if title != ''
        " Consider non-existing line numbers.
        let overText = extline#strip(getline(a:titleLineNum - 1))
        let underText = extline#strip(getline(a:titleLineNum + 1))
        let tg['overChar'] = extline#getPuncMonochar(overText)
        let tg['underChar'] = extline#getPuncMonochar(underText)
    endif
    return tg
endfunction

function! extline#probeTitleNearby()
    let lineNum = line('.')
    let text = extline#strip(getline(lineNum))
    let monochar = extline#getPuncMonochar(text)
    if text == '' || monochar != ''
        let tg = extline#probeTitle(lineNum - 1)
        if tg['title'] == ''
            let tg = extline#probeTitle(lineNum + 1)
        endif
    else
        let tg = extline#probeTitle(lineNum)
    endif
    return tg
endfunction

function! extline#changeTitleLine(tg, lineType, lineTypePresent)
    " lineType is 'over' or 'under'
    " lineTypePresent is 1 or 0 to use or not use lineType.
    let charType = a:lineType . 'Char'
    if a:lineTypePresent && a:tg[charType] == ''
        if charType == 'overChar'
            let otherCharType = 'underChar'
            exe a:tg['titleLineNum'] . 'copy ' . (a:tg['titleLineNum'] - 1)
            let a:tg['titleLineNum'] = (a:tg['titleLineNum'] + 1)
        else
            let otherCharType = 'overChar'
            exe a:tg['titleLineNum'] . 'copy ' . a:tg['titleLineNum']
        endif
        let a:tg[charType] = a:tg[otherCharType]
        if a:tg[charType] == ''
            let a:tg[charType] = '='
        endif
    endif
    if !a:lineTypePresent && a:tg[charType] != ''
        if charType == 'overChar'
            exe (a:tg['titleLineNum'] - 1) . 'del'
            let a:tg['titleLineNum'] = (a:tg['titleLineNum'] - 1)
        else
            exe (a:tg['titleLineNum'] + 1) . 'del'
        endif
        let a:tg[charType] = ''
    endif
endfunction

function! extline#updateTitle(tg)
    let titleLineNum = a:tg['titleLineNum']
    let titleLen = len(a:tg['title'])
    let underChar = a:tg['underChar']
    let overChar = a:tg['overChar']
    let titlePrefix = a:tg['titlePrefix']

    if overChar != ''
        let lineText = titlePrefix . repeat(overChar, titleLen)
        exe (titleLineNum - 1) . 's/^.*/\=lineText/g'
    endif
    exe titleLineNum
    normal! $
    if underChar != ''
        let lineText = titlePrefix . repeat(underChar, titleLen)
        exe (titleLineNum + 1) . 's/^.*/\=lineText/g'
        normal! $
    endif
endfunction

function! extline#makeTitle(forceMonochar, useOver, useUnder)
    let tg = extline#probeTitleNearby()
    if tg['title'] != ''
        " Always add a line before removing the other line.
        if a:useOver
            call extline#changeTitleLine(tg, 'over', a:useOver)
            call extline#changeTitleLine(tg, 'under', a:useUnder)
        else
            call extline#changeTitleLine(tg, 'under', a:useUnder)
            call extline#changeTitleLine(tg, 'over', a:useOver)
        endif
        if a:forceMonochar != ''
            if a:useOver
                let tg['overChar'] = a:forceMonochar
            endif
            if a:useUnder
                let tg['underChar'] = a:forceMonochar
            endif
        endif
        call extline#updateTitle(tg)
    endif
    return tg['title'] != ''
endfunction

function! extline#makeHline()
    let lineNum = line('.')
    let t = extline#rstrip(getline(lineNum))
    let monochar = extline#getMonochar(t)
    if monochar != ''
        let lineText = (t . repeat(monochar, 80))[:77]
        exe 's/^.*/' . escape(lineText, '/') . '/g'
        normal! $
    endif
endfunction

function! extline#autoTitle()
    let tg = extline#probeTitleNearby()
    if tg['title'] != ''
        if tg['overChar'] == '' && tg['underChar'] == ''
            if tg['titleLineNum'] > line(".")
                " Title was after cursor line, use overTitle.
                call extline#changeTitleLine(tg, 'over', 1)
            else
                call extline#changeTitleLine(tg, 'under', 1)
            endif
        endif
        call extline#updateTitle(tg)
    else
        call extline#makeHline()
    endif
endfunction

" vim: sts=4 sw=4 tw=80 et ai:

