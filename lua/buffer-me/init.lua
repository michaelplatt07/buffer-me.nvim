local windower = require("buffer-me.windower")
local M = {}

function M.open()
	windower.create_floating_window()
end

function M.set_buffer_number()
	-- Sets the current buffer to the given number in the list
end

function M.remove_buffer()
	-- Removes the specified buffer from the list of managed buffers
end

function M.go_to_buffer()
	-- Goes to given buffer number in the buffer set list
end

function M.next_buffer()
	-- Goes to next buffer in the buffer set list
end

function M.prev_buffer()
	-- Goes to previous buffer in the buffer set list
end

function M.toggle_last_buffer()
	-- Toggles between the two most recent opened buffers
end

function M.setup(config)
	-- if config ~= nil then
	-- 	if config.keys ~= nil then
	-- 		for func, custombind in pairs(config.keys) do
	-- 			keybindings.update_key_binding(func, custombind)
	-- 		end
	-- 	end
	-- end
end

return M
