local M = {}


-- mappings is a table of key mappings to set, e.g.:
--   mappings = {
--       n = {
--           ["<Space>bb"] = {tsb.buffers, "Browse Buffers"},
--       },
--   }
--
-- opts is an optional table of additional options.
-- - opts.desc_prefix is an option prefix for the description.
M.set_mappings = function(mappings, opts)
    opts = opts or {}
    local desc_prefix = opts.desc_prefix or ""
    local mode
    local value
    for mode, value in pairs(mappings) do
        local lhs
        local mapping
        for lhs, mapping in pairs(value) do
            local rhs = mapping[1]
            local desc = mapping[2]
            local map_opts = mapping[3] or {}
            map_opts.desc = desc_prefix .. desc
            vim.keymap.set(mode, lhs, rhs, map_opts)
        end
    end
end

return M
