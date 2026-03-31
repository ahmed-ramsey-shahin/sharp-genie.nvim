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

local function toggle_property(buf, p)
    local line = vim.api.nvim_win_get_cursor(0)[1] - 1
    for _, property in ipairs(properties) do
        if property.line_number == line then
            property[p] = not property[p]
        end
    end
    ui.draw_marks(M.config, buf, ns_id, properties)
end

local function properties_to_text()
    local content = {}
    for _, property in ipairs(properties) do
        local get_part = property.get and "get; " or ""
        local set_part = ""
        if property.set then
            set_part = "set; "
        elseif property.init then
            set_part = "init; "
        end
        table.insert(
            content,
            property.access_modifier
            .. " "
            .. property.data_type
            .. " "
            .. property.name
            .. " "
            .. "{"
            .. " "
            .. get_part
            .. set_part
            .. "}"
        )
    end
    vim.print(content)
    return content
end

local function print_properties(win)
    local prev_buf = vim.fn.bufnr("#")
    if prev_buf == -1 or not vim.api.nvim_buf_is_loaded(prev_buf) then
        vim.notify("No previous buffer found!", vim.log.levels.WARN)
        return
    end
    local last_pos = vim.api.nvim_buf_get_mark(prev_buf, '^')
    local last_row = last_pos[1]
    if last_row == 0 then
        vim.notify("The buffer was never opened", vim.log.levels.WARN)
        return
    end
    last_row = last_row - 1
    local content = properties_to_text()
    local count = #content
    vim.api.nvim_buf_set_lines(prev_buf, last_row, last_row, false, content)
    vim.api.nvim_buf_call(prev_buf, function ()
        vim.cmd(string.format("normal! %dG%d==", last_row + 1, count))
    end)
    vim.api.nvim_win_close(win, false)
end

M.config = vim.tbl_deep_extend("force", {}, default_config)

M.open_sharp_genie = function()
	local win, buf = ui.create_buffer(M.config)
    vim.keymap.set("n", "<Tab>", function() tab_key_pressed(buf) end, { buffer = buf })
    vim.keymap.set("n", "1", function() toggle_property(buf, "get") end, { buffer = buf })
    vim.keymap.set("n", "2", function() toggle_property(buf, "set") end, { buffer = buf })
    vim.keymap.set("n", "3", function() toggle_property(buf, "init") end, { buffer = buf })
    vim.keymap.set("n", "q", function() print_properties(win) end, { buffer = buf })
    vim.keymap.set("n", "<A-q>", function() vim.api.nvim_win_close(win, false) end, { buffer = buf })
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
