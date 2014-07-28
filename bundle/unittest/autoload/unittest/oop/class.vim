"=============================================================================
" vim-oop
" OOP Support for Vim script
"
" File    : oop/class.vim
" Author  : h1mesuke <himesuke@gmail.com>
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
let s:TYPE_FUNC = type(function('tr'))

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

"-----------------------------------------------------------------------------
" Class

function! unittest#oop#class#new(name, sid, ...)
  let class = copy(s:Class)
  let class.name = a:name
  let sid = (type(a:sid) == s:TYPE_NUM ? a:sid : matchstr(a:sid, '\d\+'))
  let class.__prefix__ = printf('<SNR>%d_%s_', sid, a:name)
  "=> <SNR>10_Foo_
  let class.superclass = (a:0 ? a:1 : {})
  let class.__prototype__ = copy(s:Instance)
  let class.__prototype__.superclass =
        \ (empty(class.superclass) ? {} : class.superclass.__prototype__)
  let class.__super__ = {}
  let class.__prototype__.__super__ = {}
  " Inherit methods from superclasses.
  for klass in class.ancestors()
    call extend(class, klass, 'keep')
    call extend(class.__prototype__, klass.__prototype__, 'keep')
  endfor
  return class
endfunction

function! unittest#oop#class#xnew(...)
  let class = call('unittest#oop#class#new', a:000)
  let class.__instanciator__ = 'extend'
  return class
endfunction

let s:Class = copy(unittest#oop#__constant__('Object'))
let s:Class[unittest#oop#__constant__('OBJECT_MARK')] = unittest#oop#__constant__('TYPE_CLASS')
let s:Class.__instanciator__ = 'copy'

function! s:Class_ancestors() dict
  let ancestors = []
  let klass = self.superclass
  while !empty(klass)
    call add(ancestors, klass)
    let klass = klass.superclass
  endwhile
  return ancestors
endfunction
let s:Class.ancestors = function(s:SID . 'Class_ancestors')

function! s:Class_is_descendant_of(class) dict
  return index(self.ancestors(), a:class) >= 0
endfunction
let s:Class.is_descendant_of = function(s:SID . 'Class_is_descendant_of')

let s:Class.__class_bind__ = s:Class.__bind__

function! s:Class_class_method(func_name, ...) dict
  let func_name = self.__prefix__ . a:func_name
  call call(self.__class_bind__, [func_name] + a:000, self)
endfunction
let s:Class.class_method = function(s:SID . 'Class_class_method')

let s:Class.class_alias = s:Class.alias

function! s:Class_bind(...) dict
  call call(self.__prototype__.__bind__, a:000, self.__prototype__)
endfunction
let s:Class.__bind__ = function(s:SID . 'Class_bind')

function! s:Class_method(func_name, ...) dict
  let func_name = self.__prefix__ . a:func_name
  call call(self.__bind__, [func_name] + a:000, self)
endfunction
let s:Class.method = function(s:SID . 'Class_method')

function! s:Class_alias(...) dict
  call call(self.__prototype__.alias, a:000, self.__prototype__)
endfunction
let s:Class.alias = function(s:SID . 'Class_alias')

function! s:Class_include(...) dict
  call call(self.__prototype__.extend, a:000, self.__prototype__)
endfunction
let s:Class.include = function(s:SID . 'Class_include')

function! s:Class_new(...) dict
  if self.__instanciator__ ==# 'extend'
    let obj = extend(a:000[0], self.__prototype__, 'keep')
    let args = a:000[1:-1]
  else
    let obj = copy(self.__prototype__)
    let args = a:000
  endif
  unlet obj.superclass
  unlet obj.__super__
  let obj.class = self
  call call(obj.initialize, args, obj)
  return obj
endfunction
let s:Class.new = function(s:SID . 'Class_new')

function! s:Class___promote__(attrs) dict
  let obj = extend(a:attrs, self.__prototype__, 'keep')
  unlet obj.superclass
  unlet obj.__super__
  let obj.class = self
  return obj
endfunction
let s:Class.__promote__ = function(s:SID . 'Class___promote__')

function! s:Class_super(meth_name, args, self) dict
  let scope = (unittest#oop#is_class(a:self) ? self : self.__prototype__)
  if has_key(scope.__super__, a:meth_name)
    return call(scope.__super__[a:meth_name], a:args, a:self)
  endif
  let Meth = scope[a:meth_name]
  let meth_table = scope.superclass
  while !empty(meth_table)
    if has_key(meth_table, a:meth_name)
      let Super = meth_table[a:meth_name]
      if Super != Meth
        let scope.__super__[a:meth_name] = Super
        return call(Super, a:args, a:self)
      endif
    endif
    let meth_table = meth_table.superclass
  endwhile
  throw "vim-oop: " . a:meth_name . "()'s super implementation was not found."
endfunction
let s:Class.super = function(s:SID . 'Class_super')

"-----------------------------------------------------------------------------
" Instance

let s:Instance = copy(unittest#oop#__constant__('Object'))

function! s:Instance_initialize(...) dict
endfunction
let s:Instance.initialize = function(s:SID . 'Instance_initialize')

function! s:Instance_is_kind_of(class) dict
  return (self.class is a:class || self.class.is_descendant_of(a:class))
endfunction
let s:Instance.is_kind_of = function(s:SID . 'Instance_is_kind_of')
let s:Instance.is_a = function(s:SID . 'Instance_is_kind_of')

function! s:Instance_serialize() dict
  return unittest#oop#serialize(self)
endfunction
let s:Instance.serialize = function(s:SID . 'Instance_serialize')

let &cpo = s:save_cpo
