" This has to be called before ftplugins are loaded. Therefore
" it is here in ftdetect though it maybe shouldn't

" This is necessary to prevent errors when using vim as a pager.
if exists("vimpager")
    finish
endif

if has("autocmd")
   augroup UltiSnipsFileType
      au!
      autocmd FileType * call UltiSnips#FileTypeChanged()
   augroup END
endif
