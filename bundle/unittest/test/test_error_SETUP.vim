" unittest.vim's test suite
"
" Test case of irregular error
"
"-----------------------------------------------------------------------------
" Expected results:
"
"   Error catched
"
"-----------------------------------------------------------------------------

let s:tc = unittest#testcase#new("Green?")

function! s:tc.SETUP()
  alskdjflkasjdlkfj
endfunction

function! s:tc.test_foo()
  call self.assert(1)
endfunction

function! s:tc.test_bar()
  call self.assert(1)
endfunction

function! s:tc.test_baz()
  call self.assert(1)
endfunction

unlet s:tc
