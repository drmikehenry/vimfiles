local M = {}

---------------------------------------------------------------
-- which-key
---------------------------------------------------------------

local which_key = require('which-key')

M.setup = function()
    which_key.setup {}
    which_key.register({
        ["<Space>b"] = { name = "+buffer" },
        ["<Space>f"] = { name = "+find" },
        ["<Space>j"] = { name = "+jump" },
        ["<Space>l"] = { name = "+language" },
        ["<Space>q"] = { name = "+toggle" },
        ["<Space>w"] = { name = "+window" },
        ["<Space>x"] = { name = "+text" },
        ["<Space>xd"] = { name = "+delete" },
    })
end

return M
