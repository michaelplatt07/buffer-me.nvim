local listingMaps = {
	quit = {
		mode = "n",
		key = "q",
	},
	quit_esc = {
		mode = "n",
		key = "<Esc>",
	},
	up = { mode = "n", key = "k" },
	down = { mode = "n", key = "j" },
	open = { mode = "n", key = "o" },
	openEnter = { mode = "n", key = "<CR>" },
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
	select_placement = { mode = "n", key = "sp" },
}

local searchMaps = {
	move_up_normal = {
		mode = "n",
		key = "k",
	},
	move_down_normal = {
		mode = "n",
		key = "j",
	},
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
	open_normal = {
		mode = "n",
		key = "<CR>",
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
		key = "<C-s>",
	},
	select_placement = {
		mode = "n",
		key = "sp",
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

local keybindings = {}

function keybindings.update_key_binding(func, custombind)
	keybindings[func].key = custombind
end

function keybindings.map_keys(buf, callbacks)
	vim.keymap.set(listingMaps.up.mode, listingMaps.up.key, function()
		callbacks.up()
	end, { buffer = buf })
	vim.keymap.set(listingMaps.down.mode, listingMaps.down.key, function()
		callbacks.down()
	end, { buffer = buf })
	vim.keymap.set(listingMaps.open.mode, listingMaps.open.key, function()
		callbacks.open()
	end, { buffer = buf })
	vim.keymap.set(listingMaps.openEnter.mode, listingMaps.openEnter.key, function()
		callbacks.open()
	end, { buffer = buf })
	vim.keymap.set(listingMaps.delete.mode, listingMaps.delete.key, function()
		callbacks.del()
	end, { buffer = buf })
	vim.keymap.set(listingMaps.open_v_split.mode, listingMaps.open_v_split.key, function()
		callbacks.v_split()
	end, { buffer = buf })
	vim.keymap.set(listingMaps.open_h_split.mode, listingMaps.open_h_split.key, function()
		callbacks.h_split()
	end, { buffer = buf })
	vim.keymap.set(listingMaps.set_first_hotswap.mode, listingMaps.set_first_hotswap.key, function()
		callbacks.set_first()
	end, { buffer = buf })
	vim.keymap.set(listingMaps.set_second_hotswap.mode, listingMaps.set_second_hotswap.key, function()
		callbacks.set_second()
	end, { buffer = buf })
	vim.keymap.set(listingMaps.go_to.mode, listingMaps.go_to.key, function()
		callbacks.go_to()
	end, { buffer = buf })
	vim.keymap.set(listingMaps.quit.mode, listingMaps.quit.key, function()
		callbacks.close()
	end, { buffer = buf })
	vim.keymap.set(listingMaps.quit_esc.mode, listingMaps.quit_esc.key, function()
		callbacks.close()
	end, { buffer = buf })
	vim.keymap.set(listingMaps.select_placement.mode, listingMaps.select_placement.key, function()
		callbacks.select_window()
	end, { buffer = buf })
end

function keybindings.map_search_keys(buf, callbacks)
	vim.keymap.set(searchMaps.move_up_normal.mode, searchMaps.move_up_normal.key, function()
		vim.schedule(function()
			callbacks.up()
		end)
	end, {
		buffer = buf,
		noremap = true,
		silent = true,
	})
	vim.keymap.set(searchMaps.move_down_normal.mode, searchMaps.move_down_normal.key, function()
		vim.schedule(function()
			callbacks.down()
		end)
	end, {
		buffer = buf,
		noremap = true,
		silent = true,
	})
	vim.keymap.set(searchMaps.move_up.mode, searchMaps.move_up.key, function()
		vim.schedule(function()
			callbacks.up()
		end)
	end, {
		buffer = buf,
		noremap = true,
		silent = true,
	})
	vim.keymap.set(searchMaps.move_down.mode, searchMaps.move_down.key, function()
		vim.schedule(function()
			callbacks.down()
		end)
	end, {
		buffer = buf,
		noremap = true,
		silent = true,
	})
	vim.keymap.set(searchMaps.arrow_move_up.mode, searchMaps.arrow_move_up.key, function()
		vim.schedule(function()
			callbacks.up()
		end)
	end, {
		buffer = buf,
		noremap = true,
		silent = true,
	})
	vim.keymap.set(searchMaps.arrow_move_down.mode, searchMaps.arrow_move_down.key, function()
		vim.schedule(function()
			callbacks.down()
		end)
	end, {
		buffer = buf,
		noremap = true,
		silent = true,
	})
	vim.keymap.set(searchMaps.open_normal.mode, searchMaps.open_normal.key, function()
		callbacks.open()
	end, { buffer = buf })
	vim.keymap.set(searchMaps.open.mode, searchMaps.open.key, function()
		callbacks.open()
	end, { buffer = buf })
	vim.keymap.set(searchMaps.open_v_split.mode, searchMaps.open_v_split.key, function()
		vim.schedule(function()
			callbacks.v_split()
		end)
	end, { buffer = buf, noremap = true, silent = true })
	vim.keymap.set(searchMaps.open_h_split.mode, searchMaps.open_h_split.key, function()
		vim.schedule(function()
			callbacks.h_split()
		end)
	end, { buffer = buf, noremap = true, silent = true })
	vim.keymap.set(searchMaps.close.mode, searchMaps.close.key, function()
		callbacks.close()
	end, { buffer = buf })
	vim.keymap.set(searchMaps.close_esc.mode, searchMaps.close_esc.key, function()
		callbacks.close()
	end, { buffer = buf })
	vim.keymap.set(searchMaps.delete_i_mode.mode, searchMaps.delete_i_mode.key, function()
		vim.schedule(function()
			callbacks.del()
		end)
	end, { buffer = buf, noremap = true, silent = true })
	vim.keymap.set(searchMaps.delete_n_mode.mode, searchMaps.delete_n_mode.key, function()
		callbacks.del()
	end, { buffer = buf })
	vim.keymap.set(searchMaps.select_placement.mode, searchMaps.select_placement.key, function()
		callbacks.select_window()
	end, { buffer = buf })
end

function keybindings.map_search_res_keys(buf, callbacks)
	-- This is a safety that lets the user close the search if they accidentally click into the search result window. It
	-- will just close everything up the same as if they hit close in the search bar
	vim.keymap.set(searchMaps.close.mode, searchMaps.close.key, function()
		callbacks.close()
	end, { buffer = buf })
	vim.keymap.set(searchMaps.close_esc.mode, searchMaps.close_esc.key, function()
		callbacks.close()
	end, { buffer = buf })
end

return keybindings
