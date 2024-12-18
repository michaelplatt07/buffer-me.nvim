local state = {
	autoManage = false,
	bufListBuf = vim.api.nvim_create_buf(false, true),
	hotswapBuf = vim.api.nvim_create_buf(false, true),
	hotswapWindowHandle = nil,
	bufList = {
		[1] = "",
		[2] = "",
		[3] = "",
		[4] = "",
		[5] = "",
		[6] = "",
		[7] = "",
		[8] = "",
		[9] = "",
		[10] = "",
	},
	bufNumToLineNumMap = {},
	selectedRow = nil,
	currSelectedBuffer = nil,
	firstBufHotswap = nil,
	secondBufHotswap = nil,
	isBufListFull = false,
}

function state.append_to_buf_list(buf)
	if state.isBufListFull then
		-- Move everything down by one and then set the current buffer at index 1
		for idx = 2, #state.bufList do
			if idx < #state.bufList then
				state.bufList[idx] = state.bufList[idx + 1]
				state.bufList[1] = vim.api.nvim_buf_get_name(buf)
			end
		end
	else
		-- Check for duplicate name and if present don't add, otheriwse add at the next open space
		for idx, val in ipairs(state.bufList) do
			local buf_name = vim.api.nvim_buf_get_name(buf)
			if val == "" and state.check_for_dup_buf(buf_name) == false then
				state.bufList[idx] = buf_name
				if idx >= 10 then
					-- Set the state to full only if the last index is being set
					state.isBufListFull = true
				end
				break
			end
		end
	end
end

function state.check_for_dup_buf(buf_name)
	local is_dup = false
	for _, val in ipairs(state.bufList) do
		if val == buf_name then
			is_dup = true
		end
	end
	return is_dup
end

function state.add_buf_to_num(num, buf)
	local converted_num = tonumber(num)
	if state.bufList[converted_num] == "" then
		state.bufList[converted_num] = vim.api.nvim_buf_get_name(buf)
	else
		table.insert(state.bufList, converted_num, vim.api.nvim_buf_get_name(buf))
	end
end

function state.remove_buf_by_num(num)
	local converted_num = tonumber(num)
	state.bufList[converted_num] = ""
	state.isBufListFull = false
end

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
	state.selectedRow = state.bufNumToLineNumMap[vim.api.nvim_win_get_cursor(0)[1]]
end

function state.clear_selected_row()
	state.selectedRow = nil
end

function state.clear_state()
	state.bufList = {
		[1] = "",
		[2] = "",
		[3] = "",
		[4] = "",
		[5] = "",
		[6] = "",
		[7] = "",
		[8] = "",
		[9] = "",
		[0] = "",
	}
	state.bufNumToLineNumMap = {}
	state.selectedRow = nil
end

return state
