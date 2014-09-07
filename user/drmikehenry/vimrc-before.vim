" Don't waste time setting up GUI menu.
let did_install_default_menus = 1

function! Drmikehenry_adjust_szakdark()
  hi clear Search
  hi Search term=reverse cterm=reverse ctermfg=yellow gui=reverse guifg=yellow
endfunction

augroup drmikehenry_colors
    autocmd!
    autocmd ColorScheme szakdark call Drmikehenry_adjust_szakdark()
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
