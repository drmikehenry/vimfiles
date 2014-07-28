" unittest.vim's test suite

let s:here = expand('<sfile>:p:h')
execute 'source' s:here . '/test_context.vim'
execute 'source' s:here . '/test_data.vim'
execute 'source' s:here . '/test_setup.vim'
execute 'source' s:here . '/test_should.vim'
execute 'source' s:here . '/test_should_setup.vim'
