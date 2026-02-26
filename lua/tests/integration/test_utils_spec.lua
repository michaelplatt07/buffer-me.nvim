local utils = nil
local testUtils = require("tests.utils")

describe("utils.build_windows_map", function()
	before_each(function()
		package.loaded["buffer-me.utils"] = nil
		utils = require("buffer-me.utils")
		testUtils.reset_nvim()
	end)

	it("Should build the table of the window numbers with a single window open", function()
		-- Set up the buffers and windows
		local winOne = vim.api.nvim_get_current_win()

		-- Make the call
		utils.build_windows_map()

		-- Assert the table is correct
		assert.same(utils.windowMap, { winOne })
	end)

	it("Should build the table of the window numbers to their labels for two windows", function()
		-- Set up the buffers and windows
		local winOne = vim.api.nvim_get_current_win()
		vim.cmd("vsplit")
		local winTwo = vim.api.nvim_get_current_win()

		-- Make the call
		utils.build_windows_map()

		-- Assert the table is correct
		assert.same(utils.windowMap, { winOne, winTwo })
	end)

	it("Should build the table ignoring windows that are floats", function()
		-- Set up the buffers and windows
		local winOne = vim.api.nvim_get_current_win()
		vim.cmd("vsplit")
		local winTwo = vim.api.nvim_get_current_win()
		local buf = vim.api.nvim_create_buf(false, true)
		local winThree = vim.api.nvim_open_win(buf, false, {
			relative = "win",
			win = winTwo,
			row = 0,
			col = 0,
			width = 5,
			height = 7,
			style = "minimal",
		})

		-- Make the call
		utils.build_windows_map()

		-- Assert the table is correct
		assert.same(utils.windowMap, { winOne, winTwo })
	end)

	it("Should build the table with a complicated series of splits", function()
		-- Set up the buffers and windows
		local winOne = vim.api.nvim_get_current_win()
		vim.cmd("vsplit")
		local winTwo = vim.api.nvim_get_current_win()
		vim.cmd("vsplit")
		local winThree = vim.api.nvim_get_current_win()
		vim.cmd("split")
		local winFour = vim.api.nvim_get_current_win()
		vim.cmd("split")
		local winFive = vim.api.nvim_get_current_win()
		vim.cmd("split")
		local winSix = vim.api.nvim_get_current_win()
		vim.cmd("vsplit")
		local winSeven = vim.api.nvim_get_current_win()
		vim.cmd("vsplit")
		local winEight = vim.api.nvim_get_current_win()

		-- Make the call
		utils.build_windows_map()

		-- Assert the table is correct
		assert.same(utils.windowMap, { winOne, winTwo, winThree, winFour, winFive, winSix, winSeven, winEight })
	end)
end)
