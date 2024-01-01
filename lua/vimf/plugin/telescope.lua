local M = {}

---------------------------------------------------------------
-- telescope
---------------------------------------------------------------

local tsb = require("telescope.builtin")

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
                ["<C-u>"] = false,
                ["<C-d>"] = false,
            },
        },
    },
}

M.mappings = {
    n = {
        ["<Space>bb"] = {tsb.buffers, "Browse Buffers"},
        ["<Space>f'"] = {tsb.marks, "Find marks"},
        ["<Space>fb"] = {tsb.buffers, "Find Buffers"},
        ["<Space>pf"] = {tsb.find_files, "Find Files at project root"},

        -- Duplicative but easier to type.
        ["<Space>pp"] = {tsb.find_files, "Find Files at project root"},
        ["<Space>ff"] = {
            function()
                tsb.find_files {
                    cwd=vim.fn["expand"]("%:p:h"),
                }
            end,
            "Find Files at current file"
        },
        ["<Space>fh"] = {tsb.help_tags, "Find Help tags"},
        ["<Space>fk"] = {tsb.keymaps, "Find Keymaps"},
        ["<Space>fm"] = {
            function()
                tsb.man_pages({sections={"ALL"}})
            end,
            "Find Man pages"
        },
        ["<Space>fq"] = {tsb.quickfix, "Find in QuickFix list"},
        ["<Space>ft"] = {tsb.tags, "Tags in current dir"},
        ["<Space>fT"] = {tsb.current_buffer_tags, "Tags in current buffer"},
        ["<Space>lD"] = {tsb.diagnostics, "all Line Diagnostics"},
        ["gd"] = {tsb.lsp_definitions, "LSP: Go to Definition"},
        ["gI"] = {tsb.lsp_implementations, "LSP: Go to Implementation"},
        ["gT"] = {tsb.lsp_type_definitions, "LSP: Go to Type Definition"},
        ["<Space>lr"] = {tsb.lsp_references, "LSP: References"},
        ["gr"] = {tsb.lsp_references, "LSP: References"},
    }
}

M.setup = function()
    require('telescope').setup(M.settings)
    require('vimf.utils').set_mappings(
        M.mappings,
        {desc_prefix="Telescope: "}
    )
end

return M
