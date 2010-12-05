" Runview:
"  Language: runview
"  Maintainer: Charles E. Campbell, Jr.
"  Last change: Oct 26, 2005

" Remove any old syntax stuff hanging around
syn clear

syn match runviewTitle	"\%1lRunView.*$"
syn match runviewSep	"^===\d.*$"

if !exists("did_runview_syntax")
 let did_runview_syntax= 1
 hi link runviewTitle	Title
 hi link runviewSep		Statement
endif
