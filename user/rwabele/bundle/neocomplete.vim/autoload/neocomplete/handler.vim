"=============================================================================
" FILE: handler.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! neocomplete#handler#_on_moved_i() "{{{
  let neocomplete = neocomplete#get_current_neocomplete()
  if neocomplete.linenr != line('.')
    call neocomplete#helper#clear_result()
  endif
  let neocomplete.linenr = line('.')

  call s:close_preview_window()
endfunction"}}}
function! neocomplete#handler#_on_insert_enter() "{{{
  if !neocomplete#is_enabled()
    return
  endif

  let neocomplete = neocomplete#get_current_neocomplete()
  if neocomplete.linenr != line('.')
    call neocomplete#helper#clear_result()
  endif
  let neocomplete.linenr = line('.')

  if &l:foldmethod ==# 'expr' && foldlevel('.') != 0
    foldopen
  endif
endfunction"}}}
function! neocomplete#handler#_on_insert_leave() "{{{
  call neocomplete#helper#clear_result()

  call s:close_preview_window()
  call s:make_cache_current_line()

  let neocomplete = neocomplete#get_current_neocomplete()
  let neocomplete.cur_text = ''
  let neocomplete.completed_item = {}
  let neocomplete.overlapped_items = {}
endfunction"}}}
function! neocomplete#handler#_on_write_post() "{{{
  " Restore foldinfo.
  for winnr in filter(range(1, winnr('$')),
        \ "!empty(getwinvar(v:val, 'neocomplete_foldinfo'))")
    let neocomplete_foldinfo =
          \ getwinvar(winnr, 'neocomplete_foldinfo')
    call setwinvar(winnr, '&foldmethod',
          \ neocomplete_foldinfo.foldmethod)
    call setwinvar(winnr, '&foldexpr',
          \ neocomplete_foldinfo.foldexpr)
    call setwinvar(winnr,
          \ 'neocomplete_foldinfo', {})
  endfor
endfunction"}}}
" @vimlint(EVL102, 1, v:completed_item)
function! neocomplete#handler#_on_complete_done() "{{{
  let neocomplete = neocomplete#get_current_neocomplete()

  " Get cursor word.
  if exists('v:completed_item')
    " Use v:completed_item feature.
    if empty(v:completed_item)
      return
    endif

    let complete_str = v:completed_item.word
    if complete_str == ''
      return
    endif

    if (v:completed_item.abbr != ''
          \ && len(v:completed_item.word) < len(v:completed_item.abbr))
          \ || v:completed_item.info != ''
      let neocomplete.completed_item = v:completed_item
    endif
  else
    let cur_text = matchstr(getline('.'), '^.*\%'.col('.').'c')
    let complete_str = neocomplete#helper#match_word(cur_text)[1]
    if complete_str == ''
      " Use default keyword pattern.
      let complete_str = matchstr(cur_text, '\h\w*\(()\?\)\?$')
      if complete_str == ''
        return
      endif
    endif

    let candidates = filter(copy(neocomplete.candidates),
          \   "v:val.word ==# complete_str &&
          \    ((get(v:val, 'abbr', '') != '' &&
          \     v:val.word !=# v:val.abbr && v:val.abbr[-1] != '~') ||
          \     get(v:val, 'info', '') != '')")
    if !empty(candidates)
      let neocomplete.completed_item = candidates[0]
    endif
  endif

  " Restore overlapped item
  if exists('v:completed_item') &&
        \ has_key(neocomplete.overlapped_items, complete_str)
    " Move cursor
    call cursor(0, col('.') - len(complete_str) +
          \ len(neocomplete.overlapped_items[complete_str]))

    let complete_str = neocomplete.overlapped_items[complete_str]
  endif

  let frequencies = neocomplete#variables#get_frequencies()
  if !has_key(frequencies, complete_str)
    let frequencies[complete_str] = 20
  else
    let frequencies[complete_str] += 20
  endif

  " indent line matched by indentkeys
  for word in filter(map(split(&l:indentkeys, ','),
        \ "matchstr(v:val, '.*=\\zs.*')"), "v:val != ''")
    if stridx(complete_str, word) == 0
      call neocomplete#helper#indent_current_line()
    endif
  endfor
endfunction"}}}
" @vimlint(EVL102, 0, v:completed_item)
function! neocomplete#handler#_change_update_time() "{{{
  if &updatetime > g:neocomplete#cursor_hold_i_time
    " Change updatetime.
    let neocomplete = neocomplete#get_current_neocomplete()
    let neocomplete.update_time_save = &updatetime
    let &updatetime = g:neocomplete#cursor_hold_i_time
  endif
endfunction"}}}
function! neocomplete#handler#_restore_update_time() "{{{
  let neocomplete = neocomplete#get_current_neocomplete()
  if &updatetime < neocomplete.update_time_save
    " Restore updatetime.
    let &updatetime = neocomplete.update_time_save
  endif
endfunction"}}}
function! neocomplete#handler#_on_insert_char_pre() "{{{
  if neocomplete#is_cache_disabled()
    return
  endif

  let neocomplete = neocomplete#get_current_neocomplete()
  if neocomplete.old_char != ' ' && v:char == ' ' && v:count == 0
    call s:make_cache_current_line()
  endif

  let neocomplete.old_char = v:char
endfunction"}}}
function! neocomplete#handler#_on_text_changed() "{{{
  if neocomplete#is_cache_disabled()
    return
  endif

  if getline('.') == ''
    call s:make_cache_current_line()
  endif
endfunction"}}}

function! neocomplete#handler#_do_auto_complete(event) "{{{
  if s:check_in_do_auto_complete()
    return
  endif

  let neocomplete = neocomplete#get_current_neocomplete()
  let neocomplete.skipped = 0
  let neocomplete.event = a:event

  let cur_text = neocomplete#get_cur_text(1)

  call neocomplete#print_debug('cur_text = ' . cur_text)

  try
    " Prevent infinity loop.
    if s:is_skip_auto_complete(cur_text)
      call neocomplete#print_debug('Skipped.')
      return
    endif

    if neocomplete#helper#is_omni(cur_text)
          \ && neocomplete.old_cur_text !=# cur_text
      call s:complete_key("\<Plug>(neocomplete_start_omni_complete)")
      return
    endif

    " Check multibyte input or eskk or spaces.
    " Note: Spaces are skipped by performance problem.
    if cur_text =~ '^\s*$\|\s\+$'
          \ || neocomplete#is_eskk_enabled()
          \ || neocomplete#is_multibyte_input(cur_text)
      call neocomplete#print_debug('Skipped.')
      return
    endif

    " Check complete position.
    let complete_sources = neocomplete#complete#_set_results_pos(cur_text)
    if empty(complete_sources)
      call neocomplete#print_debug('Skipped.')
      return
    endif

    " Check previous position
    let complete_pos = neocomplete#complete#_get_complete_pos(complete_sources)
    if neocomplete.skip_next_complete
          \ && complete_pos == neocomplete.old_complete_pos
          \ && stridx(cur_text, neocomplete.old_cur_text) == 0
      " Same position.
      return
    endif
  finally
    let neocomplete.old_cur_text = cur_text
    let neocomplete.old_linenr = line('.')
  endtry

  let neocomplete.skip_next_complete = 0
  let neocomplete.old_complete_pos = complete_pos

  let &l:completefunc = 'neocomplete#complete#auto_complete'

  if neocomplete#is_prefetch()
    " Do prefetch.
    let neocomplete.complete_sources =
          \ neocomplete#complete#_get_results(cur_text)

    if empty(neocomplete.complete_sources)
      if !empty(g:neocomplete#fallback_mappings)
            \ && len(matchstr(cur_text, '\h\w*$'))
            \   > g:neocomplete#auto_completion_start_length
        let key = ''
        for i in range(0, len(g:neocomplete#fallback_mappings)-1)
          let key .= '<C-r>=neocomplete#mappings#fallback(' . i . ')<CR>'
        endfor
        execute 'inoremap <silent> <Plug>(neocomplete_fallback)' key

        " Fallback to omnifunc
        call s:complete_key("\<Plug>(neocomplete_fallback)")
      else
        call neocomplete#print_debug('Skipped.')
        return
      endif
      return
    endif
  endif

  " Start auto complete.
  call s:complete_key("\<Plug>(neocomplete_start_auto_complete)")
endfunction"}}}

function! s:check_in_do_auto_complete() "{{{
  if neocomplete#is_locked()
    return 1
  endif

  if &l:completefunc == ''
    let &l:completefunc = 'neocomplete#complete#manual_complete'
  endif

  " Detect completefunc.
  if &l:completefunc !~# '^neocomplete#'
    if &l:buftype =~ 'nofile'
      return 1
    endif

    if g:neocomplete#force_overwrite_completefunc
      " Set completefunc.
      let &l:completefunc = 'neocomplete#complete#manual_complete'
    else
      " Warning.
      redir => output
      99verbose setl completefunc?
      redir END
      call neocomplete#print_error(output)
      call neocomplete#print_error(
            \ 'Another plugin set completefunc! Disabled neocomplete.')
      NeoCompleteLock
      return 1
    endif
  endif

  " Detect AutoComplPop.
  if exists('g:acp_enableAtStartup') && g:acp_enableAtStartup
    call neocomplete#print_error(
          \ 'Detected enabled AutoComplPop! Disabled neocomplete.')
    NeoCompleteLock
    return 1
  endif
endfunction"}}}
function! s:is_skip_auto_complete(cur_text) "{{{
  let neocomplete = neocomplete#get_current_neocomplete()

  if (a:cur_text == neocomplete.old_cur_text
        \     && line('.') == neocomplete.old_linenr)
        \ || (g:neocomplete#lock_iminsert && &l:iminsert)
        \ || (&l:formatoptions =~# '[tca]' && &l:textwidth > 0
        \     && strwidth(a:cur_text) >= &l:textwidth)
    let neocomplete.skip_next_complete = 0
    return 1
  endif

  if !neocomplete.skip_next_complete
    return 0
  endif

  " Check delimiter pattern.
  let is_delimiter = 0
  let filetype = neocomplete#get_context_filetype()

  for delimiter in ['/', '.'] +
        \ get(g:neocomplete#delimiter_patterns, filetype, [])
    if stridx(a:cur_text, delimiter,
          \ len(a:cur_text) - len(delimiter)) >= 0
      let is_delimiter = 1
      break
    endif
  endfor

  if is_delimiter && neocomplete.skip_next_complete == 2
    let neocomplete.skip_next_complete = 0
  endif

  return 0
endfunction"}}}
function! s:close_preview_window() "{{{
  if g:neocomplete#enable_auto_close_preview
        \ && bufname('%') !=# '[Command Line]'
        \ && winnr('$') != 1 && !&l:previewwindow
        \ && !s:check_in_do_auto_complete()
    " Close preview window.
    pclose!
  endif
endfunction"}}}
function! s:make_cache_current_line() "{{{
  let neocomplete = neocomplete#get_current_neocomplete()
  if neocomplete#helper#is_enabled_source('buffer',
        \ neocomplete.context_filetype)
    " Caching current cache line.
    call neocomplete#sources#buffer#make_cache_current_line()
  endif
  if neocomplete#helper#is_enabled_source('member',
        \ neocomplete.context_filetype)
    " Caching current cache line.
    call neocomplete#sources#member#make_cache_current_line()
  endif
endfunction"}}}

function! s:complete_key(key) "{{{
  set completeopt-=longest
  call neocomplete#helper#complete_configure()
  call feedkeys(a:key)
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
