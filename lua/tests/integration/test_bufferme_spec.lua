local test_utils = require("tests.utils")

local bufferme = nil
local state = nil
local windower = nil
local utils = nil

local function reset_packages()
	package.loaded["buffer-me.bufferme"] = nil
	package.loaded["buffer-me.state"] = nil
	package.loaded["buffer-me.windower"] = nil
	package.loaded["buffer-me.utils"] = nil
	bufferme = require("buffer-me.bufferme")
	state = require("buffer-me.state")
	windower = require("buffer-me.windower")
	utils = require("buffer-me.utils")
end

describe("bufferme.open_selected_buffer", function()
	before_each(function()
		reset_packages()
		test_utils.reset_nvim()
	end)

	it("Should open the selected buffer in the current window", function()
		-- Set up the curren buffer and selected buffer
		local current_buf = vim.api.nvim_create_buf(false, true)
		local selected_buf = vim.api.nvim_create_buf(false, true)
		local buf_list_buf = vim.api.nvim_create_buf(false, true)
		local hotswap_buf = vim.api.nvim_create_buf(false, true)

		-- Define state and assert the current buffer is set
		state.bufList = {
			current_buf,
			selected_buf,
		}
		state.selectedRow = 2
		vim.api.nvim_set_current_buf(current_buf)
		assert.is_equal(vim.api.nvim_get_current_buf(), current_buf)

		-- Open the buf list and hotswap windows so they can be closed too
		vim.api.nvim_open_win(buf_list_buf, true, {
			relative = "editor",
			row = 0,
			col = 0,
			width = 10,
			height = 10,
		})
		state.hotswapWindowHandle = vim.api.nvim_open_win(hotswap_buf, false, {
			relative = "editor",
			row = 0,
			col = 0,
			width = 10,
			height = 10,
		})

		-- Make the call
		bufferme.open_selected_buffer()

		-- The now current buffer should ge the selected buffer
		assert.is_equal(vim.api.nvim_get_current_buf(), selected_buf)
		--State should have cleared the selected row
		assert.is_equal(state.selectedRow, nil)
	end)
end)

describe("bufferme.open_selected_buffer_at_idx", function()
	before_each(function()
		reset_packages()
		test_utils.reset_nvim()
	end)

	it("Should open the selected buffer in the current window", function()
		-- Mock the getchar so we can send keys along
		vim.fn.getchar = function()
			return string.byte("1")
		end

		-- Set up the curren buffer and selected buffer
		local current_buf = vim.api.nvim_create_buf(false, true)
		local newBuf = vim.api.nvim_create_buf(false, true)

		-- Define state and assert the current buffer is set
		vim.api.nvim_set_current_buf(current_buf)
		assert.is_equal(vim.api.nvim_get_current_buf(), current_buf)

		-- Open the buf list and hotswap windows so they can be closed too
		windower.init_required_buffers()
		state.bufList = { newBuf }

		-- Make the call
		bufferme.go_to_buffer()

		-- The now current buffer should be the selected buffer
		assert.is_equal(vim.api.nvim_get_current_buf(), newBuf)
		-- The windows and buffers have been cleaned up
		assert.is_nil(windower.bufListWindowHandle)
		assert.is_nil(windower.hotswapWindowHandle)
	end)

	it("Should exit early and not update the current buffer when Q is pressed", function()
		-- Mock the getchar so we can send keys along
		vim.fn.getchar = function()
			return string.byte("q")
		end

		-- Set up the curren buffer and selected buffer
		local currentBuf = vim.api.nvim_create_buf(false, true)
		local newBuf = vim.api.nvim_create_buf(false, true)

		-- Define state and assert the current buffer is set
		vim.api.nvim_set_current_buf(currentBuf)
		assert.is_equal(vim.api.nvim_get_current_buf(), currentBuf)

		-- Open the buf list and hotswap windows so they can be closed too
		windower.init_required_buffers()
		state.bufList = { newBuf }

		-- Make the call
		bufferme.go_to_buffer()

		-- The now current buffer should be the selected buffer
		assert.is_equal(vim.api.nvim_get_current_buf(), currentBuf)
		-- The windows and buffers have been cleaned up
		assert.is_nil(windower.bufListWindowHandle)
		assert.is_nil(windower.hotswapWindowHandle)
	end)

	it("Should return when a buffer number is not set or valid", function()
		-- Mock the getchar so we can send keys along
		vim.fn.getchar = function()
			return string.byte("8")
		end

		-- Set up the curren buffer and selected buffer
		local currentBuf = vim.api.nvim_create_buf(false, true)
		local newBuf = vim.api.nvim_create_buf(false, true)

		-- Define state and assert the current buffer is set
		vim.api.nvim_set_current_buf(currentBuf)
		assert.is_equal(vim.api.nvim_get_current_buf(), currentBuf)

		-- Open the buf list and hotswap windows so they can be closed too
		windower.init_required_buffers()
		state.bufList = { newBuf }

		-- Make the call
		bufferme.go_to_buffer()

		-- The now current buffer should be the selected buffer
		assert.is_equal(vim.api.nvim_get_current_buf(), currentBuf)
		-- The windows and buffers have been cleaned up
		assert.is_nil(windower.bufListWindowHandle)
		assert.is_nil(windower.hotswapWindowHandle)
	end)
end)

describe("bufferme.open_selected_search_result", function()
	before_each(function()
		reset_packages()
		test_utils.reset_nvim()
	end)

	it("Should open the selected search result buffer in the current window", function()
		-- Set up the curren buffer and selected buffer
		local current_buf = vim.api.nvim_create_buf(false, true)
		local buf_1 = vim.api.nvim_create_buf(false, true)
		local buf_2 = vim.api.nvim_create_buf(false, true)
		local buf_3 = vim.api.nvim_create_buf(false, true)

		-- Open the buf search and search results windows
		local buf_search_buffer = vim.api.nvim_create_buf(false, true)
		local buf_search_results_buffer = vim.api.nvim_create_buf(false, true)
		state.bufListSearch = buf_search_buffer
		state.bufListSearchResultBuff = buf_search_results_buffer
		state.searchBarWindowHandle = vim.api.nvim_open_win(buf_search_buffer, true, {
			relative = "editor",
			row = 0,
			col = 0,
			width = 10,
			height = 10,
		})
		state.searchResultsWindowHandle = vim.api.nvim_open_win(buf_search_results_buffer, false, {
			relative = "editor",
			row = 0,
			col = 0,
			width = 10,
			height = 10,
		})

		-- Define state and set the search results to be accessed
		state.buff_search_results = {
			{ item = buf_1, score = 3 },
			{ item = buf_2, score = 2 },
			{ item = buf_3, score = 1 },
		}
		-- Set the current buffer
		vim.api.nvim_set_current_buf(current_buf)
		-- Pick a search result
		state.selected_search_result = 2

		-- Make the call
		bufferme.open_selected_search_result()

		-- Assert the current buffer is set correctly, the results are empty, and the search is closed
		assert.is_equal(vim.api.nvim_get_current_buf(), buf_2)
		assert.is_nil(state.selected_search_result)
		assert.are.same(state.buff_search_results, {})
		assert.is_nil(windower.searchResultsWindowHandle)
		assert.is_nil(windower.bufListSearchBuf)
		assert.is_nil(windower.bufListSearchResultBuf)
	end)
end)

describe("bufferme.open_search_bar", function()
	before_each(function()
		reset_packages()
		test_utils.reset_nvim()
	end)

	it("Should open the search bar for the buffer list", function()
		-- Call the open method
		bufferme.open_search_bar()

		assert.is_not_nil(windower.bufListSearchBuf)
		assert.is_not_nil(windower.bufListSearchResultBuf)
		assert.is_equal(state.selected_search_result, 1)
		assert.is_equal(vim.api.nvim_get_current_buf(), windower.bufListSearchBuf)
	end)
end)

describe("bufferme.move_search_selection", function()
	before_each(function()
		reset_packages()
		test_utils.reset_nvim()
	end)

	it("Should move the search selection up", function()
		-- Set up the required buffers
		windower.init_required_buffers()
		state.buff_search_results = { "Line 1", "Line 2", "Line 3" }
		vim.api.nvim_buf_set_lines(
			windower.bufListSearchResultBuf,
			0,
			#state.buff_search_results,
			false,
			state.buff_search_results
		)

		--Set up the state to be ready to move the mark up and assert the mark is where it should be
		state.selected_search_result = 3
		windower.highlight_current_mark(windower.bufListSearchResultBuf, state.selected_search_result)
		local highlights = vim.api.nvim_buf_get_extmarks(
			windower.bufListSearchResultBuf,
			windower.ns_search_cursor,
			0,
			-1,
			{ details = true }
		)
		assert.is_equal(highlights[1][2] + 1, state.selected_search_result)

		-- Make the call
		bufferme.move_search_selection_up()

		-- Assert everything was updated
		highlights = vim.api.nvim_buf_get_extmarks(
			windower.bufListSearchResultBuf,
			windower.ns_search_cursor,
			0,
			-1,
			{ details = true }
		)
		assert.is_equal(state.selected_search_result, 2)
		assert.is_equal(highlights[1][2] + 1, state.selected_search_result)
	end)

	it("Should move the search selection down", function()
		-- Set up the required buffers
		windower.init_required_buffers()
		state.buff_search_results = { "Line 1", "Line 2", "Line 3" }
		vim.api.nvim_buf_set_lines(
			windower.bufListSearchResultBuf,
			0,
			#state.buff_search_results,
			false,
			state.buff_search_results
		)

		--Set up the state to be ready to move the mark up and assert the mark is where it should be
		state.selected_search_result = 1
		windower.highlight_current_mark(windower.bufListSearchResultBuf, state.selected_search_result)
		local highlights = vim.api.nvim_buf_get_extmarks(
			windower.bufListSearchResultBuf,
			windower.ns_search_cursor,
			0,
			-1,
			{ details = true }
		)
		assert.is_equal(highlights[1][2] + 1, state.selected_search_result)

		-- Make the call
		bufferme.move_search_selection_down()

		-- Assert everything was updated
		highlights = vim.api.nvim_buf_get_extmarks(
			windower.bufListSearchResultBuf,
			windower.ns_search_cursor,
			0,
			-1,
			{ details = true }
		)
		assert.is_equal(state.selected_search_result, 2)
		assert.is_equal(highlights[1][2] + 1, state.selected_search_result)
	end)
end)

describe("bufferme.open_buffers_list", function()
	before_each(function()
		reset_packages()
		test_utils.reset_nvim()
	end)

	it("Should only show the first three buffers despite having several in the list", function()
		-- Set up the state to have more than three buffers but have a max recent track of three
		state.maxRecentBufferTrack = 3
		state.bufList = { "Buf 1", "Buf 2", "Buf 3", "Buf 4", "Buf 5" }

		-- Make the call
		bufferme.open_buffers_list()

		-- Assert only the first three buffers were rendered
		assert.same(
			vim.api.nvim_buf_get_lines(windower.bufListBuf, 0, -1, true),
			{ "1: Buf 1", "2: Buf 2", "3: Buf 3" }
		)
	end)
end)

describe("bufferme.delete_and_re_render_buf_list", function()
	before_each(function()
		reset_packages()
		test_utils.reset_nvim()
	end)

	it("Remove the buffer from the middle of the list and rerender the search dialog", function()
		-- Set up the required buffers
		windower.init_required_buffers()
		state.bufList = { "Line 1", "Line 2", "Line 3" }
		vim.api.nvim_buf_set_lines(windower.bufListBuf, 0, #state.bufList, false, state.bufList)

		--Set up the state to be ready to delete the buffer in the middle of the list
		state.selectedRow = 2
		windower.highlight_current_mark(windower.bufListBuf, state.selectedRow)
		local highlights =
			vim.api.nvim_buf_get_extmarks(windower.bufListBuf, windower.ns_search_cursor, 0, -1, { details = true })
		assert.is_equal(highlights[1][2] + 1, state.selectedRow)

		-- Make the call
		bufferme.delete_and_re_render_buf_list()

		-- Assert everything was updated
		highlights =
			vim.api.nvim_buf_get_extmarks(windower.bufListBuf, windower.ns_search_cursor, 0, -1, { details = true })
		assert.is_equal(state.selectedRow, 2)
		assert.same(state.bufList, { "Line 1", "Line 3" })
		assert.is_equal(highlights[1][2] + 1, state.selectedRow)
	end)

	-- it("Remove the buffer from the top of the list and rerender the search dialog", function()
	-- 	-- Set up the required buffers
	-- 	windower.init_required_buffers()
	-- 	state.buff_search_results = { "Line 1", "Line 2", "Line 3" }
	-- 	vim.api.nvim_buf_set_lines(
	-- 		windower.bufListSearchResultBuf,
	-- 		0,
	-- 		#state.buff_search_results,
	-- 		false,
	-- 		state.buff_search_results
	-- 	)
	--
	-- 	--Set up the state to be ready to delete the buffer at the top of the list
	-- 	state.selected_search_result = 1
	-- 	windower.highlight_current_mark(windower.bufListSearchResultBuf, state.selected_search_result)
	-- 	local highlights = vim.api.nvim_buf_get_extmarks(
	-- 		windower.bufListSearchResultBuf,
	-- 		windower.ns_search_cursor,
	-- 		0,
	-- 		-1,
	-- 		{ details = true }
	-- 	)
	-- 	assert.is_equal(highlights[1][2] + 1, state.selected_search_result)
	--
	-- 	-- Make the call
	-- 	bufferme.delete_and_re_render_buf_search_list()
	--
	-- 	-- Assert everything was updated
	-- 	highlights = vim.api.nvim_buf_get_extmarks(
	-- 		windower.bufListSearchResultBuf,
	-- 		windower.ns_search_cursor,
	-- 		0,
	-- 		-1,
	-- 		{ details = true }
	-- 	)
	-- 	assert.is_equal(state.selected_search_result, 1)
	-- 	assert.same(state.buff_search_results, { "Line 2", "Line 3" })
	-- 	assert.is_equal(highlights[1][2] + 1, state.selected_search_result)
	-- end)

	-- it("Remove the buffer from the bottom of the list and rerender the search dialog", function()
	-- 	-- Set up the required buffers
	-- 	windower.init_required_buffers()
	-- 	state.buff_search_results = { "Line 1", "Line 2", "Line 3" }
	-- 	vim.api.nvim_buf_set_lines(
	-- 		windower.bufListSearchResultBuf,
	-- 		0,
	-- 		#state.buff_search_results,
	-- 		false,
	-- 		state.buff_search_results
	-- 	)
	--
	-- 	--Set up the state to be ready to delete the buffer in the middle of the list
	-- 	state.selected_search_result = 3
	-- 	windower.highlight_current_mark(windower.bufListSearchResultBuf, state.selected_search_result)
	-- 	local highlights = vim.api.nvim_buf_get_extmarks(
	-- 		windower.bufListSearchResultBuf,
	-- 		windower.ns_search_cursor,
	-- 		0,
	-- 		-1,
	-- 		{ details = true }
	-- 	)
	-- 	assert.is_equal(highlights[1][2] + 1, state.selected_search_result)
	--
	-- 	-- Make the call
	-- 	bufferme.delete_and_re_render_buf_search_list()
	--
	-- 	-- Assert everything was updated
	-- 	highlights = vim.api.nvim_buf_get_extmarks(
	-- 		windower.bufListSearchResultBuf,
	-- 		windower.ns_search_cursor,
	-- 		0,
	-- 		-1,
	-- 		{ details = true }
	-- 	)
	-- 	assert.is_equal(state.selected_search_result, 2)
	-- 	assert.same(state.buff_search_results, { "Line 1", "Line 2" })
	-- 	assert.is_equal(highlights[1][2] + 1, state.selected_search_result)
	-- end)
end)

describe("bufferme.delete_and_re_render_buf_search_list", function()
	before_each(function()
		reset_packages()
		test_utils.reset_nvim()
	end)

	it("Remove the buffer from the middle of the list and rerender the search dialog", function()
		-- Set up the required buffers
		windower.init_required_buffers()
		state.buff_search_results = { "Line 1", "Line 2", "Line 3" }
		vim.api.nvim_buf_set_lines(
			windower.bufListSearchResultBuf,
			0,
			#state.buff_search_results,
			false,
			state.buff_search_results
		)

		--Set up the state to be ready to delete the buffer in the middle of the list
		state.selected_search_result = 2
		windower.highlight_current_mark(windower.bufListSearchResultBuf, state.selected_search_result)
		local highlights = vim.api.nvim_buf_get_extmarks(
			windower.bufListSearchResultBuf,
			windower.ns_search_cursor,
			0,
			-1,
			{ details = true }
		)
		assert.is_equal(highlights[1][2] + 1, state.selected_search_result)

		-- Make the call
		bufferme.delete_and_re_render_buf_search_list()

		-- Assert everything was updated
		highlights = vim.api.nvim_buf_get_extmarks(
			windower.bufListSearchResultBuf,
			windower.ns_search_cursor,
			0,
			-1,
			{ details = true }
		)
		assert.is_equal(state.selected_search_result, 2)
		assert.same(state.buff_search_results, { "Line 1", "Line 3" })
		assert.is_equal(highlights[1][2] + 1, state.selected_search_result)
	end)

	it("Remove the buffer from the top of the list and rerender the search dialog", function()
		-- Set up the required buffers
		windower.init_required_buffers()
		state.buff_search_results = { "Line 1", "Line 2", "Line 3" }
		vim.api.nvim_buf_set_lines(
			windower.bufListSearchResultBuf,
			0,
			#state.buff_search_results,
			false,
			state.buff_search_results
		)

		--Set up the state to be ready to delete the buffer at the top of the list
		state.selected_search_result = 1
		windower.highlight_current_mark(windower.bufListSearchResultBuf, state.selected_search_result)
		local highlights = vim.api.nvim_buf_get_extmarks(
			windower.bufListSearchResultBuf,
			windower.ns_search_cursor,
			0,
			-1,
			{ details = true }
		)
		assert.is_equal(highlights[1][2] + 1, state.selected_search_result)

		-- Make the call
		bufferme.delete_and_re_render_buf_search_list()

		-- Assert everything was updated
		highlights = vim.api.nvim_buf_get_extmarks(
			windower.bufListSearchResultBuf,
			windower.ns_search_cursor,
			0,
			-1,
			{ details = true }
		)
		assert.is_equal(state.selected_search_result, 1)
		assert.same(state.buff_search_results, { "Line 2", "Line 3" })
		assert.is_equal(highlights[1][2] + 1, state.selected_search_result)
	end)

	it("Remove the buffer from the bottom of the list and rerender the search dialog", function()
		-- Set up the required buffers
		windower.init_required_buffers()
		state.buff_search_results = { "Line 1", "Line 2", "Line 3" }
		vim.api.nvim_buf_set_lines(
			windower.bufListSearchResultBuf,
			0,
			#state.buff_search_results,
			false,
			state.buff_search_results
		)

		--Set up the state to be ready to delete the buffer in the middle of the list
		state.selected_search_result = 3
		windower.highlight_current_mark(windower.bufListSearchResultBuf, state.selected_search_result)
		local highlights = vim.api.nvim_buf_get_extmarks(
			windower.bufListSearchResultBuf,
			windower.ns_search_cursor,
			0,
			-1,
			{ details = true }
		)
		assert.is_equal(highlights[1][2] + 1, state.selected_search_result)

		-- Make the call
		bufferme.delete_and_re_render_buf_search_list()

		-- Assert everything was updated
		highlights = vim.api.nvim_buf_get_extmarks(
			windower.bufListSearchResultBuf,
			windower.ns_search_cursor,
			0,
			-1,
			{ details = true }
		)
		assert.is_equal(state.selected_search_result, 2)
		assert.same(state.buff_search_results, { "Line 1", "Line 2" })
		assert.is_equal(highlights[1][2] + 1, state.selected_search_result)
	end)
end)

describe("bufferme.open_selected_buffer_v_split", function()
	before_each(function()
		reset_packages()
		test_utils.reset_nvim()
	end)

	it("Should open the buffer in a new vsplit", function()
		-- Ensure there is only one pane to start
		assert.is_equal(1, #vim.api.nvim_tabpage_list_wins(0))

		-- Set up the current buffer and selected buffer
		local current_buf = vim.api.nvim_create_buf(false, true)
		local buf_1 = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(buf_1, "test-buffer")

		-- Open the buf search and search results windows
		windower.init_required_buffers()
		windower.create_buf_list_window()
		windower.create_hot_swap_window()

		-- Define state and set the search results to be accessed
		state.bufList = {
			buf_1,
		}
		-- Set the current buffer
		vim.api.nvim_set_current_buf(current_buf)
		-- Pick a buffer to open
		state.selectedRow = 1

		-- Make the call
		bufferme.open_selected_buffer_v_split()

		-- Assert the current buffer is set correctly, the results are empty, and the search is closed
		assert.is_equal(vim.api.nvim_get_current_buf(), buf_1)
		assert.is_nil(state.selectedRow)
		assert.are.same(state.bufList, { buf_1 })
		assert.is_nil(windower.bufListWindowHandle)
		assert.is_nil(windower.hotswapWindowHandle)
		assert.is_nil(windower.bufListBuf)
		assert.is_nil(windower.hotswapBuf)
		assert.is_equal(2, #vim.api.nvim_tabpage_list_wins(0))
		assert.is_equal("row", vim.fn.winlayout()[1])
	end)
end)

describe("bufferme.open_selected_buffer_h_split", function()
	before_each(function()
		reset_packages()
		test_utils.reset_nvim()
	end)

	it("Should open the buffer in a new vsplit", function()
		-- Ensure there is only one pane to start
		assert.is_equal(1, #vim.api.nvim_tabpage_list_wins(0))

		-- Set up the curren buffer and selected buffer
		local current_buf = vim.api.nvim_create_buf(false, true)
		local buf_1 = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(buf_1, "test-buffer")

		-- Open the buf search and search results windows
		windower.init_required_buffers()
		windower.create_buff_search_bar()
		windower.create_buff_search_results_window_if_not_exists()

		-- Open the buf search and search results windows
		windower.init_required_buffers()
		windower.create_buf_list_window()
		windower.create_hot_swap_window()

		-- Define state and set the search results to be accessed
		state.bufList = {
			buf_1,
		}
		-- Set the current buffer
		vim.api.nvim_set_current_buf(current_buf)
		-- Pick a buffer to open
		state.selectedRow = 1

		-- Make the call
		bufferme.open_selected_buffer_h_split()

		-- Assert the current buffer is set correctly, the results are empty, and the search is closed
		assert.is_equal(vim.api.nvim_get_current_buf(), buf_1)
		assert.is_nil(state.selectedRow)
		assert.are.same(state.bufList, { buf_1 })
		assert.is_nil(windower.bufListWindowHandle)
		assert.is_nil(windower.hotswapWindowHandle)
		assert.is_nil(windower.bufListBuf)
		assert.is_nil(windower.hotswapBuf)
		assert.is_equal(2, #vim.api.nvim_tabpage_list_wins(0))
		assert.is_equal("col", vim.fn.winlayout()[1])
	end)
end)

describe("bufferme.open_selected_search_result_v_split", function()
	before_each(function()
		reset_packages()
		test_utils.reset_nvim()
	end)

	it("Should open the buffer in a new vsplit", function()
		-- Ensure there is only one pane to start
		assert.is_equal(1, #vim.api.nvim_tabpage_list_wins(0))

		-- Set up the current buffer and selected buffer
		local current_buf = vim.api.nvim_create_buf(false, true)
		local buf_1 = vim.api.nvim_create_buf(false, true)

		-- Open the buf search and search results windows
		windower.init_required_buffers()
		windower.create_buff_search_bar()
		windower.create_buff_search_results_window_if_not_exists()

		-- Define state and set the search results to be accessed
		state.buff_search_results = {
			{ item = buf_1, score = 3 },
		}
		-- Set the current buffer
		vim.api.nvim_set_current_buf(current_buf)
		-- Pick a search result
		state.selected_search_result = 1

		-- Make the call
		bufferme.open_selected_search_result_v_split()

		-- Assert the current buffer is set correctly, the results are empty, and the search is closed
		assert.is_equal(vim.api.nvim_get_current_buf(), buf_1)
		assert.is_nil(state.selected_search_result)
		assert.are.same(state.buff_search_results, {})
		assert.is_nil(windower.searchResultsWindowHandle)
		assert.is_nil(windower.bufListSearchBuf)
		assert.is_nil(windower.bufListSearchResultBuf)
		assert.is_equal(2, #vim.api.nvim_tabpage_list_wins(0))
		assert.is_equal("row", vim.fn.winlayout()[1])
	end)
end)

describe("bufferme.open_selected_search_result_h_split", function()
	before_each(function()
		reset_packages()
		test_utils.reset_nvim()
	end)

	it("Should open the buffer in a new vsplit", function()
		-- Ensure there is only one pane to start
		assert.is_equal(1, #vim.api.nvim_tabpage_list_wins(0))

		-- Set up the curren buffer and selected buffer
		local current_buf = vim.api.nvim_create_buf(false, true)
		local buf_1 = vim.api.nvim_create_buf(false, true)

		-- Open the buf search and search results windows
		windower.init_required_buffers()
		windower.create_buff_search_bar()
		windower.create_buff_search_results_window_if_not_exists()

		-- Define state and set the search results to be accessed
		state.buff_search_results = {
			{ item = buf_1, score = 3 },
		}
		-- Set the current buffer
		vim.api.nvim_set_current_buf(current_buf)
		-- Pick a search result
		state.selected_search_result = 1

		-- Make the call
		bufferme.open_selected_search_result_h_split()

		-- Assert the current buffer is set correctly, the results are empty, and the search is closed
		assert.is_equal(vim.api.nvim_get_current_buf(), buf_1)
		assert.is_nil(state.selected_search_result)
		assert.are.same(state.buff_search_results, {})
		assert.is_nil(windower.searchResultsWindowHandle)
		assert.is_nil(windower.bufListSearch)
		assert.is_nil(windower.bufListSearchResultBuff)
		assert.is_equal(2, #vim.api.nvim_tabpage_list_wins(0))
		assert.is_equal("col", vim.fn.winlayout()[1])
	end)
end)

describe("bufferme.select_window_placement", function()
	before_each(function()
		reset_packages()
		test_utils.reset_nvim()
	end)

	it(
		"Should use the buffer manager to open the selected buffer in the selected window and jump to that buffer",
		function()
			-- Set up the curren buffer and selected buffer
			local firstWin = vim.api.nvim_get_current_win()
			local current_buf = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_set_current_buf(current_buf)
			local selected_buf = vim.api.nvim_create_buf(false, true)
			state.bufListBuf = vim.api.nvim_create_buf(false, true)
			state.hotswapBuf = vim.api.nvim_create_buf(false, true)

			-- Split and make a new buffer
			vim.cmd("vsplit")
			local secondWin = vim.api.nvim_get_current_win()
			local secondBuf = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_set_current_buf(secondBuf)

			-- Define state and assert the current windows have the correct buffers
			state.bufList = {
				current_buf,
				selected_buf,
				secondBuf,
			}
			state.selectedRow = 2
			vim.api.nvim_set_current_win(secondWin)
			assert.is_equal(vim.api.nvim_get_current_buf(), secondBuf)
			vim.api.nvim_set_current_win(firstWin)
			assert.is_equal(vim.api.nvim_get_current_buf(), current_buf)

			-- Open the buf list and hotswap windows so they can be closed too
			local bufWinListHandle = vim.api.nvim_open_win(state.bufListBuf, true, {
				relative = "editor",
				row = 0,
				col = 0,
				width = 10,
				height = 10,
			})
			state.hotswapWindowHandle = vim.api.nvim_open_win(state.hotswapBuf, false, {
				relative = "editor",
				row = 0,
				col = 0,
				width = 10,
				height = 10,
			})
			vim.api.nvim_set_current_win(bufWinListHandle)

			-- Make the call. Note that because the method call is wrapped in a schedule, this basically hijacks the
			-- callback and ensures that the value 2 is passed back. Apparently this is the idiomatic way to do this?
			vim.ui.input = function(opts, callback)
				callback("2")
			end
			bufferme.select_window_placement()
			vim.wait(100, function()
				return false
			end)

			-- The second window should have the selected buffer and it should be the current window
			-- TODO(map) Call the current window here and make sure it's equal to second window
			assert.is_equal(vim.api.nvim_get_current_win(), secondWin)
			assert.is_equal(vim.api.nvim_get_current_buf(), selected_buf)
			-- The first window should still have the buffer
			vim.api.nvim_set_current_win(firstWin)
			assert.is_equal(vim.api.nvim_get_current_buf(), current_buf)
		end
	)

	it(
		"Should use the search window to open the selected buffer in the selected window and jump to that buffer",
		function()
			-- Set up the curren buffer and selected buffer
			local firstWin = vim.api.nvim_get_current_win()
			local current_buf = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_set_current_buf(current_buf)
			local buf_1 = vim.api.nvim_create_buf(false, true)
			local buf_2 = vim.api.nvim_create_buf(false, true)
			local buf_3 = vim.api.nvim_create_buf(false, true)

			-- Split and make a new buffer
			vim.cmd("vsplit")
			local secondWin = vim.api.nvim_get_current_win()
			vim.api.nvim_set_current_buf(buf_1)

			-- Open the buf search and search results windows
			windower.init_required_buffers()
			windower.create_buff_search_bar()
			windower.create_buff_search_results_window_if_not_exists()

			-- Define state and set the search results to be accessed
			state.buff_search_results = {
				{ item = buf_1, score = 3 },
				{ item = buf_2, score = 2 },
				{ item = buf_3, score = 1 },
			}
			-- Pick a search result
			state.selected_search_result = 2
			vim.api.nvim_set_current_win(secondWin)
			assert.is_equal(vim.api.nvim_get_current_buf(), buf_1)
			vim.api.nvim_set_current_win(firstWin)
			assert.is_equal(vim.api.nvim_get_current_buf(), current_buf)

			-- Make the call. Note that because the method call is wrapped in a schedule, this basically hijacks the
			-- callback and ensures that the value 2 is passed back. Apparently this is the idiomatic way to do this?
			vim.ui.input = function(opts, callback)
				callback("2")
			end
			bufferme.select_window_placement()
			vim.wait(100, function()
				return false
			end)

			-- Assert the current buffer is set correctly, the results are empty, and the search is closed
			assert.is_equal(vim.api.nvim_get_current_buf(), buf_2)
			assert.is_nil(state.selected_search_result)
			assert.are.same(state.buff_search_results, {})
			assert.is_nil(windower.searchResultsWindowHandle)
			assert.is_nil(windower.bufListSearch)
			assert.is_nil(windower.bufListSearchResultBuff)
		end
	)
end)

describe("bufferme.add_buf", function()
	before_each(function()
		reset_packages()
		test_utils.reset_nvim()
	end)

	it("Should add a buffer to the buffers list", function()
		-- Set up the current buffer and selected buffer
		local currentBuf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(currentBuf, "test-name")
		vim.api.nvim_set_current_buf(currentBuf)

		-- Define state
		state.bufList = {}

		-- Make the call
		bufferme.add_buf()

		-- Assert the buffer was added
		assert.is_same(state.bufList, { "test-name" })
	end)

	it("Should add all buffers to the buffers list", function()
		-- Set up the current buffer and selected buffer
		local currentBuf = vim.api.nvim_create_buf(true, true)
		vim.api.nvim_buf_set_name(currentBuf, "test-name")
		local additionalBufOne = vim.api.nvim_create_buf(true, true)
		vim.api.nvim_buf_set_name(additionalBufOne, "test-name-1")
		local additionalBufTwo = vim.api.nvim_create_buf(true, true)
		vim.api.nvim_buf_set_name(additionalBufTwo, "test-name-2")
		local additionalBufThree = vim.api.nvim_create_buf(true, true)
		vim.api.nvim_buf_set_name(additionalBufThree, "test-name-3")
		vim.api.nvim_set_current_buf(currentBuf)

		-- Define state
		state.bufList = {}

		-- Make the call
		bufferme.add_all_buffers()

		-- Assert the buffer was added
		assert.is_same(state.bufList, { "test-name-3", "test-name-2", "test-name-1", "test-name" })
	end)
end)

describe("bufferme.remove_buf_current_selected_buff", function()
	before_each(function()
		reset_packages()
		test_utils.reset_nvim()
	end)

	it("Should remove the buffer given the current cursor position", function()
		-- Set up the current buffer and selected buffer
		local currentBuf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(currentBuf, "test-name")
		vim.api.nvim_set_current_buf(currentBuf)

		-- Define state
		windower.init_required_buffers()
		windower.create_buf_list_window()
		state.bufList = { "test-name" }
		vim.api.nvim_set_current_win(windower.bufListWindowHandle)

		-- Make the call
		bufferme.remove_buf_current_selected_buff()

		-- Assert the buffer was added
		assert.is_same(state.bufList, {})
	end)
end)

describe("bufferme.clear_buffer_list", function()
	before_each(function()
		reset_packages()
		test_utils.reset_nvim()
	end)

	it("Should clear the state", function()
		-- Set up the state
		state.buff_search_results = { { item = "One", value = 3 } }
		state.selected_search_result = 3
		state.selectedRow = 1
		state.currSelectedBuffer = 2

		-- Make the call
		bufferme.clear_buffer_list()

		-- Assert everything was cleared
		assert.is_same(state.buff_search_results, {})
		assert.is_nil(state.selected_search_result)
		assert.is_nil(state.selectedRow)
		assert.is_nil(state.currSelectedBuffer)
	end)
end)

describe("bufferme.set_hotswap", function()
	before_each(function()
		reset_packages()
		test_utils.reset_nvim()
	end)

	it("Should set the first hotswap when outside the window", function()
		-- Set up the buffer and assert the state doesn't have the hotswap set
		local buf = vim.api.nvim_create_buf(true, true)
		vim.api.nvim_set_current_buf(buf)
		assert.is_nil(state.firstBufHotswap)

		-- Make the call
		bufferme.set_first_hotswap()

		-- Assert the hotswap is set
		assert.is_equal(state.firstBufHotswap, buf)
	end)

	it("Should set the second hotswap when outside the window", function()
		-- Set up the buffer and assert the state doesn't have the hotswap set
		local buf = vim.api.nvim_create_buf(true, true)
		vim.api.nvim_set_current_buf(buf)
		assert.is_nil(state.secondBufHotswap)

		-- Make the call
		bufferme.set_second_hotswap()

		-- Assert the hotswap is set
		assert.is_equal(state.secondBufHotswap, buf)
	end)

	it("Should set the first hotswap and rerender when set in the buffer window", function()
		-- Set up the state
		local bufOne = vim.api.nvim_create_buf(true, true)
		vim.api.nvim_buf_set_name(bufOne, "bufOne")
		local bufTwo = vim.api.nvim_create_buf(true, true)
		vim.api.nvim_buf_set_name(bufTwo, "bufTwo")
		local bufThree = vim.api.nvim_create_buf(true, true)
		vim.api.nvim_buf_set_name(bufThree, "bufThree")
		state.bufList = { "bufOne", "bufTwo", "bufThree" }
		state.selectedRow = 2

		-- Open the windows
		bufferme.open_buffers_list()

		-- Assert the hotswap window has nothing
		assert.is_same(vim.api.nvim_buf_get_lines(windower.hotswapBuf, 0, 2, false), { "1: nil", "2: nil" })

		-- Make the call
		bufferme.set_first_hotswap_from_window()

		-- Assert the window was updated
		local fullPath = vim.api.nvim_buf_get_name(bufTwo)
		assert.is_same(
			vim.api.nvim_buf_get_lines(windower.hotswapBuf, 0, 2, false),
			{ string.format("1: %s", fullPath), "2: nil" }
		)
	end)

	it("Should set the second hotswap and rerender when set in the buffer window", function()
		-- Set up the state
		local bufOne = vim.api.nvim_create_buf(true, true)
		vim.api.nvim_buf_set_name(bufOne, "bufOne")
		local bufTwo = vim.api.nvim_create_buf(true, true)
		vim.api.nvim_buf_set_name(bufTwo, "bufTwo")
		local bufThree = vim.api.nvim_create_buf(true, true)
		vim.api.nvim_buf_set_name(bufThree, "bufThree")
		state.bufList = { "bufOne", "bufTwo", "bufThree" }
		state.selectedRow = 3

		-- Open the windows
		bufferme.open_buffers_list()

		-- Assert the hotswap window has nothing
		assert.is_same(vim.api.nvim_buf_get_lines(windower.hotswapBuf, 0, 2, false), { "1: nil", "2: nil" })

		-- Make the call
		bufferme.set_second_hotswap_from_window()

		-- Assert the window was updated
		local fullPath = vim.api.nvim_buf_get_name(bufThree)
		assert.is_same(
			vim.api.nvim_buf_get_lines(windower.hotswapBuf, 0, 2, false),
			{ "1: nil", string.format("2: %s", fullPath) }
		)
	end)
end)

describe("bufferme.toggle_hotswap", function()
	before_each(function()
		reset_packages()
		test_utils.reset_nvim()
	end)

	it("Should not do anything given there are no first or second hotswaps set", function()
		-- Set up state
		local buf = vim.api.nvim_create_buf(true, true)
		vim.api.nvim_set_current_buf(buf)
		state.firstBufHotswap = nil
		state.secondBufHotswap = nil

		-- Make the call
		bufferme.toggle_hotswap_buffers()

		-- Assert the buffer is the same
		assert.is_equal(vim.api.nvim_get_current_buf(), buf)
	end)

	it("Should toggle to the first hotswap when the second is not set", function()
		-- Set up state
		local buf = vim.api.nvim_create_buf(true, true)
		local bufTwo = vim.api.nvim_create_buf(true, true)
		vim.api.nvim_set_current_buf(buf)
		state.firstBufHotswap = bufTwo
		state.secondBufHotswap = nil

		-- Make the call
		bufferme.toggle_hotswap_buffers()

		-- Assert the toggle went to the new buffer from the first hotswap
		assert.is_equal(vim.api.nvim_get_current_buf(), bufTwo)
	end)

	it("Should toggle to the second hotswap when the first is not set", function()
		-- Set up state
		local buf = vim.api.nvim_create_buf(true, true)
		local bufTwo = vim.api.nvim_create_buf(true, true)
		vim.api.nvim_set_current_buf(buf)
		state.firstBufHotswap = nil
		state.secondBufHotswap = bufTwo

		-- Make the call
		bufferme.toggle_hotswap_buffers()

		-- Assert the toggle went to the new buffer from the first hotswap
		assert.is_equal(vim.api.nvim_get_current_buf(), bufTwo)
	end)

	it("Should toggle to the second hotswap if on the first hotswap", function()
		-- Set up state
		local buf = vim.api.nvim_create_buf(true, true)
		local bufTwo = vim.api.nvim_create_buf(true, true)
		vim.api.nvim_set_current_buf(buf)
		state.firstBufHotswap = buf
		state.secondBufHotswap = bufTwo

		-- Make the call
		bufferme.toggle_hotswap_buffers()

		-- Assert the toggle went to the new buffer from the second hotswap
		assert.is_equal(vim.api.nvim_get_current_buf(), bufTwo)
	end)

	it("Should toggle to the first hotswap if on the second hotswap", function()
		-- Set up state
		local buf = vim.api.nvim_create_buf(true, true)
		local bufTwo = vim.api.nvim_create_buf(true, true)
		vim.api.nvim_set_current_buf(buf)
		state.firstBufHotswap = bufTwo
		state.secondBufHotswap = buf

		-- Make the call
		bufferme.toggle_hotswap_buffers()

		-- Assert the toggle went to the new buffer from the second hotswap
		assert.is_equal(vim.api.nvim_get_current_buf(), bufTwo)
	end)
end)

describe("bufferme.open_hotswap", function()
	before_each(function()
		reset_packages()
		test_utils.reset_nvim()
	end)

	it("Should not open the first hotswap as there is none set", function()
		-- Set up state
		local buf = vim.api.nvim_create_buf(true, true)
		vim.api.nvim_set_current_buf(buf)

		-- Make the call
		bufferme.open_first_hotswap()

		-- Assert the buffer didn't chage
		assert.is_equal(vim.api.nvim_get_current_buf(), buf)
	end)

	it("Should open the first hotswap when set", function()
		-- Set up state
		local buf = vim.api.nvim_create_buf(true, true)
		local bufTwo = vim.api.nvim_create_buf(true, true)
		vim.api.nvim_set_current_buf(buf)

		-- Make the call
		state.firstBufHotswap = bufTwo
		bufferme.open_first_hotswap()

		-- Assert the buffer at hotswap one was opened
		assert.is_equal(vim.api.nvim_get_current_buf(), bufTwo)
	end)

	it("Should not open the second hotswap as there is none set", function()
		-- Set up state
		local buf = vim.api.nvim_create_buf(true, true)
		vim.api.nvim_set_current_buf(buf)

		-- Make the call
		bufferme.open_second_hotswap()

		-- Assert the toggle went to the new buffer from the second hotswap
		assert.is_equal(vim.api.nvim_get_current_buf(), buf)
	end)

	it("Should not open the second hotswap when set", function()
		-- Set up state
		local buf = vim.api.nvim_create_buf(true, true)
		local bufTwo = vim.api.nvim_create_buf(true, true)
		vim.api.nvim_set_current_buf(buf)

		-- Make the call
		state.secondBufHotswap = bufTwo
		bufferme.open_second_hotswap()

		-- Assert the buffer at hotswap two was opened
		assert.is_equal(vim.api.nvim_get_current_buf(), bufTwo)
	end)
end)
