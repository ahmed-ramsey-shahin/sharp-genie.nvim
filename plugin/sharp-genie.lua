vim.api.nvim_create_user_command('SharpGenie', function()
    require('sharp_genie').open_sharp_genie()
end, { desc = "Open sharp-genie" })
