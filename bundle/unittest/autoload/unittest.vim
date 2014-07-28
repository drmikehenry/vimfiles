"=============================================================================
" Unit Testing Framework for Vim script
"
" File    : autoload/unittest.vim
" Updated : 2012-01-31
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

function! unittest#run(...)
  try
    let [tc_files, filters, output] = s:parse_args(a:000)
  catch /^unittest: /
    call unittest#print_error(v:exception)
    return
  endtry
  let runner = s:TestRunner.new(filters, output)
  call runner.load_testcases(tc_files)
  call runner.run()
endfunction

function! s:parse_args(args)
  let tc_files = []
  let filters = { 'only': [], 'except': [] }
  let output = 'buffer'
  for value in a:args
    " Filtering pattern
    let matched = matchlist(value, '^\([gv]\)/\(.*\)$')
    if len(matched) > 0
      if matched[1] ==# 'g'
        call add(filters.only, matched[2])
      else
        call add(filters.except, matched[2])
      endif
      continue
    endif
    " Output
    if value =~ '^>>\='
      let output = value
      continue
    endif
    " Test case
    if s:is_testcase_file(value)
      call add(tc_files, value)
      continue
    endif
    " Invalid value
    throw "unittest: Invalid arguement: " . string(value)
  endfor
  if empty(tc_files)
    let path = expand('%')
    if s:is_testcase_file(path)
      call add(tc_files, path)
    else
      throw "unittest: The current buffer is not a test case."
    endif
  endif
  return [tc_files, filters, output]
endfunction

function! s:is_testcase_file(path)
  return (a:path =~# '\<\(test_\|t[cs]_\)\w\+\.vim$')
endfunction

function! unittest#print_error(msg)
  echohl ErrorMsg | echomsg a:msg | echohl None
endfunction

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

"-----------------------------------------------------------------------------
" TestRunner

let s:TestRunner = unittest#oop#class#new('TestRunner', s:SID)

function! s:TestRunner_initialize(filters, output) dict
  let self.testcases = []
  let self.filters = a:filters
  let self.current = {}
  let self.results = s:TestResults.new()
  let matched = matchlist(a:output, '^\(>>\=\)\(.*\)$')
  if len(matched) > 0
    let file = matched[2]
    let mode = (matched[1] == '>>' ? 'a' : 'w')
    let self.out = s:OutFile.new(file, mode)
  else
    let self.out = s:OutBuffer.new()
  endif
endfunction
call s:TestRunner.method('initialize')

function! s:TestRunner_load_testcases(tc_files) dict
  let save_cpo = &cpo
  set cpo&vim
  for tc_file in a:tc_files
    try
      source `=tc_file`
    catch
      let dummy_tc = { 'name': fnamemodify(tc_file, ':t') }
      call self.results.add_error(dummy_tc, " ")
    endtry
  endfor
  let &cpo = save_cpo
  for tc in unittest#testcase#take()
    call self.add_testcase(tc)
  endfor
endfunction
call s:TestRunner.method('load_testcases')

function! s:TestRunner_add_testcase(tc) dict
  let a:tc.runner = self
  call add(self.testcases, a:tc)
endfunction
call s:TestRunner.method('add_testcase')

function! s:TestRunner_run() dict
  if has("reltime")
    let start_time = reltime()
  endif
  call self.out.open()
  call self.out.puts("Started at " . strftime('%c'))
  for tc in self.testcases
    call self.run_testcase(tc)
  endfor
  call self.print_results()
  if has("reltime")
    let used_time = split(reltimestr(reltime(start_time)))[0]
    call self.out.puts("Finished in " . used_time . " seconds.")
  endif
  call self.out.close()
endfunction
call s:TestRunner.method('run')

function! s:TestRunner_run_testcase(tc) dict
  try
    let self.current.testcase = a:tc
    call self.out.print_header(a:tc.name)
    call self.out.puts()
    call a:tc.__SETUP__()
    let tests = self.filter_tests(a:tc.__tests__())
    for test in tests
      let self.current.test = test
      try
        call a:tc.__setup__(test)
        call call(a:tc[test], [], a:tc)
      catch
        call self.results.add_error(a:tc, test)
      endtry
      try
        call a:tc.__teardown__(test)
      catch
        call self.results.add_error(a:tc, test)
      endtry
      if empty(self.results.get(a:tc, test))
        call self.results.add_pending(a:tc, test)
      endif
      call self.print_status(a:tc, test)
    endfor
    call a:tc.__TEARDOWN__()
  catch
    call self.results.add_error(a:tc, " ")
    " NOTE: Cannot use empty test name.
  endtry
endfunction
call s:TestRunner.method('run_testcase')

function! s:TestRunner_filter_tests(tests) dict
  let tests = copy(a:tests)
  for pat in self.filters.only
    call filter(tests, 'v:val =~# pat')
  endfor
  for pat in self.filters.except
    call filter(tests, 'v:val !~# pat')
  endfor
  return tests
endfunction
call s:TestRunner.method('filter_tests')

function! s:TestRunner_count_assertion() dict
  call self.results.count_assertion()
endfunction
call s:TestRunner.method('count_assertion')

function! s:TestRunner_report_success() dict
  call self.results.add_success(self.current.testcase, self.current.test)
endfunction
call s:TestRunner.method('report_success')

function! s:TestRunner_report_failure(reason, hint) dict
  call self.results.add_failure(self.current.testcase, self.current.test,
        \ a:reason, a:hint)
endfunction
call s:TestRunner.method('report_failure')

function! s:TestRunner_puts(...) dict
  call call(self.out.puts, a:000, self.out)
endfunction
call s:TestRunner.method('puts')

function! s:TestRunner_print_status(tc, test) dict
  let line = a:test . ' => '
  for result in self.results.get(a:tc, a:test)
    if result.is_a(s:Failure)
      let line .= 'F'
    elseif result.is_a(s:Error)
      let line .= 'E'
    elseif result.is_a(s:Pending)
      let line .= '*'
    else
      let line .= '.'
    endif
  endfor
  call self.out.puts(line)
endfunction
call s:TestRunner.method('print_status')

function! s:TestRunner_print_results() dict
  call self.out.print_header("Results")
  let number_of = self.results.get_counts() 
  if number_of.failures > 0
    call self.out.puts()
    call self.out.puts("Failures:")
    let nr = 1
    for fail in self.results.failures
      call self.print_failure(fail, nr)
      let nr += 1
    endfor
  endif
  if number_of.errors > 0
    call self.out.puts()
    call self.out.puts("Errors:")
    let nr = 1
    for err in self.results.errors
      call self.print_error(err, nr)
      let nr += 1
    endfor
  endif
  if number_of.pendings > 0
    call self.out.puts()
    call self.out.puts("Pending:")
    let nr = 1
    for pend in self.results.pendings
      call self.print_pending(pend, nr)
      let nr += 1
    endfor
  endif
  call self.out.puts()
  call self.out.puts(printf("%d tests, %d assertions, %d failures, %d errors%s",
        \ number_of.tests, number_of.assertions, number_of.failures, number_of.errors,
        \ (number_of.pendings > 0 ? printf(" (%d pending)", number_of.pendings) : "")))
  call self.out.puts()
endfunction
call s:TestRunner.method('print_results')

function! s:TestRunner_print_failure(fail, nr) dict
  call self.out.puts()
  call self.out.puts(
        \     printf("  %d) %s: %s", a:nr, a:fail.testcase.name, a:fail.test))
  call self.out.puts(
        \     printf("    Failed: %s %s", a:fail.assert, a:fail.hint))
  call self.out.puts("    " . substitute(a:fail.reason, '\n', "\n    ", 'g'))
endfunction
call s:TestRunner.method('print_failure')

function! s:TestRunner_print_error(err, nr) dict
  call self.out.puts()
  call self.out.puts(
        \     printf("  %d) %s: %s" , a:nr, a:err.testcase.name, a:err.test))
  call self.out.puts("    Error: " . a:err.throwpoint)
  call self.out.puts("    " . a:err.exception)
endfunction
call s:TestRunner.method('print_error')

function! s:TestRunner_print_pending(pend, nr) dict
  call self.out.puts()
  call self.out.puts(
        \     printf("  %d) %s: %s", a:nr, a:pend.testcase.name, a:pend.test))
  call self.out.puts("    # Not Yet Implemented")
endfunction
call s:TestRunner.method('print_pending')

"-----------------------------------------------------------------------------
" Output

let s:Output = unittest#oop#class#new('Output', s:SID)

function! s:Output_get_width() dict
  return 78
endfunction
call s:Output.method('get_width')

function! s:Output_puts() dict
  throw "unittest: Abstract method was called unexpectedly!"
endfunction
call s:Output.method('puts')

function! s:Output_print_separator() dict
  call self.puts(repeat('-', self.get_width()))
endfunction
call s:Output.method('print_separator')

function! s:Output_print_header(title) dict
  call self.puts()
  call self.print_separator()
  call self.puts(a:title)
endfunction
call s:Output.method('print_header')

"---------------------------------------
" OutBuffer < Output

let s:OutBuffer = unittest#oop#class#new('OutBuffer', s:SID, s:Output)
let s:OutBuffer.nr = -1

function! s:OutBuffer_get_width() dict
  let winw = winwidth(bufwinnr(s:OutBuffer.nr))
  return (min([80, winw]) - 2)
endfunction
call s:OutBuffer.method('get_width')

function! s:OutBuffer_open() dict
  call self.open_window()
endfunction
call s:OutBuffer.method('open')

function! s:OutBuffer_open_window() dict
  if !bufexists(s:OutBuffer.nr)
    " The results buffer doesn't exist.
    split
    edit `='[unittest results]'`
    let s:OutBuffer.nr = bufnr('%')
  elseif bufwinnr(s:OutBuffer.nr) != -1
    " The results buffer exists, and it has a window.
    call self.focus_window()
  else
    " The results buffer exists, but it has no window.
    split
    execute 'buffer' s:OutBuffer.nr
  endif
  call self.init_buffer()
endfunction
call s:OutBuffer.method('open_window')

function! s:OutBuffer_focus_window() dict
  execute bufwinnr(s:OutBuffer.nr) 'wincmd w'
endfunction
call s:OutBuffer.method('focus_window')

function! s:OutBuffer_init_buffer() dict
  nnoremap <buffer> q <C-w>c
  setlocal bufhidden=hide buftype=nofile noswapfile nobuflisted
  setlocal filetype=unittest
  silent! %delete _
endfunction
call s:OutBuffer.method('init_buffer')

function! s:OutBuffer_close() dict
  call self.focus_window()
  normal! z-
endfunction
call s:OutBuffer.method('close')

function! s:OutBuffer_puts(...) dict
  let save_winnr =  bufwinnr('%')
  execute bufwinnr(s:OutBuffer.nr) 'wincmd w'
  try
    let lines  = (a:0 ? split(a:1, "\n") : "")
    call append(line('$'), lines)
    setlocal nomodified
    " Redraw smoothly.
    normal! G
    redraw
  finally
    execute save_winnr 'wincmd w'
  endtry
endfunction
call s:OutBuffer.method('puts')

"---------------------------------------
" OutFile < Output

let s:OutFile = unittest#oop#class#new('OutFile', s:SID, s:Output)

function! s:OutFile_initialize(file, mode) dict
  let self.file = a:file
  let self.mode = a:mode
endfunction
call s:OutFile.method('initialize')

function! s:OutFile_open() dict
  if self.mode ==# 'w' && filereadable(self.file)
    if delete(self.file) != 0
      throw "unittest: Can't remove the previous output: " . self.file
    endif
  endif
endfunction
call s:OutFile.method('open')

function! s:OutFile_close() dict
  call self.puts()
endfunction
call s:OutFile.method('close')

" NOTE: puts() is reequired to execute :redir to the output file evety time
" because the code to be tested may execute :redir END.
function! s:OutFile_puts(...) dict
  execute 'redir >>' self.file
  for line in (a:0 ? split(a:1, "\n") : [""])
    silent echomsg line
  endfor
  redir END
endfunction
call s:OutFile.method('puts')

"-----------------------------------------------------------------------------
" TestResults

let s:TestResults = unittest#oop#class#new('TestResults', s:SID)

function! s:TestResults_initialize() dict
  let self.__results__ = {}
  let self.__count__ = { 'tests': 0, 'assertions': 0 }
  let self.failures = []
  let self.errors   = []
  let self.pendings = []
endfunction
call s:TestResults.method('initialize')

function! s:TestResults_get(tc, test) dict
  try
    " NOTE: Don't shortcut this :let statment, or Vim can't catch E716!
    let results = self.__results__[a:tc.name][a:test]
    return results
  catch /^Vim\%((\a\+)\)\=:E716:/
    " E716: Key not present in Dictionary:
    return []
  endtry
endfunction
call s:TestResults.method('get')

function! s:TestResults_get_counts() dict
  return {
        \ 'tests'     : self.__count__.tests,
        \ 'assertions': self.__count__.assertions,
        \ 'failures'  : len(self.failures),
        \ 'errors'    : len(self.errors),
        \ 'pendings'  : len(self.pendings),
        \ }
endfunction
call s:TestResults.method('get_counts')

function! s:TestResults_count_assertion() dict
  let self.__count__.assertions += 1
endfunction
call s:TestResults.method('count_assertion')

function! s:TestResults_add_success(tc, test) dict
  call self.add(a:tc, a:test, s:SUCCESS)
endfunction
call s:TestResults.method('add_success')

function! s:TestResults_add_failure(tc, test, reason, hint) dict
  let fail = s:Failure.new(a:tc, a:test, a:reason, a:hint)
  call self.add(a:tc, a:test, fail)
endfunction
call s:TestResults.method('add_failure')

function! s:TestResults_add_error(tc, test) dict
  let err = s:Error.new(a:tc, a:test)
  call self.add(a:tc, a:test, err)
endfunction
call s:TestResults.method('add_error')

function! s:TestResults_add_pending(tc, test) dict
  let pend = s:Pending.new(a:tc, a:test)
  call self.add(a:tc, a:test, pend)
endfunction
call s:TestResults.method('add_pending')

function! s:TestResults_add(tc, test, result) dict
  let tc_name = a:tc.name
  if !has_key(self.__results__, tc_name)
    let self.__results__[tc_name] = {}
  endif
  let tc_results = self.__results__[tc_name]
  if !has_key(tc_results, a:test)
    let tc_results[a:test] = []
    let self.__count__.tests += 1
  endif
  call add(tc_results[a:test], a:result)

  if a:result isnot s:SUCCESS
    let kind_s = tolower(a:result.class.name) . 's'
    "=> 'failures', 'errors' or 'pendings'
    call add(self[kind_s], a:result)
  endif
endfunction
call s:TestResults.method('add')

"---------------------------------------
" Success

let s:SUCCESS = unittest#oop#class#new('Success', s:SID).new()

"---------------------------------------
" Failure

let s:Failure = unittest#oop#class#new('Failure', s:SID)

function! s:Failure_initialize(tc, test, reason, hint) dict
  let self.testcase = a:tc
  let self.test = a:test
  let self.failpoint = expand('<sfile>')
  let self.assert = matchstr(self.failpoint, '\.\.<SNR>\d\+_Assertions_\zsassert\w*\ze\.\.')
  let self.reason = a:reason
  let self.hint = (type(a:hint) == type("") ? a:hint : unittest#oop#string(a:hint))
endfunction
call s:Failure.method('initialize')

"---------------------------------------
" Error

let s:Error = unittest#oop#class#new('Error', s:SID)

function! s:Error_initialize(tc, test) dict
  let self.testcase = a:tc
  let self.test = a:test
  let self.throwpoint = v:throwpoint
  let self.exception = v:exception
endfunction
call s:Error.method('initialize')

"---------------------------------------
" Pending

let s:Pending = unittest#oop#class#new('Pending', s:SID)

function! s:Pending_initialize(tc, test) dict
  let self.testcase = a:tc
  let self.test = a:test
endfunction
call s:Pending.method('initialize')

let &cpo = s:save_cpo
unlet s:save_cpo
