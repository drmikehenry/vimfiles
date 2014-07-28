"=============================================================================
" vim-oop
" OOP Support for Vim script
"
" File    : oop/module.vim
" Author  : h1mesuke <himesuke+vim@gmail.com>
" Updated : 2012-01-26
" Version : 0.3.0
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

let s:save_cpo = &cpo
set cpo&vim

let s:TYPE_NUM  = type(0)

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

"-----------------------------------------------------------------------------
" Module

function! unittest#oop#module#new(name, sid)
  let module = copy(s:Module)
  let module.name = a:name
  let sid = (type(a:sid) == s:TYPE_NUM ? a:sid : matchstr(a:sid, '\d\+'))
  let module.__prefix__ = printf('<SNR>%d_%s_', sid, a:name)
  "=> <SNR>10_Fizz_
  let module.__export__ = []
  return module
endfunction

let s:Module = copy(unittest#oop#__constant__('Object'))
let s:Module[unittest#oop#__constant__('OBJECT_MARK')] = unittest#oop#__constant__('TYPE_MODULE')

function! s:Module_function(func_name, ...) dict
  let func_name = self.__prefix__ . a:func_name
  call call(self.__bind__, [func_name] + a:000, self)
endfunction
let s:Module.function = function(s:SID . 'Module_function')

let &cpo = s:save_cpo
