local renderer = {}

-- The highlight group needs to be global in the tool so it can be used anywhere
renderer.ns_search_cursor = vim.api.nvim_create_namespace("bufferme_search_cursor")

function renderer.highlight_current_mark(buf, line_num)
	-- Subtract one from the line_num value because lua is 1 indexed
	local line = vim.api.nvim_buf_get_lines(buf, line_num - 1, line_num, false)[1]
	vim.api.nvim_buf_set_extmark(buf, renderer.ns_search_cursor, line_num - 1, 0, {
		hl_group = "CursorLine",
		end_col = #line,
	})
end

function renderer.remove_highlight(buf, line_num)
	vim.api.nvim_buf_clear_namespace(buf, renderer.ns_search_cursor, line_num - 1, -1)
end

function renderer.render_hotswap_lines(hotswapBuf, firstBufHotswap, secondBufHotswap)
	-- Enable modifications to draw the lines to the buffer
	vim.api.nvim_buf_set_option(hotswapBuf, "modifiable", true)

	local hotswap_lines = {}
	local firstHotswapName = nil
	if firstBufHotswap ~= nil then
		firstHotswapName = vim.api.nvim_buf_get_name(firstBufHotswap)
	end
	local secondHotswapName = nil
	if secondBufHotswap ~= nil then
		secondHotswapName = vim.api.nvim_buf_get_name(secondBufHotswap)
	end
	table.insert(hotswap_lines, string.format("%s: %s", 1, firstHotswapName))
	table.insert(hotswap_lines, string.format("%s: %s", 2, secondHotswapName))
	vim.api.nvim_buf_set_lines(hotswapBuf, 0, 2, false, hotswap_lines)

	-- Disable modifications because it's rendered
	vim.api.nvim_buf_set_option(hotswapBuf, "modifiable", false)
end

function renderer.render_buf_search_results(bufListSearchResultBuf, buff_search_results)
	-- Enable modifications to draw the lines to the buffer
	vim.api.nvim_buf_set_option(bufListSearchResultBuf, "modifiable", true)

	local lines = {}
	for _, value in pairs(buff_search_results) do
		table.insert(lines, string.format("%s", value.item))
	end
	vim.api.nvim_buf_set_lines(bufListSearchResultBuf, 0, #lines, false, lines)

	-- Disable modifications because it's rendered
	vim.api.nvim_buf_set_option(bufListSearchResultBuf, "modifiable", false)
end

function renderer.render_buf_list_lines(bufListBuf, bufList, maxRecentBufferTrack)
	-- Enable modifications to draw the lines to the buffer
	vim.api.nvim_buf_set_option(bufListBuf, "modifiable", true)

	local lines = {}
	for idx, value in pairs(bufList) do
		if idx > maxRecentBufferTrack then
			break
		end
		table.insert(lines, string.format("%s: %s", idx, value))
	end
	vim.api.nvim_buf_set_lines(bufListBuf, 0, #lines, false, lines)

	-- Disable modifications because it's rendered
	vim.api.nvim_buf_set_option(bufListBuf, "modifiable", false)
end

local function clear_buf_search_results(bufListSearchResultBuf)
	vim.api.nvim_buf_set_option(bufListSearchResultBuf, "modifiable", true)
	vim.api.nvim_buf_set_lines(bufListSearchResultBuf, 0, -1, false, {})
	vim.api.nvim_buf_set_option(bufListSearchResultBuf, "modifiable", false)
end

function renderer.re_render_buf_search_results(bufListSearchResultBuf, buff_search_results, selected_search_result)
	clear_buf_search_results(bufListSearchResultBuf)
	renderer.render_buf_search_results(bufListSearchResultBuf, buff_search_results)
	vim.api.nvim_buf_set_option(bufListSearchResultBuf, "modifiable", true)
	renderer.highlight_current_mark(bufListSearchResultBuf, selected_search_result)
	vim.api.nvim_buf_set_option(bufListSearchResultBuf, "modifiable", false)
end

return renderer
