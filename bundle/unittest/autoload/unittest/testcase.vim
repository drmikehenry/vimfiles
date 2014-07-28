"=============================================================================
" Unit Testing Framework for Vim script
"
" File    : autoload/unittest/testcase.vim
" Author  : h1mesuke <himesuke+vim@gmail.com>
" Updated : 2012-04-02
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

let s:save_cpo = &cpo
set cpo&vim

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

"-----------------------------------------------------------------------------
" TestCase

let s:queue = []

function! unittest#testcase#take()
  let tcs = s:queue
  let s:queue = []
  return tcs
endfunction

nnoremap <silent> <Plug>(unittest-testcase-queue-clear) :<C-u>call <SID>clear()<CR>

function! s:clear()
  if !empty(s:queue)
    call unittest#print_error("unittest: Don't source a testcase directly, " .
          \ "please use :UnitTest command.")
    let s:queue = []
  endif
endfunction

function! unittest#testcase#class()
  return s:TestCase
endfunction

function! unittest#testcase#new(...)
  return call(s:TestCase.new, a:000, s:TestCase)
endfunction

let s:TestCase = unittest#oop#class#new('TestCase', s:SID)
call s:TestCase.include(unittest#assertions#module())

function! s:TestCase_initialize(name, ...) dict
  let self.name = a:name
  let self.__context__ = s:Context.new(a:0 ? a:1 : {})
  let self.data = self.__context__.data
  let self.__private__ = {}
  call add(s:queue, self)
  call feedkeys("\<Plug>(unittest-testcase-queue-clear)")
endfunction
call s:TestCase.method('initialize')

function! s:TestCase___SETUP__() dict
  let funcs = s:get_funcs(self)
  let tests = s:grep(funcs, '\%(^test\|\%(^\|[^_]_\)should\)_')
  let tests = s:grep(tests, '^\%(\%(assert\|setup\|teardown\)_\)\@!')
  let self.__private__.tests = sort(tests)

  let setups = sort(s:grep(funcs, '^setup_'), 's:compare_strlen')
  let self.__private__.setup_suffixes = s:map_matchstr(setups, '^setup_\zs.*$')

  let teardowns = reverse(sort(s:grep(funcs, '^teardown_'), 's:compare_strlen'))
  let self.__private__.teardown_suffixes = s:map_matchstr(teardowns, '^teardown_\zs.*$')

  if self.__context__.data.is_given()
    call self.__open_data_window__()
  endif
  if has_key(self, 'SETUP')
    call self.SETUP()
  endif
endfunction
call s:TestCase.method('__SETUP__')

function! s:TestCase___tests__() dict
  return self.__private__.tests
endfunction
call s:TestCase.method('__tests__')

function! s:TestCase___open_data_window__() abort dict
  echomsg "__open_data_window__"
  let data_file = s:escape_file_pattern(self.__context__.data.file)
  if !bufexists(data_file)
    " The buffer doesn't exist.
    split
    hide edit `=self.__context__.data.file`
  elseif bufwinnr(data_file) != -1
    " The buffer exists, and it has a window.
    execute bufwinnr(data_file) 'wincmd w'
  else
    " The buffer exists, but it has no window.
    split
    execute 'buffer' bufnr(data_file)
  endif
  autocmd! * <buffer>
  autocmd BufWritePre <buffer>
        \ throw "InvalidDataWrite: Overwriting of the test data is prohibited."
endfunction
call s:TestCase.method('__open_data_window__')

function! s:TestCase___TEARDOWN__() dict
  if has_key(self, 'TEARDOWN')
    call self.TEARDOWN()
  endif
  if self.__context__.data.is_given()
    call self.__close_context_window__()
  endif
endfunction
call s:TestCase.method('__TEARDOWN__')

function! s:TestCase___close_context_window__() dict
  let data_file = s:escape_file_pattern(self.__context__.data.file)
  if bufwinnr(data_file) != -1
    execute bufwinnr(data_file) 'wincmd c'
  endif
endfunction
call s:TestCase.method('__close_context_window__')

function! s:TestCase___setup__(test) dict
  if has_key(self, 'setup')
    call self.setup()
  endif
  for suffix in self.__private__.setup_suffixes
    if substitute(a:test, '^test_', '', '') =~# '^'. suffix
      call call(self['setup_' . suffix], [], self)
    endif
  endfor
endfunction
call s:TestCase.method('__setup__')

function! s:TestCase___teardown__(test) dict
  for suffix in self.__private__.teardown_suffixes
    if substitute(a:test, '^test_', '', '') =~# '^'. suffix
      call call(self['teardown_' . suffix], [], self)
    endif
  endfor
  if has_key(self, 'teardown')
    call self.teardown()
  endif
  call self.__context__.revert()
endfunction
call s:TestCase.method('__teardown__')

function! s:TestCase_call(...) dict
  return call(self.__context__.call, a:000, self.__context__)
endfunction
call s:TestCase.method('call')

function! s:TestCase_exists(...) dict
  return call(self.__context__.exists, a:000, self.__context__)
endfunction
call s:TestCase.method('exists')

function! s:TestCase_get(...) dict
  return call(self.__context__.get, a:000, self.__context__)
endfunction
call s:TestCase.method('get')

function! s:TestCase_set(...) dict
  call call(self.__context__.set, a:000, self.__context__)
endfunction
call s:TestCase.method('set')

function! s:TestCase_save(...) dict
  call call(self.__context__.save, a:000, self.__context__)
endfunction
call s:TestCase.method('save')

function! s:TestCase_puts(...) dict
  call call(self.runner.puts, a:000, self.runner)
endfunction
call s:TestCase.method('puts')

"-----------------------------------------------------------------------------
" Context

let s:Context = unittest#oop#class#new('Context', s:SID)

function! s:Context_initialize(context) dict
  if has_key(a:context, 'sid')
    let self.sid = s:sid_prefix(a:context.sid)
  endif
  if has_key(a:context, 'scope')
    let self.scope = a:context.scope
  endif
  let self.data = s:Data.new(get(a:context, 'data', ''))
  let self.saved   = {}
  let self.defined = {}
endfunction
call s:Context.method('initialize')

function! s:sid_prefix(sid)
  let sid = (type(a:sid) == type(0) ? a:sid : matchstr(a:sid, '\d\+'))
  return printf('<SNR>%d_', sid)
endfunction

" call( {func}, {args} [, {dict}])
function! s:Context_call(func, args, ...) dict
  if a:func =~ '^s:'
    if !has_key(self, 'sid')
      throw "InvalidSIDAccess: Context SID is not given."
    endif
    let func = substitute(a:func, '^s:', self.sid, '')
  else
    let func = a:func
  endif
  if a:0
    let dict = a:1
    return call(func, a:args, dict)
  else
    return call(func, a:args)
  endif
endfunction
call s:Context.method('call')

function! s:Context_exists(expr) dict
  if a:expr =~ '^[bwtgs]:'
    let scope = self.get_scope_for(a:expr)
    let name = substitute(a:expr, '^\w:', '', '')
    return has_key(scope, name)
  else
    let expr = substitute(a:expr, '^*s:', '*' . self.sid, '')
    return exists(expr)
  endif
endfunction
call s:Context.method('exists')

" call( {name} [, {default}])
function! s:Context_get(name, ...) dict
  if a:name =~ '^[bwtgs]:'
    let scope = self.get_scope_for(a:name)
    let name = substitute(a:name, '^\w:', '', '')
    return get(scope, name, (a:0 ? a:1 : 0))
  elseif a:name =~ '^&\%([lg]:\)\='
    execute 'let value = ' . a:name
    return value
  endif
endfunction
call s:Context.method('get')

" call( {name}, {value} [, {save}])
function! s:Context_set(name, value, ...) dict
  let should_save = (a:0 ? a:1 : 1)
  if should_save
    call self.save(a:name)
  endif
  if a:name =~ '^[bwtgs]:'
    let scope = self.get_scope_for(a:name)
    let name = substitute(a:name, '^\w:', '', '')
    let scope[name] = a:value
  elseif a:name =~ '^&\%([lg]:\)\='
    execute 'let ' . a:name . ' = a:value'
  endif
endfunction
call s:Context.method('set')

function! s:Context_save(name) dict
  if has_key(self.saved, a:name)
    return
  endif
  if a:name =~ '^[bwtgs]:'
    let scope = self.get_scope_for(a:name)
    let name = substitute(a:name, '^\w:', '', '')
    if has_key(scope, name)
      let self.saved[a:name] = scope[name]
    else
      let self.defined[a:name] = 1
    endif
  elseif a:name =~ '^&\%([lg]:\)\='
    execute 'let self.saved[a:name] = ' . a:name
  endif
endfunction
call s:Context.method('save')

function! s:Context_get_scope_for(name) dict
  if a:name =~# '^b:'
    if !self.data.is_given()
      throw "InvalidScopeAccess: Test data is not given."
    endif
    let scope = b:
  elseif a:name =~# '^s:'
    if !has_key(self, 'scope')
      throw "InvalidScopeAccess: Context scope is not given."
    endif
    let scope = self.scope
  elseif a:name =~# '^[wtg]:'
    execute 'let scope = ' . matchstr(a:name, '^\w:')
  endif
  return scope
endfunction
call s:Context.method('get_scope_for')

function! s:Context_revert() dict
  if !empty(self.saved) || !empty(self.defined)
    for [name, value] in items(self.saved)
      call self.set(name, value, 0)
    endfor
    for [name, value] in items(self.defined)
      let scope = self.get_scope_for(name)
      let name = substitute(name, '^\w:', '', '')
      unlet scope[name]
    endfor
    let self.saved   = {}
    let self.defined = {}
  endif
  call self.data.revert()
endfunction
call s:Context.method('revert')

"---------------------------------------
" Data

let s:Data = unittest#oop#class#new('Data', s:SID)

function! s:Data_initialize(file) dict
  let self.file = (filereadable(a:file) ? fnamemodify(a:file, ':p') : '')
  let self.marker_formats = ['# %s', '# end_%s']
endfunction
call s:Data.method('initialize')

function! s:Data_is_given() dict
  return !empty(self.file)
endfunction
call s:Data.method('is_given')

function! s:Data___check__() dict
  if !self.is_given()
    throw "InvalidDataAccess: Test data is not given."
  endif
endfunction
call s:Data.method('__check__')

function! s:Data_bufnr() dict
  return bufnr(s:escape_file_pattern(self.file))
endfunction
call s:Data.method('bufnr')

" data.goto( {marker} [, {char}])
function! s:Data_goto(marker, ...) dict
  call self.__check__()
  let marker = printf(self.marker_formats[0], a:marker)
  let mkpat = '^\C' . s:escape_pattern(marker) . '$'
  let lnum = search(mkpat, 'w')
  if lnum > 0
    call cursor(lnum + 1, 1)
  else
    throw "InvalidMarker: Marker '" . marker . "' not found."
  endif
  if a:0
    let char = a:000[0]
    " NOTE: a:000 may contain {mode} argument at [1], which is the last
    " argument of data.select()/get()/execute() and meaningless here.
    if len(char) != 1
      throw "InvalidMarker: '" . char . "' is not a character."
    endif
    execute 'normal! f' . char . 'l'
  endif
endfunction
call s:Data.method('goto')

" data.goto_end( {marker} [, {char}])
function! s:Data_goto_end(marker, ...) dict
  call self.__check__()
  let marker = printf(self.marker_formats[1], a:marker)
  let mkpat = '^\C' . s:escape_pattern(marker) . '$'
  let lnum = search(mkpat, 'w')
  if lnum > 0
    call cursor(lnum - 1, 1)
  else
    throw "InvalidMarker: Marker '" . marker . "' not found."
  endif
  if a:0
    let char = a:000[0]
    if len(char) != 1
      throw "InvalidMarker: '" . char . "' is not a character."
    endif
    execute 'normal! $F' . s:end_char(char) . 'h'
  endif
endfunction
call s:Data.method('goto_end')

function! s:end_char(char)
  return get({ '(': ')', '[': ']', '{': '}', '<': '>' }, a:char, a:char)
endfunction

" data.range( {marker} [, {char}])
function! s:Data_range(...) dict
  let args = a:000
  call call(self.goto, args, self)
  let beg = getpos('.')
  call call(self.goto_end, args, self)
  let end = getpos('.')
  return [beg, end]
endfunction
call s:Data.method('range')

" data.select( {marker} [, {char} [, {mode}]])
function! s:Data_select(...) dict
  let args = a:000
  let [beg, end] = call(self.range, args, self)
  if len(args) > 1
    let mode = get(args, 2, "\<C-v>")
  else
    let mode = 'V'
  endif
  let mode = get({ 'line': 'V', 'block': "\<C-v>", 'char': 'v' }, mode, mode)
  call setpos('.', beg)
  execute 'normal!' mode
  call setpos('.', end)
endfunction
call s:Data.method('select')

" data.get( {marker} [, {char} [, {mode}]])
function! s:Data_get(...) dict
  let args = a:000
  call call(self.select, args, self)
  let save_regv = { 'value': getreg('v'), 'type': getregtype('v') }
  normal! "vy
  let lines = split(@v, "\<NL>")
  call setreg('v', save_regv.value, save_regv.type)
  if has_key(self, 'uncomment')
    call map(lines, 'self.uncomment(v:val)')
  endif
  return lines
endfunction
call s:Data.method('get')

" data.execute( {command}, {marker} [, {char} [, {mode}]])
function! s:Data_execute(command, ...) dict
  let args = a:000
  let range_str = join(call(self.line_range, args, self), ',')
  execute range_str . a:command
endfunction
call s:Data.method('execute')

" data.visual_execute( {command}, {marker} [, {char} [, {mode}]])
function! s:Data_visual_execute(command, ...) dict
  let args = a:000
  call call(self.select, args, self)
  execute "normal! \<Esc>"
  execute "'<,'>" . a:command
endfunction
call s:Data.method('visual_execute')

" data.line_range( {marker})
function! s:Data_line_range(...) dict
  let args = a:000
  let [beg, end] = call(self.range, args, self)
  return [beg[1], end[1]]
endfunction
call s:Data.method('line_range')

" data.block_range( {marker}, {char})
function! s:Data_block_range(...) dict
  let args = a:000
  let [beg, end] = call(self.range, args, self)
  return [beg[1:2], end[1:2]]
endfunction
call s:Data.method('block_range')
call s:Data.alias('char_range', 'block_range')

function! s:Data_revert() dict
  if &l:modified
    edit!
  endif
endfunction
call s:Data.method('revert')

"-----------------------------------------------------------------------------
" Utils

function! s:get_funcs(obj)
  return filter(keys(a:obj), 'type(a:obj[v:val]) == type(function("tr"))')
endfunction

function! s:grep(list, pat)
  return filter(copy(a:list), 'match(v:val, a:pat) != -1')
endfunction

function! s:map_matchstr(list, pat)
  return map(copy(a:list), 'matchstr(v:val, a:pat)')
endfunction

function! s:compare_strlen(str1, str2)
  let len1 = strlen(a:str1)
  let len2 = strlen(a:str2)
  return (len1 == len2 ? 0 : (len1 > len2 ? 1 : -1))
endfunction

function! s:escape_file_pattern(path)
  return escape(a:path, '*[]?{},')
endfunction

function! s:escape_pattern(str)
  return escape(a:str, '~"\.^$[]*')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
