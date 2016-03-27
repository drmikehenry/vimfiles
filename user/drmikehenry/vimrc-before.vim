let did_install_default_menus = 1

let g:EnableAirline = 1

function! Drmikehenry_adjustSzakDark()
"    if exists('+colorcolumn')
"        if &t_Co > 255 || has("gui_running")
"            highlight ColorColumn ctermbg=233 guibg=#121212
"            highlight ColorColumn ctermbg=234 guibg=#1c1c1c
"            highlight ColorColumn ctermbg=235 guibg=#262626
"            highlight ColorColumn ctermbg=236 guibg=#303030
"        endif
"    endif
endfunction

augroup Drmikehenry_vimrc
    au!
    autocmd ColorScheme szakdark call Drmikehenry_adjustSzakDark()
augroup END

function! Drmikehenry_solarized()
    "let g:solarized_contrast = "low"
    "let g:solarized_contrast = "normal"
    "let g:solarized_contrast = "high"
    " Make diffs more visible (particularly whitespace diffs).
    let g:solarized_diffmode = "high"
    colorscheme solarized
    let g:Powerline_colorscheme = "solarized256"
endfunction

if has("gui_running")
    "call Drmikehenry_solarized()
else
    "colorscheme moria
endif

" Possible dark colorschemes:
"    set background=dark
"    colorscheme moria
"    colorscheme desert256
"    colorscheme wombat256
"    colorscheme herald
"    colorscheme hybrid
"    colorscheme gruvbox
"    colorscheme base16-default
"    colorscheme base16-solarized
"    colorscheme wombat256i
"    colorscheme badwolf
"    colorscheme monokai
"    colorscheme peaksea
" Possible light colorschemes:
"    set background=light
"    colorscheme nuvola
