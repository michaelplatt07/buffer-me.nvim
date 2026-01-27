local state
local luaunit = require("luaunit")

-- Mock Vim so we can mock returns on method bindings
vim = {
	api = {},
	loop = {},
}
-- End mocking

require("luacov")

TestState = {}

-- Setting up and tearing down for each test
function TestState:setup()
	package.loaded["buffer-me.state"] = nil
	state = require("buffer-me.state")
end

function TestState:teardown() end
-- End setup and teardown

function TestState:test_init_required_buffers()
	vim.api.nvim_create_buf = function()
		return 1
	end
	vim.api.nvim_buf_set_option = function()
		-- Do nothing as setting the type shouldn't matter here
	end

	luaunit.assertEquals(state.bufListBuf, nil)
	luaunit.assertEquals(state.hotswapBuf, nil)
	state.init_required_buffers()
	luaunit.assertNotIsNil(state.bufListBuf, "BufListBuf should not be nil")
	luaunit.assertNotIsNil(state.hotswapBuf, "HotswapBuf should not be nil")
end

function TestState:test_append_no_entries_no_duplicate()
	vim.api.nvim_buf_get_name = function()
		return "this_is_a_buffer_name"
	end
	vim.loop.cwd = function()
		return "this_is_a_buffer_name"
	end
	vim.pesc = function()
		return "this_is_a_buffer_name"
	end

	luaunit.assertEquals(state.bufList[1], nil)
	state.append_to_buf_list(0)
	luaunit.assertEquals(state.bufList[1], "this_is_a_buffer_name")
end

function TestState:test_append_with_entries_no_duplicate()
	vim.api.nvim_buf_get_name = function()
		return "this_is_a_buffer_name"
	end
	vim.loop.cwd = function()
		return "this_is_a_buffer_name"
	end
	vim.pesc = function()
		return "this_is_a_buffer_name"
	end

	state.bufList[1] = "place_holder_1_asdf"
	state.bufList[2] = "place_holder_2_asdf"

	luaunit.assertEquals(state.bufList[1], "place_holder_1_asdf")
	luaunit.assertEquals(state.bufList[2], "place_holder_2_asdf")
	state.append_to_buf_list(0)
	luaunit.assertEquals(state.bufList[1], "this_is_a_buffer_name")
	luaunit.assertEquals(state.bufList[2], "place_holder_1_asdf")
	luaunit.assertEquals(state.bufList[3], "place_holder_2_asdf")
end

function TestState:test_append_duplicate_no_reset_flag()
	-- Tests leaving the buffer in the current list if it's already there
	vim.api.nvim_buf_get_name = function()
		return "place_holder_1"
	end
	vim.loop.cwd = function()
		return "place_holder_1"
	end
	vim.pesc = function()
		return "place_holder_1"
	end

	state.bufList[1] = "place_holder_1"
	state.bufList[2] = "place_holder_2"

	luaunit.assertEquals(state.bufList[1], "place_holder_1")
	luaunit.assertEquals(state.bufList[2], "place_holder_2")
	state.append_to_buf_list(0)
	luaunit.assertEquals(state.bufList[3], nil)
end

function TestState:test_append_duplicate_reset_flag()
	-- Tests duplicate that should shift to the top
	vim.api.nvim_buf_get_name = function()
		return "place_holder_3"
	end
	vim.loop.cwd = function()
		return "place_holder_3"
	end
	vim.pesc = function()
		return "place_holder_3"
	end

	state.recentToTop = true

	state.bufList[1] = "place_holder_1"
	state.bufList[2] = "place_holder_2"
	state.bufList[3] = "place_holder_3"

	luaunit.assertEquals(state.bufList[1], "place_holder_1")
	luaunit.assertEquals(state.bufList[2], "place_holder_2")
	luaunit.assertEquals(state.bufList[3], "place_holder_3")
	state.append_to_buf_list(0)
	luaunit.assertEquals(state.bufList[1], "place_holder_3")
	luaunit.assertEquals(state.bufList[2], "place_holder_1")
	luaunit.assertEquals(state.bufList[3], "place_holder_2")
	luaunit.assertEquals(#state.bufList, 3)
end

function TestState.test_append_last_entry()
	vim.api.nvim_buf_get_name = function()
		return "place_holder_11"
	end
	vim.loop.cwd = function()
		return "place_holder_11"
	end
	vim.pesc = function()
		return "place_holder_11"
	end

	state.isBufListFull = true
	for idx = 1, 9 do
		state.bufList[idx] = "place_holder_" .. idx
	end

	state.append_to_buf_list(0)
	luaunit.assertEquals(state.bufList[1], "place_holder_11")
	luaunit.assertEquals(state.bufList[2], "place_holder_1")
	luaunit.assertEquals(state.bufList[3], "place_holder_2")
	luaunit.assertEquals(state.isBufListFull, true)
end

function TestState:test_append_full()
	vim.api.nvim_buf_get_name = function()
		return "place_holder_11"
	end
	vim.loop.cwd = function()
		return "place_holder_11"
	end
	vim.pesc = function()
		return "place_holder_11"
	end

	state.isBufListFull = true
	for idx = 1, 10 do
		state.bufList[idx] = "place_holder_" .. idx
	end

	state.append_to_buf_list(0)
	luaunit.assertEquals(state.bufList[1], "place_holder_11")
	luaunit.assertEquals(state.bufList[2], "place_holder_1")
	luaunit.assertEquals(state.bufList[3], "place_holder_2")
	luaunit.assertEquals(#state.bufList, 10)
end

function TestState:test_open_already_tracked_buffer()
	-- The purpose of this is to test to ensure we are not removing from the buffer list if we switch into a new buffer
	-- that is already in the buffer list leading to a false removal
	vim.api.nvim_buf_get_name = function()
		return "place_holder_7"
	end
	vim.loop.cwd = function()
		return "place_holder_7"
	end
	vim.pesc = function()
		return "place_holder_7"
	end

	state.isBufListFull = true
	state.recentToTop = true
	for idx = 1, 10 do
		state.bufList[idx] = "place_holder_" .. idx
	end

	state.append_to_buf_list(0)
	luaunit.assertEquals(state.bufList[1], "place_holder_7")
	luaunit.assertEquals(state.bufList[2], "place_holder_1")
	luaunit.assertEquals(state.bufList[3], "place_holder_2")
	luaunit.assertEquals(#state.bufList, 10)
end

function TestState:test_clear_selected_row()
	state.selectedRow = "Some Value"
	luaunit.assertEquals(state.selectedRow, "Some Value")
	state.clear_selected_row()
	luaunit.assertEquals(state.selectedRow, nil)
end

function TestState:test_add_buf_to_num_to_empty_spot()
	vim.api.nvim_buf_get_name = function()
		return "place_holder"
	end

	luaunit.assertEquals(state.bufList[4], nil)
	state.add_buf_to_num(4, 0)
	luaunit.assertEquals(state.bufList[4], "place_holder")
end

function TestState:test_add_buf_to_num_to_filled_spot()
	vim.api.nvim_buf_get_name = function()
		return "replacement_name"
	end
	for idx = 1, 10 do
		state.bufList[idx] = "place_holder_" .. idx
	end

	luaunit.assertEquals(state.bufList[4], "place_holder_4")
	state.add_buf_to_num(4, 0)
	luaunit.assertEquals(state.bufList[4], "replacement_name")
end

function TestState:test_remove_buf_by_num_value_present()
	for idx = 1, 10 do
		table.insert(state.bufList, "place_holder_" .. idx)
	end

	luaunit.assertEquals(state.bufList[4], "place_holder_4")
	state.remove_buf_by_num(4)
	luaunit.assertEquals(state.bufList[4], "place_holder_5")
end

function TestState:test_remove_buf_by_num_no_value_present()
	luaunit.assertEquals(state.bufList[4], nil)
	state.remove_buf_by_num(4)
	luaunit.assertEquals(state.bufList[4], nil)
end

function TestState.test_go_next_buffer_currently_empty()
	for idx = 1, 10 do
		state.bufList[idx] = "place_holder_" .. idx
	end

	luaunit.assertEquals(state.currSelectedBuffer, nil)
	state.go_next_buffer()
	luaunit.assertEquals(state.currSelectedBuffer, 1)
end

function TestState.test_go_next_buffer_immediately_after()
	for idx = 1, 10 do
		state.bufList[idx] = "place_holder_" .. idx
	end
	state.currSelectedBuffer = 1

	luaunit.assertEquals(state.currSelectedBuffer, 1)
	state.go_next_buffer()
	luaunit.assertEquals(state.currSelectedBuffer, 2)
end

function TestState.test_go_next_buffer_wraps_to_beginning()
	state.bufList[1] = "place_holder_1"
	state.bufList[2] = "place_holder_5"
	state.currSelectedBuffer = 2

	luaunit.assertEquals(state.currSelectedBuffer, 2)
	state.go_next_buffer()
	luaunit.assertEquals(state.currSelectedBuffer, 1)
end

function TestState.test_go_prev_buffer_currently_empty()
	for idx = 1, 10 do
		state.bufList[idx] = "place_holder_" .. idx
	end

	luaunit.assertEquals(state.currSelectedBuffer, nil)
	state.go_prev_buffer()
	luaunit.assertEquals(state.currSelectedBuffer, 9)
end

function TestState.test_go_prev_buffer_immediately_before()
	for idx = 1, 10 do
		state.bufList[idx] = "place_holder_" .. idx
	end

	state.currSelectedBuffer = 2
	luaunit.assertEquals(state.currSelectedBuffer, 2)
	state.go_prev_buffer()
	luaunit.assertEquals(state.currSelectedBuffer, 1)
end

function TestState.test_go_prev_buffer_wraps_to_beginning()
	state.bufList[1] = "place_holder_1"
	state.bufList[2] = "place_holder_5"

	state.currSelectedBuffer = 1

	luaunit.assertEquals(state.currSelectedBuffer, 1)
	state.go_next_buffer()
	luaunit.assertEquals(state.currSelectedBuffer, 2)
end

os.exit(luaunit.LuaUnit.run())
