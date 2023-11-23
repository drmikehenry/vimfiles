local M = {}

---------------------------------------------------------------
-- Overall setup for Neovim
---------------------------------------------------------------

M.setup = function()
    vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
    require('vimf.plugin.cmp').setup()
    require('vimf.plugin.lsp').setup()
    require('vimf.plugin.telescope').setup()
    require('vimf.plugin.which-key').setup()
end

return M
