if (exists('g:loaded_lsp_ale') && g:loaded_lsp_ale) || &cp
    finish
endif
let g:loaded_lsp_ale = 1

let g:lsp_ale_diagnostics_severity = get(g:, 'lsp_ale_diagnostics_severity', 'information')
let g:lsp_ale_auto_enable_linter = get(g:, 'lsp_ale_auto_enable_linter', v:true)

if get(g:, 'lsp_ale_auto_config_vim_lsp', v:true)
    " Enable diagnostics and disable all functionalities to show error
    " messages by vim-lsp
    let g:lsp_diagnostics_enabled = 1
    let g:lsp_diagnostics_echo_cursor = 0
    let g:lsp_diagnostics_float_cursor = 0
    let g:lsp_diagnostics_highlights_enabled = 0
    let g:lsp_diagnostics_signs_enabled = 0
    let g:lsp_diagnostics_virtual_text_enabled = 0
endif
if get(g:, 'lsp_ale_auto_config_ale', v:true)
    " Disable ALE's LSP integration
    let g:ale_disable_lsp = 1
endif

augroup plugin-lsp-ale
    autocmd!
    autocmd User lsp_setup call lsp#ale#enable()
    autocmd User ALEWantResults call lsp#ale#on_ale_want_results(g:ale_want_results_buffer)
augroup END
