local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

return h.make_builtin({
    name = "rufo",
    meta = {
        url = "https://github.com/ruby-formatter/rufo",
        description = "Opinionated ruby formatter.",
    },
    method = FORMATTING,
    filetypes = { "ruby" },
    generator_opts = {
        command = "rufo",
        args = { "-x" },
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
