" Runview:
"  Language: runview
"  Maintainer: Charles E. Campbell, Jr.
"  Last change: Sep 17, 2009

" Remove any old syntax stuff hanging around
syn clear

syn match runviewNmbr	'\<[-+]\=\%(\.\d\+\)\=\%([eE][-+]\d\+\)\='
syn match runviewNmbr	'\<[-+]\=\d\+\%(\.\d*\)\=\%([eE][-+]\d\+\)\='
syn match runviewOp		'[=]'

syn match runviewTitle	"\%1lRunView.*$"
syn match runviewSep	"^===\d.*$"

if !exists("did_runview_syntax")
 let did_runview_syntax= 1
 hi link runviewTitle	Title
 hi link runviewSep		Statement
 hi link runviewNmbr	Number
 hi link runviewOp		Operator
endif
