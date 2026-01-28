local state = require("buffer-me.state")
local windower = {}

-- Local hl group so it can be referenced across the board
local ns_search_cursor = vim.api.nvim_create_namespace("bufferme_search_cursor")

local function get_window_dimensions()
	return vim.api.nvim_list_uis()[1]
end

function windower.create_buf_list_window()
	local windowInfo = get_window_dimensions()
	return vim.api.nvim_open_win(state.bufListBuf, true, {
		relative = "editor",
		row = math.floor((windowInfo.height - 20) / 2),
		col = math.floor((windowInfo.width - 100) / 2),
		width = 100,
		height = 20,
		border = "double",
		style = "minimal",
		title = "Buffers",
	})
end

function windower.render_buf_list_lines()
	-- Enable modifications to draw the lines to the buffer
	vim.api.nvim_buf_set_option(state.bufListBuf, "modifiable", true)

	local lines = {}
	for idx, value in pairs(state.bufList) do
		table.insert(lines, string.format("%s: %s", idx, value))
	end
	vim.api.nvim_buf_set_lines(state.bufListBuf, 0, #lines, false, lines)

	-- Disable modifications because it's rendered
	vim.api.nvim_buf_set_option(state.bufListBuf, "modifiable", false)
end

local function clear_buf_list_lines()
	vim.api.nvim_buf_set_option(state.bufListBuf, "modifiable", true)
	vim.api.nvim_buf_set_lines(state.bufListBuf, 0, -1, false, {})
	vim.api.nvim_buf_set_option(state.bufListBuf, "modifiable", false)
end

function windower.re_render_buf_list_lines()
	clear_buf_list_lines()
	windower.render_buf_list_lines()
end

function windower.create_hot_swap_window()
	local windowInfo = get_window_dimensions()
	return vim.api.nvim_open_win(state.hotswapBuf, false, {
		relative = "editor",
		row = math.floor((windowInfo.height - 26) / 2),
		col = math.floor((windowInfo.width - 100) / 2),
		-- row = 0,
		-- col = 0,
		width = 100,
		height = 2,
		border = "double",
		style = "minimal",
		title = "Hotswap",
	})
end

function windower.render_hotswap_lines()
	-- Enable modifications to draw the lines to the buffer
	vim.api.nvim_buf_set_option(state.hotswapBuf, "modifiable", true)

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

	-- Disable modifications because it's rendered
	vim.api.nvim_buf_set_option(state.hotswapBuf, "modifiable", false)
end

function windower.close_buffer_me()
	-- Clean up the state
	state.clear_selected_row()

	-- Close the buffers and recreate them
	vim.api.nvim_buf_delete(state.bufListBuf, { force = true })
	state.bufListBuf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(state.bufListBuf, "buftype", "nofile")
	vim.api.nvim_buf_delete(state.hotswapBuf, { force = true })
	state.hotswapBuf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(state.hotswapBuf, "buftype", "nofile")
end

function windower.close_buffer_me_search()
	-- Reset the search results
	state.buff_search_results = {}

	-- Remove the reference to the old results window since it is going to be destroyed
	state.searchResultsWindowHandle = nil

	-- Close the buffers
	state.clean_up_buffers_on_close()
end

--- Wrapper function around Neovim's line highlight functionality
--- @param line_num number The 1-indexed value of the line number
function windower.highlight_current_mark(buf, line_num)
	-- Subtract one from the line_num value because lua is 1 indexed
	vim.api.nvim_buf_add_highlight(buf, ns_search_cursor, "CursorLine", line_num - 1, 0, -1)
end

--- Wrapper function around Neovim's line highlight removal functionality
--- @param line_num number The 1-indexed value of the line number
function windower.remove_highlight(buf, line_num)
	vim.api.nvim_buf_clear_namespace(buf, ns_search_cursor, line_num - 1, -1)
end

function windower.create_buff_search_bar()
	local windowInfo = get_window_dimensions()
	return vim.api.nvim_open_win(state.bufListSearch, true, {
		relative = "editor",
		row = math.floor((windowInfo.height - 1) / 2),
		col = math.floor((windowInfo.width - 100) / 2),
		width = 100,
		height = 1,
		border = "double",
		style = "minimal",
		title = "Search",
	})
end

function windower.create_buff_search_results_window_if_not_exists()
	if state.searchResultsWindowHandle then
		return state.searchResultsWindowHandle
	else
		local windowInfo = get_window_dimensions()
		return vim.api.nvim_open_win(state.bufListSearchResultBuff, false, {
			relative = "editor",
			row = math.floor((windowInfo.height - 52) / 2),
			col = math.floor((windowInfo.width - 100) / 2),
			width = 100,
			height = 25,
			border = "double",
			style = "minimal",
			title = "Matches",
		})
	end
end

function windower.render_buf_search_results()
	-- Enable modifications to draw the lines to the buffer
	vim.api.nvim_buf_set_option(state.bufListSearchResultBuff, "modifiable", true)

	local lines = {}
	for _, value in pairs(state.buff_search_results) do
		table.insert(lines, string.format("%s", value.item))
	end
	vim.api.nvim_buf_set_lines(state.bufListSearchResultBuff, 0, #lines, false, lines)

	-- Disable modifications because it's rendered
	vim.api.nvim_buf_set_option(state.bufListSearchResultBuff, "modifiable", false)
end

local function clear_buf_search_results()
	vim.api.nvim_buf_set_option(state.bufListSearchResultBuff, "modifiable", true)
	vim.api.nvim_buf_set_lines(state.bufListSearchResultBuff, 0, -1, false, {})
	vim.api.nvim_buf_set_option(state.bufListSearchResultBuff, "modifiable", false)
end

function windower.re_render_buf_search_results()
	clear_buf_search_results()
	windower.render_buf_search_results()
	vim.api.nvim_buf_set_option(state.bufListSearchResultBuff, "modifiable", true)
	windower.highlight_current_mark(state.bufListSearchResultBuff, state.selected_search_result)
	vim.api.nvim_buf_set_option(state.bufListSearchResultBuff, "modifiable", false)
end

return windower
