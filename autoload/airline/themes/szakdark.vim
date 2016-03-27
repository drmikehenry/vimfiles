" Structured after bundle/airline-themes/autoload/airline/themes/dark.vim,
" which contains some comments explaining the overall concept.

" Xterm color mappings taken from:
" https://github.com/guns/xterm-color-table.vim/blob/master/plugin/xterm-color-table.vim

let s:palette = {
      \ 'black'          : [ '#000000', 16],
      \ 'white'          : [ '#ffffff', 231],
      \
      \ 'darkestgreen'   : ['#005f00', 22],
      \ 'darkgreen'      : ['#008700', 28],
      \ 'mediumgreen'    : ['#5faf00', 70],
      \ 'brightgreen'    : ['#afdf00', 148],
      \
      \ 'darkestcyan'    : ['#005f5f', 23],
      \ 'mediumcyan'     : ['#87dfff', 117],
      \
      \ 'darkestblue'    : ['#005f87', 24],
      \ 'darkblue'       : ['#0087af', 31],
      \
      \ 'darkestred'     : ['#5f0000', 52],
      \ 'darkred'        : ['#870000', 88],
      \ 'mediumred'      : ['#af0000', 124],
      \ 'brightred'      : ['#df0000', 160],
      \ 'brightestred'   : ['#ff0000', 196],
      \
      \ 'darkestpurple'  : ['#5f00af', 55],
      \ 'mediumpurple'   : ['#875fdf', 98],
      \ 'brightpurple'   : ['#dfdfff', 189],
      \
      \ 'brightorange'   : ['#ff8700', 208],
      \ 'brightestorange': ['#ffaf00', 214],
      \
      \ 'gray0'          : ['#121212', 233],
      \ 'gray1'          : ['#262626', 235],
      \ 'gray2'          : ['#303030', 236],
      \ 'gray3'          : ['#4e4e4e', 239],
      \ 'gray4'          : ['#585858', 240],
      \ 'gray5'          : ['#606060', 241],
      \ 'gray6'          : ['#808080', 244],
      \ 'gray7'          : ['#8a8a8a', 245],
      \ 'gray8'          : ['#9e9e9e', 247],
      \ 'gray9'          : ['#bcbcbc', 250],
      \ 'gray10'         : ['#d0d0d0', 252],
      \
      \ 'unchanged'      : ['', ''],
      \ }

function! s:Colors(foreground, background, options)
    let fg = s:palette[a:foreground]
    let bg = s:palette[a:background]
    return [fg[0], bg[0],  fg[1], bg[1], a:options]
endfunction

" Default sections:
"   g:airline_section_a       (mode, crypt, paste, spell, iminsert)
"   g:airline_section_b       (hunks, branch)
"   g:airline_section_c       (bufferline or filename)
"   g:airline_section_gutter  (readonly, csv)
"   g:airline_section_x       (tagbar, filetype, virtualenv)
"   g:airline_section_y       (fileencoding, fileformat)
"   g:airline_section_z       (percentage, line number, column number)
"   g:airline_section_error   (ycm_error_count, syntastic, eclim)
"   g:airline_section_warning (ycm_warning_count, whitespace)

let g:airline#themes#szakdark#palette = {}

" Setup Normal-mode foreground and background colors.
let s:N_a        = s:Colors('darkestgreen', 'brightgreen', 'bold')
let s:N_b        = s:Colors('gray9', 'gray4', '')
let s:N_c        = s:Colors('white', 'gray4', 'bold')
let s:N_x        = s:Colors('gray8', 'gray2', '')
let s:N_y        = s:Colors('gray8', 'gray2', '')
let s:N_z        = s:Colors('gray2', 'gray10', 'bold')
let g:airline#themes#szakdark#palette.normal =
        \ airline#themes#generate_color_map(
        \ s:N_a, s:N_b, s:N_c, s:N_x, s:N_y, s:N_z)

let s:I_a        = s:Colors('darkestcyan', 'white', 'bold')
let s:I_b        = s:Colors('mediumcyan', 'darkblue', '')
let s:I_c        = s:Colors('white', 'darkblue', 'bold')
let s:I_x        = s:Colors('darkestcyan', 'mediumcyan', 'bold')
let s:I_y        = s:Colors('gray8', 'gray2', '')
let s:I_z        = s:Colors('mediumcyan', 'darkblue', '')
let g:airline#themes#szakdark#palette.insert =
        \ airline#themes#generate_color_map(
        \ s:I_a, s:I_b, s:I_c, s:I_x, s:I_y, s:I_z)

let s:R_a        = s:Colors('white', 'brightred', 'bold')
let s:R_b        = s:I_b
let s:R_c        = s:I_c
let s:R_x        = s:I_x
let s:R_y        = s:I_y
let s:R_z        = s:I_z
let g:airline#themes#szakdark#palette.replace =
        \ airline#themes#generate_color_map(
        \ s:R_a, s:R_b, s:R_c, s:R_x, s:R_y, s:R_z)

let s:V_a        = s:Colors('darkred', 'brightorange', 'bold')
let s:V_b        = s:Colors('gray9', 'gray4', '')
let s:V_c        = s:Colors('gray10', 'gray4', '')
let s:V_x        = s:Colors('gray8', 'gray2', '')
let s:V_y        = s:Colors('gray8', 'gray2', '')
let s:V_z        = s:Colors('gray2', 'gray10', '')
let g:airline#themes#szakdark#palette.visual =
        \ airline#themes#generate_color_map(
        \ s:V_a, s:V_b, s:V_c, s:V_x, s:V_y, s:V_z)

let s:IA_a       = s:Colors('darkestgreen', 'brightgreen', 'bold')
let s:IA_b       = s:Colors('gray8', 'gray3', '')
let s:IA_c       = s:Colors('gray9', 'gray2', 'bold')
let s:IA_x       = s:Colors('gray8', 'gray2', '')
let s:IA_y       = s:Colors('gray8', 'gray2', '')
let s:IA_z       = s:Colors('gray8', 'gray3', '')
let g:airline#themes#szakdark#palette.inactive =
        \ airline#themes#generate_color_map(
        \ s:IA_a, s:IA_b, s:IA_c, s:IA_x, s:IA_y, s:IA_z)

" Accents are used to give parts within a section a slightly different look or
" color. Here we are defining a "red" accent, which is used by the 'readonly'
" part by default. Only the foreground colors are specified, so the background
" colors are automatically extracted from the underlying section colors. What
" this means is that regardless of which section the part is defined in, it
" will be red instead of the section's foreground color. You can also have
" multiple parts with accents within a section.
let g:airline#themes#szakdark#palette.accents = {
        \ 'red': s:Colors('brightestorange', 'unchanged', 'bold')
        \ }
