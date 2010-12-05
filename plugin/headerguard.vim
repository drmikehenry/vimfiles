" Vim global plugin for adding C/C++ header guards.
" Version:      0.1.0
" Last Change:  September 14, 2007
" Maintainer:   Michael Henry (vim at drmikehenry.com)
" License:      This file is placed in the public domain.

if exists("loaded_headerguard")
    finish
endif
let loaded_headerguard = 1


" Save 'cpoptions' and set Vim default to enable line continuations.
let s:save_cpoptions = &cpoptions
set cpoptions&vim

if ! exists("*g:HeaderguardName")
    function! g:HeaderguardName()
        return toupper(expand('%:t:gs/[^0-9a-zA-Z_]/_/g'))
    endfunction
endif

if ! exists("*g:HeaderguardLine1")
    function! g:HeaderguardLine1()
        return "#ifndef " . g:HeaderguardName()
    endfunction
endif

if ! exists("*g:HeaderguardLine2")
    function! g:HeaderguardLine2()
        return "#define " . g:HeaderguardName()
    endfunction
endif

if ! exists("*g:HeaderguardLine3")
    function! g:HeaderguardLine3()
        return "#endif /* " . g:HeaderguardName() . " */"
    endfunction
endif

function! s:HeaderguardAdd()
    " Test for empty filename.
    if expand('%') == ""
        echoerr "Empty filename (save file and try again)."
        return
    endif
    " Locate first, second, and last pre-processor directives.
    call cursor(1, 1)
    let s:poundLine1 = search('^#', "cW")
    let s:poundLine2 = search('^#', "W")
    call cursor(line("$"), col("$"))
    let s:poundLine3 = search('^#', "b")

    " Locate #ifndef, #define, #endif directives.
    call cursor(1, 1)
    let s:regex1  = '^#\s*ifndef\s\+\w\+\|'
    let s:regex1 .= '^#\s*if\s\+!\s*defined(\s*\w\+\s*)'
    let s:guardLine1 = search(s:regex1, "cW")
    let s:guardLine2 = search('^#\s*define', "W")
    call cursor(line("$"), col("$"))
    let s:guardLine3 = search('^#\s*endif', "b")

    " Locate #define of desired guardName.
    call cursor(1, 1)
    let s:guardDefine = search('^#\s*define\s\+' . 
                \ g:HeaderguardName() . '\>', "cW")

    " If the candidate guard lines were found in the proper
    " location (the outermost pre-processor directives), they
    " are deemed valid header guards.
    if s:guardLine1 > 0 && s:guardLine2 > 0 && s:guardLine3 > 0 &&
                \ s:guardLine1 == s:poundLine1 &&
                \ s:guardLine2 == s:poundLine2 &&
                \ s:guardLine3 == s:poundLine3
        " Replace existing header guard.
        call setline(s:guardLine1, g:HeaderguardLine1())
        call setline(s:guardLine2, g:HeaderguardLine2())
        call setline(s:guardLine3, g:HeaderguardLine3())
        " Position at new header guard start.
        call cursor(s:guardLine1, 1)

    elseif s:guardDefine > 0
        echoerr "Found '#define " . g:HeaderguardName() . 
                    \ "' without guard structure"
        " Position at unexpected #define.
        call cursor(s:guardDefine, 1)

    else
        " No header guard found.
        call append(0, [ g:HeaderguardLine1(), g:HeaderguardLine2(), "" ])
        call append(line("$"), ["", g:HeaderguardLine3()])
        call cursor(1, 1)
    endif
endfunction
command! HeaderguardAdd call s:HeaderguardAdd()

" Restore saved 'cpoptions'.
let cpoptions = s:save_cpoptions
" vim: sts=4 sw=4 tw=80 et ai:
