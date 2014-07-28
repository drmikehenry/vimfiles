"=============================================================================
" Unit Testing Framework for Vim script
"
" File    : plugin/unittest.vim
" Author  : h1mesuke <himesuke+vim@gmail.com>
" Updated : 2012-01-26
" Version : 0.6.0
" License : MIT license {{{
"
"   Permission is hereby granted, free of charge, to any person obtaining
"   a copy of this software and associated documentation files (the
"   "Software"), to deal in the Software without restriction, including
"   without limitation the rights to use, copy, modify, merge, publish,
"   distribute, sublicense, and/or sell copies of the Software, and to
"   permit persons to whom the Software is furnished to do so, subject to
"   the following conditions:
"
"   The above copyright notice and this permission notice shall be included
"   in all copies or substantial portions of the Software.
"
"   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"   OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

if &cp || (exists('g:loaded_unittest') && g:loaded_unittest)
  finish
elseif v:version < 702
  echoerr "unittest: Vim 7.2 or later required."
  finish
endif
let g:loaded_unittest = 1

"-----------------------------------------------------------------------------
" Variables

if !exists('g:unittest_color_red')
  let g:unittest_color_red = "DarkRed"
endif

if !exists('g:unittest_color_green')
  let g:unittest_color_green = "Green"
endif

if !exists('g:unittest_color_pending')
  let g:unittest_color_pending = "DarkYellow"
endif

"-----------------------------------------------------------------------------
" Command

command! -nargs=* -complete=file UnitTest call unittest#run(<f-args>)
