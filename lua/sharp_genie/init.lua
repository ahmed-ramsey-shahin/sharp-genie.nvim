local M = {}
local ui = require("sharp_genie.ui")

local augroup = vim.api.nvim_create_augroup("sharp_genie_augroup", { clear = true })

local default_config = {
	width = 50,
	height = 15,
	border = "rounded",
}

M.config = vim.tbl_deep_extend("force", {}, default_config)

M.open_sharp_genie = function()
	local win, buf = ui.create_buffer(M.config)
end

M.setup = function(user_config)
    M.config = vim.tbl_deep_extend("force", default_config, user_config or {})
end

return M
