" vissort.vim
"  Author:	Charles E. Campbell
"  Date:	Apr 16, 2013
"  Version:	4
"               COMBAK: need to check on document.  I've removed the input() stuff, using defaults instead

" ---------------------------------------------------------------------
" Load Once: {{{1
if &cp || exists("g:loaded_vissort")
 finish
endif
if v:version < 700
 echohl WarningMsg
 echo "***warning*** this version of vissort needs at least vim 7.0"
 echohl Normal
 finish
endif
let g:loaded_vissort = "v4"
let s:keepcpo        = &cpo
set cpo&vim

" ---------------------------------------------------------------------
"  Options: {{{1
if !exists("g:vissort_sort")
 let g:vissort_sort= "sort"
endif
if !exists("g:vissort_option")
 let g:vissort_option= ""
endif

" =====================================================================
" Functions: {{{1

" ---------------------------------------------------------------------
" vissort#VisSort:  sorts lines based on visual-block selected portion of the lines {{{2
" Author: Charles E. Campbell
fun! vissort#VisSort(isnmbr) range
"  call Dfunc("vissort#VisSort(isnmbr=".a:isnmbr.")")
  let vissort_option= (exists("g:vissort_option") && g:vissort_option != "")? " ".g:vissort_option : ""
"  call Decho("vissort_option<".vissort_option.">")
  if visualmode() != "\<c-v>"
   " no visual selection, just plain sort it
   exe "sil! ".a:firstline.",".a:lastline.g:vissort_sort.vissort_option
"   call Dret("vissort#VisSort : no visual selection, just plain sort it")
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
  sil! keepj norm! '<0"aP
  if a:isnmbr
   sil! '<,'>s/^\s\+/\=substitute(submatch(0),' ','0','g')/
  endif
  exe "sil! keepj '<,'>".g:vissort_sort.vissort_option

  " cleanup
  exe "sil! keepj ".firstline.",".lastline.'s/^.\{-}@@@//'

  let @a= keeprega
"  call Dret("vissort#VisSort")
endfun

" ---------------------------------------------------------------------
" vissort#Options: {{{2
fun! vissort#Options(...)
"  call Dfunc("vissort#Options() a:0=".a:0)
  if a:0 > 0
   if exists("g:vissort_option") && g:vissort_option == ""
"	call Decho("unlet-ting g:vissort_option")
    unlet g:vissort_option
   endif
   let g:vissort_option= a:1
"   call Decho("setting g:vissort_option<".g:vissort_option.">")
  elseif exists("g:vissort_option")
"   call Decho("unlet-ting g:vissort_option")
   unlet g:vissort_option
  endif
"  call Dret("vissort#Options")
endfun

" ---------------------------------------------------------------------
" vissort#BlockSort: provides an autoload-style interface for BS and CFuncSort commands {{{2
fun! vissort#BlockSort(...) range
"  call Dfunc("vissort#BlockSort() range=".a:firstline.",".a:lastline." args=".string(a:000))
"  call Decho('exe '.a:firstline.','.a:lastline.'call BlockSort('.string(a:000).')')
  let arglist= a:000
  exe a:firstline.','.a:lastline.'call BlockSort(arglist)'
"  call Dret("vissort#BlockSort")
endfun

" ---------------------------------------------------------------------
" BlockSort: Uses either vim-v7's built-in sort or, for vim-v6, Piet Delport's {{{2
"            binary-insertion sort, to sort blocks of text based on tags
"            contained within them.
"              nextblock : text to search() to find the beginning of next block
"                          "" means to use the line following the endblock pattern
"              endblock  : text to search() to find end-of-current block
"                          "" means use just-before-the-nextblock
"              findtag   : text to search() to find the tag in the current block.
"                          "" means the nextblock began with the tag
"              tagpat    : text to use in substitute() to specify tag pattern (extract tag from findtag)
"              			   "" means to use "^.*$"
"              tagsub    : text to use in substitute() to eliminate non-tag portion
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
"  call Dfunc("BlockSort(".string(a:000).") a:0=".a:0." range=".a:firstline.",".a:lastline)

  " get input from argument list or query user
  if a:0 == 1 && type(a:1) == 3
   let arglist= a:1
  else
   let arglist= a:000
  endif
"  call Decho(string(arglist)." (len=".len(arglist).")")
  let vars      = ["nextblock","endblock","findtag","tagpat","tagsub"]
  let ivar      = 0
  let nextblock = '^.*$'
  let endblock  = ''
  let findtag   = '^.*$'
  let tagpat    = ''
  let tagsub    = '&'
  for var in vars
   if ivar <= len(arglist)
"	call Decho("exe let ".vars[ivar]."='".arglist[ivar]."'")
	exe "let ".vars[ivar]."='".arglist[ivar]."'"
   else
	break
   endif
   let ivar= ivar + 1
  endfor

  " sanity check
  if nextblock == "" && endblock == ""
   echoerr "BlockSort: both nextblock and endblock patterns are empty strings"
"   call Dret("BlockSort")
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
"  call Decho("nextblock<".nextblock.">")
"  call Decho("endblock <".endblock.">")
"  call Decho("findtag  <".findtag.">")
"  call Decho("tagpat   <".tagpat.">")
"  call Decho("tagsub   <".tagsub.">")

  " don't allow wrapping around the end-of-file during searches
  " I put an empty "guard line" at the end to take care of fencepost issues
  " Its removed at the end of the function
  let akeep  = @a
  let wskeep = &ws
  set nows
  set lz
  let tagcnt = 0
  keepj $put =''
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
    let t= search(findtag,'c')
	if t == 0
	 echoerr "unable to find tag in block starting at line ".i
"     call Dret("BlockSort")
	 return
	endif
   endif
"   call Decho(printf("tag#%3d line#%3d: %s",tagcnt,line("."),getline(".")))
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
"	call Decho(printf("blockbgn%-3d at line#%3d",tagcnt,blockbgn{tagcnt}))
"    call Decho(printf("blocktag%-3d='%s'"       ,tagcnt,blocktag{tagcnt}))
"	call Decho(printf("blockend%-3d at line#%3d",tagcnt,blockend{tagcnt}))
   endif

   " save block text
   exe "sil! keepj ".blockbgn{tagcnt}.",".blockend{tagcnt}."y a"
   let blocktxt{tagcnt}= @a
   
"   call Decho("tag<".blocktag{tagcnt}."> block[".blockbgn{tagcnt}.",".blockend{tagcnt}."] i=".i." inxt=".inxt)
   let i= inxt
  endwhile

  " set up a temporary buffer+window with sorted tags
  new
  set buftype=nofile
  let i= 1
  while i <= tagcnt
   sil! keepj put =blocktag{i}
   let i= i + 1
  endwhile
  sil! keepj 1d
  if exists("vissort_option") && g:vissort_option != ""
   exe "sil! keepj %".g:vissort_sort." ".g:vissort_option
  else
   exe "sil! keepj %".g:vissort_sort
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
   exe "sil! ".blockbgn{tagcnt}.",".blockend{tagcnt}."d"
   sil! keepj put! =blocktxt{blocksrt{tagcnt}}
   let tagcnt= tagcnt - 1
  endwhile

  " cleanup: restore setting(s) and register(s)
  let &ws= wskeep
  let @a = akeep
  set nolz
  sil! keepj $d
  call cursor(a:firstline,1)
"  call Dret("BlockSort")
endfun

" ---------------------------------------------------------------------
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo

" ---------------------------------------------------------------------
"  Modelines: {{{1
" vim:ts=4 fdm=marker
