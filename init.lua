--[[
Source this file from Neovim's `init.lua` file:

- On Linux, this is `~/.config/nvim/init.lua`

Example contents:

    -- Chain to startup file in vimfiles:
    vim.cmd('source ~/.vim/init.lua')

--]]

local dot_vim = vim.fn.expand('<sfile>:p:h')

vim.cmd('source ' .. dot_vim .. '/vimrc')
