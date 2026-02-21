local utils = {}

function utils.reset_nvim()
	-- Close floating windows
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local config = vim.api.nvim_win_get_config(win)
		if config.relative ~= "" then
			vim.api.nvim_win_close(win, true)
		end
	end

	-- Close all normal windows except one
	if #vim.api.nvim_tabpage_list_wins(0) > 1 then
		vim.cmd("only")
	end

	-- Wipe all buffers except current
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if buf ~= vim.api.nvim_get_current_buf() then
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end

	-- Reset to empty buffer
	vim.cmd("enew!")
end

return utils
