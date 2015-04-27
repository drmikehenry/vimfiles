" Vim plugin for adding C/C++ header guards.

if exists("loaded_headerguard")
    finish
endif
let loaded_headerguard = 1

if !exists('g:headerguard_use_cpp_comments')
    let g:headerguard_use_cpp_comments = 0
endif

" Save 'cpoptions' and set Vim default to enable line continuations.
let s:save_cpoptions = &cpoptions
set cpoptions&vim

" Search list of scopes for function named funcName, returning first-found.
function! s:ResolveFunc(funcName, scopes)
    for scope in a:scopes
        let scopedFuncName = scope . ':' . a:funcName
        if exists('*' . scopedFuncName)
            return function(scopedFuncName)
        endif
    endfor
    throw "Unknown function " . a:funcName
endfunction

" Return reference to Headerguard function having given suffix.
function! s:Func(funcSuffix)
    return s:ResolveFunc('Headerguard' . a:funcSuffix, ['b', 'g', 's'])
endfunction

function! s:HeaderguardName()
    return toupper(expand('%:t:gs/[^0-9a-zA-Z_]/_/g'))
endfunction

function! s:HeaderguardLine1()
    return "#ifndef " . s:Func('Name')()
endfunction

function! s:HeaderguardLine2()
    return "#define " . s:Func('Name')()
endfunction

function! s:HeaderguardLine3()
    if g:headerguard_use_cpp_comments
        return "#endif // " . s:Func('Name')()
    else
        return "#endif /* " . s:Func('Name')() . " */"
    endif
endfunction

function! g:HeaderguardAdd()
    " Test for empty filename.
    if expand('%') == ""
        echoerr "Empty filename (save file and try again)."
        return
    endif
    " Locate first, second, and last pre-processor directives.
    call cursor(1, 1)
    let poundLine1 = search('^#', "cW")
    let poundLine2 = search('^#', "W")
    call cursor(line("$"), col("$"))
    let poundLine3 = search('^#', "b")

    " Locate #ifndef, #define, #endif directives.
    call cursor(1, 1)
    let regex1  = '^#\s*ifndef\s\+\w\+\|'
    let regex1 .= '^#\s*if\s\+!\s*defined(\s*\w\+\s*)'
    let guardLine1 = search(regex1, "cW")
    let guardLine2 = search('^#\s*define', "W")
    call cursor(line("$"), col("$"))
    let guardLine3 = search('^#\s*endif', "b")

    " Locate #define of desired guardName.
    call cursor(1, 1)
    let guardDefine = search('^#\s*define\s\+' .
                \ s:Func('Name')() . '\>', "cW")

    " If the candidate guard lines were found in the proper
    " location (the outermost pre-processor directives), they
    " are deemed valid header guards.
    if guardLine1 > 0 && guardLine2 > 0 && guardLine3 > 0 &&
                \ guardLine1 == poundLine1 &&
                \ guardLine2 == poundLine2 &&
                \ guardLine3 == poundLine3
        " Replace existing header guard.
        call setline(guardLine1, s:Func('Line1')())
        call setline(guardLine2, s:Func('Line2')())
        call setline(guardLine3, s:Func('Line3')())
        " Position at new header guard start.
        call cursor(guardLine1, 1)

    elseif guardDefine > 0
        echoerr "Found '#define " . s:Func('Name')() .
                    \ "' without guard structure"
        " Position at unexpected #define.
        call cursor(guardDefine, 1)

    else
        " No header guard found.
        call append(0, [ s:Func('Line1')(), s:Func('Line2')(), "" ])
        call append(line("$"), ["", s:Func('Line3')()])
        call cursor(1, 1)
    endif
endfunction
command! -bar HeaderguardAdd call g:HeaderguardAdd()

" Restore saved 'cpoptions'.
let &cpoptions = s:save_cpoptions
" vim: sts=4 sw=4 tw=80 et ai:
