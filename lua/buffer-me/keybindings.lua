local keybindings = {
	quit = { "n", "q", ':lua require("buffer-me.windower").close_window()<CR>', {} },
}

function keybindings.update_key_binding(func, custombind) end

function keybindings.map_keys(buf)
	vim.api.nvim_buf_set_keymap(buf, "n", "o", ':lua require("buffer-me.bufferme").open_selected_buffer()<CR>', {})
	vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", ':lua require("buffer-me.bufferme").open_selected_buffer()<CR>', {})
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"f",
		':lua require("buffer-me.bufferme").set_first_hotswap_from_window()<CR>',
		{}
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"s",
		':lua require("buffer-me.bufferme").set_second_hotswap_from_window()<CR>',
		{}
	)
	vim.api.nvim_buf_set_keymap(buf, "n", "g", ':lua require("buffer-me.bufferme").go_to_buffer()<CR>', {})
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ':lua require("buffer-me.windower").close_buffer_me()<CR>', {})
end

return keybindings
