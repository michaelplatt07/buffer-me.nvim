-- Load luacov if coverage is enabled
require("luacov")
vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		require("luacov.runner").save_stats()
	end,
})

-- Set the paths
vim.opt.rtp:append(".")
vim.opt.rtp:append("../plenary.nvim")
vim.opt.rtp:append("../buffer-me.lua")

-- Load plugins
vim.cmd("runtime! plugin/plenary.vim")
vim.cmd("runtime! plugin/buffer-me.lua")
