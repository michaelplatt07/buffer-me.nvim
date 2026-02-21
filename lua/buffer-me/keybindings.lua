local keybindings = {
	quit = {
		mode = "n",
		key = "q",
	},
	quit_esc = {
		mode = "n",
		key = "<Esc>",
	},
	open = { mode = "n", key = "o" },
	delete = {
		mode = "n",
		key = "d",
	},
	open_v_split = {
		mode = "n",
		key = "v",
	},
	open_h_split = {
		mode = "n",
		key = "h",
	},
	set_first_hotswap = {
		mode = "n",
		key = "f",
	},
	set_second_hotswap = {
		mode = "n",
		key = "s",
	},
	go_to = { mode = "n", key = "g" },
}

local searchKeybindings = {
	move_up = {
		mode = "i",
		key = "<C-p>",
	},
	move_down = {
		mode = "i",
		key = "<C-n>",
	},
	arrow_move_up = {
		mode = "i",
		key = "<Up>",
	},
	arrow_move_down = {
		mode = "i",
		key = "<Down>",
	},
	open = {
		mode = "i",
		key = "<CR>",
	},
	open_v_split = {
		mode = "i",
		key = "<C-v>",
	},
	open_h_split = {
		mode = "i",
		key = "<C-h>",
	},
	close = {
		mode = "n",
		key = "q",
	},
	close_esc = {
		mode = "n",
		key = "<Esc>",
	},
	delete_i_mode = {
		mode = "i",
		key = "<C-d>",
	},
	delete_n_mode = {
		mode = "n",
		key = "d",
	},
}

function keybindings.update_key_binding(func, custombind)
	keybindings[func].key = custombind
end

function keybindings.delete_and_re_render_buf_list()
	require("buffer-me.bufferme").remove_buf_current_selectded_buff()
	require("buffer-me.windower").re_render_buf_list_lines()
end

function keybindings.map_keys(buf)
	vim.keymap.set(keybindings.open.mode, keybindings.open.key, function()
		require("buffer-me.windower").close_buffer_me()
	end, { buffer = buf })
	vim.keymap.set(keybindings.delete.mode, keybindings.delete.key, function()
		require("buffer-me.windower").close_buffer_me()
	end, { buffer = buf })
	vim.keymap.set(keybindings.open_v_split.mode, keybindings.open_v_split.key, function()
		require("buffer-me.bufferme").open_selected_buffer()
	end, { buffer = buf })
	vim.keymap.set(keybindings.open_h_split.mode, keybindings.open_h_split.key, function()
		require("buffer-me.keybindings").delete_and_re_render_buf_list()
	end, { buffer = buf })
	vim.keymap.set(keybindings.set_first_hotswap.mode, keybindings.set_first_hotswap.key, function()
		require("buffer-me.bufferme").open_selected_buffer_v_split()
	end, { buffer = buf })
	vim.keymap.set(keybindings.set_second_hotswap.mode, keybindings.set_second_hotswap.key, function()
		require("buffer-me.bufferme").open_selected_buffer_h_split()
	end, { buffer = buf })
	vim.keymap.set(keybindings.go_to.mode, keybindings.go_to.key, function()
		require("buffer-me.bufferme").set_first_hotswap_from_window()
	end, { buffer = buf })
	vim.keymap.set(keybindings.quit.mode, keybindings.quit.key, function()
		require("buffer-me.bufferme").set_second_hotswap_from_window()
	end, { buffer = buf })
	vim.keymap.set(keybindings.quit_esc.mode, keybindings.quit_esc.key, function()
		require("buffer-me.bufferme").go_to_buffer()
	end, { buffer = buf })
end

function keybindings.map_search_keys(buf)
	vim.keymap.set(searchKeybindings.move_up.mode, searchKeybindings.move_up.key, function()
		vim.schedule(function()
			require("buffer-me.bufferme").move_search_selection_up()
		end)
	end, {
		buffer = buf,
		expr = true,
		noremap = true,
		silent = true,
	})
	vim.keymap.set(searchKeybindings.move_down.mode, searchKeybindings.move_down.key, function()
		vim.schedule(function()
			require("buffer-me.bufferme").move_search_selection_down()
		end)
	end, {
		buffer = buf,
		expr = true,
		noremap = true,
		silent = true,
	})
	vim.keymap.set(searchKeybindings.arrow_move_up.mode, searchKeybindings.arrow_move_up.key, function()
		vim.schedule(function()
			require("buffer-me.bufferme").move_search_selection_up()
		end)
	end, {
		buffer = buf,
		expr = true,
		noremap = true,
		silent = true,
	})
	vim.keymap.set(searchKeybindings.arrow_move_down.mode, searchKeybindings.arrow_move_down.key, function()
		vim.schedule(function()
			require("buffer-me.bufferme").move_search_selection_down()
		end)
	end, {
		buffer = buf,
		expr = true,
		noremap = true,
		silent = true,
	})
	vim.keymap.set(searchKeybindings.open.mode, searchKeybindings.open.key, function()
		require("buffer-me.bufferme").open_selected_search_result()
	end, { buffer = buf })
	vim.keymap.set(searchKeybindings.open_v_split.mode, searchKeybindings.open_v_split.key, function()
		vim.schedule(function()
			require("buffer-me.bufferme").open_selected_search_result_v_split()
		end)
	end, { buffer = buf, expr = true, noremap = true, silent = true })
	vim.keymap.set(searchKeybindings.open_h_split.mode, searchKeybindings.open_h_split.key, function()
		vim.schedule(function()
			require("buffer-me.bufferme").open_selected_serach_result_h_split()
		end)
	end, { buffer = buf, expr = true, noremap = true, silent = true })
	vim.keymap.set(searchKeybindings.close.mode, searchKeybindings.close.key, function()
		require("buffer-me.bufferme").close_buffer_me_search()
	end, { buffer = buf })
	vim.keymap.set(searchKeybindings.close_esc.mode, searchKeybindings.close_esc.key, function()
		require("buffer-me.bufferme").close_buffer_me_search()
	end, { buffer = buf })
	vim.keymap.set(searchKeybindings.delete_i_mode.mode, searchKeybindings.delete_i_mode.key, function()
		vim.schedule(function()
			require("buffer-me.bufferme").delete_and_re_render_buf_search_list()
		end)
	end, { buffer = buf, expr = true, noremap = true, silent = true })
	vim.keymap.set(searchKeybindings.delete_n_mode.mode, searchKeybindings.delete_n_mode.key, function()
		require("buffer-me.bufferme").delete_and_re_render_buf_search_list()
	end, { buffer = buf })
end

function keybindings.map_search_res_keys(buf)
	-- This is a safety that lets the user close the search if they accidentally click into the search result window. It
	-- will just close everything up the same as if they hit close in the search bar
	vim.keymap.set(searchKeybindings.close.mode, searchKeybindings.close.key, function()
		require("buffer-me.bufferme").close_buffer_me_search()
	end, { buffer = buf })
	vim.keymap.set(searchKeybindings.close_esc.mode, searchKeybindings.close_esc.key, function()
		require("buffer-me.bufferme").close_buffer_me_search()
	end, { buffer = buf })
end

return keybindings
