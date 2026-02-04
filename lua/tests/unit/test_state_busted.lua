-- Mock Vim so we can mock returns on method bindings
_G.vim = {
	api = {},
	loop = {},
	fn = {},
}
-- End mocking

-- Require for code coverage
-- require("luacov")

describe("state.init_required_buffers", function()
	local state = nil

	before_each(function()
		stub(vim.api, "nvim_create_buf", function()
			return 1
		end)

		stub(vim.api, "nvim_buf_set_option", function()
			-- no-op
		end)

		stub(vim.fn, "prompt_setprompt", function()
			-- no-op
		end)

		-- Set up the dependencies
		package.loaded["buffer-me.state"] = nil
		state = require("buffer-me.state")

		-- reset state
		state.bufListBuf = nil
		state.hotswapBuf = nil
	end)

	it("initializes required buffers when they are nil", function()
		assert.is_nil(state.bufListBuf)
		assert.is_nil(state.hotswapBuf)

		state.init_required_buffers()

		assert.is_not_nil(state.bufListBuf)
		assert.is_not_nil(state.hotswapBuf)
	end)
end)
