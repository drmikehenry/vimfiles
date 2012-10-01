" Customized filetypes by extension

if exists("did_load_filetypes")
    finish
endif

" By default, shell scripts are "kornshell" (same as "posix").
let g:is_kornshell = 1

augroup filetypedetect
    au!
    au BufNewFile,BufRead *.cxx setf cpp
    au BufNewFile,BufRead *.dxy setf c
    au BufNewFile,BufRead *.txt setf text
    au BufNewFile,BufRead *.wiki setf Wikipedia
    au BufNewFile,BufRead *.{md,mkd,mdwn,mdown,markdown} setf mkd
    au BufNewFile,BufRead *.{rest} setf rst
    au BufNewFile,BufRead bash-fc-* unlet g:is_kornshell | let g:is_bash=1 | setf sh | setl nospell | setl tw=0 | Highlight no*
    au BufNewFile,BufRead *.cljs setf clojure

    " Use the copy and overwrite mechanism on crontab files, otherwise crontab
    " may not see the changes we make.
    au FileType crontab setl backupcopy=yes
augroup END
