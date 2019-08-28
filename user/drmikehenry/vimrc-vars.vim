" Experiment with a plugin.
" call filter(g:pathogen_disabled, 'v:val !=# "plugin_name"')
call filter(g:pathogen_disabled, 'v:val !=# "matchup"')

" Gvim bug https://github.com/vim/vim/issues/3417 is fixed in Gvim 8.1.0834.
" Without this patch, Gvim support for timers is buggy.
if v:version > 801 || (v:version == 801 && has('patch0834'))
    call add(g:pathogen_disabled, 'syntastic')
    call filter(g:pathogen_disabled, 'v:val !=# "ale"')
    command! SyntasticReset let b:syntastic_enabled = 0
endif
