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
			windower.create_window_labels()

			-- Assert the table is correct
			assert.same(utils.windowMap, { winOne, winTwo })
			assert.is_equal(#state.bufLabelHandles, 2)
		end)
	end)
end)
