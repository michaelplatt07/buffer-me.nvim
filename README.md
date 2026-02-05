# Buffer Me Plugin
A simple plugin for managing buffers within NeoVim.

## Features
The plugin is designed to offer the ability to track buffers and swap between them with an easy to use and intuitive 
interface. It an automatically track buffers on entering and exiting and can also be manually modified with the list of
commands below:
* `BufferAppend` -> Function to add a buffer to the list of managed buffers
* `BufferSet` -> Sets a buffer at the specified number in the list
* `BufferRemove` -> Removes a buffer from the list
* `BufferAddAll` -> Adds all currently open buffers within NeoVim to the managed list
* `BufferOpenIdx` -> Opens a buffer at a specific index
* `BufferClearAll` -> Removes all buffers from the managed list
* `BufferGoNext` -> Goes to the next buffer in the list
* `BufferPrevNext` -> Goes to the previous buffer in the list
* `BufferSetFirstHotswap` -> Sets the current buffer as the first hotswap buffer
* `BufferSetSecondHotswap` -> Sets the current buffer as the second hotswap buffer
* `BufferToggleHotswap` -> Toggles between the buffers set as the hotswaps
* `BufferOpenFirstHotswap` -> Opens the buffer set at the first hotswap
* `BufferOpenSecondHotswap` -> Opens the buffer set at the second hotswap
* `BufferOpenMostRecent` -> Jumps back to the most recently opened buffer

## Installation
If using Lazy, the configuration for the plugin looks like:
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

The `branch` line is not necessary if the user doesn't desire to specify a particular branch or version. 
**Config Options Explained**
* `auto_manage`: Sets hooks that will add a buffer to the list of buffers upon opening or entering
* `most_recent_to_top`: Ensures that any buffer added to the list is bumped to the top, whether it's through a manual add or using the hooks in the above flag

## Keybindings
When inside the window for managing buffers, the default keybindings are available to perform certain actions:
* `o` -> Open the currently selected buffer
* `d` -> Remove the currently selected buffer from the list
* `v` -> Open the currently selected buffer in a vertical split
* `h` -> Open the currently selected buffer in a horizontal split
* `f` -> Set the currently selected buffer as the first hotswap
* `s` -> Set the currently selected buffer as the second hotswap
* `g` -> Prompt the user to provide a number for which buffer to open
* `q` -> Closes the management window

### Overriding for Custom Keybindings
These bindings can be changed by providing custom key bindings and their associated functions in the `setup` of the 
configuration. The following example overrides the basic functionality of using `q` in normal mode to close the buffer 
management window:
```lua
... -- All the setup work
{
    keys = {
        quit = "e",
    }
}
```

The full list of functions that can be overriden are listed below and are bound to normal mode. Currently there is no 
way to change the binding or function associated with the keys:
* quit
* open
* delete
* open_v_split
* open_h_split
* set_first_hotswap
* set_second_hotswap
* go_to

## Configuration
A sample configuration (if you are using Lazy) might look something like this in the `init.lua` file:
```lua
-- Set adding the current buffer to the buffer list
vim.keymap.set("n", "<leader>ba", ":BufferAppend<cr>")
-- Opens up the window for the plugin
vim.keymap.set("n", "<leader>b", ":BufferMe<cr>")
```

## Test Suite
This plugin comes with a test suite that can be ran but will required some dependencies to be installed first. Run the
following commands to set up the project for testing:
```bash
sudo apt-get install luarocks
cd buffer-me.nvim
luarocks install busted --tree=.luarocks
luarocks install luacov --tree=.luarocks
```

### Feature Requests/Bugs
If you find a bug or have a request for a feature feel free to add them in GitHub under the issue tracker
