local state = {
	bufListBuf = vim.api.nvim_create_buf(false, true),
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
		[0] = "",
	},
	bufNumToLineNumMap = {},
	selectedRow = nil,
	currSelectedBuffer = nil,
}

function state.append_to_buf_list(buf)
	-- TODO(map) Prevent appending if the buffer list is greater than 10 as we will only support hotkeys between
	-- 0 and 9 for quick access
	-- TODO(map) This needs to be smart and insert at the lowest value that is an empty string
	for idx, val in ipairs(state.bufList) do
		local buf_name = vim.api.nvim_buf_get_name(buf)
		if val == "" and state.check_for_dup_buf(buf_name) == false then
			state.bufList[idx] = buf_name
			break
		end
	end
	-- table.insert(state.bufList, vim.api.nvim_buf_get_name(buf))
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
end

function state.go_next_buffer()
	--TODO(map) Handle case of wrapping from end
	--TODO(map) Handle case of wrapping from beginning
	-- Case where we don't have a currently selected buffer, start from beginning of all buffers and set that as the
	-- current selected buffer
	print("TODO(map) REMOVE ME : Current selected buffer: ", state.currSelectedBuffer)
	if state.currSelectedBuffer == nil then
		state.currSelectedBuffer = state.get_next_available_buffer(0)
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
	print("TODO(map) REMOVE ME : next buffer number: ", next_buf_num)
	return next_buf_num
end

function state.update_selected_row()
	state.selectedRow = state.bufNumToLineNumMap[vim.api.nvim_win_get_cursor(0)[1]]
	print("Updated row to: ", state.selectedRow)
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
