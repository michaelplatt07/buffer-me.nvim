local state = {
	-- Configs
	autoManage = false,
	recentToTop = false,

	-- State management
	isBufListFull = false,
	bufListBuf = nil,
	hotswapBuf = nil,
	hotswapWindowHandle = nil,
	bufListSearch = nil,
	bufListSearchResultBuff = nil,
	searchResultsWindowHandle = nil,
	buff_search_results = {},
	selected_search_result = nil,
	bufList = {},
	maxBufferTrack = 10, -- Default to 10 but this can be set in configs
	selectedRow = nil,
	currSelectedBuffer = nil,
	firstBufHotswap = nil,
	secondBufHotswap = nil,
	lastExitedBuffer = nil,
	mostRecentBuffer = nil,
	is_ui_active = false,
}

function state.init_required_buffers()
	if state.bufListBuf == nil then
		state.bufListBuf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_option(state.bufListBuf, "buftype", "nofile")
	end

	if state.hotswapBuf == nil then
		state.hotswapBuf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_option(state.hotswapBuf, "buftype", "nofile")
	end

	if state.bufListSearch == nil then
		state.bufListSearch = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_option(state.bufListSearch, "buftype", "prompt")
		vim.fn.prompt_setprompt(state.bufListSearch, "> ")
	end

	if state.bufListSearchResultBuff == nil then
		state.bufListSearchResultBuff = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_option(state.bufListSearchResultBuff, "buftype", "nofile")
	end
end

function state.clean_up_buffers_on_close()
	vim.api.nvim_buf_delete(state.bufListSearch, { force = true })
	state.bufListSearch = nil
	vim.api.nvim_buf_delete(state.bufListSearchResultBuff, { force = true })
	state.bufListSearchResultBuff = nil
end

local function shiftAndInsertBuffer(buf_name)
	if #state.bufList + 1 >= state.maxBufferTrack then
		state.isBufListFull = true
	else
		state.isBufListFull = false
	end
	if buf_name ~= nil and buf_name ~= "" then
		table.insert(state.bufList, 1, buf_name)
	end
end

function state.append_to_buf_list(buf)
	local buf_name = vim.api.nvim_buf_get_name(buf)

	-- Replace the fully qualified file name with just the relative path
	buf_name = buf_name:gsub("^" .. vim.pesc(vim.loop.cwd()) .. "/", "")

	-- Return early if the buffer already exists in the list
	local existsInList, dup_loc = state.check_for_dup_buf(buf_name)
	if existsInList == true and (state.recentToTop == false or state.recentToTop == nil) then
		return
	elseif existsInList == true and state.recentToTop == true then
		-- Pop the item from the list and shift everything down
		table.remove(state.bufList, dup_loc)
		shiftAndInsertBuffer(buf_name)
	else
		shiftAndInsertBuffer(buf_name)
	end
	--
	-- Pop the last item from the list in the event it was not already part of the list to keep the list length to the
	-- configured value
	-- TODO: Clean up might need to be actually removing everything from the max onward.
	if state.isBufListFull == true and existsInList == false then
		table.remove(state.bufList, #state.bufList)
	end
end

function state.check_for_dup_buf(buf_name)
	local is_dup = false
	local dup_loc = nil
	for idx, val in ipairs(state.bufList) do
		if val == buf_name then
			is_dup = true
			dup_loc = idx
		end
	end
	return is_dup, dup_loc
end

-- TODO(map) Consider removing this. I don't think it makes much sense to just add a buffer to a random number
function state.add_buf_to_num(num, buf)
	local converted_num = tonumber(num)
	state.bufList[converted_num] = vim.api.nvim_buf_get_name(buf)
	if #state.bufList + 1 >= state.maxBufferTrack then
		state.isBufListFull = true
	else
		state.isBufListFull = false
	end

	-- Pop the last item from the list as it shouldn't be there anymore
	-- TODO: Clean up might need to be actually removing everything from the max onward.
	if state.isBufListFull == true then
		table.remove(state.bufList, #state.bufList)
	end
end

function state.remove_buf_by_num(num)
	local converted_num = tonumber(num)

	-- Only remove if we can
	if converted_num < #state.bufList then
		table.remove(state.bufList, converted_num)
		state.isBufListFull = false
	end
end
--TODO(map) Consider removing end

function state.go_next_buffer()
	-- Case where we don't have a currently selected buffer, start from beginning of all buffers and set that as the
	-- current selected buffer
	if state.currSelectedBuffer == nil then
		state.currSelectedBuffer = state.get_next_available_buffer(0)
	else
		local next_buf = state.get_next_available_buffer(state.currSelectedBuffer)
		if next_buf ~= nil then
			state.currSelectedBuffer = next_buf
		else
			-- Handles wrapping back to first available buffer
			state.currSelectedBuffer = state.get_first_available_buffer()
		end
	end
end

function state.get_next_available_buffer(curr_buf_num)
	local next_buf_num = nil
	for idx, val in ipairs(state.bufList) do
		if val ~= "" and idx > curr_buf_num then
			next_buf_num = idx
			break
		end
	end
	return next_buf_num
end

function state.get_first_available_buffer()
	local next_buf_num = nil
	for idx, val in ipairs(state.bufList) do
		if val ~= "" then
			next_buf_num = idx
			break
		end
	end
	return next_buf_num
end

function state.go_prev_buffer()
	-- Case where we don't have a currently selected buffer, start from end of all buffers and set that as the
	-- current selected buffer
	if state.currSelectedBuffer == nil then
		state.currSelectedBuffer = state.get_prev_available_buffer(#state.bufList)
	else
		local next_buf = state.get_prev_available_buffer(state.currSelectedBuffer)
		if next_buf ~= nil then
			state.currSelectedBuffer = next_buf
		else
			-- Handles wrapping back to first available buffer
			state.currSelectedBuffer = state.get_first_available_buffer_rev()
		end
	end
end

function state.get_prev_available_buffer(curr_buf_num)
	local next_buf_num = nil
	for i = #state.bufList, 0, -1 do
		if state.bufList[i] ~= "" and i < curr_buf_num then
			next_buf_num = i
			break
		end
	end
	return next_buf_num
end

function state.get_first_available_buffer_rev()
	local next_buf_num = nil
	for i = #state.bufList, 0, -1 do
		if state.bufList[i] ~= "" then
			next_buf_num = i
			break
		end
	end
	return next_buf_num
end

function state.set_first_hotswap(bufnr)
	state.firstBufHotswap = bufnr
end

function state.set_first_hotswap_from_window()
	state.firstBufHotswap = vim.fn.bufnr(state.bufList[state.selectedRow])
end

function state.set_second_hotswap(bufnr)
	state.secondBufHotswap = bufnr
end

function state.set_second_hotswap_from_window()
	state.secondBufHotswap = vim.fn.bufnr(state.bufList[state.selectedRow])
end

function state.update_selected_row()
	state.selectedRow = vim.api.nvim_win_get_cursor(0)[1]
end

function state.move_up_selected_search_result()
	if state.selected_search_result - 1 <= 0 then
		state.selected_search_result = 1
	else
		state.selected_search_result = state.selected_search_result - 1
	end
end

function state.move_down_selected_search_result()
	if state.selected_search_result + 1 >= #state.buff_search_results then
		state.selected_search_result = #state.buff_search_results
	else
		state.selected_search_result = state.selected_search_result + 1
	end
end

function state.clear_selected_row()
	state.selectedRow = nil
end

function state.clear_selected_search_result()
	state.selected_search_result = nil
end

function state.clear_state()
	state.bufList = {}
	state.selectedRow = nil
end

local function fuzzy_path_score(query, path)
	query = query:lower()
	path = path:lower()

	local last = path:match("([^/]+)$") or path
	local score = 0

	-- Rule 1: exact substring in last segment
	if last:find(query, 1, true) then
		score = score + 1
	end

	-- Rule 2: fuzzy match in last segment
	do
		local pos = 0
		local ok = true
		for c in query:gmatch(".") do
			local s, e = last:find(c, pos + 1, true)
			if not s then
				ok = false
				break
			end
			pos = e
		end
		if ok then
			score = score + 1
		end
	end

	-- Rule 3: fuzzy match anywhere
	do
		local pos = 0
		local ok = true
		for c in query:gmatch(".") do
			local s, e = path:find(c, pos + 1, true)
			if not s then
				ok = false
				break
			end
			pos = e
		end
		if ok then
			score = score + 1
		end
	end

	return score
end

local function fuzzy_substr(query, items)
	local results = {}
	query = query:lower()
	for _, item in ipairs(items) do
		local score = fuzzy_path_score(query, item)
		if score > 0 then
			table.insert(results, { item = item, score = score })
		end
	end

	if #results > 0 then
		table.sort(results, function(a, b)
			return a.score > b.score
		end)
	end

	return results
end

function state.search_buffers(buf_search_term)
	state.buff_search_results = fuzzy_substr(buf_search_term, state.bufList)
end

return state
