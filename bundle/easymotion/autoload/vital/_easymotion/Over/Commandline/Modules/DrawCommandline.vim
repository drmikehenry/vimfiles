scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:module = {
\	"name" : "DrawCommandline"
\}

let s:cmdheight = {}

function! s:cmdheight.save()
	if has_key(self, "value")
		return
	endif
	let self.value = &cmdheight
endfunction

function! s:cmdheight.restore()
	if has_key(self, "value")
		let &cmdheight = self.value
		unlet self.value
	endif
endfunction


function! s:cmdheight.get()
	return self.value
endfunction


function! s:suffix(left, suffix)
	let left_len = strdisplaywidth(a:left)
	let len = &columns - left_len % &columns
	let len = len + (&columns * (strdisplaywidth(a:suffix) > (len - 1))) - 1
	return repeat(" ", len - strdisplaywidth(a:suffix)) . a:suffix
" 	return printf("%" . len . "S", a:suffix)
endfunction


let s:old_width = 0
function! s:_redraw(cmdline)
	let left = a:cmdline.get_prompt() . a:cmdline.getline() . (empty(a:cmdline.line.pos_word()) ? " " : "")
	let width = len(left) + 1

	if	a:cmdline.get_suffix() != ""
		let width += len(s:suffix(left, a:cmdline.get_suffix())) - 1
	endif

	if &columns >= width && &columns <= s:old_width && s:old_width >= width
		redraw
		normal! :
	elseif &columns <= width
		normal! :
	else
		redraw
	endif
	let s:old_width = width

	call s:cmdheight.save()
	let height = max([(width - 1) / (&columns) + 1, s:cmdheight.get()])
	if height > &cmdheight || &cmdheight > height
		let &cmdheight = height
		redraw
	endif
endfunction


function! s:_as_echon(str)
	return "echon " . strtrans(string(a:str))
endfunction


function! s:module.on_draw_pre(cmdline)
	if empty(a:cmdline.line.pos_word())
		let cursor = "echohl " . a:cmdline.highlights.cursor . " | echon ' '"
	else
		let cursor = "echohl " . a:cmdline.highlights.cursor_on . " | " . s:_as_echon(a:cmdline.line.pos_word())
	endif
	let suffix = ""
	if	a:cmdline.get_suffix() != ""
		let suffix = s:_as_echon(s:suffix(a:cmdline.get_prompt() . a:cmdline.getline() . repeat(" ", empty(a:cmdline.line.pos_word())), a:cmdline.get_suffix()))
	endif
	let self.draw_command  = join([
\		"echohl " . a:cmdline.highlights.prompt,
\		s:_as_echon(a:cmdline.get_prompt()),
\		"echohl NONE",
\		s:_as_echon(a:cmdline.backward()),
\		cursor,
\		"echohl NONE",
\		s:_as_echon(a:cmdline.forward()),
\		suffix,
\	], " | ")

	call s:_redraw(a:cmdline)
endfunction


function! s:_echon(expr)
	echon strtrans(a:expr)
endfunction


function! s:module.on_draw(cmdline)
	execute self.draw_command
" 	execute "echohl" a:cmdline.highlights.prompt
" 	call s:echon(a:cmdline.get_prompt())
" 	echohl NONE
" 	call s:echon(a:cmdline.backward())
" 	if empty(a:cmdline.line.pos_word())
" 		execute "echohl" a:cmdline.highlights.cursor
" 		call s:echon(' ')
" 	else
" 		execute "echohl" a:cmdline.highlights.cursor_on
" 		call s:echon(a:cmdline.line.pos_word())
" 	endif
" 	echohl NONE
" 	call s:echon(a:cmdline.forward())
" 	if	a:cmdline.get_suffix() != ""
" 		call s:echon(s:suffix(a:cmdline.get_prompt() . a:cmdline.getline() . repeat(" ", empty(a:cmdline.line.pos_word())), a:cmdline.get_suffix()))
" 	endif
endfunction


function! s:module.on_execute_pre(...)
	call s:cmdheight.restore()
endfunction


function! s:module.on_leave(...)
	call s:cmdheight.restore()
endfunction


function! s:make()
	return deepcopy(s:module)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo