" Customized filetypes by extension

if exists("did_load_filetypes")
    finish
endif

augroup szak_filetypedetect
    au!
    au BufNewFile,BufRead gitconfig setfiletype gitconfig
augroup END
