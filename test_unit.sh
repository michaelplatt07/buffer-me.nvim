#!/bin/bash

set -e
export LUACOV_CONFIG="$PWD/.luacov"

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

WHICH_BUSTED=$(which busted 2>& 1)
echo "Running busted at $WHICH_BUSTED with config $LUACOV_CONFIG"
busted --coverage -f $LUACOV_CONFIG lua/tests/unit/*.lua
luacov
