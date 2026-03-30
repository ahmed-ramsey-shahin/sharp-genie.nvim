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
local properties = {}

local function handle_inputs(buf)
    properties = {}
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
end

local function tab_key_pressed(buf)
    local line = vim.api.nvim_win_get_cursor(0)[1] - 1
    for _, property in ipairs(properties) do
        if property.line_number == line then
            if property.access_modifier == "public" then
                property.access_modifier = "private"
            elseif property.access_modifier == "private" then
                property.access_modifier = "protected"
            elseif property.access_modifier == "protected" then
                property.access_modifier = "public"
            end
        end
    end
    ui.draw_marks(M.config, buf, ns_id, properties)
end

M.config = vim.tbl_deep_extend("force", {}, default_config)

M.open_sharp_genie = function()
	local _, buf = ui.create_buffer(M.config)
    vim.keymap.set("n", "<Tab>", function() tab_key_pressed(buf) end)
    vim.api.nvim_create_autocmd(
        { "InsertLeave", "TextChanged" },
        {
            group = augroup,
            buffer = buf,
            callback = function()
                handle_inputs(buf)
                ui.draw_marks(M.config, buf, ns_id, properties)
            end,
        }
    )
end

M.setup = function(user_config)
    M.config = vim.tbl_deep_extend("force", default_config, user_config or {})
end

return M
