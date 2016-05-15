"
" The MIT License (MIT)
" Copyright (c) 2015 Sergei Dyshel
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in all
" copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
" SOFTWARE.
" ==========================================================================

" Unite sorter to use with 'matcher_abbrev'

let s:save_cpo = &cpo
set cpo&vim

function! unite#filters#sorter_abbrev#define()
  if exists('g:loaded_abbrev_matcher')
    return s:sorter
  else
    echoerr 'sorter_abbrev (Unite): plugin not loaded'
    return {}
  endif
endfunction

let s:sorter = {
      \ 'name' : 'sorter_abbrev',
      \ 'description' : 'sort by abbrev ranking',
      \}

let s:plugin_path = escape(expand('<sfile>:p:h'), '\')

function! s:sorter.filter(candidates, context)
  if a:context.input == '' || !has('float') || empty(a:candidates)
    return a:candidates
  endif

  let candidate = a:candidates[0]
  let is_file = 0
  if has_key(candidate, 'kind')
    let kind = candidate.kind
    let is_file = ((type(kind) == type("") && (kind == 'file'))
          \ || ((type(kind) == type([])) && (index(kind, 'file') >= 0)))
  endif

  python import abbrev_matcher_vim
  python abbrev_matcher_vim.sort_unite()

  return unite#util#sort_by(a:candidates, 'v:val.filter__rank')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
