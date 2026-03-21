local utils = {
	windowMap = {},
	numberToAsciiMap = {
		{
			"    ",
			"  ██",
			"   █",
			"   █",
			"   █",
			" ███",
			"    ",
		},
		{
			"    ",
			" ███",
			"   █",
			" ███",
			" █  ",
			" ███",
			"    ",
		},
		{
			"    ",
			" ███",
			"   █",
			"  ██",
			"   █",
			" ███",
			"    ",
		},
		{
			"    ",
			" █ █",
			" █ █",
			" ███",
			"   █",
			"   █",
			"    ",
		},
		{
			"    ",
			" ███",
			" █  ",
			" ███",
			"   █",
			" ███",
			"    ",
		},
		{
			"    ",
			" ███",
			" █  ",
			" ███",
			" █ █",
			" ███",
			"    ",
		},
		{
			"    ",
			" ███",
			"   █",
			"   █",
			"   █",
			"   █",
			"    ",
		},
		{
			"    ",
			" ███",
			" █ █",
			" ███",
			" █ █",
			" ███",
			"    ",
		},
		{
			"    ",
			" ███",
			" █ █",
			" ███",
			"   █",
			" ███",
			"    ",
		},
	},
}

function utils.build_windows_map()
	local function traverse(node)
		if node[1] == "leaf" then
			table.insert(utils.windowMap, node[2])
		else
			for _, child in ipairs(node[2]) do
				traverse(child)
			end
		end
	end

	traverse(vim.fn.winlayout())
end

function utils.clear_window_map()
	-- This method should be called when the buffer windows close
	utils.windowMap = {}
end

return utils
