local M = {}

M.config = {
    --
}

M.setup = function(user_config)
    M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
end

M.open_sharp_genie = function()
    print("Opening your Todo List UI...")
end

return M
