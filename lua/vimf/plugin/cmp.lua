local M = {}

---------------------------------------------------------------
-- cmp
---------------------------------------------------------------

local cmp = require('cmp')

M.settings = {
    snippet = {
        -- Specify a snippet engine (required).
        expand = function(args)
            vim.fn["UltiSnips#Anon"](args.body)
        end,
    },
    window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        -- Use `select=false` to require explicit selection of menu items;
        -- otherwise, a `<CR>` pressed with the goal of inserting a newline
        -- can be intercepted to select the first menu option.
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
    }),
    sources = cmp.config.sources(
        {
            { name = 'nvim_lsp' },
            -- For now, disabling support for UltiSnips as a source because
            -- it's unusably slow in `.c` files when there are a large number of
            -- snippets (have 1800+ snippets in some cases).
            -- An alternative that didn't work effectively is to allow caching
            -- of the snippets in `cmp_nvim_ultisnips`.  This still has the
            -- annoyance of a one-time lengthy delay at first editing, and it
            -- also didn't seem to fix the performance issues entirely.
            -- To experiment with allowing caching in the plugin, use this:
            --   require('cmp_nvim_ultisnips').setup {
            --       show_snippets = "all",
            --   }
            -- { name = 'ultisnips' },
        },
        {
            { name = 'buffer' },
        }
    ),
}

M.setup = function()
    cmp.setup(M.settings)

    -- TODO: This interferes with cmdline history for some reason.
    -- local cmdline_mapping = function()
    --     -- Fallback function that always falls back.
    --     local fb = function (fallback) fallback() end

    --     -- Start with `cmp` default mapping for cmdline mode.
    --     local mapping = cmp.mapping.preset.cmdline()
    --     -- These keys must be spelled exactly as below, as Lua is case-sensitive
    --     -- and would allow both `<C-p>` and `<C-P>` to exist (for example).
    --     -- mapping['<C-P>'] = fb
    --     -- mapping['<C-N>'] = fb
    --     mapping['<C-P>'] = nil
    --     mapping['<C-N>'] = nil
    --     -- TODO: I've got some `:cmap` stuff that might be interfering.
    --     print('mapping:')
    --     for key,_ in pairs(mapping) do
    --         print(key)
    --     end
    --     return mapping
    -- end

    -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this
    -- won't work anymore).
    -- TODO: This interferes with search history for some reason.
    -- cmp.setup.cmdline({ '/', '?' }, {
    --     mapping = cmdline_mapping(),
    --     sources = {
    --         { name = 'buffer' }
    --     }
    -- })

    -- Use cmdline & path source for ':' (if you enabled `native_menu`, this
    -- won't work anymore).
    -- TODO: This interferes with cmdline history for some reason.
    -- cmp.setup.cmdline(':', {
    --     mapping = cmdline_mapping(),
    --     sources = cmp.config.sources({
    --         { name = 'path' },
    --     }, {
    --         { name = 'cmdline' },
    --     }),
    -- })

end

return M
