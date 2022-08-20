" Customized filetypes by extension

if exists("did_load_filetypes")
    finish
endif

" By default, shell scripts are "kornshell" (same as "posix").
let g:is_kornshell = 1

augroup filetypedetect
    au!

    " This needs to be before *.txt, otherwise CMakeLists.txt doesn't get the
    " correct filetype.
    au BufNewFile,BufRead CMakeLists.txt,*.cmake,*.cmake.in setfiletype cmake

    au BufNewFile,BufRead *.cxx setfiletype cpp
    au BufNewFile,BufRead *.dxy setfiletype c
    au BufNewFile,BufRead *.ll setfiletype llvm
    au BufNewFile,BufRead *.txt setfiletype text
    au BufNewFile,BufRead *.wiki setfiletype Wikipedia
    au BufNewFile,BufRead *.rest setfiletype rst
    au BufNewFile,BufRead *.td setfiletype tablegen
    au BufNewFile,BufRead bash-fc[-.]* SetupBashFixcommand
    au BufNewFile,BufRead leinrc setfiletype sh
    au BufNewFile,BufRead .pypirc setfiletype cfg
    au BufNewFile,BufRead .coveragerc setfiletype cfg
    au BufNewFile,BufRead Jenkinsfile setfiletype groovy

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

    " Treat .syntastic_c_config as vim.
    autocmd BufNewFile,BufRead .syntastic_c_config setfiletype vim

    " Salt server support.  Treat .sls files as yaml, unless #!py is at the top.
    autocmd BufNewFile,BufRead *.sls
                \ if getline(1) =~ "^#!py" |
                \   setfiletype python |
                \ else |
                \   setfiletype yaml |
                \ endif

    " ssh-related configuration:
    autocmd BufNewFile,BufRead */.ssh/config.d/*.conf setfiletype sshconfig
augroup END
