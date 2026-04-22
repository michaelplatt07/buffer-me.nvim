local stub = require("luassert.stub")
local keybindings = require("buffer-me.keybindings")
local bufferme

local function trigger_keymap(buf, mode, key)
	local keymaps = vim.api.nvim_buf_get_keymap(buf, mode)
	for _, map in ipairs(keymaps) do
		if map.lhs == key then
			assert.is_not_nil(map.callback, "Keybinding '" .. key .. "' should have a callback")
			map.callback()
			return
		end
	end
	error("Keybinding '" .. key .. "' not found in mode '" .. mode .. "'")
end

describe("keybindings.map_keys", function()
	local open_stub
	local open_del
	local open_v_split
	local open_h_split
	local open_set_f
	local open_set_s
	local open_gt_buf
	local open_close
	local open_sel_win_place
	local test_buf

	before_each(function()
		package.loaded["buffer-me.bufferme"] = nil
		bufferme = require("buffer-me.bufferme")
		package.loaded["buffer-me.bufferme"] = bufferme

		open_stub = stub(bufferme, "open_selected_buffer")
		open_del = stub(bufferme, "delete_and_re_render_buf_list")
		open_v_split = stub(bufferme, "open_selected_buffer_v_split")
		open_h_split = stub(bufferme, "open_selected_buffer_h_split")
		open_set_f = stub(bufferme, "set_first_hotswap")
		open_set_s = stub(bufferme, "set_second_hotswap")
		open_gt_buf = stub(bufferme, "go_to_buffer")
		open_close = stub(bufferme, "close_buffer_me")
		open_sel_win_place = stub(bufferme, "select_window_placement")

		test_buf = vim.api.nvim_create_buf(false, true)
		keybindings.map_keys(test_buf)
	end)

	after_each(function()
		open_stub:revert()
		open_del:revert()
		open_v_split:revert()
		open_h_split:revert()
		open_set_f:revert()
		open_set_s:revert()
		open_gt_buf:revert()
		open_close:revert()
		open_sel_win_place:revert()
	end)

	it("Should call open_selected_buffer when open.key is pressed", function()
		local keys = vim.api.nvim_replace_termcodes("o", true, false, true)
		trigger_keymap(test_buf, "n", "o")
		assert.stub(open_stub).was_called()
	end)

	it("Should call open_selected_buffer when openEnter.key is pressed", function()
		vim.api.nvim_set_current_buf(test_buf)
		trigger_keymap(test_buf, "n", "<CR>")
		assert.stub(open_stub).was_called()
	end)

	it("Should call delete_and_re_render_buf_list when delete.key is pressed", function()
		vim.api.nvim_set_current_buf(test_buf)
		trigger_keymap(test_buf, "n", "d")
		assert.stub(open_del).was_called()
	end)

	it("Should call open_selected_buffer_v_split when open_v_split.key is pressed", function()
		vim.api.nvim_set_current_buf(test_buf)
		trigger_keymap(test_buf, "n", "v")
		assert.stub(open_v_split).was_called()
	end)

	it("Should call open_selected_buffer_h_split when open_h_split.key is pressed", function()
		vim.api.nvim_set_current_buf(test_buf)
		trigger_keymap(test_buf, "n", "h")
		assert.stub(open_h_split).was_called()
	end)

	it("Should call set_first_hotswap when set_first_hotswap.key is pressed", function()
		vim.api.nvim_set_current_buf(test_buf)
		trigger_keymap(test_buf, "n", "f")
		assert.stub(open_set_f).was_called()
	end)

	it("Should call set_second_hotswap when set_second_hotswap.key is pressed", function()
		vim.api.nvim_set_current_buf(test_buf)
		trigger_keymap(test_buf, "n", "s")
		assert.stub(open_set_s).was_called()
	end)

	it("Should call go_to_buffer when go_to.key is pressed", function()
		vim.api.nvim_set_current_buf(test_buf)
		trigger_keymap(test_buf, "n", "g")
		assert.stub(open_gt_buf).was_called()
	end)

	it("Should call close_buffer_me when quit.key is pressed", function()
		vim.api.nvim_set_current_buf(test_buf)
		trigger_keymap(test_buf, "n", "q")
		assert.stub(open_close).was_called()
	end)

	it("Should call close_buffer_me when quit_esc.key is pressed", function()
		vim.api.nvim_set_current_buf(test_buf)
		trigger_keymap(test_buf, "n", "<Esc>")
		assert.stub(open_close).was_called()
	end)

	it("Should call select_window_placement when selecte_placement.key is pressed", function()
		vim.api.nvim_set_current_buf(test_buf)
		trigger_keymap(test_buf, "n", "sp")
		assert.stub(open_sel_win_place).was_called()
	end)
end)

describe("keybindings.map_search_keys", function()
	local stub_mov_sel_down
	local stub_mov_sel_up
	local stub_open_sel_result
	local stub_open_sel_result_v
	local stub_open_sel_result_h
	local stub_close_search
	local stub_del_and_rerender
	local stub_sel_win_placement

	local test_buf

	before_each(function()
		package.loaded["buffer-me.bufferme"] = nil
		bufferme = require("buffer-me.bufferme")
		package.loaded["buffer-me.bufferme"] = bufferme

		stub_mov_sel_down = stub(bufferme, "move_search_selection_down")
		stub_mov_sel_up = stub(bufferme, "move_search_selection_up")
		stub_open_sel_result = stub(bufferme, "open_selected_search_result")
		stub_open_sel_result_v = stub(bufferme, "open_selected_search_result_v_split")
		stub_open_sel_result_h = stub(bufferme, "open_selected_search_result_h_split")
		stub_close_search = stub(bufferme, "close_buffer_me_search")
		stub_del_and_rerender = stub(bufferme, "delete_and_re_render_buf_search_list")
		stub_sel_win_placement = stub(bufferme, "select_window_placement")

		test_buf = vim.api.nvim_create_buf(false, true)
		keybindings.map_search_keys(test_buf)
	end)

	after_each(function()
		stub_mov_sel_down:revert()
		stub_mov_sel_up:revert()
		stub_open_sel_result:revert()
		stub_open_sel_result_v:revert()
		stub_open_sel_result_h:revert()
		stub_close_search:revert()
		stub_del_and_rerender:revert()
		stub_sel_win_placement:revert()
	end)

	it("Should call move_search_selection_down when move_up_normal.key is pressed", function()
		vim.api.nvim_set_current_buf(test_buf)
		trigger_keymap(test_buf, "n", "j")

		-- Complete one event cycle to handle async nature of vim.schedule
		vim.wait(0)

		assert.stub(stub_mov_sel_down).was_called()
	end)

	it("Should call move_search_selection_up when move_up_normal.key is pressed", function()
		vim.api.nvim_set_current_buf(test_buf)
		trigger_keymap(test_buf, "n", "k")

		-- Complete one event cycle to handle async nature of vim.schedule
		vim.wait(0)

		assert.stub(stub_mov_sel_up).was_called()
	end)

	it("Should call move_search_selection_up when move_up.key is pressed", function()
		vim.api.nvim_set_current_buf(test_buf)
		trigger_keymap(test_buf, "i", "<C-P>")

		-- Complete one event cycle to handle async nature of vim.schedule
		vim.wait(0)

		assert.stub(stub_mov_sel_up).was_called()
	end)

	it("Should call move_search_selection_down when move_down.key is pressed", function()
		vim.api.nvim_set_current_buf(test_buf)
		trigger_keymap(test_buf, "i", "<C-N>")

		-- Complete one event cycle to handle async nature of vim.schedule
		vim.wait(0)

		assert.stub(stub_mov_sel_down).was_called()
	end)

	it("Should call move_search_selection_up when arrown_move_up.key is pressed", function()
		vim.api.nvim_set_current_buf(test_buf)
		trigger_keymap(test_buf, "i", "<Up>")

		-- Complete one event cycle to handle async nature of vim.schedule
		vim.wait(0)

		assert.stub(stub_mov_sel_up).was_called()
	end)

	it("Should call move_search_selection_down when arrown_move_down.key is pressed", function()
		vim.api.nvim_set_current_buf(test_buf)
		trigger_keymap(test_buf, "i", "<Down>")

		-- Complete one event cycle to handle async nature of vim.schedule
		vim.wait(0)

		assert.stub(stub_mov_sel_down).was_called()
	end)

	it("Should call open_selected_search_result when open_normal.key is pressed", function()
		vim.api.nvim_set_current_buf(test_buf)
		trigger_keymap(test_buf, "n", "<CR>")

		-- Complete one event cycle to handle async nature of vim.schedule
		vim.wait(0)

		assert.stub(stub_open_sel_result).was_called()
	end)

	it("Should call open_selected_search_result when open.key is pressed", function()
		vim.api.nvim_set_current_buf(test_buf)
		trigger_keymap(test_buf, "i", "<CR>")

		-- Complete one event cycle to handle async nature of vim.schedule
		vim.wait(0)

		assert.stub(stub_open_sel_result).was_called()
	end)

	it("Should call open_selected_search_result_v_split when open_v_split.key is pressed", function()
		vim.api.nvim_set_current_buf(test_buf)
		trigger_keymap(test_buf, "i", "<C-V>")

		-- Complete one event cycle to handle async nature of vim.schedule
		vim.wait(0)

		assert.stub(stub_open_sel_result_v).was_called()
	end)

	it("Should call open_selected_search_result_h_split when open_h_split.key is pressed", function()
		vim.api.nvim_set_current_buf(test_buf)
		trigger_keymap(test_buf, "i", "<C-S>")

		-- Complete one event cycle to handle async nature of vim.schedule
		vim.wait(0)

		assert.stub(stub_open_sel_result_h).was_called()
	end)

	it("Should call close_buffer_me_search when close.key is pressed", function()
		vim.api.nvim_set_current_buf(test_buf)
		trigger_keymap(test_buf, "n", "q")

		-- Complete one event cycle to handle async nature of vim.schedule
		vim.wait(0)

		assert.stub(stub_close_search).was_called()
	end)

	it("Should call close_buffer_me_search when close_esc.key is pressed", function()
		vim.api.nvim_set_current_buf(test_buf)
		trigger_keymap(test_buf, "n", "<Esc>")

		-- Complete one event cycle to handle async nature of vim.schedule
		vim.wait(0)

		assert.stub(stub_close_search).was_called()
	end)

	it("Should call delete_and_re_render_buf_search_list when delete_i_mode.key is pressed", function()
		vim.api.nvim_set_current_buf(test_buf)
		trigger_keymap(test_buf, "i", "<C-D>")

		-- Complete one event cycle to handle async nature of vim.schedule
		vim.wait(0)

		assert.stub(stub_del_and_rerender).was_called()
	end)

	it("Should call delete_and_re_render_buf_search_list when delete_n_mode.key is pressed", function()
		vim.api.nvim_set_current_buf(test_buf)
		trigger_keymap(test_buf, "n", "d")

		-- Complete one event cycle to handle async nature of vim.schedule
		vim.wait(0)

		assert.stub(stub_del_and_rerender).was_called()
	end)

	it("Should call select_window_placement when select_placement.key is pressed", function()
		vim.api.nvim_set_current_buf(test_buf)
		trigger_keymap(test_buf, "n", "sp")

		-- Complete one event cycle to handle async nature of vim.schedule
		vim.wait(0)

		assert.stub(stub_sel_win_placement).was_called()
	end)
end)
