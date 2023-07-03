local M = {}

---------------------------------------------------------------
-- Overall setup for Neovim
---------------------------------------------------------------

M.setup = function()
    vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
    require('vimf.cmp').setup()
    require('vimf.lsp').setup()
    require('vimf.telescope').setup()
    require('vimf.which-key').setup()
end

return M
