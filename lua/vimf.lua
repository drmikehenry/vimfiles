local M = {}

---------------------------------------------------------------
-- Overall setup for Neovim
---------------------------------------------------------------

M.setup = function()
    local plugin = require('vimf.plugin')
    vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
    if plugin.enabled("cmp") then
        require('vimf.plugin.cmp').setup()
    end
    if plugin.enabled("cscope_maps") then
        require('vimf.plugin.cscope_maps').setup()
    end
    if plugin.enabled("lsp") then
        require('vimf.plugin.lsp').setup()
    end
    if plugin.enabled("telescope") then
        require('vimf.plugin.telescope').setup()
    end
    if plugin.enabled("which-key") then
        require('vimf.plugin.which-key').setup()
    end
end

return M
