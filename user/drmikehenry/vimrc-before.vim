" Don't waste time setting up GUI menu.
let did_install_default_menus = 1

if has("gui_running")
    "set background=light
    "colorscheme nuvola
    set background=dark
    "colorscheme moria
    "let g:solarized_contrast = "low"
    "let g:solarized_contrast = "normal"
    "let g:solarized_contrast = "high"
    " Make diffs more visible (particularly whitespace diffs).
    let g:solarized_diffmode = "high"
    colorscheme solarized
    let g:Powerline_colorscheme = "solarized256"
endif
