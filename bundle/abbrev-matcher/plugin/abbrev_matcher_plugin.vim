
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

" fuzzy abbreviation matcher

let s:save_cpo = &cpo
set cpo&vim

if exists("g:loaded_abbrev_matcher")
  finish
endif

if !has('python')
  echoerr 'abbrev_matcher: you need vim compiled with +python support'
  finish
endif

if !exists('g:abbrev_matcher_grep_exe')
    let g:abbrev_matcher_grep_exe = has('win32') ? 'grep.exe' : 'grep'
endif

if !exists('g:abbrev_matcher_grep_args')
    let g:abbrev_matcher_grep_args = '-E -n'
endif


let g:loaded_abbrev_matcher = 1
let &cpo = s:save_cpo
