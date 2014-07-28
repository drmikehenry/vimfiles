" unittest.vim's test suite
"
" Test case of context accessors
"
"-----------------------------------------------------------------------------
" Expected results:
"
"   Green
"
"   WARNING:
"   Exporting s: in Vim 7.2 causes deadly signal SEGV. You had better use Vim
"   7.3 or later when you run tests that access any script-local variables.
"
"-----------------------------------------------------------------------------

if v:version < 703
  throw "Can't export s:, please use Vim 7.3 or later."
endif

let s:tc = unittest#testcase#new("Context Accessors", unittest#assertions#__context__())

let g:unittest_test_flag = 1
let s:current = {
      \ 'g:unittest_test_flag' : g:unittest_test_flag,
      \ '&ignorecase'          : &ignorecase,
      \ '&g:autoindent'        : &g:autoindent,
      \ '&l:autoindent'        : &l:autoindent,
      \ }

function! s:tc.test_context_exists_global_function()
  call self.assert(self.exists('*unittest#run'))
  call self.assert_not(self.exists('*unittest#foo'))
endfunction

function! s:tc.test_context_exists_script_local_function()
  call self.assert(self.exists('*s:Assertions_assert'))
  call self.assert_not(self.exists('*s:Assertions_foo'))
endfunction

function! s:tc.test_context_exists_global_variable()
  call self.assert(self.exists('g:unittest_test_flag'))
  call self.assert_not(self.exists('g:unittest_foo'))
endfunction

function! s:tc.test_context_exists_script_local_variable()
  call self.assert(self.exists('s:TYPE_NUM'))
  call self.assert_not(self.exists('s:foo'))
endfunction

function! s:tc.test_context_call_global_function()
  call self.assert_is(unittest#testcase#class(), self.call('unittest#testcase#class', []))
endfunction

function! s:tc.test_context_call_script_local_function()
  call self.call('s:Assertions_assert', [1], self)
endfunction

function! s:tc.test_context_get_global_variable()
  call self.assert_equal(g:unittest_test_flag, self.get('g:unittest_test_flag'))
endfunction

function! s:tc.test_context_get_script_local_variable()
  call self.assert_equal(type(0), self.get('s:TYPE_NUM'))
endfunction

function! s:tc.test_context_get_option()
  call self.assert_equal(&ignorecase, self.get('&ignorecase'))
endfunction

function! s:tc.test_context_get_global_option()
  call self.assert_equal(&g:autoindent, self.get('&g:autoindent'))
endfunction

function! s:tc.test_context_get_local_option()
  call self.assert_equal(&l:shiftwidth, self.get('&l:shiftwidth'))
endfunction

function! s:tc.test_context_set_global_variable()
  call self.set('g:unittest_test_flag', !s:current['g:unittest_test_flag'])
  call self.assert_equal(!s:current['g:unittest_test_flag'], g:unittest_test_flag)
endfunction
function! s:tc.test_context_set_global_variable_revert()
  call self.assert_equal(s:current['g:unittest_test_flag'], g:unittest_test_flag)
endfunction

function! s:tc.test_context_define_global_variable()
  call self.set('g:unittest_foo', 10)
  call self.assert_equal(10, self.get('g:unittest_foo'))
endfunction
function! s:tc.test_context_define_global_variable_revert()
  call self.assert_not(self.exists('g:unittest_foo'))
endfunction

function! s:tc.test_context_set_script_local_variable()
  call self.set('s:TYPE_NUM', 10)
  call self.assert_equal(10, self.get('s:TYPE_NUM'))
endfunction
function! s:tc.test_context_set_script_local_variable_revert()
  call self.assert_equal(type(0), self.get('s:TYPE_NUM'))
endfunction

function! s:tc.test_context_define_script_local_variable()
  call self.set('s:foo', 10)
  call self.assert_equal(10, self.get('s:foo'))
endfunction
function! s:tc.test_context_define_script_local_variable_revert()
  call self.assert_not(self.exists('s:foo'))
endfunction

function! s:tc.test_context_set_global_option()
  call self.set('&ignorecase', !s:current['&ignorecase'])
  call self.assert_equal(!s:current['&ignorecase'], &ignorecase)
endfunction
function! s:tc.test_context_set_global_option_revert()
  call self.assert_equal(s:current['&ignorecase'], &ignorecase)
endfunction

function! s:tc.test_context_set_local_option_g()
  call self.set('&g:autoindent', !s:current['&g:autoindent'])
  call self.assert_equal(!s:current['&g:autoindent'], &g:autoindent)
endfunction
function! s:tc.test_context_set_local_option_g_revert()
  call self.assert_equal(s:current['&g:autoindent'], &g:autoindent)
endfunction

function! s:tc.test_context_set_local_option()
  call self.set('&l:autoindent', !s:current['&l:autoindent'])
  call self.assert_equal(!s:current['&l:autoindent'], &l:autoindent)
endfunction
function! s:tc.test_context_set_local_option_revert()
  call self.assert_equal(s:current['&l:autoindent'], &l:autoindent)
endfunction

function! s:tc.test_context_save_global_option()
  call self.save('&ignorecase')
  set ignorecase!
  call self.assert_equal(!s:current['&ignorecase'], &ignorecase)
endfunction
function! s:tc.test_context_save_global_option_revert()
  call self.assert_equal(s:current['&ignorecase'], &ignorecase)
endfunction

function! s:tc.test_context_save_local_option_g()
  call self.save('&g:autoindent')
  setglobal autoindent!
  call self.assert_equal(!s:current['&g:autoindent'], &g:autoindent)
endfunction
function! s:tc.test_context_save_local_option_g_revert()
  call self.assert_equal(s:current['&g:autoindent'], &g:autoindent)
endfunction

function! s:tc.test_context_save_local_option()
  call self.save('&l:autoindent')
  setlocal autoindent!
  call self.assert_equal(!s:current['&l:autoindent'], &l:autoindent)
endfunction
function! s:tc.test_context_save_local_option_revert()
  call self.assert_equal(s:current['&l:autoindent'], &l:autoindent)
endfunction

unlet s:tc
