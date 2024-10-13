local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "dfmt",
    meta = {
        url = "https://github.com/dlang-community/dfmt",
        description = "Formatter for D source code.",
    },
    method = FORMATTING,
    filetypes = { "d" },
    generator_opts = {
        command = "dfmt",
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
