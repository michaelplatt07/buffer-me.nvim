local state = require("buffer-me.state")
local windower = require("buffer-me.windower")
local keybindings = require("buffer-me.keybindings")
local bufferme = {}

function bufferme.open_selected_buffer()
	local selected_buf_handle = nil
	if state.selectedRow then
		local win_handle = vim.api.nvim_get_current_win()
		vim.api.nvim_win_close(win_handle, true)
		selected_buf_handle = vim.fn.bufnr(state.bufList[state.selectedRow])
	elseif state.currSelectedBuffer then
		selected_buf_handle = vim.fn.bufnr(state.bufList[state.currSelectedBuffer])
	else
		error("There was problem opening a buffer")
	end
	vim.api.nvim_set_current_buf(selected_buf_handle)
	state.clear_selected_row()
end

function bufferme.open_buffer_at_idx(idx)
	local converted_idx = tonumber(idx)
	-- Check first if we even have a buffer to open
	if state.bufList[converted_idx] == "" then
		return
	else
		local win_handle = vim.api.nvim_get_current_win()
		vim.api.nvim_win_close(win_handle, true)
		local selected_buf_handle = vim.fn.bufnr(state.bufList[converted_idx])
		vim.api.nvim_set_current_buf(selected_buf_handle)
	end
	state.clear_selected_row()
end

function bufferme.open_buffers_list()
	local lines = {}
	for idx, value in pairs(state.bufList) do
		if value ~= "" then
			table.insert(state.bufNumToLineNumMap, idx)
			-- Conditionally add an asterisk to show the current buffer in the buffer list
			if idx == state.currSelectedBuffer then
				table.insert(lines, string.format("*%s: %s", idx, value))
			else
				table.insert(lines, string.format("%s: %s", idx, value))
			end
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

	-- Set the lines for the hotswap buffer
	local hotswap_lines = {}
	table.insert(hotswap_lines, string.format("*%s: %s", 1, state.firstBufHotswap))
	table.insert(hotswap_lines, string.format("*%s: %s", 2, state.secondBufHotswap))
	vim.api.nvim_buf_set_lines(state.hotswapBuf, 0, 2, false, hotswap_lines)
	windower.create_hot_swap_window()

	-- Set the lines for the buffer list
	vim.api.nvim_buf_set_lines(state.bufListBuf, 0, #lines, false, lines)
	windower.create_buf_list_window()

	-- Handle an empty selected row for the first time
	if state.selectedRow == nil then
		state.update_selected_row()
	end

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
	state.clear_selected_row()
end

function bufferme.go_next_buffer()
	state.go_next_buffer()
	bufferme.open_selected_buffer()
	state.clear_selected_row()
end

function bufferme.go_prev_buffer()
	state.go_prev_buffer()
	bufferme.open_selected_buffer()
	state.clear_selected_row()
end

function bufferme.clear_buffer_list()
	state.clear_state()
end

function bufferme.set_first_hotswap()
	print("Input buffer number for first hotswap:")
	local idx = vim.fn.nr2char(vim.fn.getchar())
	if idx == "q" then
		return
	elseif idx == "\r" then
		local bufnr = vim.api.nvim_win_get_buf(0)
		state.set_first_hotswap(bufnr)
	else
		state.set_first_hotswap(tonumber(idx))
	end
end

function bufferme.set_second_hotswap()
	print("Input buffer number for second hotswap:")
	local idx = vim.fn.nr2char(vim.fn.getchar())
	if idx == "q" then
		return
	elseif idx == "\r" then
		local bufnr = vim.api.nvim_win_get_buf(0)
		state.set_second_hotswap(bufnr)
	else
		state.set_second_hotswap(tonumber(idx))
	end
end

function bufferme.toggle_hotswap_buffers()
	-- TODO(map) Might need to include a check here to make sure the window is visible??
	-- Get the current windows buffer and name
	local bufnr = vim.api.nvim_win_get_buf(0)
	if state.firstBufHotswap ~= bufnr then
		-- Not on the current first buf hotswap
		vim.api.nvim_set_current_buf(state.firstBufHotswap)
	elseif state.firstBufHotswap == bufnr and state.secondBufHotswap ~= nil then
		-- On the first buf hotswap so go to the second
		vim.api.nvim_set_current_buf(state.secondBufHotswap)
	elseif state.secondBufHotswap == bufnr and state.firstBufHotswap ~= nil then
		-- On the second so go to the first
		vim.api.nvim_set_current_buf(state.firstBufHotswap)
	else
		-- Generic error case
		print("Error in toggleing hotswap buffers")
	end
end

return bufferme
