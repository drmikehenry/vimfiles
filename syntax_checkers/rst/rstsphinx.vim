if exists("g:loaded_syntastic_rst_rstsphinx_checker")
    finish
endif
let g:loaded_syntastic_rst_rstsphinx_checker = 1

let s:save_cpo = &cpo
set cpo&vim

" We reuse the location for storing the output to help reduce the time of
" subsequent checks.
let s:temp_dir = tempname()
lockvar s:temp_dir

if has("python")
    function! s:compute_hash(s)
python << endpython
import hashlib
vim.command("let l:hash = '%s'" % (hashlib.md5(vim.eval("a:s"),).hexdigest()))
endpython

        return l:hash
    endfunction
endif

function! SyntaxCheckers_rst_rstsphinx_GetLocList() dict
    let conf_py = syntastic#util#findInParent('conf.py', expand('%:p:h'))

    if conf_py != ''
        let output_path =
                    \ s:temp_dir . '/vim-rstsphinx-' . s:compute_hash(conf_py)
        let makeprg = self.makeprgBuild({
            \ 'args': '-b html -N -q',
            \ 'fname': syntastic#util#shescape(fnamemodify(conf_py, ":h")),
            \ 'tail': syntastic#util#shescape(output_path) })

        let errorformat =
            \ '%f:%l: %tNFO: %m,'.
            \ '%f:%l: %tARNING: %m,'.
            \ '%f:%l: %tRROR: %m,'.
            \ '%f:%l: %tEVERE: %m,'.
            \ '%-G%.%#'

        let loclist = SyntasticMake({
            \ 'makeprg': makeprg,
            \ 'errorformat': errorformat})

        for e in loclist
            if e['type'] ==? 'S'
                let e['type'] = 'E'
            elseif e['type'] ==? 'I'
                let e['type'] = 'W'
                let e['subtype'] = 'Style'
            endif
        endfor

        return loclist
    endif

    return []
endfunction

if has("python")
    call g:SyntasticRegistry.CreateAndRegisterChecker({
        \ 'filetype': 'rst',
        \ 'name': 'rstsphinx',
        \ 'exec': 'sphinx-build' })
endif

let &cpo = s:save_cpo
unlet s:save_cpo
