local state = require("buffer-me.state")
local windower = {}

function windower.create_floating_window()
	return vim.api.nvim_open_win(state.bufListBuf, true, {
		relative = "editor",
		row = 0,
		col = 0,
		width = 100,
		height = 20,
		border = "double",
		style = "minimal",
		title = "Buffers",
	})
end

function windower.close_window()
	-- Clean up the state
	state.bufNumToLineNumMap = {}
	state.clear_selected_row()

	-- Reset modifiable flag so the buffer can be updated on the next search
	vim.api.nvim_buf_set_option(state.bufListBuf, "modifiable", true)

	-- Close the buffers and recreate them
	vim.api.nvim_buf_delete(state.bufListBuf, { force = true })
	state.bufListBuf = vim.api.nvim_create_buf(false, true)
end

return windower
