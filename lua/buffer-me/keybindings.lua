local keybindings = {
	quit = { "n", "q", ':lua require("buffer-me.windower").close_window()<CR>', {} },
}

function keybindings.update_key_binding(func, custombind) end

function keybindings.map_keys(buf)
	vim.api.nvim_buf_set_keymap(buf, "n", "<leader>o", ':lua require("buffer-me.bufferme").open_selected_buffer()<CR>', {})
	vim.api.nvim_buf_set_keymap(buf, "n", "<leader>g", ':lua require("buffer-me.bufferme").go_to_buffer()<CR>', {})
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ':lua require("buffer-me.windower").close_window()<CR>', {})
end

return keybindings
