local state = {
	bufListBuf = vim.api.nvim_create_buf(false, true),
	bufList = {
		[0] = "",
		[1] = "",
		[2] = "",
		[3] = "",
		[4] = "",
		[5] = "",
		[6] = "",
		[7] = "",
		[8] = "",
		[9] = "",
	},
	bufNumToLineNumMap = {},
	selectedBuffer = nil,
}

function state.append_to_buf_list(buf)
	-- TODO(map) Prevent appending if the buffer list is greater than 10 as we will only support hotkeys between
	-- 0 and 9 for quick access
	-- TODO(map) This needs to be smart and insert at the lowest value that is an empty string
	for idx, val in ipairs(state.bufList) do
		if val == "" then
			state.bufList[idx] = vim.api.nvim_buf_get_name(buf)
			break
		else
			print("Buffer list is full")
		end
	end
	-- table.insert(state.bufList, vim.api.nvim_buf_get_name(buf))
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

function state.update_selected_row()
	state.selectedBuffer = state.bufNumToLineNumMap[vim.api.nvim_win_get_cursor(0)[1]]
	print("Updated row to: ", state.selectedBuffer)
end

return state
