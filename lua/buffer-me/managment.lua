local state = require("buffer-me.state")
local management = {}

function management.create_bindings()
	-- Trigger on opening a new file
	vim.api.nvim_create_autocmd("BufNewFile", {
		pattern = "*",
		callback = function()
			if state.autoManage then
				print("Opened a new file!")
			end
		end,
	})

	-- Trigger on reading an existing file
	vim.api.nvim_create_autocmd("BufRead", {
		pattern = "*",
		callback = function()
			if state.autoManage then
				print("Opened an existing file!")
			end
		end,
	})
end

return management
