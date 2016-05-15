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

" fuzzy abbreviation matcher for Unite

let s:save_cpo = &cpo
set cpo&vim

function! unite#filters#matcher_abbrev#define() "{{{
if exists('g:loaded_abbrev_matcher')
  return s:matcher
else
  echoerr 'matcher_abbrev (Unite): plugin not loaded'
  return {}
endif
endfunction "}}}


let s:matcher = {
      \ 'name' : 'matcher_abbrev',
      \ 'description' : 'abbrev matcher',
      \}

function! s:matcher.pattern(input) "{{{
  python import abbrev_matcher_vim
  let regex =  pyeval(printf('abbrev_matcher_vim.highlight_regex("%s")', a:input))
  return regex
endfunction "}}}

function! s:matcher.filter(candidates, context) "{{{
  if a:context.input == ''
    return unite#filters#filter_matcher(
          \ a:candidates, '', a:context)
  endif

  python import abbrev_matcher_vim

  for input in a:context.input_list
    if input == '!' || input == ''
      continue
    elseif input =~ '^:'
      " Executes command.
      let a:context.execute_command = input[1:]
      continue
    endif

    python abbrev_matcher_vim.filter_unite()
  endfor

  return a:candidates
endfunction"}}}


let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
