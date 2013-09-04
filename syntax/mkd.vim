" We're now using Tim Pope's vim-markdown.  Delegate to it.
runtime! syntax/markdown.vim
unlet b:current_syntax
let b:current_syntax = "mkd"
