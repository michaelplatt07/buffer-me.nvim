.PHONY: clearcoverage testunit testintegration test

clearcoverage:
	@rm -f luacov.report.out && rm -f luacov.stats.out

testunit:
	@export PATH="./.luarocks/bin:$$PATH" && \
	export LUA_PATH="./.luarocks/share/lua/5.3/?.lua;./.luarocks/share/lua/5.3/?/init.lua;./lua/?.lua;$$LUA_PATH" && \
	export LUA_CPATH="./.luarocks/lib/lua/5.3/?.so;$$LUA_CPATH" && \
	busted --coverage lua/tests/unit && \
	luacov

testintegration:
	@export PATH="./.luarocks/bin:$$PATH" && \
	export LUA_PATH="./.luarocks/share/lua/5.3/?.lua;./.luarocks/share/lua/5.3/?/init.lua;./lua/?.lua;$$LUA_PATH" && \
	export LUA_CPATH="./.luarocks/lib/lua/5.3/?.so;$$LUA_CPATH" && \
	nvim --headless --noplugin \
     -u lua/tests/minimal_init.lua \
     -c "PlenaryBustedDirectory lua/tests/integration/ { minimal_init = 'lua/tests/minimal_init.lua' }" && \
	luacov


testfull: clearcoverage testunit testintegration
	
