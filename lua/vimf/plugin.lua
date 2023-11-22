local M = {}

M.enabled = function(plugin_name)
    return vim.fn["vimf#plugin#enabled"](plugin_name)
end

M.enable = function(plugin_name)
    return vim.fn["vimf#plugin#enable"](plugin_name)
end

M.disable = function(plugin_name)
    return vim.fn["vimf#plugin#disable"](plugin_name)
end

return M
