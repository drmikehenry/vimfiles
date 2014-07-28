" unittest.vim's test suite
"
" Test case of pendings
"
"-----------------------------------------------------------------------------
" Expected results:
"
"   Pending
"
"-----------------------------------------------------------------------------

let s:tc = unittest#testcase#new("Pending")

function! s:tc.test_foo()
endfunction

function! s:tc.test_bar()
endfunction

function! s:tc.test_baz()
endfunction

unlet s:tc
