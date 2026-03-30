vim.api.nvim_create_user_command('SharpGenie', function()
    require('sharp_genie').open_todo_list()
end, { desc = "Open sharp-genie" })
