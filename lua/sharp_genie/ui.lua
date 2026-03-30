local M = {}

M.create_buffer = function(config)
	local screen_width = vim.opt.columns:get()
	local screen_height = vim.opt.lines:get()
	local row = math.floor((screen_height - config.height) / 2)
	local col = math.floor((screen_width - config.width) / 2)
    local buf = vim.api.nvim_create_buf(false, true)
    local win_opts = {
        relative = "editor",
        width = config.width,
        height = config.height,
        row = row,
        col = col,
        style = "minimal",
        border = config.border,
    }
    local win = vim.api.nvim_open_win(buf, true, win_opts)
    vim.keymap.set("n", "q", ":close<CR>", {
        noremap = true,
        silent = true,
        buffer = buf,
    })
    return win, buf
end

M.draw_marks = function(config, buf, ns_id, properties)
    vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
    for _, property in ipairs(properties) do
        local access_modifier_highlight = ""
        if property.access_modifier == "public" then
            access_modifier_highlight = "DiagnosticOk"
        elseif property.access_modifier == "private" then
            access_modifier_highlight = "DiagnosticError"
        elseif property.access_modifier == "protected" then
            access_modifier_highlight = "DiagnosticWarn"
        end
        local mark_opts = {
            virt_text = {
                { string.format("Access Modifier: %s", property.access_modifier), access_modifier_highlight },
                { " | ", "Comment" },
                { string.format("Get: %s", property.get and config.true_icon or config.false_icon), property.get and "DiagnosticOk" or "DiagnosticError" },
                { " | ", "Comment" },
                { string.format("Set: %s", property.set and config.true_icon or config.false_icon), property.set and "DiagnosticOk" or "DiagnosticError" },
                { " | ", "Comment" },
                { string.format("Init: %s", property.init and config.true_icon or config.false_icon), property.init and "DiagnosticOk" or "DiagnosticError" },
            },
            virt_text_pos = "eol",
            hl_mode = "combine",
        }
        vim.api.nvim_buf_set_extmark(buf, ns_id, property.line_number, 0, mark_opts)
    end
end

return M
