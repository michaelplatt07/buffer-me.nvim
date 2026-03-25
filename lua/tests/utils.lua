local utils = {}

function utils.reset_nvim()
	vim.cmd("silent! %bwipeout!")
	vim.cmd("enew!")
	vim.cmd("silent! only")

	-- Handle floating windows if they are still opened
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local config = vim.api.nvim_win_get_config(win)
		if config.relative ~= "" then
			pcall(vim.api.nvim_win_close, win, true)
		end
	end
end

return utils
