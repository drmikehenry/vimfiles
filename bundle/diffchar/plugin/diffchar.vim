" diffchar.vim: Highlight the exact differences, based on characters and words
"
"  ____   _  ____  ____  _____  _   _  _____  ____   
" |    | | ||    ||    ||     || | | ||  _  ||  _ |  
" |  _  || ||  __||  __||     || | | || | | || | ||  
" | | | || || |__ | |__ |   __|| |_| || |_| || |_||_ 
" | |_| || ||  __||  __||  |   |     ||     ||  __  |
" |     || || |   | |   |  |__ |  _  ||  _  || |  | |
" |____| |_||_|   |_|   |_____||_| |_||_| |_||_|  |_|
"
" Last Change:	2021/12/07
" Version:		8.91
" Author:		Rick Howe (Takumi Ohtani) <rdcxy754@ybb.ne.jp>
" Copyright:	(c) 2014-2021 by Rick Howe

if exists('g:loaded_diffchar') || !has('diff') || v:version < 800
	finish
endif
let g:loaded_diffchar = 8.91

let s:save_cpo = &cpoptions
set cpo&vim

" Commands
command! -range -bar SDChar
				\ call diffchar#ShowDiffChar(range(<line1>, <line2>))
command! -range -bar RDChar
				\ call diffchar#ResetDiffChar(range(<line1>, <line2>))
command! -range -bar TDChar
				\ call diffchar#ToggleDiffChar(range(<line1>, <line2>))
command! -range -bang -bar EDChar
				\ call diffchar#EchoDiffChar(range(<line1>, <line2>), <bang>1)

" Configurable Keymaps
for [key, plg, cmd] in [
	\['[b', '<Plug>JumpDiffCharPrevStart',
									\':call diffchar#JumpDiffChar(0, 0)'],
	\[']b', '<Plug>JumpDiffCharNextStart',
									\':call diffchar#JumpDiffChar(1, 0)'],
	\['[e', '<Plug>JumpDiffCharPrevEnd',
									\':call diffchar#JumpDiffChar(0, 1)'],
	\[']e', '<Plug>JumpDiffCharNextEnd',
									\':call diffchar#JumpDiffChar(1, 1)'],
	\['<Leader>g', '<Plug>GetDiffCharPair',
									\':call diffchar#CopyDiffCharPair(0)'],
	\['<Leader>p', '<Plug>PutDiffCharPair',
									\':call diffchar#CopyDiffCharPair(1)']]
	if !hasmapto(plg, 'n') && empty(maparg(key, 'n'))
		if get(g:, 'DiffCharDoMapping', 1)
			execute 'nmap <silent> ' . key . ' ' . plg
		endif
	endif
	execute 'nnoremap <silent> ' plg . ' ' . cmd . '<CR>'
endfor

" a type of difference unit
if !exists('g:DiffUnit')
	let g:DiffUnit = 'Word1'	" \w\+ word and any \W single character
	" let g:DiffUnit = 'Word2'	" non-space and space words
	" let g:DiffUnit = 'Word3'	" \< or \> character class boundaries
	" let g:DiffUnit = 'Char'	" any single character
	" let g:DiffUnit = 'CSV(,)'	" split characters
endif

" matching colors for changed units
if !exists('g:DiffColors')
	let g:DiffColors = 0		" always 1 color
	" let g:DiffColors = 1		" up to 4 colors in fixed order
	" let g:DiffColors = 2		" up to 8 colors in fixed order
	" let g:DiffColors = 3		" up to 16 colors in fixed order
	" let g:DiffColors = 4		" all available colors in fixed order
	" let g:DiffColors = 100	" all colors in dynamic random order
endif

" a visibility of corresponding diff units
if !exists('g:DiffPairVisible')
	let g:DiffPairVisible = 1	" highlight
	" let g:DiffPairVisible = 2	" highlight + echo
	" let g:DiffPairVisible = 3	" highlight + popup/floating at cursor pos
	" let g:DiffPairVisible = 4	" highlight + popup/floating at mouse pos
	" let g:DiffPairVisible = 0	" disable
endif

" Set this plugin's DiffCharExpr() to the diffexpr option if empty
" and when internal diff is not used
if !exists('g:DiffExpr')
	let g:DiffExpr = 1			" enable
	" let g:DiffExpr = 0		" disable
endif
if g:DiffExpr && empty(&diffexpr) && &diffopt !~ 'internal'
	let &diffexpr = 'diffchar#DiffCharExpr()'
endif

" an event group of this plugin
if has('patch-8.0.736')			" OptionSet triggered with diff option
	let g:DiffCharInitEvent = ['augroup diffchar', 'autocmd!',
				\'autocmd OptionSet diff call diffchar#ToggleDiffModeSync(0)',
															\'augroup END']
	call execute(g:DiffCharInitEvent)
	if has('patch-8.1.1113') || has('nvim-0.4.0')
		call execute('autocmd diffchar VimEnter * ++once
					\ if &diff | call diffchar#ToggleDiffModeSync(1) | endif')
	else
		call execute('autocmd diffchar VimEnter *
					\ if &diff | call diffchar#ToggleDiffModeSync(1) | endif |
												\ autocmd! diffchar VimEnter')
	endif
else
	let g:DiffCharInitEvent = ['augroup diffchar', 'autocmd!',
				\'autocmd FilterWritePost * call diffchar#SetDiffModeSync()',
															\'augroup END']
	call execute(g:DiffCharInitEvent)
endif

let &cpoptions = s:save_cpo
unlet s:save_cpo

" vim: ts=4 sw=4
