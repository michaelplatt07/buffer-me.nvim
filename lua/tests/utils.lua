local utils = {}

function utils.reset_nvim()
	vim.cmd("silent! %bwipeout!")
	vim.cmd("enew!")
	vim.cmd("silent! only")
end

return utils
