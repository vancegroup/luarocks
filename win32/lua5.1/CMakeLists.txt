install(PROGRAMS
	bin/Microsoft.VC80.CRT.manifest
	bin/bin2c5.1.exe
	bin/lua5.1.dll
	bin/lua5.1.exe
	bin/lua5.1.lib
	bin/lua51.dll
	bin/lua51.lib
	bin/luac5.1.exe
	bin/msvcm80.dll
	bin/msvcp80.dll
	bin/msvcr80.dll
	bin/wlua5.1.exe
	DESTINATION ${BINDIR_RELATIVE})

install(FILES
	include/lauxlib.h
	include/lua.h
	include/lua.hpp
	include/luaconf.h
	include/lualib.h
	DESTINATION ${INCDIR_RELATIVE})