" vissortPlugin.vim
"  Author:	Charles E. Campbell
"			BISort() by Piet Delport
"  Date:	Nov 02, 2012
"  Version:	4d	NOT RELEASED

" ---------------------------------------------------------------------
" Load Once: {{{1
if &cp || exists("g:loaded_vissort")
 finish
endif
let s:keepcpo= &cpo
set cpo&vim

" ---------------------------------------------------------------------
"  Public Interface: {{{1
com! -range -nargs=0 -bang	Vissort		sil! keepj  <line1>,<line2>call vissort#VisSort(<bang>0)
com! -range -nargs=*		BS			sil! keepj  <line1>,<line2>call vissort#BlockSort(<f-args>)
com! -range -nargs=*		CFuncSort	sil! keepj  <line1>,<line2>call vissort#BlockSort('','^}','^[^/*]\&^[^ ][^*]\&^.*\h\w*\s*(','^.\{-}\(\h\w*\)\s*(.*$','')
com!        -nargs=?		VisOption	sil! call vissort#Options(<q-args>)
sil! com    -nargs=?		VSO	        sil! call vissort#Options(<q-args>)

" ---------------------------------------------------------------------
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo

" ---------------------------------------------------------------------
"  Modelines: {{{1
" vim:ts=4 fdm=marker
