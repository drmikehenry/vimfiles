local M = {}

function M.table_shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

-- `mappings` is a table of key mappings to set, e.g.:
--     mappings = {
--         [mode] = {
--             [lhs] = details;
--             [lhs] = details;
--         }
--         [mode2] = {
--             [lhs] = details;
--             [lhs] = details;
--         }
--     }
--
--   `mode` is a mapping mode such as `"n"` (normal mode).
--
--   `details` is a table with mandatory positional keys:
--     [1] = right-hand side of mapping.
--     [2] = user-facing description of mapping.
--   and optional keys:
--     ["map_opts"] = options for `vim.keymap.set()`.
--
--   For example:
--
--     mappings = {
--         n = {
--             ["<Space>bb"] = {tsb.buffers, "Browse Buffers"},
--         },
--     }
--
-- `opts` is an optional table of options with keys:
-- - ["desc_prefix"] = prefix for the description.
M.set_mappings = function(mappings, opts)
    opts = opts or {}
    local desc_prefix = opts.desc_prefix or ""
    local mode
    local value
    for mode, value in pairs(mappings) do
        local lhs
        local details
        for lhs, details in pairs(value) do
            local rhs = details[1]
            local desc = details[2]
            local map_opts = M.table_shallow_copy(details.map_opts or {})
            map_opts.desc = desc_prefix .. desc
            vim.keymap.set(mode, lhs, rhs, map_opts)
        end
    end
end

return M
