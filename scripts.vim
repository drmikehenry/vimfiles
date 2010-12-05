" User support file to detect file types in scripts

" This file is called by an autocommand for every file that has just been
" loaded into a buffer.  It checks if the type of file can be recognized by
" the file contents.  The autocommand is in $VIMRUNTIME/filetype.vim.

" The user-supplied scripts.vim file should chain $VIMRUNTIME/scripts.vim
" at the end.

" Only do the rest when the FileType autocommand has not been triggered yet.
if did_filetype()
    finish
endif

" Line continuation is used here, remove 'C' from 'cpoptions'
let s:cpo_save = &cpo
set cpo&vim

let s:line1 = getline(1)

if s:line1 =~ '^#format\s\+rst'
    set ft=rst
endif

" Restore 'cpoptions' and tidy up variables.
let &cpo = s:cpo_save
unlet s:cpo_save s:line1

" Chain to system-supplied scripts.vim file.
source $VIMRUNTIME/scripts.vim
