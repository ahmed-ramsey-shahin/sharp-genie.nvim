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

return M
