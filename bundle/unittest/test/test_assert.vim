" unittest.vim's test suite
"
" Test case of assertions
"
"-----------------------------------------------------------------------------
" Expected results:
"
"   {T} tests, {A} assertions, {A/2} failures, 1 errors
"
" NOTE: The tests in this file are written to test assertions themselves, so
" not only successes but also failures are expected as the results.
"
"-----------------------------------------------------------------------------

let s:tc = unittest#testcase#new("Assertions")

function! s:tc.test_assert()
  call self.assert(1)
  call self.assert(0)
endfunction

function! s:tc.test_assert_not()
  call self.assert_not(0)
  call self.assert_not(1)
endfunction

function! s:tc.test_assert_equal()
  call self.assert_equal(1, 1)
  call self.assert_equal(1, 2)
endfunction

function! s:tc.test_assert_not_equal()
  call self.assert_not_equal(1, 2)
  call self.assert_not_equal(1, 1)
endfunction

function! s:tc.test_assert_equal_c()
  call self.assert_equal_c("a", "A")
  call self.assert_equal_c("a", "b")
endfunction
function! s:tc.test_assert_equal_q()
  call self.assert_equal_q("a", "A")
  call self.assert_equal_q("a", "b")
endfunction

function! s:tc.test_assert_not_equal_c()
  call self.assert_not_equal_c("a", "b")
  call self.assert_not_equal_c("a", "A")
endfunction
function! s:tc.test_assert_not_equal_q()
  call self.assert_not_equal_q("a", "b")
  call self.assert_not_equal_q("a", "A")
endfunction

function! s:tc.test_assert_equal_C()
  call self.assert_equal_C("a", "a")
  call self.assert_equal_C("a", "b")
endfunction
function! s:tc.test_assert_equal_s()
  call self.assert_equal_s("a", "a")
  call self.assert_equal_s("a", "b")
endfunction

function! s:tc.test_assert_not_equal_C()
  call self.assert_not_equal_C("a", "b")
  call self.assert_not_equal_C("a", "a")
endfunction
function! s:tc.test_assert_not_equal_s()
  call self.assert_not_equal_s("a", "b")
  call self.assert_not_equal_s("a", "a")
endfunction

function! s:tc.test_assert_exists()
  call self.assert_exists('*tr')
  call self.assert_exists('*foo#bar#baz')

  call self.assert_exists(':bnext')
  call self.assert_exists(':bn')
endfunction

function! s:tc.test_assert_not_exists()
  call self.assert_not_exists('*foo#bar#baz')
  call self.assert_not_exists('*tr')

  call self.assert_not_exists(':bn')
  call self.assert_not_exists(':bnext')
endfunction

function! s:tc.test_assert_has_key()
  call self.assert_has_key('a', { 'a': 10 })
  call self.assert_has_key('b', { 'a': 10 })
endfunction

function! s:tc.test_assert_not_has_key()
  call self.assert_not_has_key('b', { 'a': 10 })
  call self.assert_not_has_key('a', { 'a': 10 })
endfunction

function! s:tc.test_assert_is()
  let a = []
  let b = []
  call self.assert_is(a, a)
  call self.assert_is(a, b)
endfunction

function! s:tc.test_assert_isnot()
  let a = []
  let b = []
  call self.assert_isnot(a, b)
  call self.assert_isnot(a, a)
endfunction
function! s:tc.test_assert_is_not()
  let a = []
  let b = []
  call self.assert_is_not(a, b)
  call self.assert_is_not(a, a)
endfunction

function! s:tc.test_assert_is_Number()
  call self.assert_is_Number(1)
  call self.assert_is_Number("a")
endfunction

function! s:tc.test_assert_is_String()
  call self.assert_is_String("a")
  call self.assert_is_String(1)
endfunction

function! s:tc.test_assert_is_Funcref()
  call self.assert_is_Funcref(function("type"))
  call self.assert_is_Funcref(1)
endfunction

function! s:tc.test_assert_is_List()
  call self.assert_is_List([1,2,3])
  call self.assert_is_List(1)
endfunction

function! s:tc.test_assert_is_Dictionary()
  call self.assert_is_Dictionary({ 1:'a', 2:'b' })
  call self.assert_is_Dictionary(1)
endfunction

function! s:tc.test_assert_is_Float()
  call self.assert_is_Float(3.14)
  call self.assert_is_Float(1)
endfunction

function! s:tc.test_assert_match()
  call self.assert_match('e', "hello")
  call self.assert_match('x', "hello")
endfunction

function! s:tc.test_assert_not_match()
  call self.assert_not_match('x', "hello")
  call self.assert_not_match('e', "hello")
endfunction

function! s:tc.test_assert_match_c()
  call self.assert_match_c('e', "HELLO")
  call self.assert_match_c('x', "HELLO")
endfunction
function! s:tc.test_assert_match_q()
  call self.assert_match_q('e', "HELLO")
  call self.assert_match_q('x', "HELLO")
endfunction

function! s:tc.test_assert_not_match_c()
  call self.assert_not_match_c('x', "HELLO")
  call self.assert_not_match_c('e', "HELLO")
endfunction
function! s:tc.test_assert_not_match_q()
  call self.assert_not_match_q('x', "HELLO")
  call self.assert_not_match_q('e', "HELLO")
endfunction

function! s:tc.test_assert_match_C()
  call self.assert_match_C('E', "HELLO")
  call self.assert_match_C('e', "HELLO")
endfunction
function! s:tc.test_assert_match_s()
  call self.assert_match_s('E', "HELLO")
  call self.assert_match_s('e', "HELLO")
endfunction

function! s:tc.test_assert_not_match_C()
  call self.assert_not_match_C('e', "HELLO")
  call self.assert_not_match_C('E', "HELLO")
endfunction
function! s:tc.test_assert_not_match_s()
  call self.assert_not_match_s('e', "HELLO")
  call self.assert_not_match_s('E', "HELLO")
endfunction

function! s:tc.test_assert_throw()
  call self.assert_throw('E492', 'FooBarBaz')
  call self.assert_throw('E492', 'nohl')
endfunction

function! s:tc.test_assert_throw_something()
  call self.assert_throw_something('FooBarBaz')
  call self.assert_throw_something('nohl')
endfunction
function! s:tc.test_assert_something_thrown()
  call self.assert_something_thrown('FooBarBaz')
  call self.assert_something_thrown('nohl')
endfunction

function! s:tc.test_assert_not_throw()
  call self.assert_not_throw('nohl')
  call self.assert_not_throw('FooBarBaz')
endfunction
function! s:tc.test_assert_nothing_thrown()
  call self.assert_nothing_thrown('nohl')
  call self.assert_nothing_thrown('FooBarBaz')
endfunction

function! s:tc.test_error()
  call foo#bar#baz()
endfunction

unlet s:tc
