local M = {}

---------------------------------------------------------------
-- LSP
---------------------------------------------------------------

-- Table of language servers to configure.
M.servers = {
    clangd = {
        executable = 'clangd',
        settings = {},
    },
    pylsp = {
        executable = 'pylsp',
        settings = {
            pylsp = {
                plugins = {
                    black = {
                        enabled = true,
                        line_length = 79,
                    },
                    mypy = {
                        enabled = true,
                    },
                    ruff = {
                        enabled = true,
                    },
                }
            }
        },
    },
    rust_analyzer = {
        executable = 'rust-analyzer',
        settings = {},
    },
}


M.lsp_on_attach = function(client, bufnr)
    local nmap = function(keys, func, desc)
        if desc then
            desc = 'LSP: ' .. desc
        end
        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end

    local nmapif = function(keys, func, desc, method)
        if client.supports_method('textDocument/' .. method) then
            nmap(keys, func, desc)
        end
    end

    nmapif('K', vim.lsp.buf.hover, 'Hover symbol details', 'hover')
    nmapif('<Space>lR', vim.lsp.buf.rename, 'Rename current symbol', 'rename')
    nmapif('<Space>la', vim.lsp.buf.code_action, 'Code Action', 'codeAction')
    nmapif('<Space>lh', vim.lsp.buf.signature_help, 'Signature help',
        'signatureHelp')
    nmapif('gD', vim.lsp.buf.declaration, 'Go to Declaration', 'declaration')

    nmapif('<Space>=', vim.lsp.buf.format, 'Format buffer', 'formatting')
    nmapif('<Space>lf', vim.lsp.buf.format, 'Format buffer', 'formatting')

    if client.supports_method('workspace/symbol') then
        nmap('<Space>lG', vim.lsp.buf.workspace_symbol,
            'Find Workspace Symbols')
    end

end

---------------------------------------------------------------
-- null-ls
---------------------------------------------------------------

local null_ls = require('null-ls')

M.shellcheck_exclusions = {
    "SC1090",   -- Can't follow non-constant source.
    "SC2016",   -- Expressions don't expand in single quotes.
}

M.null_ls_setup = function()
    null_ls.setup {
        sources = {
            null_ls.builtins.formatting.stylua,

            null_ls.builtins.formatting.shfmt,
            null_ls.builtins.diagnostics.shellcheck.with({
                extra_args = {
                    "--exclude=" .. table.concat(M.shellcheck_exclusions, ","),
                },
            }),

        },
    }
end

------------------------------------------------------------------------------
-- lsp setup
------------------------------------------------------------------------------

M.setup = function()
    local server
    local config
    for server, config in pairs(M.servers) do
        local on_attach = config.on_attach or M.lsp_on_attach
        local capabilities = require('cmp_nvim_lsp').default_capabilities()
        if vim.fn.executable(config.executable) == 1 then
            require('lspconfig')[server].setup {
                on_attach = on_attach,
                settings = config.settings,
                capabilities = capabilities,
            }
        end
    end

    local nmap = function(keys, func, desc)
        vim.keymap.set('n', keys, func, { desc = desc })
    end

    -- Key bindings that are related to the language but not associated
    -- with a specific LSP.
    nmap('<Space>ld', vim.diagnostic.open_float, 'Line Diagnostics')
    nmap('<Space>lq', vim.diagnostic.setloclist,
        'copy diagnostics into Location List')
    nmap('[d', vim.diagnostic.goto_prev, 'Go to Previous Diagnostic')
    nmap(']d', vim.diagnostic.goto_next, 'Go to Next Diagnostic')
    nmap('<Space>li', '<Cmd>LspInfo<CR>', 'LSP Information')
    nmap('<Space>lI', '<Cmd>NullLsInfo<CR>', 'Null-ls LSP Information')

    M.null_ls_setup()
end

return M
