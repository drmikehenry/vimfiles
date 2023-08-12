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
    nmap('<Space>pf', telescope.find_files, 'Find Files at project root')

    -- Duplicative but easier to type.
    nmap('<Space>pp', telescope.find_files, 'Find Files at project root')
    nmap(
        '<Space>ff',
        function()
            telescope.find_files {
                cwd=vim.fn["expand"]("%:p:h"),
            }
        end,
        'Find Files at current file'
    )
    nmap('<Space>fh', telescope.help_tags, 'Find Help tags')
    nmap('<Space>fk', telescope.keymaps, 'Find Keymaps')
    nmap(
        '<Space>fm',
        function()
            telescope.man_pages({sections={'ALL'}})
        end,
        'Find Man pages'
    )
    nmap('<Space>ft', telescope.tags, 'Tags in current dir')
    nmap('<Space>fT', telescope.current_buffer_tags, 'Tags in current buffer')
    nmap('<Space>lD', telescope.diagnostics, 'all Line Diagnostics')
    nmap('gd', telescope.lsp_definitions, 'LSP: Go to Definition')
    nmap('gI', telescope.lsp_implementations, 'LSP: Go to Implementation')
    nmap('gT', telescope.lsp_type_definitions, 'LSP: Go to Type Definition')
    nmap('<Space>lr', telescope.lsp_references, 'LSP: References')
    nmap('gr', telescope.lsp_references, 'LSP: References')

end

return M
