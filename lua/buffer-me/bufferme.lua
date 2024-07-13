local state = require("buffer-me.state")
local windower = require("buffer-me.windower")
local keybindings = require("buffer-me.keybindings")
local bufferme = {}

function bufferme.open_selected_buffer()
	local win_handle = vim.api.nvim_get_current_win()
	vim.api.nvim_win_close(win_handle, true)
	local selected_buf_handle = vim.fn.bufnr(state.bufList[state.selectedBuffer])
	vim.api.nvim_set_current_buf(selected_buf_handle)
end

function bufferme.open_buffer_at_idx(idx)
	local converted_idx = vim.fn.nr2char(idx)
	vim.api.nvim_win_close(win_handle, true)
	local selected_buf_handle = vim.fn.bufnr(state.bufList[converted_idx])
	if state.bufList[state.selectedBuffer] == "" then
		return
	end
	vim.api.nvim_set_current_buf(selected_buf_handle)
end

function bufferme.open_buffers_list()
	local lines = {}
	for idx, value in pairs(state.bufList) do
		if value ~= "" then
			table.insert(state.bufNumToLineNumMap, idx)
			table.insert(lines, string.format("%s: %s", idx, value))
		end
	end

	-- Callback for when the cursor moves around in the buffer
	vim.api.nvim_create_autocmd({ "CursorMoved" }, {
		buffer = state.bufListBuf,
		callback = function()
			if #state.bufList > 0 then
				state.update_selected_row()
			end
		end,
	})

	vim.api.nvim_buf_set_lines(state.bufListBuf, 0, 2, false, lines)
	windower.create_floating_window()

	-- Initialize key bindings
	keybindings.map_keys(state.bufListBuf)
end

function bufferme.add_buf()
	state.append_to_buf_list(0)
end

function bufferme.add_buf_at_idx()
	print("Assign buffer to index:")
	local idx = vim.fn.nr2char(vim.fn.getchar())
	if idx == "q" then
		return
	else
		state.add_buf_to_num(idx, 0)
	end
end

function bufferme.add_all_buffers()
	for _, buf_handle in pairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_option(buf_handle, "buflisted") then
			state.append_to_buf_list(buf_handle)
		end
	end
end

function bufferme.remove_buf_at_idx()
	print("Remove buffer at index:")
	local idx = vim.fn.nr2char(vim.fn.getchar())
	if idx == "q" then
		return
	else
		state.remove_buf_by_num(idx)
	end
end

function bufferme.go_to_buffer()
	print("Open buffer at index:")
	local idx = vim.fn.nr2char(vim.fn.getchar())
	if idx == "q" then
		return
	else
		bufferme.open_buffer_at_idx(idx)
	end
end

return bufferme
