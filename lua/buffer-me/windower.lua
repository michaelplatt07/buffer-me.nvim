local state = require("buffer-me.state")
local utils = require("buffer-me.utils")
local windower = {}

-- The highlight group needs to be global in the tool so it can be used anywhere
windower.ns_search_cursor = vim.api.nvim_create_namespace("bufferme_search_cursor")

local function get_full_window_dimensions()
	-- Gets the UI which should always actually be available. The else block is strictly for handling integrations as
	-- they are being ran through the --headless switch.
	local uis = vim.api.nvim_list_uis()
	if uis and uis[1] then
		return uis[1]
	else
		return {
			height = 100,
			width = 100,
		}
	end
end

local function get_specified_window_dimensions(winId)
	-- Gets the dimensions of a given window instead of the overall terminal's size.
	local width = vim.api.nvim_win_get_width(winId)
	local height = vim.api.nvim_win_get_height(winId)
	return { width = width, height = height }
end

function windower.create_buf_list_window()
	local windowInfo = get_full_window_dimensions()
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
		if idx > state.maxRecentBufferTrack then
			break
		end
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
	local windowInfo = get_full_window_dimensions()
	return vim.api.nvim_open_win(state.hotswapBuf, false, {
		relative = "editor",
		row = math.floor((windowInfo.height - 26) / 2),
		col = math.floor((windowInfo.width - 100) / 2),
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
	-- TODO(map) Move this to the orchestration level of bufferme.lua
	state.clear_state()

	-- Close the buffers and recreate them
	if state.bufListBuf then
		vim.api.nvim_buf_delete(state.bufListBuf, { force = true })
	end
	state.bufListBuf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(state.bufListBuf, "buftype", "nofile")
	if state.hotswapBuf then
		vim.api.nvim_buf_delete(state.hotswapBuf, { force = true })
	end
	state.hotswapBuf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(state.hotswapBuf, "buftype", "nofile")
	if state.bufListSearch then
		vim.api.nvim_buf_delete(state.bufListSearch, { force = true })
		state.bufListSearch = nil
	end
	if state.bufListSearchResultBuff then
		vim.api.nvim_buf_delete(state.bufListSearchResultBuff, { force = true })
		state.bufListSearchResultBuff = nil
	end

	state.searchBarWindowHandle = nil
	state.searchResultsWindowHandle = nil

	-- Close the labels if they are open. This should get cleaned up at some point
	for _, win in ipairs(state.bufLabelHandles) do
		vim.api.nvim_win_close(win, true)
	end
	-- TODO(map) Move this to the orchestration level of bufferme.lua
	state.bufLabelHandles = {}
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
	local line = vim.api.nvim_buf_get_lines(buf, line_num - 1, line_num, false)[1]
	vim.api.nvim_buf_set_extmark(buf, windower.ns_search_cursor, line_num - 1, 0, {
		hl_group = "CursorLine",
		end_col = #line,
	})
end

--- Wrapper function around Neovim's line highlight removal functionality
--- @param line_num number The 1-indexed value of the line number
function windower.remove_highlight(buf, line_num)
	vim.api.nvim_buf_clear_namespace(buf, windower.ns_search_cursor, line_num - 1, -1)
end

function windower.create_buff_search_bar()
	local windowInfo = get_full_window_dimensions()
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
		local windowInfo = get_full_window_dimensions()
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

function windower.create_window_labels()
	for idx, windowNum in ipairs(utils.windowMap) do
		local buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, utils.numberToAsciiMap[idx])
		vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
		local windowInfo = get_specified_window_dimensions(windowNum)
		local win = vim.api.nvim_open_win(buf, false, {
			relative = "win",
			win = windowNum,
			row = math.floor((windowInfo.height - 7) / 2),
			col = math.floor((windowInfo.width - 5) / 2),
			width = 5,
			height = 7,
			style = "minimal",
		})
		vim.api.nvim_set_hl(0, "WinLabel", { fg = "black", bg = "white", bold = true })
		vim.api.nvim_set_option_value("winhl", "Normal:WinLabel", { win = win })
		table.insert(state.bufLabelHandles, win)
	end
end

return windower
