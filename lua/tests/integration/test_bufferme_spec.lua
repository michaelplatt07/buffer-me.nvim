local bufferme = nil
local state = nil
local windower = nil

describe("bufferme.open_selected_buffer", function()
	before_each(function()
		package.loaded["buffer-me.bufferme"] = nil
		package.loaded["buffer-me.state"] = nil
		package.loaded["buffer-me.windower"] = nil
		bufferme = require("buffer-me.bufferme")
		state = require("buffer-me.state")
		windower = require("buffer-me.windower")
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

describe("bufferme.open_selected_search_result", function()
	before_each(function()
		package.loaded["buffer-me.bufferme"] = nil
		package.loaded["buffer-me.state"] = nil
		package.loaded["buffer-me.windower"] = nil
		bufferme = require("buffer-me.bufferme")
		state = require("buffer-me.state")
		windower = require("buffer-me.windower")
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
		assert.is_nil(state.searchResultsWindowHandle)
		assert.is_nil(state.bufListSearch)
		assert.is_nil(state.bufListSearchResultBuff)
	end)
end)

describe("bufferme.open_search_bar", function()
	before_each(function()
		package.loaded["buffer-me.bufferme"] = nil
		package.loaded["buffer-me.state"] = nil
		package.loaded["buffer-me.windower"] = nil
		bufferme = require("buffer-me.bufferme")
		state = require("buffer-me.state")
		windower = require("buffer-me.windower")
	end)

	it("Should open the search bar for the buffer list", function()
		-- Call the open method
		bufferme.open_search_bar()

		assert.is_not_nil(state.bufListSearch, "Nil bufListSearch")
		assert.is_not_nil(state.bufListSearchResultBuff, "Nil bufListSearchResultBuff")
		assert.is_equal(state.selected_search_result, 1)
		assert.is_equal(vim.api.nvim_get_current_buf(), state.bufListSearch)
	end)
end)

describe("bufferme.move_search_selection", function()
	before_each(function()
		package.loaded["buffer-me.bufferme"] = nil
		package.loaded["buffer-me.state"] = nil
		package.loaded["buffer-me.windower"] = nil
		bufferme = require("buffer-me.bufferme")
		state = require("buffer-me.state")
		windower = require("buffer-me.windower")
	end)

	it("Should move the search selection up", function()
		-- Set up the required buffers
		state.bufListSearchResultBuff = vim.api.nvim_create_buf(false, true)
		state.buff_search_results = { "Line 1", "Line 2", "Line 3" }
		vim.api.nvim_buf_set_lines(
			state.bufListSearchResultBuff,
			0,
			#state.buff_search_results,
			false,
			state.buff_search_results
		)

		--Set up the state to be ready to move the mark up and assert the mark is where it should be
		state.selected_search_result = 3
		windower.highlight_current_mark(state.bufListSearchResultBuff, state.selected_search_result)
		local highlights = vim.api.nvim_buf_get_extmarks(
			state.bufListSearchResultBuff,
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
			state.bufListSearchResultBuff,
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
		state.bufListSearchResultBuff = vim.api.nvim_create_buf(false, true)
		state.buff_search_results = { "Line 1", "Line 2", "Line 3" }
		vim.api.nvim_buf_set_lines(
			state.bufListSearchResultBuff,
			0,
			#state.buff_search_results,
			false,
			state.buff_search_results
		)

		--Set up the state to be ready to move the mark up and assert the mark is where it should be
		state.selected_search_result = 1
		windower.highlight_current_mark(state.bufListSearchResultBuff, state.selected_search_result)
		local highlights = vim.api.nvim_buf_get_extmarks(
			state.bufListSearchResultBuff,
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
			state.bufListSearchResultBuff,
			windower.ns_search_cursor,
			0,
			-1,
			{ details = true }
		)
		assert.is_equal(state.selected_search_result, 2)
		assert.is_equal(highlights[1][2] + 1, state.selected_search_result)
	end)
end)
