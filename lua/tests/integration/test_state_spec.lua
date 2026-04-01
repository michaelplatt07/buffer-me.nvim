local state = nil

describe("state.init_required_buffers", function()
	before_each(function()
		package.loaded["buffer-me.state"] = nil
		state = require("buffer-me.state")
	end)

	-- TODO(map) Likely the only integration tests needed are for things that make actual NVim API calls
	-- append_to_buf_list
	-- set_first_hotswap_from_window
	--set_second_hotswap_from_window
end)
