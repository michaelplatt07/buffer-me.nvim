local management = {}

-- Trigger on opening a new file
vim.api.nvim_create_autocmd("BufNewFile", {
	pattern = "*",
	callback = function()
		print("Opened a new file!")
	end,
})

-- Trigger on reading an existing file
vim.api.nvim_create_autocmd("BufRead", {
	pattern = "*",
	callback = function()
		print("Opened an existing file!")
	end,
})

return management
