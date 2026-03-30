local M = {}
local ui = require("sharp_genie.ui")
local augroup = vim.api.nvim_create_augroup("sharp_genie_augroup", { clear = true })
local ns_id = vim.api.nvim_create_namespace("sharp_genie_ns")
local default_config = {
	width = 70,
	height = 15,
	border = "rounded",
    true_icon = "✓",
    false_icon = "✗",
}

local function handle_inputs(buf)
    local properties = {}
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    for i, line in ipairs(lines) do
        local data_type, name = line:match("^%s*(.*)%s+(.*)%s*$")
        if data_type and name then
            table.insert(properties, {
                data_type = data_type,
                name = name,
                access_modifier = "public",
                get = true,
                set = true,
                init = false,
                line_number = i-1,
            })
        end
    end
    return properties
end

M.config = vim.tbl_deep_extend("force", {}, default_config)

M.open_sharp_genie = function()
	local _, buf = ui.create_buffer(M.config)
    vim.api.nvim_create_autocmd(
        { "InsertLeave", "TextChanged" },
        {
            group = augroup,
            buffer = buf,
            callback = function()
                local properties = handle_inputs(buf)
                ui.draw_marks(M.config, buf, ns_id, properties)
            end,
        }
    )
end

M.setup = function(user_config)
    M.config = vim.tbl_deep_extend("force", default_config, user_config or {})
end

return M
