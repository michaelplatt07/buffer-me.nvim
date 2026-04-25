local testUtils = require("tests.utils")

local windower
local utils
local state

local function reset_packages()
	package.loaded["buffer-me.windower"] = nil
	package.loaded["buffer-me.utils"] = nil
	package.loaded["buffer-me.state"] = nil
	windower = require("buffer-me.windower")
	utils = require("buffer-me.utils")
	state = require("buffer-me.state")
end

describe("buffer-me.windower", function()
	before_each(function()
		reset_packages()
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
			assert.is_equal(#windower.bufLabelHandles, 1)
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
			assert.is_equal(#windower.bufLabelHandles, 2)
		end)
	end)

	describe("windower.close_buffer_me", function()
		it("Should close the buffer me plugin with no labels open", function()
			-- Set up the buffers and windows
			local winOne = vim.api.nvim_get_current_win()
			vim.cmd("vsplit")
			local winTwo = vim.api.nvim_get_current_win()

			-- Open the buffer-me window
			windower.init_required_buffers()
			windower.create_buf_list_window()
			windower.create_hot_swap_window()

			-- Be sure there are more windows open than the two original
			assert.is_equal(#vim.api.nvim_list_wins(), 4)

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
			windower.init_required_buffers()
			windower.create_buf_list_window()
			windower.create_hot_swap_window()

			-- Open the labels
			utils.build_windows_map()
			windower.create_window_labels()

			-- Be sure there are more windows open than the two original
			assert.is_equal(#vim.api.nvim_list_wins(), 6)

			-- Call to close the windows
			windower.close_buffer_me()

			-- Check that everything closed and only the two original windows remain
			assert.is_same(vim.api.nvim_list_wins(), { winOne, winTwo })
		end)

		it("Should rerender buffer lines when the method is called", function()
			-- Ensure the buffer is empty
			local curBuf = vim.api.nvim_get_current_buf()
			assert.is_same(vim.api.nvim_buf_get_lines(curBuf, 0, 10, false), { "" })

			-- Set the buffer list to be rendered and make the call
			state.selectedRow = 1
			windower.bufListBuf = curBuf
			state.bufList = { "One", "Two", "Three" }
			windower.re_render_buf_list_lines()

			assert.is_same(vim.api.nvim_buf_get_lines(curBuf, 0, 10, false), { "1: One", "2: Two", "3: Three" })
		end)
	end)
end)
