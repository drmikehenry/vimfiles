local M = {}

---------------------------------------------------------------
-- cscope_maps
---------------------------------------------------------------

local csm = require("cscope_maps")

M.settings = {
    -- `true` disables default keymaps.
    -- NOTE: Always disable the built-in maps; adjust mappings in `M.mappings`
    -- below to configure.
    disable_maps = true,

    -- `true` doesn't ask for input.
    skip_input_prompt = false,

    -- `cscope` related defaults.
    cscope = {
        -- Location of cscope `db` file.
        db_file = "./cscope.out",

        -- `cscope` executable: "cscope", "gtags-cscope"
        exec = "cscope",

        -- Choice of picker: "telescope", "fzf-lua", "quickfix"
        picker = "telescope",

        -- `true` to JUMP without opening picker when there's only one result.
        skip_picker_for_single_result = false,

        -- Args that are directly passed to `cscope -f <db_file> <args>`.
        db_build_cmd_args = { "-bqkv" },

        -- Statusline indicator; default is the cscope executable (if `nil`).
        statusline_indicator = nil,
    }
}

M.get_cscope_prompt_cmd = function(operation, selection)
    -- Word under cursor.
    local sel = "cword"
    if selection == "f" then
        -- File under cursor.
        sel = "cfile"
    end

    local csp = "<CMD>lua require('cscope_maps').cscope_prompt"
    return string.format(
        "%s('%s', vim.fn.expand('<%s>'))<CR>",
        csp,
        operation,
        sel
    )
end

M.mappings = {
    n = {
        ["<Space>ca"] = {
            M.get_cscope_prompt_cmd("a", "w"),
            "Find assignments to symbol",
        },
        ["<Space>cb"] = {
            "<CMD>Cscope build<CR>",
            "Build database",
        },
        ["<Space>cc"] = {
            M.get_cscope_prompt_cmd("c", "w"),
            "Find callers of this func",
        },
        ["<Space>cd"] = {
            M.get_cscope_prompt_cmd("d", "w"),
            "Find called funcs from this func",
        },
        ["<Space>ce"] = {
            M.get_cscope_prompt_cmd("e", "w"),
            "Find egrep pattern",
        },
        ["<Space>cf"] = {
            M.get_cscope_prompt_cmd("f", "f"),
            "Find file",
        },
        ["<Space>cg"] = {
            M.get_cscope_prompt_cmd("g", "w"),
            "Find global definition",
        },
        ["<Space>ci"] = {
            M.get_cscope_prompt_cmd("i", "f"),
            "Find #includers of this file",
        },
        ["<Space>cs"] = {
            M.get_cscope_prompt_cmd("s", "w"),
            "Find symbol",
        },
        ["<Space>ct"] = {
            M.get_cscope_prompt_cmd("t", "w"),
            "Find text string",
        },
    }
}

M.setup = function()
    require('cscope_maps').setup(M.settings)
    require('vimf.utils').set_mappings(
        M.mappings,
        {desc_prefix="cscope: "}
    )
end

return M
