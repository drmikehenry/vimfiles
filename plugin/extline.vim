" Vim global plugin for extending lines (e.g., underlined titles).
" Version:      0.1.3
" Last Change:  September 24, 2013
" Maintainer:   Michael Henry (vim at drmikehenry.com)
" License:      This file is placed in the public domain.

if exists('loaded_extline')
    finish
endif
let loaded_extline = 1


" Save 'cpoptions' and set Vim default to enable line continuations.
let s:save_cpoptions = &cpoptions
set cpoptions&vim

function! s:Lstrip(s)
    return substitute(a:s, '^\s*', '', '')
endfunction

function! s:Rstrip(s)
    return substitute(a:s, '\s*$', '', '')
endfunction

function! s:Strip(s)
    return s:Lstrip(s:Rstrip(a:s))
endfunction

function! s:LeadingWhitespace(s)
    return substitute(a:s, '^\s*\zs\(.*\)$', '', '')
endfunction

function! s:GetMonochar(s)
    let monochar = substitute(s:Strip(a:s), '^\(\S\)\1*$', '\1', '')
    if len(monochar) > 1
        let monochar = ''
    endif
    return monochar
endfunction

" Return monochar that is non-alphanumeric.
function! s:GetPuncMonochar(s)
    let monochar = s:GetMonochar(a:s)
    if match(monochar, '[:alnum:]') >= 0
        let monochar = ''
    endif
    return monochar
endfunction

function! s:FirstNonEmpty(strings)
    for s in a:strings
        if s != ''
            return s
        endif
    endfor
    return a:strings[0]
endfunction

function! s:ProbeTitle(titleLineNum)
    let titleText = getline(a:titleLineNum)
    let title = s:Strip(titleText)
    let titlePrefix = s:LeadingWhitespace(titleText)
    if s:GetPuncMonochar(title) != ''
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
        let overText = s:Strip(getline(a:titleLineNum - 1))
        let underText = s:Strip(getline(a:titleLineNum + 1))
        let tg['overChar'] = s:GetPuncMonochar(overText)
        let tg['underChar'] = s:GetPuncMonochar(underText)
    endif
    return tg
endfunction

function! s:ProbeTitleNearby()
    let lineNum = line('.')
    let text = s:Strip(getline(lineNum))
    let monochar = s:GetPuncMonochar(text)
    if text == '' || monochar != ''
        let tg = s:ProbeTitle(lineNum - 1)
        if tg['title'] == ''
            let tg = s:ProbeTitle(lineNum + 1)
        endif
    else
        let tg = s:ProbeTitle(lineNum)
    endif
    return tg
endfunction

function! s:ChangeTitleLine(tg, lineType, lineTypePresent)
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

function! s:UpdateTitle(tg)
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

function! s:MakeTitle(forceMonochar, useOver, useUnder)
    let tg = s:ProbeTitleNearby()
    if tg['title'] != ''
        " Always add a line before removing the other line.
        if a:useOver
            call s:ChangeTitleLine(tg, 'over', a:useOver)
            call s:ChangeTitleLine(tg, 'under', a:useUnder)
        else
            call s:ChangeTitleLine(tg, 'under', a:useUnder)
            call s:ChangeTitleLine(tg, 'over', a:useOver)
        endif
        if a:forceMonochar != ''
            if a:useOver
                let tg['overChar'] = a:forceMonochar
            endif
            if a:useUnder
                let tg['underChar'] = a:forceMonochar
            endif
        endif
        call s:UpdateTitle(tg)
    endif
    return tg['title'] != ''
endfunction

function! s:MakeHline()
    let lineNum = line('.')
    let t = s:Rstrip(getline(lineNum))
    let monochar = s:GetMonochar(t)
    if monochar != ''
        let lineText = (t . repeat(monochar, 80))[:77]
        exe 's/^.*/' . escape(lineText, '/') . '/g'
        normal! $
    endif
endfunction

function! s:AutoTitle()
    let tg = s:ProbeTitleNearby()
    if tg['title'] != ''
        if tg['overChar'] == '' && tg['underChar'] == ''
            if tg['titleLineNum'] > line(".")
                " Title was after cursor line, use overTitle.
                call s:ChangeTitleLine(tg, 'over', 1)
            else
                call s:ChangeTitleLine(tg, 'under', 1)
            endif
        endif
        call s:UpdateTitle(tg)
    else
        call s:MakeHline()
    endif
endfunction

xnoremap <silent> <C-L><C-L>  <ESC>:call <SID>AutoTitle()<CR>^
inoremap <silent> <C-L><C-L>  <C-G>u<C-O>:call <SID>AutoTitle()<CR>
xnoremap <silent> <C-L><C-H>  <ESC>:call <SID>MakeHline()<CR>^
inoremap <silent> <C-L><C-H>  <C-G>u<C-O>:call <SID>MakeHline()<CR>

xnoremap <silent> <C-L><C-U>  <ESC>:call <SID>MakeTitle("",  0, 1)<CR>^
xnoremap <silent> <C-L><C-O>  <ESC>:call <SID>MakeTitle("",  1, 0)<CR>^
xnoremap <silent> <C-L><C-I>  <ESC>:call <SID>MakeTitle("",  1, 1)<CR>^
xnoremap <silent> <C-L>1      <ESC>:call <SID>MakeTitle("=", 0, 1)<CR>^
xnoremap <silent> <C-L>=      <ESC>:call <SID>MakeTitle("=", 0, 1)<CR>^
xnoremap <silent> <C-L>2      <ESC>:call <SID>MakeTitle("-", 0, 1)<CR>^
xnoremap <silent> <C-L>-      <ESC>:call <SID>MakeTitle("-", 0, 1)<CR>^
xnoremap <silent> <C-L>3      <ESC>:call <SID>MakeTitle("^", 0, 1)<CR>^
xnoremap <silent> <C-L>^      <ESC>:call <SID>MakeTitle("^", 0, 1)<CR>^
xnoremap <silent> <C-L>4      <ESC>:call <SID>MakeTitle('"', 0, 1)<CR>^
xnoremap <silent> <C-L>"      <ESC>:call <SID>MakeTitle('"', 0, 1)<CR>^
xnoremap <silent> <C-L>5      <ESC>:call <SID>MakeTitle("'", 0, 1)<CR>^
xnoremap <silent> <C-L>'      <ESC>:call <SID>MakeTitle("'", 0, 1)<CR>^
xnoremap <silent> <C-L>9      <ESC>:call <SID>MakeTitle("#", 1, 1)<CR>^
xnoremap <silent> <C-L>#      <ESC>:call <SID>MakeTitle("#", 1, 1)<CR>^
xnoremap <silent> <C-L>0      <ESC>:call <SID>MakeTitle("*", 1, 1)<CR>^
xnoremap <silent> <C-L>*      <ESC>:call <SID>MakeTitle("*", 1, 1)<CR>^

" Undo-break via CTRL-G u.
inoremap <silent> <C-L><C-I>  <C-G>u<C-O>:call <SID>MakeTitle("",  1, 1)<CR>
inoremap <silent> <C-L><C-O>  <C-G>u<C-O>:call <SID>MakeTitle("",  1, 0)<CR>
inoremap <silent> <C-L><C-U>  <C-G>u<C-O>:call <SID>MakeTitle("",  0, 1)<CR>
inoremap <silent> <C-L>1      <C-G>u<C-O>:call <SID>MakeTitle("=", 0, 1)<CR>
inoremap <silent> <C-L>=      <C-G>u<C-O>:call <SID>MakeTitle("=", 0, 1)<CR>
inoremap <silent> <C-L>2      <C-G>u<C-O>:call <SID>MakeTitle("-", 0, 1)<CR>
inoremap <silent> <C-L>-      <C-G>u<C-O>:call <SID>MakeTitle("-", 0, 1)<CR>
inoremap <silent> <C-L>3      <C-G>u<C-O>:call <SID>MakeTitle("^", 0, 1)<CR>
inoremap <silent> <C-L>^      <C-G>u<C-O>:call <SID>MakeTitle("^", 0, 1)<CR>
inoremap <silent> <C-L>4      <C-G>u<C-O>:call <SID>MakeTitle('"', 0, 1)<CR>
inoremap <silent> <C-L>"      <C-G>u<C-O>:call <SID>MakeTitle('"', 0, 1)<CR>
inoremap <silent> <C-L>5      <C-G>u<C-O>:call <SID>MakeTitle("'", 0, 1)<CR>
inoremap <silent> <C-L>'      <C-G>u<C-O>:call <SID>MakeTitle("'", 0, 1)<CR>
inoremap <silent> <C-L>9      <C-G>u<C-O>:call <SID>MakeTitle("#", 1, 1)<CR>
inoremap <silent> <C-L>#      <C-G>u<C-O>:call <SID>MakeTitle("#", 1, 1)<CR>
inoremap <silent> <C-L>0      <C-G>u<C-O>:call <SID>MakeTitle("*", 1, 1)<CR>
inoremap <silent> <C-L>*      <C-G>u<C-O>:call <SID>MakeTitle("*", 1, 1)<CR>

" Restore saved 'cpoptions'.
let &cpoptions = s:save_cpoptions

finish

" ----------------------------------------------------------------------------


Types of single lines of text
-----------------------------

- Monoline:

  - Start of line
  - Optional leading whitespace
  - One or more identical non-alphanumeric non-white characters, c
  - Optional trailing whitespace
  - End of line

- Genline:
    prefix <longest run of characters> postfix

    postfix might contain optional column number

  - Start of line
  - Optional leading whitespace
  - Optional prefix with final character, L
  - One or more identical non-white characters, c, with c != L
  - Optional suffix with first character, R, with R != c
  - Optional white (ignored)
  - Optional integer column number
  --------------------------------

- Title:

  - Non-blank

Title types
-----------

- NoTitle:


- BareTitle::


    Title


- UnderTitle::


    Title
    =====


- OverTitle::


    =====
    Title
             

- OverUnderTitle::


    =====
    Title
    =====


HLine types
-----------

    =============================

    /****************************

    ****************************/

    /***************************/

    # ---------------------------
    # --------------------------- #



" vim: sts=4 sw=4 tw=80 et ai:
