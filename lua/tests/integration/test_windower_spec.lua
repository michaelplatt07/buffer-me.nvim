local testUtils = require("tests.utils")

describe("buffer-me.windower", function()
	local windower
	local utils
	local state

	before_each(function()
		package.loaded["buffer-me.windower"] = nil
		package.loaded["buffer-me.utils"] = nil
		package.loaded["buffer-me.state"] = nil
		windower = require("buffer-me.windower")
		utils = require("buffer-me.utils")
		state = require("buffer-me.state")
		testUtils.reset_nvim()
	end)

	describe("windower.create_window_lables", function()
		it("Should build the table of the window numbers with a single window open", function()
			-- Set up the buffers and windows
			local winOne = vim.api.nvim_get_current_win()

			-- Make the call
			utils.build_windows_map()
			windower.create_window_labels()

			-- Assert the table is correct
			assert.same(utils.windowMap, { winOne })
			assert.is_equal(#state.bufLabelHandles, 1)
		end)

		it("Should build the table of the window numbers to their labels for two windows", function()
			-- Set up the buffers and windows
			local winOne = vim.api.nvim_get_current_win()
			vim.cmd("vsplit")
			local winTwo = vim.api.nvim_get_current_win()

			-- Make the call
			utils.build_windows_map()
			windower.create_window_labels()

			-- Assert the table is correct
			assert.same(utils.windowMap, { winOne, winTwo })
			assert.is_equal(#state.bufLabelHandles, 2)
		end)
	end)

	describe("windower.close_buffer_me", function()
		it("Should close the buffer me plugin with no labels open", function()
			-- Set up the buffers and windows
			local winOne = vim.api.nvim_get_current_win()
			vim.cmd("vsplit")
			local winTwo = vim.api.nvim_get_current_win()

			-- Open the buffer-me window
			state.init_required_buffers()
			windower.create_buf_list_window()

			-- Be sure there are more windows open than the two original
			assert.is_equal(#vim.api.nvim_list_wins(), 3)

			-- Call to close the windows
			windower.close_buffer_me()

			-- Check that everything closed and only the two original windows remain
			assert.is_same(vim.api.nvim_list_wins(), { winOne, winTwo })
		end)

		it("Should close the buffer me plugin with labels open", function()
			-- Set up the buffers and windows
			local winOne = vim.api.nvim_get_current_win()
			vim.cmd("vsplit")
			local winTwo = vim.api.nvim_get_current_win()

			-- Open the buffer-me window
			state.init_required_buffers()
			windower.create_buf_list_window()

			-- Open the labels
			utils.build_windows_map()
			windower.create_window_labels()

			-- Be sure there are more windows open than the two original
			assert.is_equal(#vim.api.nvim_list_wins(), 5)

			-- Call to close the windows
			windower.close_buffer_me()

			-- Check that everything closed and only the two original windows remain
			assert.is_same(vim.api.nvim_list_wins(), { winOne, winTwo })
		end)
	end)
end)
