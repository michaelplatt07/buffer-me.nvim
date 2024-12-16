local state = require("buffer-me.state")
local bufferme = require("buffer-me.bufferme")
local management = {}

function management.create_bindings()
	-- Handle any pre-processing of the buffer needed
	vim.api.nvim_create_autocmd("BufReadPre", {
		pattern = "*",
		callback = function()
			state.mostRecentBuffer = vim.api.nvim_get_current_buf()
		end,
	})

	-- Trigger on opening a new file
	vim.api.nvim_create_autocmd("BufNewFile", {
		pattern = "*",
		callback = function()
			if state.autoManage then
				local bufnr = vim.api.nvim_get_current_buf()
				state.append_to_buf_list(bufnr)
			end
		end,
	})

	-- Trigger on reading a file for the first time and loading it into memory
	vim.api.nvim_create_autocmd("BufReadPost", {
		pattern = "*",
		callback = function()
			if state.autoManage then
				local bufnr = vim.api.nvim_get_current_buf()
				state.append_to_buf_list(bufnr)
			end
		end,
	})

	-- Trigger on switching to a buffer that has already been read into memory.
	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = "*",
		callback = function()
			if state.autoManage then
				local bufnr = vim.api.nvim_get_current_buf()
				state.append_to_buf_list(bufnr)
			end
		end,
	})
end

return management
