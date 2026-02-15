-- Mock Vim so we can mock returns on method bindings
_G.vim = {
	api = {},
	loop = {},
	fn = {},
}
-- End mocking

local state = nil

describe("state.append_to_buf_list", function()
	before_each(function()
		stub(vim.api, "nvim_buf_get_name", function()
			return "sample_buf_1"
		end)
		stub(vim.loop, "cwd", function()
			return "sample_buf_1"
		end)
		stub(vim, "pesc", function()
			return "sample_buf_1"
		end)

		-- Set up the dependencies
		package.loaded["buffer-me.state"] = nil
		state = require("buffer-me.state")
	end)

	it("Should append to an empty buffer list with no duplicates", function()
		assert.is_nil(state.bufList[1], nil)
		state.append_to_buf_list(0)
		assert.is_equal(state.bufList[1], "sample_buf_1")
	end)

	it("Should append to an already populated list with no duplicates", function()
		state.bufList[1] = "sample_buf_2"
		state.bufList[2] = "sample_buf_3"

		assert.is_equal(state.bufList[1], "sample_buf_2")
		assert.is_equal(state.bufList[2], "sample_buf_3")
		state.append_to_buf_list(0)
		assert.is_equal(state.bufList[1], "sample_buf_1")
		assert.is_equal(state.bufList[2], "sample_buf_2")
		assert.is_equal(state.bufList[3], "sample_buf_3")
	end)

	it("Should not append the buffer name because its a duplicate", function()
		state.bufList[1] = "sample_buf_1"
		state.bufList[2] = "sample_buf_2"

		assert.is_equal(state.bufList[1], "sample_buf_1")
		assert.is_equal(state.bufList[2], "sample_buf_2")
		state.append_to_buf_list(0)
		assert.is_equal(state.bufList[3], nil)
	end)

	it("Should not append because it's a duplicate but should move the buffer to the top", function()
		state.recentToTop = true

		state.bufList[1] = "sample_buf_3"
		state.bufList[2] = "sample_buf_2"
		state.bufList[3] = "sample_buf_1"

		assert.is_equal(state.bufList[1], "sample_buf_3")
		assert.is_equal(state.bufList[2], "sample_buf_2")
		assert.is_equal(state.bufList[3], "sample_buf_1")
		state.append_to_buf_list(0)
		assert.is_equal(state.bufList[1], "sample_buf_1")
		assert.is_equal(state.bufList[2], "sample_buf_3")
		assert.is_equal(state.bufList[3], "sample_buf_2")
		assert.is_equal(#state.bufList, 3)
	end)

	it("Should add the buffer to the list and mark the list as full", function()
		for idx = 1, 9 do
			state.bufList[idx] = "sample_buf_" .. idx + 1
		end

		assert.is_equal(state.bufList[1], "sample_buf_2")
		assert.is_equal(state.bufList[2], "sample_buf_3")
		assert.is_equal(state.bufList[3], "sample_buf_4")
		state.append_to_buf_list(0)
		assert.is_equal(state.bufList[1], "sample_buf_1")
		assert.is_equal(state.bufList[2], "sample_buf_2")
		assert.is_equal(state.bufList[3], "sample_buf_3")
		assert.is_equal(#state.bufList, 10)
	end)

	it("Should add the buffer but not beyond the allowed list size", function()
		for idx = 1, 10 do
			state.bufList[idx] = "sample_buf_" .. idx + 1
		end

		assert.is_equal(state.bufList[1], "sample_buf_2")
		assert.is_equal(state.bufList[2], "sample_buf_3")
		assert.is_equal(state.bufList[3], "sample_buf_4")
		state.append_to_buf_list(0)
		assert.is_equal(state.bufList[1], "sample_buf_1")
		assert.is_equal(state.bufList[2], "sample_buf_2")
		assert.is_equal(state.bufList[3], "sample_buf_3")
	end)

	it("Should move an already listed buffer to the top of the list", function()
		state.recentToTop = true
		for idx = 10, 1, -1 do
			table.insert(state.bufList, "sample_buf_" .. idx)
		end

		assert.is_equal(state.bufList[1], "sample_buf_10")
		assert.is_equal(state.bufList[2], "sample_buf_9")
		assert.is_equal(state.bufList[3], "sample_buf_8")
		state.append_to_buf_list(0)
		assert.is_equal(state.bufList[1], "sample_buf_1")
		assert.is_equal(state.bufList[2], "sample_buf_10")
		assert.is_equal(state.bufList[3], "sample_buf_9")
	end)
end)

describe("state.clear_selected_row", function()
	before_each(function()
		-- Set up the dependencies
		package.loaded["buffer-me.state"] = nil
		state = require("buffer-me.state")
	end)

	it("Clears the seslectedRow field from the state", function()
		state.selectedRow = "Selected row"
		assert.is_equal(state.selectedRow, "Selected row")
		state.clear_selected_row()
		assert.is_nil(state.selectedRow)
	end)
end)

describe("state.remove_buf_by_num", function()
	before_each(function()
		-- Set up the dependencies
		package.loaded["buffer-me.state"] = nil
		state = require("buffer-me.state")
	end)

	it("Clears the buffer from the list at the given number", function()
		for idx = 1, 10 do
			table.insert(state.bufList, "place_holder_" .. idx)
		end

		assert.is_equal(state.bufList[4], "place_holder_4")
		state.remove_buf_by_num(4)
		assert.is_equal(state.bufList[4], "place_holder_5")
	end)
end)

-- NOTE(map) Tests to still be ported after issue: https://github.com/michaelplatt07/buffer-me.nvim/issues/31 has been
-- implemented
-- function TestState.test_go_next_buffer_currently_empty()
-- 	for idx = 1, 10 do
-- 		state.bufList[idx] = "place_holder_" .. idx
-- 	end
--
-- 	luaunit.assertEquals(state.currSelectedBuffer, nil)
-- 	state.go_next_buffer()
-- 	luaunit.assertEquals(state.currSelectedBuffer, 1)
-- end

-- function TestState.test_go_next_buffer_immediately_after()
-- 	for idx = 1, 10 do
-- 		state.bufList[idx] = "place_holder_" .. idx
-- 	end
-- 	state.currSelectedBuffer = 1
--
-- 	luaunit.assertEquals(state.currSelectedBuffer, 1)
-- 	state.go_next_buffer()
-- 	luaunit.assertEquals(state.currSelectedBuffer, 2)
-- end

-- function TestState.test_go_next_buffer_wraps_to_beginning()
-- 	state.bufList[1] = "place_holder_1"
-- 	state.bufList[2] = "place_holder_5"
-- 	state.currSelectedBuffer = 2
--
-- 	luaunit.assertEquals(state.currSelectedBuffer, 2)
-- 	state.go_next_buffer()
-- 	luaunit.assertEquals(state.currSelectedBuffer, 1)
-- end

-- function TestState.test_go_prev_buffer_currently_empty()
-- 	for idx = 1, 10 do
-- 		state.bufList[idx] = "place_holder_" .. idx
-- 	end
--
-- 	luaunit.assertEquals(state.currSelectedBuffer, nil)
-- 	state.go_prev_buffer()
-- 	luaunit.assertEquals(state.currSelectedBuffer, 9)
-- end

-- function TestState.test_go_prev_buffer_immediately_before()
-- 	for idx = 1, 10 do
-- 		state.bufList[idx] = "place_holder_" .. idx
-- 	end
--
-- 	state.currSelectedBuffer = 2
-- 	luaunit.assertEquals(state.currSelectedBuffer, 2)
-- 	state.go_prev_buffer()
-- 	luaunit.assertEquals(state.currSelectedBuffer, 1)
-- end

-- function TestState.test_go_prev_buffer_wraps_to_beginning()
-- 	state.bufList[1] = "place_holder_1"
-- 	state.bufList[2] = "place_holder_5"
--
-- 	state.currSelectedBuffer = 1
--
-- 	luaunit.assertEquals(state.currSelectedBuffer, 1)
-- 	state.go_next_buffer()
-- 	luaunit.assertEquals(state.currSelectedBuffer, 2)
-- end
