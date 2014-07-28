" unittest.vim's test suite
"
" Test case of data accessors
"
"-----------------------------------------------------------------------------
" Expected results:
"
"   Green
"
"-----------------------------------------------------------------------------

let s:here = expand('<sfile>:p:h')
let s:tc = unittest#testcase#new("Data Accessors", { 'data': s:here . '/test_data.dat' })

" Lorem ipsum's range
let s:LINE_BEG = 4 | let s:COL_BEG = 23
let s:LINE_END = 9 | let s:COL_END = 56

let s:LOREM_IPSUM = [
      \ 'Lorem ipsum dolor sit[amet, consectetur adipisicing elit, sed do eiusmod',
      \ 'tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,',
      \ 'quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo',
      \ 'consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse',
      \ 'cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non',
      \ 'proident, sunt in culpa qui officia deserunt mollit anim]id est laborum.',
      \ ]

let s:LOREM_IPSUM_BLOCK = [
      \ 'amet, consectetur adipisicing elit',
      \ 'abore et dolore magna aliqua. Ut e',
      \ 'ion ullamco laboris nisi ut aliqui',
      \ 'rure dolor in reprehenderit in vol',
      \ 't nulla pariatur. Excepteur sint o',
      \ 'a qui officia deserunt mollit anim',
      \ ]

let s:LOREM_IPSUM_CHAR = [
      \ 'amet, consectetur adipisicing elit, sed do eiusmod',
      \ 'tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,',
      \ 'quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo',
      \ 'consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse',
      \ 'cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non',
      \ 'proident, sunt in culpa qui officia deserunt mollit anim',
      \ ]

let s:LOREM_IPSUM_SORTED = [
      \ 'Lorem ipsum dolor sit[amet, consectetur adipisicing elit, sed do eiusmod',
      \ 'cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non',
      \ 'consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse',
      \ 'proident, sunt in culpa qui officia deserunt mollit anim]id est laborum.',
      \ 'quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo',
      \ 'tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,',
      \ ]

function! s:tc.SETUP()
  let self.saved = {}
endfunction

function! s:tc.test_data_is_given()
  call self.assert(self.data.is_given())
endfunction

function! s:tc.setup_data_marker_formats_change()
  let self.saved.marker_formats = self.data.marker_formats
  let self.data.marker_formats = ['// BEGIN %s', '// END %s']
endfunction
function! s:tc.test_data_marker_formats_change()
  let expected = ['TEST DATA IN CHANGED MARKER']
  call self.assert_equal(expected, self.data.get('CHANGED MARKER'))
endfunction
function! s:tc.teardown_data_marker_formats_change()
  let self.data.marker_formats = self.saved.marker_formats
endfunction

function! s:tc.test_data_goto()
  call self.data.goto('lorem_ipsum')
  call self.assert_equal(s:LINE_BEG, line('.'))
endfunction
function! s:tc.test_data_goto_char()
  call self.data.goto('lorem_ipsum', '[')
  call self.assert_equal(s:LINE_BEG, line('.'))
  call self.assert_equal(s:COL_BEG, col('.'))
endfunction

function! s:tc.test_data_goto_end()
  call self.data.goto_end('lorem_ipsum')
  call self.assert_equal(s:LINE_END, line('.'))
endfunction
function! s:tc.test_data_goto_end_char()
  call self.data.goto_end('lorem_ipsum', '[')
  call self.assert_equal(s:LINE_END, line('.'))
  call self.assert_equal(s:COL_END, col('.'))
endfunction

function! s:tc.test_data_range()
  let range = self.data.range('lorem_ipsum')
  let expected = [[0, s:LINE_BEG, 1, 0], [0, s:LINE_END, 1, 0]]
  " NOTE: getpos() returns 0 as bufnum unless a mark like '0 or 'A is used.
  call self.assert_equal(expected, range)
endfunction
function! s:tc.test_data_range_block()
  let range = self.data.range('lorem_ipsum', '[')
  let expected = [[0, s:LINE_BEG, s:COL_BEG, 0], [0, s:LINE_END, s:COL_END, 0]]
  call self.assert_equal(expected, range)
endfunction

function! s:tc.test_data_select()
  call self.data.select('lorem_ipsum')
  call self.assert_equal('V', mode())
  execute "normal! \<Esc>"
  call self.assert_equal(s:LINE_BEG, getpos("'<")[1])
  call self.assert_equal(s:LINE_END, getpos("'>")[1])
endfunction
function! s:tc.test_data_select_block()
  call self.data.select('lorem_ipsum', '[')
  call self.assert_equal("\<C-v>", mode())
  execute "normal! \<Esc>"
  call self.assert_equal([0, s:LINE_BEG, s:COL_BEG, 0], getpos("'<"))
  call self.assert_equal([0, s:LINE_END, s:COL_END, 0], getpos("'>"))
endfunction
function! s:tc.test_data_select_char()
  call self.data.select('lorem_ipsum', '[', 'char')
  call self.assert_equal('v', mode())
  execute "normal! \<Esc>"
  call self.assert_equal([0, s:LINE_BEG, s:COL_BEG, 0], getpos("'<"))
  call self.assert_equal([0, s:LINE_END, s:COL_END, 0], getpos("'>"))
endfunction

function! s:tc.test_data_get()
  call self.assert_equal(s:LOREM_IPSUM, self.data.get('lorem_ipsum'))
endfunction
function! s:tc.test_data_get_block()
  call self.assert_equal(s:LOREM_IPSUM_BLOCK, self.data.get('lorem_ipsum', '['))
endfunction
function! s:tc.test_data_get_char()
  call self.assert_equal(s:LOREM_IPSUM_CHAR, self.data.get('lorem_ipsum', '[', 'char'))
endfunction

function! s:tc.test_data_execute()
  call self.data.execute('sort', 'lorem_ipsum')
  call self.assert_equal(s:LOREM_IPSUM_SORTED, self.data.get('lorem_ipsum'))
endfunction

function! s:tc.test_data_visual_execute()
  call self.data.visual_execute('sort', 'lorem_ipsum')
  call self.assert_equal(s:LOREM_IPSUM_SORTED, self.data.get('lorem_ipsum'))
endfunction

function! s:tc.test_data_line_range()
  let range = self.data.line_range('lorem_ipsum')
  let expected = [s:LINE_BEG, s:LINE_END]
  call self.assert_equal(expected, range)
endfunction

function! s:tc.test_data_block_range()
  let range = self.data.block_range('lorem_ipsum', '[')
  let expected = [[s:LINE_BEG, s:COL_BEG], [s:LINE_END, s:COL_END]]
  call self.assert_equal(expected, range)
endfunction

function! s:tc.test_data_char_range()
  let range = self.data.char_range('lorem_ipsum', '[')
  let expected = [[s:LINE_BEG, s:COL_BEG], [s:LINE_END, s:COL_END]]
  call self.assert_equal(expected, range)
endfunction

function! s:tc.setup_data_uncomment()
  function! self.data.uncomment(line)
    return substitute(a:line, '^# ', '', '')
  endfunction
endfunction
function! s:tc.test_data_uncomment()
  let expected = ['TEST DATA EMBEDDED AS COMMENT']
  call self.assert_equal(expected, self.data.get('commented'))
endfunction
function! s:tc.teardown_data_uncomment()
  call remove(self.data, 'uncomment')
endfunction

unlet s:tc
