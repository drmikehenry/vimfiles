--[[
This file will eventually be removed.  Instead of sourcing this file from
`~/.config/nvim/init.lua`, following the directions in `vimfiles/doc/notes.txt`
to setup `~/.config/nvim/init.vim` to directly source `~/.vim/vimrc`, e.g.:

    source ~/.vim/vimrc

--]]

local dot_vim = vim.fn.expand('<sfile>:p:h')

vim.cmd('source ' .. dot_vim .. '/vimrc')
