#!/bin/bash
[ -f luacov.report.out ] && rm luacov.report.out
[ -f luacov.stats.out ] && rm luacov.stats.out

# Get lua version for lua rocks as it may not be the same across systems
LUA_VERSION_INFO=$(lua -v 2>& 1)
# echo $LUA_VERSION_INFO
SPLIT_INFO=($LUA_VERSION_INFO)
VERSION_FOLDER=${SPLIT_INFO[1]:0:3}
echo "Setting path for Luarocks..."
echo "Using version $VERSION_FOLDER"

export PATH="./.luarocks/bin:$PATH"
export LUA_PATH="./.luarocks/share/lua/$VERSION_FOLDER/?.lua;./.luarocks/share/lua/$VERSION_FOLDER/?/init.lua;./lua/?.lua;$LUA_PATH"
export LUA_CPATH="./.luarocks/lib/lua/$VERSION_FOLDER/?.so;$LUA_CPATH"

./test_unit.sh
./test_integration.sh

./.luarocks/bin/luacov -c luacov.conf

