# Configs
Loading the plugin can be done through Lazy with a configuration that looks like this:
```lua
return {
	"michaelplatt07/buffer-me.nvim",
	branch = "main",
	config = function()
		local bufferme = require("buffer-me")
		bufferme.setup({
			auto_manage = true,
			most_recent_to_top = true,
		})
	end,
}
```
**Config Options Explained**
* `auto_manage`: Sets hooks that will add a buffer to the list of buffers upon opening or entering
* `most_recent_to_top`: Ensures that any buffer added to the list is bumped to the top, whether it's through a manual add or using the hooks in the above flag

# Test Suite
This plugin comes with a test suite that can be ran but will required some dependencies to be installed first. Run the
following commands to set up the project for testing:
```bash
sudo apt-get install luarocks
cd mark-me.nvim
luarocks install luaunit --tree=.luarocks
luarocks install luacov --tree=.luarocks
```
