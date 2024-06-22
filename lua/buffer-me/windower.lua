local windower = {}

function windower.create_floating_window()
	return vim.api.nvim_open_win(0, true, {
		relative = "editor",
		row = 0,
		col = 0,
		width = 100,
		height = 100,
		border = "double",
		style = "minimal",
		title = "Buffers",
	})
end

function windower.close_window()
	-- Reset modifiable flag so the buffer can be updated on the next search
	-- vim.api.nvim_buf_set_option(state.referenceBuf, "modifiable", true)
	--
	-- -- Close the buffers and recreate them
	-- vim.api.nvim_buf_delete(state.referenceBuf, { force = true })
	-- state.referenceBuf = vim.api.nvim_create_buf(false, true)
	-- vim.api.nvim_buf_delete(state.previewBuf, { force = true })
	-- state.previewBuf = vim.api.nvim_create_buf(false, true)
	--
	-- -- Clear the state for the next time it loads
	-- state.clear_state()
end

return windower
