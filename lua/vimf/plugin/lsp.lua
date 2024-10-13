local M = {}

---------------------------------------------------------------
-- LSP
---------------------------------------------------------------

-- Enable debug if desired:
-- vim.lsp.set_log_level("debug")

-- Table of language servers to configure.
M.servers = {
    clangd = {
        executable = "clangd",
        settings = {},
    },
    lua_ls = {
        executable = "lua-language-server",
        cmd = {
            "lua-language-server",
            "--logpath",
            vim.fn.stdpath("cache") .. "/lua-language-server/",
            "--metapath",
            vim.fn.stdpath("cache") .. "/lua-language-server/meta/"
        },
        settings = {},
        on_init = function(client)
            local path = client.workspace_folders[1].name
            if (not vim.loop.fs_stat(path .. "/.luarc.json")
                    and not vim.loop.fs_stat(path .. "/.luarc.jsonc")) then
                client.config.settings = vim.tbl_deep_extend(
                    "force", client.config.settings, {
                        Lua = {
                            runtime = {
                                -- Tell the language server which version of
                                -- Lua you"re using (most likely LuaJIT in the
                                -- case of Neovim).
                                version = "LuaJIT"
                            },
                            -- Make the server aware of Neovim runtime files.
                            workspace = {
                                checkThirdParty = false,
                                -- Can define individual top-level directories:
                                -- library = {
                                --     -- vim.env.VIMRUNTIME
                                --     vim.env.VIMRUNTIME
                                --     -- "${3rd}/luv/library"
                                --     -- "${3rd}/busted/library",
                                -- }
                                -- Or pull in all of 'runtimepath'.
                                library = vim.api.nvim_get_runtime_file("", true)
                            }
                        }
                    }
                )

                vim.print(client.config.settings)
                client.notify(
                    "workspace/didChangeConfiguration",
                    {
                        settings = client.config.settings
                    }
                )
            end
            return true
        end
    },
    pylsp = {
        executable = "pylsp",
        settings = {
            pylsp = {
                plugins = {
                    black = {
                        enabled = true,
                        line_length = 79,
                    },
                    pylsp_mypy = {
                        enabled = true,
                        overrides = {
                            "--python-executable",
                            "python",
                            -- `true` means "insert other arguments here".
                            true,
                        }
                    },
                    pycodestyle = {
                        enabled = false,
                    },
                    pylint = {
                        enabled = false,
                    },
                    ruff = {
                        enabled = true,
                    },
                }
            }
        },
    },
    rust_analyzer = {
        executable = "rust-analyzer",
        settings = {},
    },
}


-- Key bindings that are related to the language but not associated
-- with a specific LSP.
M.mappings = {
    n = {
        ["<Space>ld"] = { vim.diagnostic.open_float, "Line Diagnostics" },
        ["<Space>lq"] = {
            vim.diagnostic.setloclist,
            "copy diagnostics into Location List",
        },
        ["[d"] = { vim.diagnostic.goto_prev, "Go to Previous Diagnostic" },
        ["]d"] = { vim.diagnostic.goto_next, "Go to Next Diagnostic" },
        ["<Space>li"] = { "<Cmd>LspInfo<CR>", "LSP Information" },
        ["<Space>lI"] = { "<Cmd>NullLsInfo<CR>", "Null-ls LSP Information" },
    }
}


-- Per-buffer mappings to LSP methods.
M.lsp_mappings = {
    n = {
        ["<Space>la"] = {
            vim.lsp.buf.code_action,
            "Code Action",
            method = "textDocument/codeAction",
        },
        ["<Space>lh"] = {
            vim.lsp.buf.hover,
            "Hover info at cursor",
            method = "textDocument/hover info",
        },
        ["<Space>lR"] = {
            vim.lsp.buf.rename,
            "Rename current symbol",
            method = "textDocument/rename",
        },
        ["<Space>ls"] = {
            vim.lsp.buf.signature_help,
            "Signature help",
            method = "textDocument/signatureHelp",
        },
        ["gD"] = {
            vim.lsp.buf.declaration,
            "Go to Declaration",
            method = "textDocument/declaration",
        },
        ["<Space>="] = {
            vim.lsp.buf.format,
            "Format buffer",
            method = "textDocument/formatting",
        },
        ["<Space>lf"] = {
            vim.lsp.buf.format,
            "Format buffer",
            method = "textDocument/formatting",
        },
        ["<Space>lG"] = {
            vim.lsp.buf.workspace_symbol,
            "Find Workspace Symbols",
            method = "workspace/symbol",
        },
    }
}

M.set_lsp_mappings = function(client, bufnr, lsp_mappings, opts)
    local utils = require("vimf.utils")
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
                    { [mode] = { [lhs] = details } },
                    opts
                )
            end
        end
    end
end


M.lsp_on_attach = function(client, bufnr)
    opts = { desc_prefix = "LSP: " }
    M.set_lsp_mappings(client, bufnr, M.lsp_mappings, opts)
end

---------------------------------------------------------------
-- null-ls
---------------------------------------------------------------

local null_ls = require("null-ls")
local shellcheck_code_actions = require("none-ls-shellcheck.code_actions")
local shellcheck_diagnostics = require("none-ls-shellcheck.diagnostics")

M.shellcheck_exclusions = {
    "SC1090", -- Can't follow non-constant source.
    "SC2016", -- Expressions don't expand in single quotes.
}

M.null_ls_setup = function()
    null_ls.setup {
        sources = {
            null_ls.builtins.formatting.stylua,

            null_ls.builtins.formatting.shfmt,
            shellcheck_code_actions,
            -- shellcheck_diagnostics,
            shellcheck_diagnostics.with({
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
        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        if vim.fn.executable(config.executable) == 1 then
            require("lspconfig")[server].setup {
                on_init = config.on_init,
                on_attach = on_attach,
                cmd = config.cmd,
                settings = config.settings,
                capabilities = capabilities,
            }
        end
    end

    local utils = require("vimf.utils")
    utils.set_mappings(M.mappings)

    M.null_ls_setup()
end

return M
