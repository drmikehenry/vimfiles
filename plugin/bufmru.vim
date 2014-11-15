" bufmru - switch to most recently used buffers
" File:         bufmru.vim
" Vimscript:	#2346
" Created:      2008 Aug 18
" Last Change:  2009 May 10
" Rev Days:     33
" Author:	Andy Wokula <anwoku@yahoo.de>
" Version:	3.3 (splashbufs only)
" Credits:	Anton Sharonov (g:bufmru_splashbufs)
" License:	Vim license

" Comments

" Description: {{{1
"   Switch between MRU buffers from the current session. Like CTRL-^, but
"   reach more buffers (and maintain only one global list, not one list per
"   window).  Visual Studio users not used to split windows may find this
"   handy.

" Usage: {{{1
"   KEY(S)	    ACTION
"   <Space>	    switch to the most recently used buffer and enter Bufmru
"   		    mode.
"
"   in BUFMRU MODE:
"   f  b	    reach more MRU buffers (forward/backward)
"   e  <Enter>	    accept current choice
"   !		    accept current choice (an abandoned modified buffer
"		    becomes hidden)
"   q  <Esc>	    quit the mode, go back to start buffer (forcibly)
"   y		    copy file name
"
"   The mode times out after 'timeoutlen' ms.  A key not mapped in the mode
"   (e.g. <Space>) quits the mode and executes as usual.

" Configuration: {{{1
"   :let g:bufmru_lazy_filetype = 0
"	(checked always) If 1, do lazy filetype detection when going through
"	the buffers with f and b.  Not used if 'hidden' is set.
"
"   :let g:bufmru_switchkey = "<Space>"
"	(checked once) Key to enter Bufmru Mode.
"
"   :let g:bufmru_confclose = 0
"	(always) Use :confirm (1) when switching buffers.  If a modified
"	buffer cannot be abandoned (only happens with 'nohidden'), this will
"	prompt you with a dialog.  Otherwise (0, default) you'll get an
"	error message.
"
"   :let g:bufmru_bnrs = []
"	(always) The internal stack of buffer numbers.  Normally, you'll
"	leave this alone, but you can manually add or remove buffer numbers
"	or initialize the list.  Don't worry about wrong numbers (though
"	duplicates aren't removed automatically).
"
"   :let g:bufmru_read_nummarks = 0
"	(checked once; only if g:bufmru_bnrs still empty) Add the number
"	mark '0..'9 buffers to g:bufmru_bnrs.
"	Note: This adds buffers to the buffer list!
"
"   :let g:bufmru_limit = 40
"	(checked when adding a bufnr) Maximum number of entries to keep in
"	the MRU list.
"
" Notes: {{{1
" - "checked once": (re-)source the script to apply the change
" - "special buffer": 'buftype' not empty or 'previewwindow' set for the
"   window; not a special buffer if merely 'buflisted' is off.
"
" See Also: {{{1
" - http://vim.wikia.com/wiki/Easier_buffer_switching
" - Message-ID: <6690c6ec-7f1d-4430-9271-0511f8f874e3@e39g2000hsf.googlegroups.com>

" TODO {{{1
" + no limit with g:bufmru_limit = 0
" + option: turn off filetype events while switching, detect filetype when
"   accepting the choice
" + :filetype detect
"   * not after :syn off (or :filetype off)
"   * not needed if buffer is shown in another window
" + :let s:did_bufread=0 <-- set to zero only if switching to _another_
"   buffer

" End Of Comments {{{1
" }}}1

" Start Of Code

" Script Init Folklore: "{{{
if exists("loaded_bufmru")
    finish
endif
let loaded_bufmru = 1

if v:version < 700
    echomsg "bufmru: you need at least Vim 7.0"
    finish
endif

let s:sav_cpo = &cpo
set cpo&vim
"}}}

" Customization: "{{{
if !exists("g:bufmru_lazy_filetype")
    let g:bufmru_lazy_filetype = 0
endif

if !exists("g:bufmru_confclose")
    let g:bufmru_confclose = 0
endif

" mru buf is at index 0
if !exists("g:bufmru_bnrs")
    let g:bufmru_bnrs = []
endif

if !exists("g:bufmru_limit")
    let g:bufmru_limit = 40
endif

if !exists("g:bufmru_switchkey")
    let g:bufmru_switchkey = "<Space>"
endif

if !exists("g:bufmru_read_nummarks")
    let g:bufmru_read_nummarks = 0
endif
"}}}
" Autocommands: "{{{
augroup bufmru
    au!
    au BufEnter * if !s:noautocmd| call s:maketop(bufnr(""),1)| endif
    au BufRead * let s:did_bufread = 1
augroup End "}}}
" Mappings: {{{1
exec "nmap" g:bufmru_switchkey "<SID>idxz<SID>buf<Plug>bufmru...."
nmap <Plug>bufmru....f	    <SID>next<SID>buf<Plug>bufmru....
nmap <Plug>bufmru....b	    <SID>prev<SID>buf<Plug>bufmru....
sil! unmap	    <Plug>bufmru....<Tab>
sil! unmap	    <Plug>bufmru....<S-Tab>
nmap <Plug>bufmru....!	    <SID>bang<Plug>bufmru....
nmap <Plug>bufmru....<Enter> <SID>raccept
nmap <Plug>bufmru....e	    <SID>raccept
nmap <Plug>bufmru....<Esc>   <SID>reset
nmap <Plug>bufmru....q	    <SID>reset
nmap <Plug>bufmru....	    <SID>raccept
nmap <Plug>bufmru....y	    <SID>yank<Plug>bufmru....

nnoremap <silent> <SID>idxz	:<C-U>call<sid>idxz()<cr>
nnoremap <silent> <SID>next	:call<sid>next()<cr>
nnoremap <silent> <SID>prev   	:call<sid>prev()<cr>
nnoremap <silent> <SID>buf    	:call<sid>buf()<cr>
nnoremap <silent> <SID>raccept 	:call<sid>reset(1)<cr>
nnoremap <silent> <SID>reset 	:call<sid>reset(0)<cr>
nnoremap <silent> <SID>yank   	:call<sid>yank()<cr>
nnoremap <silent> <SID>bang	:call<sid>bang()<cr>
" }}}

" Global Functions:
" add the files behind the global marks '0..'9 to the buffer list and the
" MRU list as well, and return a list of the assigned buffer numbers
func! Bufmru_Read_Nummarks() "{{{
    " call map(reverse(range(0,9)),'s:maketop(getpos("''".v:val)[0])')
    let res_bnrs = []
    for nmark in reverse(range(0,9))
	let bnr = getpos("'".nmark)[0]
	call insert(res_bnrs, bnr)
	call setbufvar(bnr, "&buflisted", 1)
	call s:maketop(bnr)
    endfor
    call s:maketop(bufnr(""))
    return res_bnrs
endfunc "}}}

" Local Functions:
func! s:maketop(bnr, ...) "{{{
    " with a:1, don't check {bnr} now, it may become valid later
    if a:0==0 && !s:isvalidbuf(a:bnr)
	return
    endif

    let idx = index(g:bufmru_bnrs, a:bnr)
    if idx >= 1
	call remove(g:bufmru_bnrs, idx)
    endif
    if idx != 0
	call insert(g:bufmru_bnrs, a:bnr)
    endif
    if g:bufmru_limit >= 1
	sil! call remove(g:bufmru_bnrs, g:bufmru_limit, -1)
    endif
endfunc "}}}

func! s:isvalidbuf(bnr) "{{{
    return buflisted(a:bnr)
	\ && getbufvar(a:bnr, '&buftype') == ""
endfunc "}}}

func! s:bnr() "{{{
    try
	let bnr = g:bufmru_bnrs[s:bidx]
	let i = 0
	while !s:isvalidbuf(bnr)
	    if i < 2
		call remove(g:bufmru_bnrs, s:bidx)
	    else
		call filter(g:bufmru_bnrs, 's:isvalidbuf(v:val)')
	    endif
	    let len = len(g:bufmru_bnrs)
	    if s:bidx >= len
		let s:bidx = len < 2 ? 0 : len-1
	    endif
	    let bnr = g:bufmru_bnrs[s:bidx]
	    let i += 1
	endwhile
    catch
	let bnr = bufnr("")
	call s:maketop(bnr)
    endtry
    return bnr
endfunc "}}}

func! <sid>next() "{{{
    " let s:bidx = (s:bidx+1) % len(g:bufmru_bnrs)
    if !s:switch_ok
	return
    endif
    call s:check_start_ei()
    let s:bidx += 1
    let len = len(g:bufmru_bnrs)
    if s:bidx >= len
	let s:bidx = len-1
	echohl WarningMsg
	echo "No older MRU buffers"
	echohl None
    endif
endfunc "}}}

func! <sid>prev() "{{{
    if !s:switch_ok
	return
    endif
    call s:check_start_ei()
    let s:bidx -= 1
    if s:bidx < 0
	" let s:bidx = len(g:bufmru_bnrs) - 1
	let s:bidx = 0
	echohl WarningMsg
	echo "At start buffer"
	echohl None
    endif
endfunc "}}}

" check if ignoring the FileType event should be started now
func! s:check_start_ei() "{{{
    if !s:start_ei
	return
    endif
    let s:start_ei = 0
    if s:quitnormal
	set eventignore+=FileType
	let s:quitnormal = 0
    endif
endfunc "}}}

func! <sid>idxz() "{{{
    let s:noautocmd = 1
    let s:bstart = bufnr("")
    let s:switch_ok = 1
    let s:start_ei = g:bufmru_lazy_filetype && !&hidden
    let s:did_bufread = 0

    let s:bidx = 1
    let len = len(g:bufmru_bnrs)
    if s:bidx >= len
	let s:bidx = 0
	echohl WarningMsg
	echo "Only one MRU buffer"
	echohl None
    endif
endfunc "}}}

func! <sid>buf() "{{{
    let oldbnr = bufnr("")
    let bnr = s:bnr()
    let s:did_bufread = s:did_bufread && oldbnr == bnr
    let s:switch_ok = 1
    try
	if &buftype != '' || &previewwindow
	    " special buffer
	    exec "sbuf" bnr
	elseif g:bufmru_confclose
	    exec "conf buf" bnr
	else
	    try
		exec "buf" bnr
	    catch /:E37:/
		echoerr "bufmru: No write since last change (press ! to override)"
	    endtry
	endif
	if &lazyredraw
	    redraw
	endif
    catch
	let s:switch_ok = 0
	echohl ErrorMsg
	echomsg matchstr(v:exception, ':\zs.*')
	echohl none
    endtry
endfunc "}}}

func! <sid>bang() "{{{
    let bnr = s:bnr()
    exec "buf!" bnr
    if &lazyredraw
	redraw
    endif
    let s:switch_ok = 1
endfunc "}}}

func! <sid>yank() "{{{
    let bnr = s:bnr()
    let fname = fnamemodify(bufname(bnr), ":p")
    let @@ = fname
    let cmd = "let @@ = '". fname. "'"
    call s:fitecho(cmd)
endfunc "}}}

func! <sid>reset(accept) "{{{
    call s:maketop(bufnr(""))
    let s:noautocmd = 0
    if !s:quitnormal
	set eventignore-=FileType
	let s:quitnormal = 1
	if a:accept || bufnr("") == s:bstart
	    if exists("g:did_load_filetypes") && s:did_bufread
		filetype detect
		" echohl TODO
		" echo "did :filetype detect"
		" echohl None
		" sleep 500m
	    endif
	endif
    endif
    if !a:accept
	" try to go back, no matter if this doesn't work:
	exec "buf!" s:bstart
	" no :redraw, mode will end soon
    endif
    if !s:switch_ok
	" remove the error message suggesting the overriding
	exec "norm! :\<C-U>"
    endif
endfunc "}}}

" general functions:
func! s:fitecho(str) "{{{
    echo s:truncstr(a:str, s:cmdline_width())
endfunc "}}}
func! s:cmdline_width() "{{{
    let showcmd_off = &sc ? 11 : 0
    let laststatus_off = &ls==0 ? 19 : &ls==2 ? 0 : winnr('$')==1 ? 19 : 0
    return &columns - showcmd_off - laststatus_off - 1
    " default 'rulerformat' assumed
endfunc "}}}
func! s:truncstr(str, maxlen) "{{{
    let len = strlen(a:str)
    if len > a:maxlen
	let amountl = (a:maxlen / 2) - 2
	let amountr = a:maxlen - amountl - 3
	let lpart = strpart(a:str, 0, amountl)
	let rpart = strpart(a:str, len-amountr)
	return strpart(lpart. '...'. rpart, 0, a:maxlen)
    else
	return a:str
    endif
endfunc "}}}

func! s:initbnrs() "{{{
    au! bufmru VimEnter
    if g:bufmru_read_nummarks
	call Bufmru_Read_Nummarks()
    endif
    if bufnr("#") >= 1
	call s:maketop(bufnr("#"))
    endif
    call s:maketop(bufnr(""))
endfunc "}}}

" Do Init: {{{1
let s:noautocmd = 0
let s:quitnormal = 1	" only for g:bufmru_lazy_filetype=1

if empty(g:bufmru_bnrs)
    if has("vim_starting")
	au! bufmru VimEnter * call s:initbnrs()
    else
	call s:initbnrs()
    endif
endif


" Cpo: {{{1
let &cpo = s:sav_cpo
unlet s:sav_cpo
"}}}
" vim:ts=8:sts=4:sw=4:noet:fdm=marker:
