" unittest.vim's test suite
"
" Test case of setup and teardown for shoulda-like tests
"
"-----------------------------------------------------------------------------
" Expected results:
"
"   SETUP
" 
"   setup
"   setup_a
"   a___it_should_be
"   teardown_a
"   teardown
"   
"   setup
"   setup_a
"   setup_a_e
"   a_e___it_should_be
"   teardown_a_e
"   teardown_a
"   teardown
"   
"   setup
"   setup_e
"   e___it_should_be
"   teardown_e
"   teardown
"   
"   setup
"   setup_e
"   setup_e_a
"   e_a___it_should_be
"   teardown_e_a
"   teardown_e
"   teardown
"
"   setup
"   setup_foo
"   foo___it_should_be
"   teardown_foo
"   teardown
"
"   setup
"   setup_foo
"   setup_foo_bar
"   foo_bar___it_should_be
"   teardown_foo_bar
"   teardown_foo
"   teardown
"
"   setup
"   setup_foo
"   setup_foo_bar
"   setup_foo_bar_baz
"   foo_bar_baz___it_should_be
"   teardown_foo_bar_baz
"   teardown_foo_bar
"   teardown_foo
"   teardown
"
"   TEARDOWN
"
"-----------------------------------------------------------------------------

let s:tc = unittest#testcase#new("Shoulda-like Tests' Setup and Teardown")

function! s:tc.SETUP()
  let self.funcalls = ["SETUP"]
  call self.puts("SETUP")
endfunction

function! s:tc.setup()
  call self.puts()
  call add(self.funcalls, "setup")
  call self.puts("setup")
endfunction

function! s:tc.setup_a()
  call add(self.funcalls, "setup_a")
  call self.puts("setup_a")
endfunction
function! s:tc.a___it_should_be()
  call add(self.funcalls, "a___it_should_be")
  call self.puts("a___it_should_be")
  call self.assert(1) | " Not pending.
endfunction
function! s:tc.teardown_a()
  call add(self.funcalls, "teardown_a")
  call self.puts("teardown_a")
endfunction

function! s:tc.setup_e()
  call add(self.funcalls, "setup_e")
  call self.puts("setup_e")
endfunction
function! s:tc.e___it_should_be()
  call add(self.funcalls, "e___it_should_be")
  call self.puts("e___it_should_be")
  call self.assert(1) | " Not pending.
endfunction
function! s:tc.teardown_e()
  call add(self.funcalls, "teardown_e")
  call self.puts("teardown_e")
endfunction

function! s:tc.setup_a_e()
  call add(self.funcalls, "setup_a_e")
  call self.puts("setup_a_e")
endfunction
function! s:tc.a_e___it_should_be()
  call add(self.funcalls, "a_e___it_should_be")
  call self.puts("a_e___it_should_be")
  call self.assert(1) | " Not pending.
endfunction
function! s:tc.teardown_a_e()
  call add(self.funcalls, "teardown_a_e")
  call self.puts("teardown_a_e")
endfunction

function! s:tc.setup_e_a()
  call add(self.funcalls, "setup_e_a")
  call self.puts("setup_e_a")
endfunction
function! s:tc.e_a___it_should_be()
  call add(self.funcalls, "e_a___it_should_be")
  call self.puts("e_a___it_should_be")
  call self.assert(1) | " Not pending.
endfunction
function! s:tc.teardown_e_a()
  call add(self.funcalls, "teardown_e_a")
  call self.puts("teardown_e_a")
endfunction

function! s:tc.setup_foo()
  call add(self.funcalls, "setup_foo")
  call self.puts("setup_foo")
endfunction

function! s:tc.teardown_foo()
  call add(self.funcalls, "teardown_foo")
  call self.puts("teardown_foo")
endfunction

function! s:tc.foo___it_should_be()
  call add(self.funcalls, "foo___it_should_be")
  call self.puts("foo___it_should_be")
  call self.assert(1) | " Not pending.
endfunction

function! s:tc.setup_foo_bar()
  call add(self.funcalls, "setup_foo_bar")
  call self.puts("setup_foo_bar")
endfunction

function! s:tc.teardown_foo_bar()
  call add(self.funcalls, "teardown_foo_bar")
  call self.puts("teardown_foo_bar")
endfunction

function! s:tc.foo_bar___it_should_be()
  call add(self.funcalls, "foo_bar___it_should_be")
  call self.puts("foo_bar___it_should_be")
  call self.assert(1) | " Not pending.
endfunction

function! s:tc.setup_foo_bar_baz()
  call add(self.funcalls, "setup_foo_bar_baz")
  call self.puts("setup_foo_bar_baz")
endfunction

function! s:tc.foo_bar_baz___it_should_be()
  call add(self.funcalls, "foo_bar_baz___it_should_be")
  call self.puts("foo_bar_baz___it_should_be")
  call self.assert(1) | " Not pending.
endfunction

function! s:tc.teardown_foo_bar_baz()
  call add(self.funcalls, "teardown_foo_bar_baz")
  call self.puts("teardown_foo_bar_baz")
endfunction

function! s:tc.teardown()
  call add(self.funcalls, "teardown")
  call self.puts("teardown")
  call self.puts()
endfunction

function! s:tc.TEARDOWN()
  call self.puts()
  call add(self.funcalls, "TEARDOWN")
  call self.puts("TEARDOWN")
endfunction

" NOTE: This test must be executed last in alphabetical order, so "zetup" of
" the name isn't a typo. Unfortunately, this can't test TEARDOWN(), so we need
" to see the output of the test results finding "TEARDOWN" printed by puts().
"
function! s:tc.test_zetup_and_teardown()
  let expected = [
        \ "SETUP",
        \
        \ "setup",
        \ "setup_a",
        \ "a___it_should_be",
        \ "teardown_a",
        \ "teardown",
        \
        \ "setup",
        \ "setup_a",
        \ "setup_a_e",
        \ "a_e___it_should_be",
        \ "teardown_a_e",
        \ "teardown_a",
        \ "teardown",
        \
        \ "setup",
        \ "setup_e",
        \ "e___it_should_be",
        \ "teardown_e",
        \ "teardown",
        \
        \ "setup",
        \ "setup_e",
        \ "setup_e_a",
        \ "e_a___it_should_be",
        \ "teardown_e_a",
        \ "teardown_e",
        \ "teardown",
        \
        \ "setup",
        \ "setup_foo",
        \ "foo___it_should_be",
        \ "teardown_foo",
        \ "teardown",
        \
        \ "setup",
        \ "setup_foo",
        \ "setup_foo_bar",
        \ "foo_bar___it_should_be",
        \ "teardown_foo_bar",
        \ "teardown_foo",
        \ "teardown",
        \
        \ "setup",
        \ "setup_foo",
        \ "setup_foo_bar",
        \ "setup_foo_bar_baz",
        \ "foo_bar_baz___it_should_be",
        \ "teardown_foo_bar_baz",
        \ "teardown_foo_bar",
        \ "teardown_foo",
        \ "teardown",
        \
        \ "setup",
        \ ]
  " NOTE: The last "setup" is called for this test.
  call self.assert_equal(expected, self.funcalls)
endfunction

unlet s:tc
