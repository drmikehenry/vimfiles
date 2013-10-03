function! SetupTextobjRstBufferMappings()
    for m in ['n', 'x', 'o']
        let cmd = 'silent! ' . m . 'map <buffer> '
        execute l:cmd . ']] <Plug>(textobj-rst-sections-n)'
        execute l:cmd . '][ <Plug>(textobj-rst-sections-N)'
        execute l:cmd . '[[ <Plug>(textobj-rst-sections-p)'
        execute l:cmd . '[] <Plug>(textobj-rst-sections-P)'
    endfor
    for m in ['x', 'o']
        let cmd = 'silent! ' . m . 'map <buffer> '
        execute cmd . 'ars <Plug>(textobj-rst-sections-a)'
        execute cmd . 'irs <Plug>(textobj-rst-sections-i)'
    endfor
endfunction
call SetupTextobjRstBufferMappings()
