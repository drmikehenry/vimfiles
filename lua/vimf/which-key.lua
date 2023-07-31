local M = {}

---------------------------------------------------------------
-- which-key
---------------------------------------------------------------

local which_key = require('which-key')

M.setup = function()
    which_key.setup {
        -- Note: disabling both `marks` and `registers` because of laggy
        -- behavior on slower machines.  The worst behavior comes from
        -- the use of `nvim_feedkeys()` without the `i` flag, causing
        -- sequences like `CTRL-r 0 moreStuff` to be processed out-of-order,
        -- with `moreStuff` coming before the value of register `0`.
        -- It's possible that using the `i` flag would fix the out-of-order
        -- issues, but these plugins don't add much value and best-case would
        -- cause typing lag even if the out-of-order behavior were fixed.
        plugins = {
            -- Shows a list of marks when pressing ' or `.
            marks = false,
            -- Show register values on pressing " (or CTRL-r in insert mode).
            registers = false,
        }
    }
    which_key.register {
        ["<Space>b"] = { name = "+buffer" },
        ["<Space>f"] = { name = "+find" },
        ["<Space>j"] = { name = "+jump" },
        ["<Space>l"] = { name = "+language" },
        ["<Space>q"] = { name = "+toggle" },
        ["<Space>w"] = { name = "+window" },
        ["<Space>x"] = { name = "+text" },
        ["<Space>xd"] = { name = "+delete" },
    }
end

return M
