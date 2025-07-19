local state = require("buffer-me.state")
local management = {}

local function get_buff_watch_flags()
	local ignoreTypes = { "nofile" }
	local bufferModifiable = vim.api.nvim_buf_get_option(0, "modifiable")
	local buffType = vim.api.nvim_buf_get_option(0, "buftype")
	local shouldIgnore = false
	for _, bType in ipairs(ignoreTypes) do
		if buffType == bType then
			shouldIgnore = true
			break
		end
	end

	return shouldIgnore, bufferModifiable
end

function management.create_bindings()
	-- Handle any pre-processing of the buffer needed
	vim.api.nvim_create_autocmd("BufLeave", {
		pattern = "*",
		callback = function()
			local bufferModifiable = vim.api.nvim_buf_get_option(0, "modifiable")
			local buffType = vim.api.nvim_buf_get_option(0, "buftype")
			local shouldIgnore = false
			for _, bType in ipairs(ignoreTypes) do
				if buffType == bType then
					shouldIgnore = true
					break
				end
			end
			if bufferModifiable and not shouldIgnore then
				state.lastExitedBuffer = vim.api.nvim_get_current_buf()
			end
		end,
	})

	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = "*",
		callback = function()
			-- Get additional flags to apply for later logic
			local shouldIgnore, bufferModifiable = get_buff_watch_flags()

			-- Handle logic for quick swap to last opened buffer
			local backToCurrBuf = vim.api.nvim_get_current_buf() == state.lastExitedBuffer
			if bufferModifiable and not shouldIgnore and not backToCurrBuf then
				state.mostRecentBuffer = state.lastExitedBuffer
			end

			-- Comment#1
			-- Handle auto adding buffers to the state based on the flag and whether or not the buffer should be
			-- ignored and whether the buffer is actually modifiable. Since I don't care about any buffers that I
			-- cannot modify because they are not buffers related to files I'm working on, this logic works for now
			if not shouldIgnore and bufferModifiable and state.autoManage then
				local bufnr = vim.api.nvim_get_current_buf()
				state.append_to_buf_list(bufnr)
			end
		end,
	})

	-- Trigger on opening a new file
	vim.api.nvim_create_autocmd("BufNewFile", {
		pattern = "*",
		callback = function()
			-- Get additional flags to apply for later logic
			local shouldIgnore, bufferModifiable = get_buff_watch_flags()

			-- See Comment#1 for explanation
			if not shouldIgnore and bufferModifiable and state.autoManage then
				local bufnr = vim.api.nvim_get_current_buf()
				state.append_to_buf_list(bufnr)
			end
		end,
	})

	-- Trigger on reading a file for the first time and loading it into memory
	vim.api.nvim_create_autocmd("BufReadPost", {
		pattern = "*",
		callback = function()
			-- Get additional flags to apply for later logic
			local shouldIgnore, bufferModifiable = get_buff_watch_flags()

			-- See Comment#1 for explanation
			if not shouldIgnore and bufferModifiable and state.autoManage then
				local bufnr = vim.api.nvim_get_current_buf()
				state.append_to_buf_list(bufnr)
			end
		end,
	})
end

return management
