local bufferme = require("buffer-me.bufferme")
local M = {}

function M.open()
	-- Opens the buffer management list
	bufferme.open_buffers_list()
end

function M.open_search()
	-- Opens the buffer search bar
	bufferme.open_search_bar()
end

function M.add()
	-- Add the current buffer to the end of the buffer management list
	bufferme.add_buf()
end

function M.add_all()
	-- Adds all current buffers open to the list
	bufferme.add_all_buffers()
end

function M.remove_current_buffer()
	-- Removes the specified buffer from the list of managed buffers
	bufferme.remove_buf_current_selectded_buff()
end

function M.go_to_buffer()
	-- Goes to given buffer number in the buffer set list
	bufferme.go_to_buffer()
end

function M.next_buffer()
	-- Goes to next buffer in the buffer set list
	bufferme.go_next_buffer()
end

function M.prev_buffer()
	-- Goes to previous buffer in the buffer set list
	bufferme.go_prev_buffer()
end

function M.clear_list()
	-- Clears all the buffers from the lists
	bufferme.clear_buffer_list()
end

function M.set_first_hotswap()
	bufferme.set_first_hotswap()
end

function M.set_second_hotswap()
	bufferme.set_second_hotswap()
end

function M.toggle_hotswap()
	bufferme.toggle_hotswap_buffers()
end

function M.open_first()
	bufferme.open_first_hotswap()
end

function M.open_second()
	bufferme.open_second_hotswap()
end

function M.toggle_last_buffer()
	-- Toggles to the most previously viewed buffer
	bufferme.open_most_recent_buffer()
end

function M.setup(config)
	bufferme.setup_plugin(config)
end

return M
