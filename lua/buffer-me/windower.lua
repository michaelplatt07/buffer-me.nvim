local state = require("buffer-me.state")
local windower = {}

function windower.create_buf_list_window()
	return vim.api.nvim_open_win(state.bufListBuf, true, {
		relative = "editor",
		row = 3,
		col = 0,
		width = 100,
		height = 20,
		border = "double",
		style = "minimal",
		title = "Buffers",
	})
end

function windower.render_buf_list_lines()
	local lines = {}
	for idx, value in pairs(state.bufList) do
		table.insert(lines, string.format("%s: %s", idx, value))
	end
	vim.api.nvim_buf_set_lines(state.bufListBuf, 0, #lines, false, lines)
end

function windower.create_hot_swap_window()
	return vim.api.nvim_open_win(state.hotswapBuf, false, {
		relative = "editor",
		row = 0,
		col = 0,
		width = 100,
		height = 2,
		border = "double",
		style = "minimal",
		title = "Hotswap",
	})
end

function windower.render_hotswap_lines()
	local hotswap_lines = {}
	local firstHotswapName = nil
	if state.firstBufHotswap ~= nil then
		firstHotswapName = vim.api.nvim_buf_get_name(state.firstBufHotswap)
	end
	local secondHotswapName = nil
	if state.secondBufHotswap ~= nil then
		secondHotswapName = vim.api.nvim_buf_get_name(state.secondBufHotswap)
	end
	table.insert(hotswap_lines, string.format("%s: %s", 1, firstHotswapName))
	table.insert(hotswap_lines, string.format("%s: %s", 2, secondHotswapName))
	vim.api.nvim_buf_set_lines(state.hotswapBuf, 0, 2, false, hotswap_lines)
end

function windower.close_buffer_me()
	-- Clean up the state
	state.clear_selected_row()

	-- Reset modifiable flag so the buffer can be updated on the next search
	vim.api.nvim_buf_set_option(state.bufListBuf, "modifiable", true)

	-- Close the buffers and recreate them
	vim.api.nvim_buf_delete(state.bufListBuf, { force = true })
	state.bufListBuf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_delete(state.hotswapBuf, { force = true })
	state.hotswapBuf = vim.api.nvim_create_buf(false, true)
end

--- Wrapper function around Neovim's line highlight functionality
--- @param line_num number The 1-indexed value of the line number
function windower.highlight_current_mark(line_num)
	-- Subtract one from the line_num value because lua is 1 indexed
	vim.api.nvim_buf_add_highlight(state.bufListBuf, -1, "CursorLine", line_num - 1, 0, -1)
end

--- Wrapper function around Neovim's line highlight removal functionality
--- @param line_num number The 1-indexed value of the line number
function windower.remove_highlight(line_num)
	vim.api.nvim_buf_clear_namespace(state.bufListBuf, -1, line_num - 1, -1)
end

return windower
