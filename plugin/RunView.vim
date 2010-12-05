" RunView:
"   Author: Charles E. Campbell, Jr.
"   Date:   Dec 15, 2005
"   Version: 1e	ASTRO-ONLY
" Copyright:    Copyright (C) 2005 Charles E. Campbell, Jr. {{{1
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               RunView.vim is provided *as is* and comes with no warranty
"               of any kind, either expressed or implied. By using this
"               plugin, you agree that in no event will the copyright
"               holder be liable for any damages resulting from the use
"               of this software.

" ---------------------------------------------------------------------
"  Load Once: {{{1
if &cp || exists("g:loaded_RunView")
 finish
endif
let g:loaded_RunView= "v1e"

" ---------------------------------------------------------------------
"  Defaults: {{{1
if !exists("g:runview_filtcmd")
 let g:runview_filtcmd= "ksh"
endif
if !exists("g:runview_swapwin")
 let g:runview_swapwin= 1
endif

" ---------------------------------------------------------------------
"  Public Interface: {{{1
com! -bang -range -nargs=? RunView silent <line1>,<line2>call s:RunView(<bang>0,<q-args>)

" \rh map: RunView filter-command
if !hasmapto('<Plug>RunViewH')
 vmap <unique> <Leader>rh <Plug>RunViewH
endif
vmap <silent> <script> <Plug>RunViewH	:call <SID>RunView(0)<cr>

" \rv map: RunView! filter-command
if !hasmapto('<Plug>RunViewV')
 vmap <unique> <Leader>rv <Plug>RunViewV
endif
vmap <silent> <script> <Plug>RunViewV	:call <SID>RunView(1)<cr>

" ---------------------------------------------------------------------
"  Functions: {{{1

" ---------------------------------------------------------------------
" RunView: {{{2
fun! s:RunView(v,...) range
"  call Dfunc("RunView(v=".a:v.") [".a:firstline.",".a:lastline."]")

  " set splitright to zero while in this function
  let keep_splitright= &splitright
  let keep_splitbelow= &splitbelow
  set nosplitright nosplitbelow

  " if arg provided, use it as filter-command.
  " Otherwise, use g:runview_filtcmd.
  if a:0 == 1
   let filtcmd= a:1
  else
   let filtcmd= g:runview_filtcmd
  endif
"  call Decho("filtcmd<".filtcmd.">")

  " get a copy of the selected lines
  let keepa   = @a
  let curfile = expand("%")
  exe "silent ".a:firstline.",".a:lastline."y a"
  let winout  = escape(filtcmd," ").'\ '.escape(curfile," ")
"  call Decho("winout<".winout.">")

  if bufexists(filtcmd." ".curfile)
   " output window already exists by given name.
   " Place delimiter and append output to it
   let curwin  = winnr()
   let bufout  = bufwinnr(winout)
   exe bufout."wincmd w"
   "   exe "au BufUnload ".escape(curname,' ').' '.bufnr(bufname("%")).'bw|q'
   set ma
   let lastline= line("$")
   $
   let delimstring = "===".strftime("%m/%d/%y %H:%M:%S")."==="
   put =delimstring
   silent put a
   let lastlinep2= lastline + 2
   exe "silent ".lastlinep2.",$!".filtcmd
   set noma nomod bh=wipe
   $
   exe curwin."wincmd w"

  else
   " (vertically) split and run register a's lines through filtcmd
   let curname= bufname("%")
   if a:v
    vert new
   else
    new
   endif
   set ma
   silent put a
   exe "silent %!".filtcmd
   exe "file ".winout
   let title       = 'RunView '.filtcmd.' Output Window'
   let delimstring = "===".strftime("%m/%d/%y %H:%M:%S")."==="
   1
   silent put!=title
   put =delimstring
   silent 3
   set ft=runview
   set noma nomod bh=wipe
   $
   if g:runview_swapwin == 1
    wincmd x
   else
    wincmd w
   endif
  endif

  " restore register a, splitright, and splitbelow
  let @a          = keepa
  let &splitright = keep_splitright
  let &splitbelow = keep_splitbelow

"  call Dret("RunView")
endfun

" ---------------------------------------------------------------------
"  Modelines: {{{1
"  vim: fdm=marker
