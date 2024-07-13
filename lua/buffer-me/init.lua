local bufferme = require("buffer-me.bufferme")
local keybindings = require("buffer-me.keybindings")
local M = {}

function M.open()
	-- Opens the buffer management list
	bufferme.open_buffers_list()
end

function M.add()
	-- Add teh current buffer to the end of the buffer management list
	bufferme.add_buf()
end

function M.add_all()
	-- Adds all current buffers open to the list
	-- TODO(map) This shoud only add up to the first 10 buffers
end

function M.set_buffer_number()
	-- Sets the current buffer to the given number in the list
	bufferme.add_buf_at_idx()
end

function M.remove_buffer()
	-- Removes the specified buffer from the list of managed buffers
	bufferme.remove_buf_at_idx()
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

function M.clear_list()
	-- Clears all the buffers from the lists
end

function M.toggle_last_buffer()
	-- Toggles between the two most recent opened buffers
end

function M.setup(config)
	if config ~= nil then
		if config.keys ~= nil then
			for func, custombind in pairs(config.keys) do
				keybindings.update_key_binding(func, custombind)
			end
		end
	end
end

return M
