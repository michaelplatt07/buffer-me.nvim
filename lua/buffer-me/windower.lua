local utils = require("buffer-me.utils")
local windower = {
	-- Buffer management
	bufListBuf = nil,
	hotswapBuf = nil,
	bufListSearchResultBuf = nil,
	bufListSearchBuf = nil,

	-- Window management
	bufListWindowHandle = nil,
	hotswapWindowHandle = nil,
	searchBarWindowHandle = nil,
	searchResultsWindowHandle = nil,
	bufLabelHandles = {},
}

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

function windower.init_required_buffers()
	if windower.bufListBuf == nil then
		windower.bufListBuf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_option(windower.bufListBuf, "buftype", "nofile")
	end

	if windower.hotswapBuf == nil then
		windower.hotswapBuf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_option(windower.hotswapBuf, "buftype", "nofile")
	end

	if windower.bufListSearchBuf == nil then
		windower.bufListSearchBuf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_option(windower.bufListSearchBuf, "buftype", "prompt")
		vim.fn.prompt_setprompt(windower.bufListSearchBuf, "> ")
	end

	if windower.bufListSearchResultBuf == nil then
		windower.bufListSearchResultBuf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_option(windower.bufListSearchResultBuf, "buftype", "nofile")
	end
end

function windower.create_buf_list_window()
	local windowInfo = get_full_window_dimensions()
	windower.bufListWindowHandle = vim.api.nvim_open_win(windower.bufListBuf, true, {
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

function windower.create_hot_swap_window()
	local windowInfo = get_full_window_dimensions()
	windower.hotswapWindowHandle = vim.api.nvim_open_win(windower.hotswapBuf, false, {
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

function windower.create_buff_search_bar()
	local windowInfo = get_full_window_dimensions()
	windower.searchBarWindowHandle = vim.api.nvim_open_win(windower.bufListSearchBuf, true, {
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

function windower.create_buff_search_results_window()
	local windowInfo = get_full_window_dimensions()
	windower.searchResultsWindowHandle = vim.api.nvim_open_win(windower.bufListSearchResultBuf, false, {
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

function windower.create_window_label_windows_and_buffers()
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
		table.insert(windower.bufLabelHandles, win)
	end
end

function windower.close_buffer_me()
	if windower.bufListWindowHandle and vim.api.nvim_win_is_valid(windower.bufListWindowHandle) then
		vim.api.nvim_win_close(windower.bufListWindowHandle, true)
		windower.bufListWindowHandle = nil
	end
	if windower.hotswapWindowHandle and vim.api.nvim_win_is_valid(windower.hotswapWindowHandle) then
		vim.api.nvim_win_close(windower.hotswapWindowHandle, true)
		windower.hotswapWindowHandle = nil
	end
	if windower.searchBarWindowHandle and vim.api.nvim_win_is_valid(windower.searchBarWindowHandle) then
		vim.api.nvim_win_close(windower.searchBarWindowHandle, true)
		windower.searchBarWindowHandle = nil
	end
	if windower.searchResultsWindowHandle and vim.api.nvim_win_is_valid(windower.searchResultsWindowHandle) then
		vim.api.nvim_win_close(windower.searchResultsWindowHandle, true)
		windower.searchResultsWindowHandle = nil
	end

	if windower.bufListBuf and vim.api.nvim_buf_is_valid(windower.bufListBuf) then
		vim.api.nvim_buf_delete(windower.bufListBuf, { force = true })
		windower.bufListBuf = nil
	end
	if windower.hotswapBuf and vim.api.nvim_buf_is_valid(windower.hotswapBuf) then
		vim.api.nvim_buf_delete(windower.hotswapBuf, { force = true })
		windower.hotswapBuf = nil
	end
	if windower.bufListSearchResultBuf and vim.api.nvim_buf_is_valid(windower.bufListSearchResultBuf) then
		vim.api.nvim_buf_delete(windower.bufListSearchResultBuf, { force = true })
		windower.bufListSearchResultBuf = nil
	end
	if windower.bufListSearchBuf and vim.api.nvim_buf_is_valid(windower.bufListSearchBuf) then
		vim.api.nvim_buf_delete(windower.bufListSearchBuf, { force = true })
		windower.bufListSearchBuf = nil
	end

	-- Close the labels if they are open. This should get cleaned up at some point
	for _, win in ipairs(windower.bufLabelHandles) do
		vim.api.nvim_win_close(win, true)
	end
	windower.bufLabelHandles = {}
end

return windower
