--[[
Source this file from Neovim's `init.lua` file:

- On Linux, this is `~/.config/nvim/init.lua`

Example contents:

    -- Chain to startup file in vimfiles:
    vim.cmd('source ~/.vim/init.lua')

--]]

local dot_vim = vim.fn.expand('<sfile>:p:h')

vim.opt.runtimepath:prepend(dot_vim)
vim.opt.runtimepath:append(dot_vim .. '/after')

vim.opt.runtimepath:prepend(dot_vim .. '/nvim')
vim.opt.runtimepath:append(dot_vim .. '/nvim/after')

-- TODO: Setting `packpath` like this from online examples.
-- Not sure yet if this is useful.
vim.o.packpath = vim.o.runtimepath

vim.cmd('source ' .. dot_vim .. '/vimrc')
