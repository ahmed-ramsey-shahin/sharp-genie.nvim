local M = {}

local function pick_access_modifier_highlight(access_modifier)
    if access_modifier == "public" then
        return "DiagnosticOk"
    elseif access_modifier == "private" then
        return "DiagnosticError"
    elseif access_modifier == "protected" then
        return "DiagnosticWarn"
    elseif access_modifier == "internal" then
        return "DiagnosticInfo"
    end
    return "Comment"
end

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
        local separator = { string.format(" %s ", config.separator), "Comment" }
        local chunks = {
            { string.format("AM: %s", property.access_modifier), pick_access_modifier_highlight(property.access_modifier) },
            separator,
        }
        if property.extra_part and property.extra_part ~= "" then
            table.insert(chunks, { string.format("Extra: %s", property.extra_part), "DiagnosticInfo" })
            table.insert(chunks, separator)
        end
        if property.extra_access_modifier and property.extra_access_modifier ~= "" then
            table.insert(chunks, { string.format("Extra AM: %s", property.extra_access_modifier), pick_access_modifier_highlight(property.extra_access_modifier) })
        end
        local mark_opts = {
            virt_text = chunks,
            virt_text_pos = "eol",
            hl_mode = "combine",
        }
        vim.api.nvim_buf_set_extmark(buf, ns_id, property.line_number, 0, mark_opts)
    end
end

return M
