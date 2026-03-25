# Buffer Me Plugin
A simple plugin for managing buffers within NeoVim.

## Features
The plugin is designed to offer the ability to track buffers and swap between them with an easy to use and intuitive 
interface. It an automatically track buffers on entering and exiting and can also be manually modified with the list of
commands below:
| Command | Functionality |
|---------|---------------|
| `BufferMe` | Opens the list of most recently accessed buffers                              |
| `BufferMeSearch` | Opens the search lst of all opened buffers                              |
| `BufferAppend` | Function to add a buffer to the list of managed buffers                   |
| `BufferAddAll` | Adds all currently open buffers within NeoVim to the managed list         |
| `BufferOpenIdx` | Opens a buffer at a specific index                                       |
| `BufferClearAll` | Removes all buffers from the managed list                               |
| `BufferGoNext` | Goes to the next buffer in the list                                       |
| `BufferPrevNext` | Goes to the previous buffer in the list                                 |
| `BufferSetFirstHotswap` | Sets the current buffer as the first hotswap buffer              |
| `BufferSetSecondHotswap` | Sets the current buffer as the second hotswap buffer            |
| `BufferToggleHotswap` | Toggles between the buffers set as the hotswaps                    |
| `BufferOpenFirstHotswap` | Opens the buffer set at the first hotswap                       |
| `BufferOpenSecondHotswap` | Opens the buffer set at the second hotswap                     |
| `BufferOpenMostRecent` | Jumps back to the most recently opened buffer                     |
| `BufferMeSelectPlacement` | Opens the selections option to place a buffer in a given window|

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
            max_recent_buffer_track = 10,
		})
	end,
}
```

The `branch` line is not necessary if the user doesn't desire to specify a particular branch or version. 
**Config Options Explained**
* `auto_manage`: Sets hooks that will add a buffer to the list of buffers upon opening or entering
* `most_recent_to_top`: Ensures that any buffer added to the list is bumped to the top, whether it's through a manual add or using the hooks in the above flag
* `max_recent_buffer_track`: How many recent buffers to track. This defaults to 10 but it can handle any size

## Keybindings
Keybinding work in two different panes as shown below. The `View Mode Window` is the default window that shows up when
launching the buffer-me plugin. This is essentially the manager window for removing buffers from the list, moving the
order, etc. The `Search Mode Window` is the window opened when a user wants to search for a buffer within the list of
all buffers that have been opened in a session:
|View Mode Window| | |
|-----------|---|---|
| Mode | Key | Functionality |
| `n` | `q` | Closes the management window|
| `n` | `<ESC>` | Closes the management window|
| `n` | `o` | Open the currently selected buffer|
| `n` | `<CR>` | Open the currently selected buffer|
| `n` | `d` | Remove the currently selected buffer from the list|
| `n` | `v` | Open the currently selected buffer in a vertical split|
| `n` | `h` | Open the currently selected buffer in a horizontal split|
| `n` | `f` | Set the currently selected buffer as the first hotswap|
| `n` | `s` | Set the currently selected buffer as the second hotswap|
| `n` | `g` | Prompt the user to provide a number for which buffer to open|
| `n` | `sp` | Select which window to place the buffer into |

|Search Mode Window| | |
|-----------|---|---|
| Mode | Key | Functionality |
| `n` | `j` | Move seletion up |
| `n` | `k` | Move selection down |
| `i` | `<C-p>` | Move selection up |
| `i` | `<C-n>` | Move selection down |
| `i` | `<Up>` | Move selection up |
| `i` | `<Down>` | Move selection down |
| `n` | `<CR>` | Open selected buffer |
| `i` | `<CR>` | Open selected buffer |
| `i` | `<C-v>` | Open selected buffer in a vertical split |
| `i` | `<C-s>` | Open selected buffer in a horizontal split |
| `n` | `q` | Close the search window |
| `n` | `<Esc>` | Close the search window |
| `i` | `<C-d>` | Remove buffer from managed list |
| `n` | `d` | Remove buffer from managed list |

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
This plugin comes with a test suite that can be ran but will required some dependencies to be installed first. The plugin
will need luarock installed in some way: 
```bash
sudo apt-get install luarocks
```
For the purposes of keeping depdencies separate, the required rocks can be installed locally at the root level of the plugin:
```bash
cd buffer-me.nvim
luarocks install busted --tree=.luarocks
luarocks install luacov --tree=.luarocks
```
The plugin will also need `plenary.nvim` in the same directory as the root of this plugin to be able to run integration
tests. Then test can be ran with the `Makefile` with any of the commands listed.

### Feature Requests/Bugs
If you find a bug or have a request for a feature feel free to add them in GitHub under the issue tracker
