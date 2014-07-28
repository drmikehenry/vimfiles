"=============================================================================
" Unit Testing Framework for Vim script
"
" File    : autoload/unittest/assertions.vim
" Author  : h1mesuke <himesuke+vim@gmail.com>
" Updated : 2012-01-29
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

function! unittest#assertions#__context__()
  return { 'sid': s:SID, 'scope': s: }
endfunction

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

"-----------------------------------------------------------------------------
" Constants

let s:TYPE_NUM  = type(0)
let s:TYPE_STR  = type("")
let s:TYPE_FUNC = type(function('tr'))
let s:TYPE_DICT = type({})
let s:TYPE_LIST = type([])
let s:TYPE_FLT  = type(0.0)

"-----------------------------------------------------------------------------
" Assertions

function! unittest#assertions#module()
  return s:Assertions
endfunction

let s:Assertions = unittest#oop#module#new('Assertions', s:SID)

function! s:Assertions_assert(expr, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if !a:expr
    call self.report_failure(
          \ printf("True expected, but was\n%s", self.__string__(a:expr)),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert')

function! s:Assertions_assert_not(expr, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:expr
    call self.report_failure(
          \ printf("False expected, but was\n%s", self.__string__(a:expr)),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_not')

function! s:Assertions_assert_equal(expected, actual, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if type(a:expected) == s:TYPE_STR && type(a:actual) == s:TYPE_STR
    if a:expected !=# a:actual
      call self.report_failure(
            \ printf("%s expected, but was\n%s",
            \   self.__string__(a:expected), self.__string__(a:actual)),
            \ hint)
    else
      call self.report_success()
    endif
  else
    if a:expected != a:actual
      call self.report_failure(
            \ printf("%s expected, but was\n%s",
            \   self.__string__(a:expected), self.__string__(a:actual)),
            \ hint)
    else
      call self.report_success()
    endif
  endif
endfunction
call s:Assertions.function('assert_equal')

function! s:Assertions_assert_not_equal(expected, actual, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if type(a:expected) == s:TYPE_STR && type(a:actual) == s:TYPE_STR
    if a:expected ==# a:actual
      call self.report_failure(
            \ printf("%s not expected, but was\n%s",
            \   self.__string__(a:expected), self.__string__(a:actual)),
            \ hint)
    else
      call self.report_success()
    endif
  else
    if a:expected == a:actual
      call self.report_failure(
            \ printf("%s not expected, but was\n%s",
            \   self.__string__(a:expected), self.__string__(a:actual)),
            \ hint)
    else
      call self.report_success()
    endif
  endif
endfunction
call s:Assertions.function('assert_not_equal')

function! s:Assertions_assert_equal_c(expected, actual, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:expected !=? a:actual
    call self.report_failure(
          \ printf("%s expected, but was\n%s",
          \   self.__string__(a:expected), self.__string__(a:actual)),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_equal_c')
call s:Assertions.alias('assert_equal_q', 'assert_equal_c')

function! s:Assertions_assert_not_equal_c(expected, actual, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:expected ==? a:actual
    call self.report_failure(
          \ printf("%s not expected, but was\n%s",
          \   self.__string__(a:expected), self.__string__(a:actual)),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_not_equal_c')
call s:Assertions.alias('assert_not_equal_q', 'assert_not_equal_c')

function! s:Assertions_assert_equal_C(expected, actual, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:expected !=# a:actual
    call self.report_failure(
          \ printf("%s expected, but was\n%s",
          \   self.__string__(a:expected), self.__string__(a:actual)),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_equal_C')
call s:Assertions.alias('assert_equal_s', 'assert_equal_C')

function! s:Assertions_assert_not_equal_C(expected, actual, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:expected ==# a:actual
    call self.report_failure(
          \ printf("%s not expected, but was\n%s",
          \   self.__string__(a:expected), self.__string__(a:actual)),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_not_equal_C')
call s:Assertions.alias('assert_not_equal_s', 'assert_not_equal_C')

function! s:Assertions_assert_exists(expr, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:expr =~ '^:' ? exists(a:expr) != 2 : !exists(a:expr)
    call self.report_failure(
          \ printf("'%s' is not defined.", a:expr),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_exists')
call s:Assertions.alias('assert_exist', 'assert_exists')

function! s:Assertions_assert_not_exists(expr, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:expr =~ '^:' ? exists(a:expr) == 2 : exists(a:expr)
    call self.report_failure(
          \ printf("'%s' is defined.", a:expr),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_not_exists')
call s:Assertions.alias('assert_not_exist', 'assert_not_exists')

function! s:Assertions_assert_has_key(key, dict, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if !has_key(a:dict, a:key)
    call self.report_failure(
          \ printf("%s doesn't has key '%s'", self.__string__(a:dict), a:key),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_has_key')

function! s:Assertions_assert_not_has_key(key, dict, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if has_key(a:dict, a:key)
    call self.report_failure(
          \ printf("%s has key '%s'", self.__string__(a:dict), a:key),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_not_has_key')

function! s:Assertions_assert_is(expected, actual, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:expected isnot a:actual
    call self.report_failure(
          \ printf("%s itself expected, but was\n%s",
          \   self.__string__(a:expected), self.__string__(a:actual)),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_is')

function! s:Assertions_assert_isnot(expected, actual, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:expected is a:actual
    call self.report_failure(
          \ printf("%s itself not expected, but was\n%s itself.",
          \   self.__string__(a:expected), self.__string__(a:actual)),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_isnot')
call s:Assertions.alias('assert_is_not', 'assert_isnot')

function! s:Assertions_assert_is_Number(value, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if type(a:value) != s:TYPE_NUM
    call self.report_failure(
          \ printf("Number expected, but was\n%s", self.__typestr__(a:value)),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_is_Number')

function! s:Assertions_assert_is_String(value, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if type(a:value) != s:TYPE_STR
    call self.report_failure(
          \ printf("String expected, but was\n%s", self.__typestr__(a:value)),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_is_String')

function! s:Assertions_assert_is_Funcref(value, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if type(a:value) != s:TYPE_FUNC
    call self.report_failure(
          \ printf("Funcref expected, but was\n%s", self.__typestr__(a:value)),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_is_Funcref')

function! s:Assertions_assert_is_List(value, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if type(a:value) != s:TYPE_LIST
    call self.report_failure(
          \ printf("List expected, but was\n%s", self.__typestr__(a:value)),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_is_List')

function! s:Assertions_assert_is_Dictionary(value, ...) dict
  call self.count_assertion()
  if type(a:value) != s:TYPE_DICT
    let hint = (a:0 ? a:1 : "")
    call self.report_failure(
          \ printf("Dictionary expected, but was\n%s", self.__typestr__(a:value)),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_is_Dictionary')
call s:Assertions.alias('assert_is_Dict', 'assert_is_Dictionary')

function! s:Assertions_assert_is_Float(value, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if type(a:value) != s:TYPE_FLT
    call self.report_failure(
          \ printf("Float expected, but was\n%s", self.__typestr__(a:value)),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_is_Float')

function! s:Assertions___typestr__(value)
  let type = type(a:value)
  if type == s:TYPE_NUM
    return 'Number'
  elseif type == s:TYPE_STR
    return 'String'
  elseif type == s:TYPE_FUNC
    return 'Funcref'
  elseif type == s:TYPE_LIST
    return 'List'
  elseif type == s:TYPE_DICT
    return 'Dictionary'
  elseif type == s:TYPE_FLT
    return 'Float'
  endif
endfunction
call s:Assertions.function('__typestr__')

function! s:Assertions_assert_match(pattern, str, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:str !~ a:pattern
    call self.report_failure(
          \ printf("'%s' didn't match pattern /%s/", a:str, a:pattern),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_match')

function! s:Assertions_assert_not_match(pattern, str, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:str =~ a:pattern
    call self.report_failure(
          \ printf("'%s' matched pattern /%s/", a:str, a:pattern),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_not_match')

function! s:Assertions_assert_match_c(pattern, str, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:str !~? a:pattern
    call self.report_failure(
          \ printf("'%s' didn't match pattern /%s/", a:str, a:pattern),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_match_c')
call s:Assertions.alias('assert_match_q', 'assert_match_c')

function! s:Assertions_assert_not_match_c(pattern, str, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:str =~? a:pattern
    call self.report_failure(
          \ printf("'%s' matched pattern /%s/", a:str, a:pattern),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_not_match_c')
call s:Assertions.alias('assert_not_match_q', 'assert_not_match_c')

function! s:Assertions_assert_match_C(pattern, str, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:str !~# a:pattern
    call self.report_failure(
          \ printf("'%s' didn't match pattern /%s/", a:str, a:pattern),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_match_C')
call s:Assertions.alias('assert_match_s', 'assert_match_C')

function! s:Assertions_assert_not_match_C(pattern, str, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  if a:str =~# a:pattern
    call self.report_failure(
          \ printf("'%s' matched pattern /%s/", a:str, a:pattern),
          \ hint)
  else
    call self.report_success()
  endif
endfunction
call s:Assertions.function('assert_not_match_C')
call s:Assertions.alias('assert_not_match_s', 'assert_not_match_C')

function! s:Assertions_assert_throw(exception, command, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  try
    execute a:command
  catch
    if v:exception !~# a:exception
      call self.report_failure(
            \ printf("Command '%s' didn't throw /%s/, but threw:\n%s",
            \   a:command, a:exception, v:exception),
            \ hint)
    else
      call self.report_success()
    endif
    return
  endtry
  call self.report_failure(
        \ empty(a:exception)
        \   ? printf("Command '%s' didn't throw anything.", a:command)
        \   : printf("Command '%s' didn't throw /%s/\nNothing thrown.",
        \       a:command, a:exception),
        \ hint)
endfunction
call s:Assertions.function('assert_throw')

function! s:Assertions_assert_throw_something(...) dict
  call call(self.assert_throw, [''] + a:000, self)
endfunction
call s:Assertions.function('assert_throw_something')
call s:Assertions.alias('assert_something_thrown', 'assert_throw_something')

function! s:Assertions_assert_not_throw(command, ...) dict
  call self.count_assertion()
  let hint = (a:0 ? a:1 : "")
  try
    execute a:command
  catch
    call self.report_failure(
          \ printf("Command '%s' threw:\n%s", a:command, v:exception),
          \ hint)
    return
  endtry
  call self.report_success()
endfunction
call s:Assertions.function('assert_not_throw')
call s:Assertions.alias('assert_nothing_thrown', 'assert_not_throw')

function! s:Assertions___string__(value)
  return unittest#oop#string(a:value)
endfunction
call s:Assertions.function('__string__')

"-----------------------------------------------------------------------------

function! s:Assertions_count_assertion() dict
  if has_key(self, 'runner')
    call self.runner.count_assertion()
  endif
endfunction
call s:Assertions.function('count_assertion')

function! s:Assertions_report_success() dict
  if has_key(self, 'runner')
    call self.runner.report_success()
  endif
endfunction
call s:Assertions.function('report_success')

function! s:Assertions_report_failure(reason, hint) dict
  if has_key(self, 'runner')
    call self.runner.report_failure(a:reason, a:hint)
  else
    let msg = substitute(a:reason, "\n", ' ', 'g')
    if !empty(a:hint)
      let msg .= " (" . a:hint . ")"
    endif
    throw "AssertionFailed: " . msg
  endif
endfunction
call s:Assertions.function('report_failure')

let &cpo = s:save_cpo
unlet s:save_cpo
