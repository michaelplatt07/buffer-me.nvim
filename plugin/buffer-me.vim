if exists("g:loaded_buffer-me")
    finish
endif
let g:loaded_bufferme = 1

let s:lua_rocks_deps_loc =  expand("<sfile>:h:r") . "/../lua/buffer-me/deps"
exe "lua package.path = package.path .. ';" . s:lua_rocks_deps_loc . "/lua-?/init.lua'"

command! -nargs=0 BufferMe lua require("buffer-me").open()
command! -nargs=0 BufferAppend lua require("buffer-me").add()
command! -nargs=0 BufferSet lua require("buffer-me").set_buffer_number()
command! -nargs=0 BufferRemove lua require("buffer-me").remove_buffer()
command! -nargs=0 BufferAddAll lua require("buffer-me").add_all()
command! -nargs=0 BufferOpenIdx lua require("buffer-me").go_to_buffer()
command! -nargs=0 BufferClearAll lua require("buffer-me").clear_list()
