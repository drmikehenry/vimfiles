" Use the 'w' flag in formatoptions to setup format=flowed editing.
" The 'w' flag causes problems for wrapping when manual editing strips
" out a trailing space.  Better to avoid the flag...
" set formatoptions+=w
setlocal tw=64 sw=2 sts=2 et ai spell
