
let s:save_cpo = &cpo
set cpo&vim

let b:match_skip = 's:comment\|string\|vimSynReg'
      \ . '\|vimSet\|vimFuncName\|vimNotPatSep'
      \ . '\|vimVar\|vimFuncVar\|vimFBVar\|vimOperParen'
      \ . '\|vimUserFunc'

call matchup#util#patch_match_words(
      \ '\<aug\%[roup]\s\+\%(END\>\)\@!\S:',
      \ '\<aug\%[roup]\ze\s\+\%(END\>\)\@!\S:'
      \)

let &cpo = s:save_cpo

