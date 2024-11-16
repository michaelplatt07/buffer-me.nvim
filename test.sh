rm luacov.report.out
rm luacov.stats.out

#!/bin/bash
export PATH="./.luarocks/bin:$PATH"
export LUA_PATH="./.luarocks/share/lua/5.3/?.lua;./.luarocks/share/lua/5.3/?/init.lua;./lua/?.lua;$LUA_PATH"
export LUA_CPATH="./.luarocks/lib/lua/5.3/?.so;$LUA_CPATH"

lua -lluacov lua/tests/test_state.lua
./.luarocks/bin/luacov -c luacov.conf
