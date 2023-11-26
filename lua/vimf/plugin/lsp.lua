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


-- Key bindings that are related to the language but not associated
-- with a specific LSP.
M.mappings = {
    n = {
        ["<Space>ld"] = {vim.diagnostic.open_float, "Line Diagnostics"};
        ["<Space>lq"] = {
            vim.diagnostic.setloclist,
            "copy diagnostics into Location List",
        };
        ["[d"] = {vim.diagnostic.goto_prev, "Go to Previous Diagnostic"};
        ["]d"] = {vim.diagnostic.goto_next, "Go to Next Diagnostic"};
        ["<Space>li"] = {"<Cmd>LspInfo<CR>", "LSP Information"};
        ["<Space>lI"] = {"<Cmd>NullLsInfo<CR>", "Null-ls LSP Information"};
    }
}


-- Per-buffer mappings to LSP methods.
M.lsp_mappings = {
    n = {
        ["<Space>la"] = {
            vim.lsp.buf.code_action,
            "Code Action",
            method="textDocument/codeAction",
        };
        ["<Space>lh"] = {
            vim.lsp.buf.hover,
            "Hover info at cursor",
            method="textDocument/hover info",
        };
        ["<Space>lR"] = {
            vim.lsp.buf.rename,
            "Rename current symbol",
            method="textDocument/rename",
        };
        ["<Space>ls"] = {
            vim.lsp.buf.signature_help,
            "Signature help",
            method="textDocument/signatureHelp",
        };
        ["gD"] = {
            vim.lsp.buf.declaration,
            "Go to Declaration",
            method="textDocument/declaration",
        };
        ["<Space>="] = {
            vim.lsp.buf.format,
            "Format buffer",
            method="textDocument/formatting",
        };
        ["<Space>lf"] = {
            vim.lsp.buf.format,
            "Format buffer",
            method="textDocument/formatting",
        };
        ["<Space>lG"] = {
            vim.lsp.buf.workspace_symbol,
            "Find Workspace Symbols",
            method="workspace/symbol",
        };
    }
}

M.set_lsp_mappings = function(client, bufnr, lsp_mappings, opts)
    local utils = require('vimf.utils')
    local mode
    local value
    for mode, value in pairs(lsp_mappings) do
        local lhs
        local details
        for lhs, details in pairs(value) do
            if client.supports_method(details.method) then
                details = utils.table_shallow_copy(details)
                details.map_opts = utils.table_shallow_copy(
                    details.map_opts or {}
                )
                details.map_opts.buffer = bufnr
                utils.set_mappings(
                    {[mode] = {[lhs] = details}},
                    opts
                )
            end
        end
    end
end


M.lsp_on_attach = function(client, bufnr)
    opts = {desc_prefix="LSP: "}
    M.set_lsp_mappings(client, bufnr, M.lsp_mappings, opts)
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

    local utils = require('vimf.utils')
    utils.set_mappings(M.mappings)

    M.null_ls_setup()
end

return M
