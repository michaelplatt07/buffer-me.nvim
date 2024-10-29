local state = require("buffer-me.state")
local bufferme = require("buffer-me.bufferme")
local management = {}

function management.create_bindings()
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

	-- Trigger on reading an existing file
	vim.api.nvim_create_autocmd("BufReadPost", {
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
