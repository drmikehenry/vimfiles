" Customized filetypes by extension

if exists("did_load_filetypes")
    finish
endif

" By default, shell scripts are "kornshell" (same as "posix").
let g:is_kornshell = 1

augroup filetypedetect
    au!
    au BufNewFile,BufRead *.cxx setfiletype cpp
    au BufNewFile,BufRead *.dxy setfiletype c
    au BufNewFile,BufRead *.txt setfiletype text
    au BufNewFile,BufRead *.wiki setfiletype Wikipedia
    au BufNewFile,BufRead *.{md,mkd,mdwn,mdown,markdown} setfiletype mkd
    au BufNewFile,BufRead *.rest setfiletype rst
    au BufNewFile,BufRead bash-fc-* call SetupBashFixcommand()
    au BufNewFile,BufRead *.cljs setfiletype clojure

    " Use the copy and overwrite mechanism on crontab files, otherwise crontab
    " may not see the changes we make.
    au FileType crontab setlocal backupcopy=yes
augroup END
