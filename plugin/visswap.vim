" visswap.vim   : Visual Mode Based Swapping
"  Author:	Charles E. Campbell, Jr.
"  Date:	Mar 07, 2006
"  Version:	4e	ASTRO-ONLY
"  Usage:
"		Visually select some text, then <ctrl-y>  (initialize)
"       Visually select some text, then <ctrl-x>  (swap)
"       (overlaps not allowed)

" ---------------------------------------------------------------------
" Load Once: {{{1
if &cp || exists("g:loaded_visswap")
 finish
endif
let s:keepcpo        = &cpo
let g:loaded_visswap = "v4e"
set cpo&vim

" ---------------------------------------------------------------------
" Public Interface: {{{1
if !hasmapto('<Plug>VisualPreSwap')
 vmap <silent> <unique> <c-y> <Plug>VisualPreSwap
endif
vnoremap <silent> <Plug>VisualPreSwap <Esc>:call <SID>VisualPreSwap()<CR>

if !hasmapto('<Plug>VisualSwap')
 vmap <silent> <unique> <c-x> <Plug>VisualSwap
endif
vnoremap <silent> <Plug>VisualSwap <Esc>:call <SID>VisualSwap()<CR>

if !hasmapto('<Plug>VisualReplace')
 nmap <silent> <unique> <Leader>vr <Plug>VisualReplace
endif
nnoremap <silent> <Plug>VisualReplace :call <SID>VisualReplace()<CR>

if &remap == 0
 echohl WarningMsg | echoerr '***warning*** your "noremap" setting prevents the visswap plugin from working' | echohl None
endif

" ---------------------------------------------------------------------

" VisualPreSwap: initializes a visual-mode swap by recording {{{1
"                visual-selection zone parameters.  This is the
"                "yank" (ctrl-y).
fun! s:VisualPreSwap()
"  call Dfunc("VisualPreSwap()")
  let s:vismode_y      = visualmode()
  let s:startswapline_y= line("'<")
  let s:startswapcol_y = virtcol("'<")
  let s:endswapline_y  = line("'>")
  let s:endswapcol_y   = virtcol("'>")
  if s:vismode_y =~ "[vV]"
   echo "visual (".s:vismode_y.") mode swap initialized"
  else
   echo "visual (ctrl-v) mode swap initialized"
  endif
"  call Dret("VisualPreSwap : starty[".s:startswapline_y.",".s:startswapcol_y."] endy[".s:endswapline_y.",".s:endswapcol_y."] vismode_y<".s:vismodey.">")
endfun

" ---------------------------------------------------------------------
" VisualSwap: Performs the swap: This action is the exchange (ctrl-x). {{{1
"
"             Yanks both visual selections into the a and b registers
"             (their original contents will be restored later)
"
"             Based on visual mode and where the two zones start:
"               A zone will be deleted and the appropriate register
"               used to put in the new contents.
"               Then the other zone will be deleted and the other
"               register's contents will inserted.
fun! s:VisualSwap()
"  call Dfunc("VisualSwap()")
  let s:vismode_x      = visualmode()
  let s:startswapline_x= line("'<")
  let s:startswapcol_x = virtcol("'<")
  let s:endswapline_x  = line("'>")
  let s:endswapcol_x   = virtcol("'>")
"  call Decho("startx[".s:startswapline_x.",".s:startswapcol_x."] endx[".s:endswapline_x.",".s:endswapcol_x."] vismode_x<".s:vismode_x.">")

  let keep_regy= @y
  let keep_regx= @x

  exe "norm! ".s:startswapline_y."G".s:startswapcol_y."|".s:vismode_y.s:endswapline_y."G".s:endswapcol_y.'|"yy'
  exe "norm! ".s:startswapline_x."G".s:startswapcol_x."|".s:vismode_x.s:endswapline_x."G".s:endswapcol_x.'|"xy'
"  call Decho("block-y: regy<".@y.">")
"  call Decho("block-x: regx<".@x.">")

  " First  visual block is y (regy) (selected with a ctrl-y)
  " Second visual block is x (regx) (selected with the ctrl-x swap)
  " Case 1: delete block x            - chosen when x appears later in the file
  "         put block y in x's place
  "         delete block y
  "         put block x in y's place
  " Case 2: opposite sequence         - chosen when y appears later in the file
  if   ( s:vismode_y =~ "[vV]" && s:startswapline_y < s:startswapline_x ) ||
   	 \ ( s:startswapline_y == s:startswapline_x && s:startswapcol_y < s:startswapcol_x ) ||
   	 \ ( s:startswapcol_y <= s:startswapcol_x )
"   call Decho("case 1 : del x, put y, del y, put x")
   exe "norm! ".s:startswapline_x."G".s:startswapcol_x."|".s:vismode_x.s:endswapline_x."G".s:endswapcol_x.'|x"yP'
   exe "norm! ".s:startswapline_y."G".s:startswapcol_y."|".s:vismode_y.s:endswapline_y."G".s:endswapcol_y.'|x"xP'
  else
"   call Decho("case 2 : del y, put x, del x, put y")
   exe "norm! ".s:startswapline_y."G".s:startswapcol_y."|".s:vismode_y.s:endswapline_y."G".s:endswapcol_y.'|x"xP'
   exe "norm! ".s:startswapline_x."G".s:startswapcol_x."|".s:vismode_x.s:endswapline_x."G".s:endswapcol_x.'|x"yP'
  endif

  let @y= keep_regy
  let @x= keep_regx
"  call Dret("VisualSwap")
endfun

" ---------------------------------------------------------------------
" VisualReplace: visual block-based text replace {{{1
"    Use ctrl-v + motion to select block, hit <esc>
"    Move cursor to where the columns are to be replaced, hit \vr
fun! s:VisualReplace()
"  call Dfunc("VisualReplace()")

  let g:curposn = SaveWinPosn(0)
"  call Decho("curposn=".g:curposn)
  let keep_ve   = &ve
  set ve

  let repline1 = line("'<")
  let repline2 = line("'>")
  if repline1 > repline2
   let repline1 = line("'>")
   let repline2 = line("'<")
  endif
  let repcol1  = col("'<")
  let repcol2  = col("'>")
  if repcol1 > repcol2
   let repcol1  = col("'<")
   let repcol2  = col("'>")
  endif
"  call Decho("rep[".repline1.",".repcol1."] [".repline2.",".repcol2."]")

  let keepa= @a
  norm! gv"ay
  call RestoreWinPosn(g:curposn)
  let linediff = repline2 - repline1
  let coldiff  = repcol2 - repcol1
"  call Decho("exe norm! \<c-v>".linediff."j".coldiff."lc\<c-o>".'"aP'."\<esc>")
  exe "keepjumps norm! \<c-v>".linediff."j".coldiff."lc\<c-o>".'"aP'."\<esc>"
"  call Decho("@a=".@a)

  " restore register @a, visual-block selection, and window positioning
  let @a= keepa
"  call Decho("exe norm! \<c-v>".linediff."j".coldiff."l\<esc>")
  exe "keepjumps norm! ".repline1."G".repcol1."\<bar>\<c-v>".linediff."j".coldiff."l\<esc>"
  let &ve= keep_ve
  call RestoreWinPosn(g:curposn)

"  call Dret("VisualReplace")
endfun

" ---------------------------------------------------------------------
"  Restore Settings:
let &cpo= s:keepcpo
unlet s:keepcpo
" ---------------------------------------------------------------------
"  Modelines: {{{1
" vim: ts=4 fdm=marker
