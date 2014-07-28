"=============================================================================
" vim-oop
" OOP Support for Vim script
"
" File    : oop.vim
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

let s:TYPE_LIST = type([])
let s:TYPE_DICT = type({})
let s:TYPE_FUNC = type(function('tr'))

let s:OBJECT_MARK = '__vim_oop__'
let s:TYPE_OBJECT = 1
let s:TYPE_CLASS  = 2
let s:TYPE_MODULE = 3

function! unittest#oop#__constant__(name)
  return get(s:, a:name)
endfunction

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

function! unittest#oop#is_object(value)
  return type(a:value) == s:TYPE_DICT && has_key(a:value, s:OBJECT_MARK)
endfunction

function! unittest#oop#is_class(value)
  return type(a:value) == s:TYPE_DICT &&
        \ get(a:value, s:OBJECT_MARK, 0) == s:TYPE_CLASS
endfunction

function! unittest#oop#is_instance(value)
  return type(a:value) == s:TYPE_DICT &&
        \ get(a:value, s:OBJECT_MARK, 0) == s:TYPE_OBJECT
endfunction

function! unittest#oop#is_module(value)
  return type(a:value) == s:TYPE_DICT &&
        \ get(a:value, s:OBJECT_MARK, 0) == s:TYPE_MODULE
endfunction

function! unittest#oop#serialize(value)
  let value = a:value
  let type = type(a:value)
  if type == s:TYPE_LIST || type == s:TYPE_DICT
    let value = deepcopy(a:value)
    call s:demote(value)
  endif
  return string(value)
endfunction

function! s:demote(value)
  let type = type(a:value)
  if type == s:TYPE_DICT && has_key(a:value, s:OBJECT_MARK)
    if a:value[s:OBJECT_MARK] == s:TYPE_OBJECT
      let a:value.class = a:value.class.name
      call filter(a:value, 'type(v:val) != s:TYPE_FUNC')
    else
      throw "vim-oop: Class and module are not serializable."
    endif
  endif
  if type == s:TYPE_LIST || type == s:TYPE_DICT
    call map(a:value, 's:demote(v:val)')
  endif
  return a:value
endfunction

function! unittest#oop#deserialize(str, loader)
  let cache = {}
  sandbox let dict = eval(a:str)
  return s:promote(dict, a:loader, cache)
endfunction

function! s:promote(value, loader, cache)
  let type = type(a:value)
  if type == s:TYPE_LIST || type == s:TYPE_DICT
    call map(a:value, 's:promote(v:val, a:loader, a:cache)')
  endif
  if type == s:TYPE_DICT && has_key(a:value, s:OBJECT_MARK)
    let name = a:value.class
    if has_key(a:cache, name)
      let class = a:cache[name]
    else
      let class = call(a:loader, [name])
      let a:cache[name] = class
    endif
    call class.__promote__(a:value)
  endif
  return a:value
endfunction

function! unittest#oop#string(value)
  let value = a:value
  let type = type(a:value)
  if type == s:TYPE_LIST || type == s:TYPE_DICT
    let value = deepcopy(a:value)
    call s:unlink(value, 1)
  endif
  return string(value)
endfunction

function! s:unlink(value, ...)
  let start = (a:0 ? a:1 : 0)
  let type = type(a:value)
  if !start && type == s:TYPE_DICT
    let obj_type = get(a:value, s:OBJECT_MARK, 0)
    if obj_type == s:TYPE_CLASS
      return '<<Reference: class ' . a:value.name . '>>'
    elseif obj_type == s:TYPE_MODULE
      return '<<Reference: module ' . a:value.name . '>>'
    else
      call filter(a:value, 'type(v:val) != s:TYPE_FUNC')
    endif
  endif
  if type == s:TYPE_LIST || type == s:TYPE_DICT
    call map(a:value, 's:unlink(v:val)')
  endif
  return a:value
endfunction

"-----------------------------------------------------------------------------
" Object

let s:Object = {}
let s:Object[s:OBJECT_MARK] = s:TYPE_OBJECT

function! s:Object_bind(func, ...) dict
  if type(a:func) == s:TYPE_FUNC
    let Func = a:func
    let meth_name = a:1
  else
    let Func = function(a:func)
    let meth_name = (a:0 ? a:1 : s:remove_prefix(a:func))
  endif
  let self[meth_name] = Func
  if has_key(self, '__export__')
    call add(self.__export__, meth_name)
  endif
endfunction
let s:Object.__bind__ = function(s:SID . 'Object_bind')

function! s:remove_prefix(func_name)
  return substitute(a:func_name, '^<SNR>\d\+_\%(\u[^_]*_\)\+', '', '')
endfunction

function! s:Object_alias(alias, meth_name) dict
  if has_key(self, a:meth_name) && type(self[a:meth_name]) == s:TYPE_FUNC
    let self[a:alias] = self[a:meth_name]
    if has_key(self, '__export__')
      call add(self.__export__, a:alias)
    endif
  else
    throw "vim-oop: " . a:meth_name . "() is not defined."
  endif
endfunction
let s:Object.alias = function(s:SID . 'Object_alias')

function! s:Object_extend(module, ...) dict
  let mode = (a:0 ? a:1 : 'force')
  let exported = {}
  for func_name in a:module.__export__
    let exported[func_name] = a:module[func_name]
  endfor
  call extend(self, exported, mode)
endfunction
let s:Object.extend = function(s:SID . 'Object_extend')

let &cpo = s:save_cpo
