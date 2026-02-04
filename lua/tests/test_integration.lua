-- Integration tests

require("tests.integration.test_bufferme")

local luaunit = require("luaunit")

os.exit(luaunit.LuaUnit.run())
