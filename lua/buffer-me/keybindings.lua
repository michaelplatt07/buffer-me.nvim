local keybindings = {
	quit = {
		mode = "n",
		key = "q",
		func = ':lua require("buffer-me.windower").close_buffer_me()<CR>',
	},
	open = { mode = "n", key = "o", func = ':lua require("buffer-me.bufferme").open_selected_buffer()<CR>' },
	delete = {
		mode = "n",
		key = "d",
		func = ':lua require("buffer-me.keybindings").delete_and_re_render_buf_list()<CR>',
	},
	open_v_split = {
		mode = "n",
		key = "v",
		func = ':lua require("buffer-me.bufferme").open_selected_buffer_v_split()<CR>',
	},
	open_h_split = {
		mode = "n",
		key = "h",
		func = ':lua require("buffer-me.bufferme").open_selected_buffer_h_split()<CR>',
	},
	set_first_hotswap = {
		mode = "n",
		key = "f",
		func = ':lua require("buffer-me.bufferme").set_first_hotswap_from_window()<CR>',
	},
	set_second_hotswap = {
		mode = "n",
		key = "s",
		func = ':lua require("buffer-me.bufferme").set_second_hotswap_from_window()<CR>',
	},
	go_to = { mode = "n", key = "g", func = ':lua require("buffer-me.bufferme").go_to_buffer()<CR>' },
}

function keybindings.update_key_binding(func, custombind)
	keybindings[func].key = custombind
end

function keybindings.delete_and_re_render_buf_list()
	require("buffer-me.bufferme").remove_buf_current_selectded_buff()
	require("buffer-me.windower").re_render_buf_list_lines()
end

function keybindings.map_keys(buf)
	vim.api.nvim_buf_set_keymap(buf, keybindings.open.mode, keybindings.open.key, keybindings.open.func, {})
	vim.api.nvim_buf_set_keymap(buf, keybindings.delete.mode, keybindings.delete.key, keybindings.delete.func, {})
	vim.api.nvim_buf_set_keymap(
		buf,
		keybindings.open_v_split.mode,
		keybindings.open_v_split.key,
		keybindings.open_v_split.func,
		{}
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		keybindings.open_h_split.mode,
		keybindings.open_h_split.key,
		keybindings.open_h_split.func,
		{}
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		keybindings.set_first_hotswap.mode,
		keybindings.set_first_hotswap.key,
		keybindings.set_first_hotswap.func,
		{}
	)
	vim.api.nvim_buf_set_keymap(
		buf,
		keybindings.set_second_hotswap.mode,
		keybindings.set_second_hotswap.key,
		keybindings.set_second_hotswap.func,
		{}
	)
	vim.api.nvim_buf_set_keymap(buf, keybindings.go_to.mode, keybindings.go_to.key, keybindings.go_to.func, {})
	vim.api.nvim_buf_set_keymap(buf, keybindings.quit.mode, keybindings.quit.key, keybindings.quit.func, {})
end

return keybindings
