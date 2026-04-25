local state = require("buffer-me.state")
local windower = require("buffer-me.windower")
local utils = require("buffer-me.utils")
local keybindings = require("buffer-me.keybindings")
local management = require("buffer-me.managment")
local bufferme = {}

function bufferme.open_most_recent_buffer()
	vim.api.nvim_set_current_buf(state.mostRecentBuffer)
end

local function getSelectedBufHandle(rowNumber)
	if next(state.bufList) ~= nil then
		return vim.fn.bufnr(state.bufList[rowNumber])
	elseif next(state.buff_search_results) ~= nil then
		return vim.fn.bufnr(state.buff_search_results[rowNumber]["item"])
	else
		error("There was problem opening a buffer")
	end
end

function bufferme.open_selected_buffer()
	local selected_buf_handle = getSelectedBufHandle(state.selectedRow)
	-- Close the windows first so the appropriate interaction happens with actual buffers and not plugin buffers
	windower.close_buffer_me()
	state.clear_state()
	vim.api.nvim_set_current_buf(selected_buf_handle)
end

local function getSelectedSearchResultBufHandle()
	-- TODO(map) This may not be safe but that's tomorrow me's issue
	return vim.fn.bufnr(state.buff_search_results[state.selected_search_result].item)
end

function bufferme.open_selected_search_result()
	-- Exit insert mode safely first
	if vim.fn.mode() == "i" then
		vim.cmd("stopinsert")
	end

	local selected_buf_handle = getSelectedSearchResultBufHandle()
	-- Close all the windows here so only NeoVim remains open and setting the current buffer to the selected one works
	-- as intended instead of replacing the contents of a temp buffer in the form of the plugin
	windower.close_buffer_me()
	vim.api.nvim_set_current_buf(selected_buf_handle)

	-- Clear the state and clean up any remaining buffers
	state.clear_state()
	windower.clean_up_buffers_on_close()
end

function bufferme.open_selected_search_result_v_split()
	-- Exit insert mode safely first
	if vim.fn.mode() == "i" then
		vim.cmd("stopinsert")
	end

	local selected_buf_handle = getSelectedSearchResultBufHandle()
	-- Close all the windows here so only NeoVim remains open and setting the current buffer to the selected one works
	-- as intended instead of replacing the contents of a temp buffer in the form of the plugin
	windower.close_buffer_me()
	vim.cmd("vsplit")
	vim.api.nvim_set_current_buf(selected_buf_handle)

	-- Clear the state and clean up any remaining buffers
	state.clear_state()
	windower.clean_up_buffers_on_close()
end

function bufferme.open_selected_search_result_h_split()
	-- Exit insert mode safely first
	if vim.fn.mode() == "i" then
		vim.cmd("stopinsert")
	end

	local selected_buf_handle = getSelectedSearchResultBufHandle()
	-- Close all the windows here so only NeoVim remains open and setting the current buffer to the selected one works
	-- as intended instead of replacing the contents of a temp buffer in the form of the plugin
	windower.close_buffer_me()
	vim.cmd("split")
	vim.api.nvim_set_current_buf(selected_buf_handle)

	-- Clear the state and clean up any remaining buffers
	state.clear_state()
	windower.clean_up_buffers_on_close()
end

function bufferme.open_selected_buffer_v_split()
	local selected_buf_handle = getSelectedBufHandle(state.selectedRow)
	-- Close all the windows here so only NeoVim remains open and setting the current buffer to the selected one works
	-- as intended instead of replacing the contents of a temp buffer in the form of the plugin
	windower.close_buffer_me()
	vim.cmd("vsplit")
	vim.api.nvim_set_current_buf(selected_buf_handle)

	-- Clear the state and clean up any remaining buffers
	state.clear_state()
	windower.clean_up_buffers_on_close()
end

function bufferme.open_selected_buffer_h_split()
	local selected_buf_handle = getSelectedBufHandle(state.selectedRow)
	-- Close all the windows here so only NeoVim remains open and setting the current buffer to the selected one works
	-- as intended instead of replacing the contents of a temp buffer in the form of the plugin
	windower.close_buffer_me()
	vim.cmd("split")
	vim.api.nvim_set_current_buf(selected_buf_handle)

	-- Clear the state and clean up any remaining buffers
	state.clear_state()
	windower.clean_up_buffers_on_close()
end

function bufferme.open_buffers_list()
	-- Initialize the required buffers
	windower.init_required_buffers()

	-- Callback for when the cursor moves around in the buffer
	vim.api.nvim_create_autocmd({ "CursorMoved" }, {
		buffer = windower.bufListBuf,
		callback = function()
			if #state.bufList > 0 then
				state.update_selected_row()
			end
		end,
	})

	-- Set the lines for the hotswap buffer
	windower.create_hot_swap_window()
	windower.render_hotswap_lines()

	-- Set the lines for the buffer list
	windower.create_buf_list_window()
	windower.render_buf_list_lines()

	-- Handle an empty selected row for the first time
	-- TODO(map) Decide whether or not we will keep the state of the selected row upon closing the window or not
	if state.selectedRow == nil then
		state.update_selected_row()
	end

	-- Initialize key bindings
	keybindings.map_keys(windower.bufListBuf)
end

function bufferme.open_search_bar()
	-- Initialize the required buffers
	windower.init_required_buffers()

	-- Set the lines for the buffer list
	windower.create_buff_search_bar()

	-- Initialize the search result to the first entry
	state.selected_search_result = 1

	vim.api.nvim_buf_attach(windower.bufListSearchBuf, false, {
		on_lines = function(_, _, _, firstline, _, linedata)
			local input = vim.api.nvim_buf_get_lines(windower.bufListSearchBuf, firstline, linedata, {})[1]
			vim.schedule(function()
				local search_term, _ = string.gsub(input, "> ", "")
				state.search_buffers(search_term)
				windower.create_buff_search_results_window_if_not_exists()
				windower.re_render_buf_search_results()
			end)
		end,
	})

	-- Set the mode to inserto start typing right away
	vim.api.nvim_set_current_buf(windower.bufListSearchBuf)
	vim.api.nvim_command("startinsert")

	-- Initialize key bindings
	keybindings.map_search_keys(windower.bufListSearchBuf)
	keybindings.map_search_res_keys(windower.bufListSearchResultBuf)
end

function bufferme.move_search_selection_up()
	vim.api.nvim_buf_set_option(windower.bufListSearchResultBuf, "modifiable", true)
	windower.remove_highlight(windower.bufListSearchResultBuf, state.selected_search_result)
	vim.api.nvim_buf_set_option(windower.bufListSearchResultBuf, "modifiable", false)

	state.move_up_selected_search_result()
	windower.re_render_buf_search_results()
end

function bufferme.move_search_selection_down()
	vim.api.nvim_buf_set_option(windower.bufListSearchResultBuf, "modifiable", true)
	windower.remove_highlight(windower.bufListSearchResultBuf, state.selected_search_result)
	vim.api.nvim_buf_set_option(windower.bufListSearchResultBuf, "modifiable", false)

	state.move_down_selected_search_result()
	windower.re_render_buf_search_results()
end

function bufferme.delete_and_re_render_buf_list()
	vim.api.nvim_buf_set_option(windower.bufListBuf, "modifiable", true)
	windower.remove_highlight(windower.bufListBuf, state.selectedRow)
	vim.api.nvim_buf_set_option(windower.bufListBuf, "modifiable", false)

	state.remove_selected_buf_from_list("selectedRow", state.selectedRow, state.bufList)
	windower.re_render_buf_list_lines()
end

function bufferme.delete_and_re_render_buf_search_list()
	vim.api.nvim_buf_set_option(windower.bufListSearchResultBuf, "modifiable", true)
	windower.remove_highlight(windower.bufListSearchResultBuf, state.selected_search_result)
	vim.api.nvim_buf_set_option(windower.bufListSearchResultBuf, "modifiable", false)

	state.remove_selected_buf_from_list(
		"selected_search_result",
		state.selected_search_result,
		state.buff_search_results
	)
	windower.re_render_buf_search_results()
end

function bufferme.add_buf()
	state.append_to_buf_list(0)
end

function bufferme.add_all_buffers()
	for _, buf_handle in pairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_option(buf_handle, "buflisted") then
			state.append_to_buf_list(buf_handle)
		end
	end
end

function bufferme.remove_buf_current_selected_buff()
	state.remove_buf_by_num(vim.api.nvim_win_get_cursor(0)[1], state.bufList)
end

function bufferme.go_to_buffer()
	print("Open buffer at index:")
	local idx = vim.fn.nr2char(vim.fn.getchar())

	-- Exit early if we get a q back
	if idx == "q" then
		return
	end

	-- Convert the input to a number
	local converted_idx = tonumber(idx)
	local selected_buf_handle = nil
	if state.bufList[converted_idx] == nil then
		return
	end
	selected_buf_handle = vim.fn.bufnr(state.bufList[converted_idx])
	windower.close_buffer_me()
	windower.clean_up_buffers_on_close()
	state.clear_state()
	vim.api.nvim_set_current_buf(selected_buf_handle)
end

-- function bufferme.go_next_buffer()
-- 	state.go_next_buffer()
-- 	bufferme.open_selected_buffer()
-- 	state.clear_selected_row()
-- end
--
-- function bufferme.go_prev_buffer()
-- 	state.go_prev_buffer()
-- 	bufferme.open_selected_buffer()
-- 	state.clear_selected_row()
-- end

function bufferme.clear_buffer_list()
	state.clear_state()
end

function bufferme.set_first_hotswap()
	state.firstBufHotswap = vim.api.nvim_win_get_buf(0)
end

function bufferme.set_first_hotswap_from_window()
	state.set_first_hotswap_from_window()
	windower.render_hotswap_lines()
end

function bufferme.set_second_hotswap()
	state.secondBufHotswap = vim.api.nvim_win_get_buf(0)
end

function bufferme.set_second_hotswap_from_window()
	state.set_second_hotswap_from_window()
	windower.render_hotswap_lines()
end

function bufferme.toggle_hotswap_buffers()
	-- TODO(map) Might need to include a check here to make sure the window is visible??
	-- Get the current windows buffer and name
	local bufnr = vim.api.nvim_win_get_buf(0)
	if state.firstBufHotswap == nil and state.secondBufHotswap == nil then
		-- No hotswaps set so we don't do anything
		return
	elseif state.firstBufHotswap ~= nil and state.secondBufHotswap == nil then
		-- If there is a first hotswap but there is no second go there
		vim.api.nvim_set_current_buf(state.firstBufHotswap)
	elseif state.firstBufHotswap == nil and state.secondBufHotswap ~= nil then
		-- If there is no first hotswap but there is a second go there
		vim.api.nvim_set_current_buf(state.secondBufHotswap)
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

function bufferme.open_first_hotswap()
	-- TODO(map) Is this safe to let the user just call this without closing the plugin first? Bug can be raised if
	-- this method is called periodically within another window in the plugin
	-- Get the current windows buffer and name
	local bufnr = vim.api.nvim_win_get_buf(0)
	if state.firstBufHotswap == nil then
		-- No first hotswap so nothing need be done
		return
	else
		-- If there is a first hotswap open it
		vim.api.nvim_set_current_buf(state.firstBufHotswap)
	end
end

function bufferme.open_second_hotswap()
	-- TODO(map) Is this safe to let the user just call this without closing the plugin first? Bug can be raised if
	-- this method is called periodically within another window in the plugin
	-- Get the current windows buffer and name
	local bufnr = vim.api.nvim_win_get_buf(0)
	if state.secondBufHotswap == nil then
		-- No first hotswap so nothing need be done
		return
	else
		-- If there is a first hotswap open it
		vim.api.nvim_set_current_buf(state.secondBufHotswap)
	end
end

function bufferme.select_window_placement()
	utils.build_windows_map()
	windower.create_window_labels()

	vim.schedule(function()
		vim.ui.input({ prompt = "Select window: " }, function(input)
			if input and tonumber(input) then
				local winHandle = utils.windowMap[tonumber(input)]
				local selectedBufHandle = nil
				if state.selectedRow ~= nil then
					selectedBufHandle = getSelectedBufHandle(state.selectedRow)
				elseif state.selected_search_result ~= nil then
					selectedBufHandle = getSelectedBufHandle(state.selected_search_result)
				else
					selectedBufHandle = nil
				end

				if selectedBufHandle ~= nil then
					vim.api.nvim_win_set_buf(winHandle, selectedBufHandle)
					vim.api.nvim_set_current_win(winHandle)
				end
			end

			-- TODO(map) Do we always clean up regardless of how the user exits? It's possible that we want to go back
			-- to the original state of asking a user for an input?
			windower.close_buffer_me()
			windower.clean_up_buffers_on_close()
			state.clear_state()
			utils.clear_window_map()
		end)
	end)
end

-- NOTE : These are just very simple functions or tests provide no value to have. If anything requires logic it should
-- not be placed in the disabled block for code coverage
-- luacov: disable
function bufferme.close_buffer_me()
	windower.close_buffer_me()
	windower.clean_up_buffers_on_close()
	state.clear_state()
end

function bufferme.close_buffer_me_search()
	windower.close_buffer_me()
	windower.clean_up_buffers_on_close()
	state.clear_state()
end

function bufferme.setup_plugin(config)
	-- Always clear before we load up so we are not doubling down on settings
	state.clear_state()

	if config ~= nil then
		if config.keys ~= nil then
			for func, custombind in pairs(config.keys) do
				keybindings.update_key_binding(func, custombind)
			end
		end
		if config.auto_manage ~= nil then
			state.autoManage = config.auto_manage
		end
		if config.most_recent_to_top ~= nil and config.most_recent_to_top == true then
			state.recentToTop = config.most_recent_to_top
		end
		if config.max_recent_buffer_track ~= nil then
			state.maxRecentBufferTrack = config.max_recent_buffer_track
		end
		if config.debug ~= nil and config.debug == true then
			state.debug = config.debug
		end
	end

	-- Create the bindings on the buffer events
	management.create_bindings()
end
-- luacov: enable

return bufferme
