local M = {}

---------------------------------------------------------------
-- telescope
---------------------------------------------------------------

M.settings = {
    defaults = {
        layout_strategy = "flex",
        -- If fewer than `flip_columns` and at least `flip_lines`, use
        -- `vertical` layout; otherwise, use `horizontal`.
        layout_config = {
            flip_columns = 150,
            flip_lines = 20,
        },
        mappings = {
            i = {
                ['<C-u>'] = false,
                ['<C-d>'] = false,
            },
        },
    },
}

M.setup = function()
    require('telescope').setup(M.settings)

    local nmap = function(keys, func, desc)
        if desc then
            desc = 'Telescope: ' .. desc
        end
        vim.keymap.set('n', keys, func, { desc = desc })
    end

    telescope = require('telescope.builtin')

    nmap('<Space>bb', telescope.buffers, 'Browse Buffers')
    nmap("<Space>f'", telescope.marks, "Find marks")
    nmap('<Space>fb', telescope.buffers, 'Find Buffers')
    nmap('<Space>ff', telescope.find_files, 'Find Files')
    nmap('<Space>fh', telescope.help_tags, 'Find Help tags')
    nmap('<Space>fk', telescope.keymaps, 'Find Keymaps')
    nmap(
        '<Space>fm',
        function()
            telescope.man_pages({sections={'ALL'}})
        end,
        'Find Man pages'
    )
    nmap('<Space>lD', telescope.diagnostics, 'all Line Diagnostics (telescope)')
    nmap('gd', telescope.lsp_definitions, 'LSP: Go to Definition (telescope)')
    nmap('gI', telescope.lsp_implementations,
        'LSP: Go to Implementation (telescope)')
    nmap('gT', telescope.lsp_type_definitions,
        'LSP: Go to Type Definition (telescope)')
    nmap('<Space>lr', telescope.lsp_references, 'LSP: References (telescope)')
    nmap('gr', telescope.lsp_references, 'LSP: References (telescope)')

end

return M
