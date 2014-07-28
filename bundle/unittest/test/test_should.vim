" unittest.vim's test suite
"
" Test case of shoulda-like tests
"
" thoughtbot/shoulda - GitHub
" https://github.com/thoughtbot/shoulda
"
"-----------------------------------------------------------------------------
" Expected results:
"
"   Green
"
"-----------------------------------------------------------------------------

let s:tc = unittest#testcase#new("Shoulda-like Tests")

function! s:tc.one_should_be_true()
  call self.assert(1)
endfunction

function! s:tc.zero_should_be_false()
  call self.assert_not(0)
endfunction

unlet s:tc
