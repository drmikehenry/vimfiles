local M = {}

---------------------------------------------------------------
-- Overall setup
---------------------------------------------------------------

M.setup = function()
    vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
end

return M
