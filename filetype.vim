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
    au BufNewFile,BufRead *.ll setfiletype llvm
    au BufNewFile,BufRead *.txt setfiletype text
    au BufNewFile,BufRead *.wiki setfiletype Wikipedia
    au BufNewFile,BufRead *.{md,mkd,mdwn,mdown,markdown} setfiletype mkd
    au BufNewFile,BufRead *.rest setfiletype rst
    au BufNewFile,BufRead *.td setfiletype tablegen
    au BufNewFile,BufRead bash-fc-* SetupBashFixcommand
    au BufNewFile,BufRead svn-prop*.tmp setfiletype svn

    " Setup Git-related filetypes.
    au BufNewFile,BufRead *.git/MERGE_MSG setfiletype gitcommit
    au BufNewFile,BufRead *.git/modules/**/MERGE_MSG setfiletype gitcommit
    au BufNewFile,BufRead *.git/TAG_EDITMSG setfiletype gitrelated
    au BufNewFile,BufRead *.git/modules/**/TAG_EDITMSG setfiletype gitrelated
    au BufNewFile,BufRead *.git/NOTES_EDITMSG setfiletype gitrelated
    au BufNewFile,BufRead *.git/modules/**/NOTES_EDITMSG setfiletype gitrelated

    " Use the copy and overwrite mechanism on crontab files, otherwise crontab
    " may not see the changes we make.
    au FileType crontab setlocal backupcopy=yes

    " Setup tmux conf files.
    au BufNewFile,BufRead .tmux.conf*,tmux.conf* setf tmux
augroup END
