local state = nil

describe("state.init_required_buffers", function()
	before_each(function()
		package.loaded["buffer-me.state"] = nil
		state = require("buffer-me.state")
	end)

	it("Should initialize the required buffers", function()
		assert.is_nil(state.bufListBuf)
		assert.is_nil(state.hotswapBuf)

		state.init_required_buffers()

		assert.is_not_nil(state.bufListBuf)
		assert.is_not_nil(state.hotswapBuf)
	end)
end)
