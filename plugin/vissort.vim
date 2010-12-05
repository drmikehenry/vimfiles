" vissort.vim
"  Author:	Charles E. Campbell, Jr.
"			BISort() by Piet Delport
"  Date:	Sep 27, 2006
"  Version:	4c	ASTRO-ONLY

" ---------------------------------------------------------------------
" Load Once: {{{1
if &cp || exists("g:loaded_vissort")
 finish
endif
let g:loaded_vissort = "v4c"
let s:keepcpo        = &cpo
set cpo&vim

" ---------------------------------------------------------------------
"  Public Interface: {{{1
com! -range -nargs=0		Bisort		silent <line1>,<line2>call s:BISort()
com! -range -nargs=0 -bang	Vissort		silent <line1>,<line2>call s:VisSort(<bang>0)
com! -range -nargs=*		BS			silent <line1>,<line2>call BlockSort(<f-args>)
com! -range -nargs=*		CFuncSort	silent <line1>,<line2>call BlockSort('','^}','^[^/*]\&^[^ ][^*]\&^.*\h\w*\s*(','^.\{-}\(\h\w*\)\s*(.*$','')

" ---------------------------------------------------------------------
" BISort: Piet Delport's BISort2() function, modified to take a range {{{1
fun! s:BISort() range
  let i = a:firstline + 1
  while i <= a:lastline
    " find insertion point via binary search
    let i_val = getline(i)
    let lo    = a:firstline
    let hi    = i
    while lo < hi
      let mid     = (lo + hi) / 2
      let mid_val = getline(mid)
      if i_val < mid_val
        let hi = mid
      else
        let lo = mid + 1
        if i_val == mid_val | break | endif
      endif
    endwhile
    " do insert
    if lo < i
      exec i.'d_'
      call append(lo - 1, i_val)
    endif
    let i = i + 1
  endwhile
endfun

" ---------------------------------------------------------------------
" VisSort:  sorts lines based on visual-block selected portion of the lines {{{1
" Author: Charles E. Campbell, Jr.
fun! s:VisSort(isnmbr) range
"  call Dfunc("VisSort(isnmbr=".a:isnmbr.")")
  if visualmode() != "\<c-v>"
   " no visual selection, just plain sort it
   if v:version < 700
    exe a:firstline.",".a:lastline."Bisort"
   else
    exe "silent ".a:firstline.",".a:lastline."sort"
   endif
"   call Dret("VisSort : no visual selection, just plain sort it")
   return
  endif

  " do visual-block sort
  "   1) yank a copy of the visual selected region
  "   2) place @@@ at the beginning of every line
  "   3) put a copy of the yanked region at the beginning of every line
  "   4) sort lines
  "   5) remove ^...@@@  from every line
  let firstline= line("'<")
  let lastline = line("'>")
  let keeprega = @a
  silent norm! gv"ay

  " prep
  '<,'>s/^/@@@/
  silent norm! '<0"aP
  if a:isnmbr
   silent! '<,'>s/^\s\+/\=substitute(submatch(0),' ','0','g')/
  endif
  if v:version < 700
   '<,'>Bisort
  else
   silent '<,'>sort
  endif

  " cleanup
  exe "silent ".firstline.",".lastline.'s/^.\{-}@@@//'

  let @a= keeprega
"  call Dret("VisSort")
endfun

" ---------------------------------------------------------------------
" BlockSort: Uses either vim-v7's built-in sort or, for vim-v6, Piet Delport's {{{1
"            binary-insertion sort, to sort blocks of text based on tags
"            contained within them.
"              nextblock : text to search() to find the beginning of next block
"                          "" means to use the line following the endblock pattern
"              endblock  : text to search() to find end-of-current block
"                          "" means use just-before-the-nextblock
"              findtag   : text to search() to find the tag in the current block.
"                          "" means the nextblock began with the tag
"              tagpat    : text to use in substitute() to specify tag pattern
"              			   "" means to use "^.*$"
"              tagsub    : text to use in substitute() to eliminate non-tag
"                          from tag pattern
"                          "" means: if tagpat == "": use '&'
"                                    else             use '\1'
"
"  Usage:
"      :[range]call BlockSort(nextblock,endblock,findtag,tagpat,tagsub)
"
"      Any missing arguments will be queried for
"
" With endblock specified, text is allowed in-between blocks;
" such text will remain in-between the sorted blocks
fun! BlockSort(...) range

  " get input from argument list or query user
  let vars="nextblock,endblock,findtag,tagpat,tagsub"
  let ivar= 1
  while ivar <= 5
   let var = substitute(vars,'^\([^,]\+\),.*$','\1','e')
   let vars= substitute(vars,'^[^,]\+,\(.*\)$','\1','e')
"   call Decho("var<".var."> vars<".vars."> ivar=".ivar." a:0=".a:0)
   if ivar <= a:0
"	call Decho("(arglist) let ".var."='".a:{ivar}."'")
	exe "let ".var."='".a:{ivar}."'"
   else
   	let inp= input("Enter ".var.": ")
"	call Decho("(input)   let ".var."='".inp."'")
	exe "let ".var."='".inp."'"
   endif
   let ivar= ivar + 1
  endwhile

  " sanity check
  if nextblock == "" && endblock == ""
   echoerr "BlockSort: both nextblock and endblock patterns are empty strings"
   return
  endif

  " defaults for tagpat and tagsub
  if tagpat == ""
   let tagpat= '^.*$'
   if tagsub == ""
   	let tagsub= '&'
   endif
  endif
  if tagsub == ""
   let tagsub= '\1'
  endif
"  call Decho("nextblock<".nextblock."> endblock<".endblock."> findtag<".findtag."> tagpat<".tagpat."> tagsub<".tagsub.">")

  " don't allow wrapping around the end-of-file during searches
  " I put an empty "guard line" at the end to take care of fencepost issues
  " Its removed at the end of the function
  let akeep  = @a
  let wskeep = &ws
  set nows
  set lz
  let tagcnt = 0
  $put =''
  call cursor(a:firstline,1)
"  call Decho("block sorting range[".a:firstline.",".a:lastline."]")

  " extract tag information: blocktag blockbgn blockend
  let i= a:firstline
  while 0 < i && i < a:lastline
   let tagcnt = tagcnt + 1
   let inxt   = 0
   call cursor(i,1)

   " find tag
   if findtag != ""
    let t= search(findtag)
	if t == 0
	 echoerr "unable to find tag in block starting at line ".i
	 return
	endif
   endif
   let blocktag{tagcnt} = substitute(getline("."),tagpat,tagsub,"")." ".tagcnt
   let blockbgn{tagcnt} = i

   " find end-of-block and nextblock
   if endblock == ""
   	let blockend{tagcnt} = search(nextblock)
   	let inxt             = blockend{tagcnt}
    if blockend{tagcnt} == 0
     let blockend{tagcnt}= a:lastline
	else
   	 let blockend{tagcnt} = blockend{tagcnt} - 1
    endif
   else
   	let blockend{tagcnt}= search(endblock)
    if blockend{tagcnt} == 0
      let blockend{tagcnt} = a:lastline
     elseif nextblock == ""
	  let inxt= blockend{tagcnt} + 1
	 else
      let inxt = search(nextblock)
    endif
   endif

   " save block text
   exe "silent ".blockbgn{tagcnt}.",".blockend{tagcnt}."y a"
   let blocktxt{tagcnt}= @a
   
"   call Decho("tag<".blocktag{tagcnt}."> block[".blockbgn{tagcnt}.",".blockend{tagcnt}."] i=".i." inxt=".inxt)
   let i= inxt
  endwhile

  " set up a temporary buffer+window with sorted tags
  new
  set buftype=nofile
  let i= 1
  while i <= tagcnt
   put =blocktag{i}
   let i= i + 1
  endwhile
  1d
  if v:version >= 700
   %sort
  else
   1,$call s:BISort()
  endif
  let i= 1
  while i <= tagcnt
   let blocksrt{i}= substitute(getline(i),'^.* \(\d\+\)$','\1','')
"   call Decho("blocksrt{".i."}=".blocksrt{i}." <".blocktag{blocksrt{i}}.">")
   let i = i + 1
  endwhile
  q!

  " delete blocks and insert sorted blocks
  while tagcnt > 0
   exe "silent ".blockbgn{tagcnt}.",".blockend{tagcnt}."d"
   silent put! =blocktxt{blocksrt{tagcnt}}
   let tagcnt= tagcnt - 1
  endwhile

  " cleanup: restore setting(s) and register(s)
  let &ws= wskeep
  let @a = akeep
  set nolz
  $d
  call cursor(a:firstline,1)
endfun

" ---------------------------------------------------------------------
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo

" ---------------------------------------------------------------------
"  Modelines: {{{1
" vim:ts=4 fdm=marker
