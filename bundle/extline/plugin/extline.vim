" Vim global plugin for extending lines (e.g., underlined titles).

if exists('loaded_extline')
    finish
endif
let loaded_extline = 1

" Save 'cpoptions' and set Vim default to enable line continuations.
let s:save_cpoptions = &cpoptions
set cpoptions&vim

xnoremap <silent> <C-L><C-L>  <ESC>:call extline#autoTitle()<CR>^
inoremap <silent> <C-L><C-L>  <C-G>u<C-O>:call extline#autoTitle()<CR>
xnoremap <silent> <C-L><C-H>  <ESC>:call extline#makeHline()<CR>^
inoremap <silent> <C-L><C-H>  <C-G>u<C-O>:call extline#makeHline()<CR>

xnoremap <silent> <C-L><C-U>  <ESC>:call extline#makeTitle("",  0, 1)<CR>^
xnoremap <silent> <C-L><C-O>  <ESC>:call extline#makeTitle("",  1, 0)<CR>^
xnoremap <silent> <C-L><C-I>  <ESC>:call extline#makeTitle("",  1, 1)<CR>^
xnoremap <silent> <C-L>1      <ESC>:call extline#makeTitle("=", 0, 1)<CR>^
xnoremap <silent> <C-L>=      <ESC>:call extline#makeTitle("=", 0, 1)<CR>^
xnoremap <silent> <C-L>2      <ESC>:call extline#makeTitle("-", 0, 1)<CR>^
xnoremap <silent> <C-L>-      <ESC>:call extline#makeTitle("-", 0, 1)<CR>^
xnoremap <silent> <C-L>3      <ESC>:call extline#makeTitle("^", 0, 1)<CR>^
xnoremap <silent> <C-L>^      <ESC>:call extline#makeTitle("^", 0, 1)<CR>^
xnoremap <silent> <C-L>4      <ESC>:call extline#makeTitle('"', 0, 1)<CR>^
xnoremap <silent> <C-L>"      <ESC>:call extline#makeTitle('"', 0, 1)<CR>^
xnoremap <silent> <C-L>5      <ESC>:call extline#makeTitle("'", 0, 1)<CR>^
xnoremap <silent> <C-L>'      <ESC>:call extline#makeTitle("'", 0, 1)<CR>^
xnoremap <silent> <C-L>9      <ESC>:call extline#makeTitle("#", 1, 1)<CR>^
xnoremap <silent> <C-L>#      <ESC>:call extline#makeTitle("#", 1, 1)<CR>^
xnoremap <silent> <C-L>0      <ESC>:call extline#makeTitle("*", 1, 1)<CR>^
xnoremap <silent> <C-L>*      <ESC>:call extline#makeTitle("*", 1, 1)<CR>^

" Undo-break via CTRL-G u.
inoremap <silent> <C-L><C-I>  <C-G>u<C-O>:call extline#makeTitle("",  1, 1)<CR>
inoremap <silent> <C-L><C-O>  <C-G>u<C-O>:call extline#makeTitle("",  1, 0)<CR>
inoremap <silent> <C-L><C-U>  <C-G>u<C-O>:call extline#makeTitle("",  0, 1)<CR>
inoremap <silent> <C-L>1      <C-G>u<C-O>:call extline#makeTitle("=", 0, 1)<CR>
inoremap <silent> <C-L>=      <C-G>u<C-O>:call extline#makeTitle("=", 0, 1)<CR>
inoremap <silent> <C-L>2      <C-G>u<C-O>:call extline#makeTitle("-", 0, 1)<CR>
inoremap <silent> <C-L>-      <C-G>u<C-O>:call extline#makeTitle("-", 0, 1)<CR>
inoremap <silent> <C-L>3      <C-G>u<C-O>:call extline#makeTitle("^", 0, 1)<CR>
inoremap <silent> <C-L>^      <C-G>u<C-O>:call extline#makeTitle("^", 0, 1)<CR>
inoremap <silent> <C-L>4      <C-G>u<C-O>:call extline#makeTitle('"', 0, 1)<CR>
inoremap <silent> <C-L>"      <C-G>u<C-O>:call extline#makeTitle('"', 0, 1)<CR>
inoremap <silent> <C-L>5      <C-G>u<C-O>:call extline#makeTitle("'", 0, 1)<CR>
inoremap <silent> <C-L>'      <C-G>u<C-O>:call extline#makeTitle("'", 0, 1)<CR>
inoremap <silent> <C-L>9      <C-G>u<C-O>:call extline#makeTitle("#", 1, 1)<CR>
inoremap <silent> <C-L>#      <C-G>u<C-O>:call extline#makeTitle("#", 1, 1)<CR>
inoremap <silent> <C-L>0      <C-G>u<C-O>:call extline#makeTitle("*", 1, 1)<CR>
inoremap <silent> <C-L>*      <C-G>u<C-O>:call extline#makeTitle("*", 1, 1)<CR>

" Restore saved 'cpoptions'.
let &cpoptions = s:save_cpoptions

finish

" ----------------------------------------------------------------------------


Types of single lines of text
-----------------------------

- Monoline:

  - Start of line
  - Optional leading whitespace
  - One or more identical non-alphanumeric non-white characters, c
  - Optional trailing whitespace
  - End of line

- Genline:
    prefix <longest run of characters> postfix

    postfix might contain optional column number

  - Start of line
  - Optional leading whitespace
  - Optional prefix with final character, L
  - One or more identical non-white characters, c, with c != L
  - Optional suffix with first character, R, with R != c
  - Optional white (ignored)
  - Optional integer column number
  --------------------------------

- Title:

  - Non-blank

Title types
-----------

- NoTitle:


- BareTitle::


    Title


- UnderTitle::


    Title
    =====


- OverTitle::


    =====
    Title


- OverUnderTitle::


    =====
    Title
    =====


HLine types
-----------

    =============================

    /****************************

    ****************************/

    /***************************/

    # ---------------------------
    # --------------------------- #



" vim: sts=4 sw=4 tw=80 et ai:
