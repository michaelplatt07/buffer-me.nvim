local bufferme = nil
local state = nil
local windower = nil
describe("Testing a quick run", function()
	before_each(function()
		package.loaded["buffer-me.bufferm"] = nil
		package.loaded["buffer-me.state"] = nil
		package.loaded["buffer-me.windower"] = nil
		bufferme = require("buffer-me.bufferme")
		state = require("buffer-me.state")
		windower = require("buffer-me.windower")
	end)
	it("Can run an execute", function()
		assert.is_nil(state.bufListBuf)
		assert.is_nil(state.hotswapBuf)

		state.init_required_buffers()

		assert.is_not_nil(state.bufListBuf)
		assert.is_not_nil(state.hotswapBuf)
	end)
end)
