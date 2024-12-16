local state = require("buffer-me.state")
local bufferme = require("buffer-me.bufferme")
local management = {}

function management.create_bindings()
	-- Handle any pre-processing of the buffer needed
	vim.api.nvim_create_autocmd("BufLeave", {
		pattern = "*",
		callback = function()
			local bufferModifiable = vim.api.nvim_buf_get_option(0, "modifiable")
			local buffType = vim.api.nvim_buf_get_option(0, "buftype")
			if not bufferModifiable and buffType ~= "" then
				state.mostRecentBuffer = vim.api.nvim_get_current_buf()
			end
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
