
set(LUAROCKS_FILES
	fs/unix/tools.lua
	fs/unix.lua
	fs/win32/tools.lua
	fs/win32.lua
	fs/lua.lua
	persist.lua
	list.lua
	require.lua
	rep.lua
	dir.lua
	make_manifest.lua
	command_line.lua
	install.lua
	build/command.lua
	build/cmake.lua
	build/make.lua
	build/builtin.lua
	fetch/cvs.lua
	fetch/git.lua
	fetch/sscm.lua
	tools/patch.lua
	fetch/svn.lua
	tools/zip.lua
	tools/tar.lua
	pack.lua
	type_check.lua
	make.lua
	path.lua
	remove.lua
	fs.lua
	manif.lua
	add.lua
	deps.lua
	build.lua
	search.lua
	show.lua
	manif_core.lua
	fetch.lua
	unpack.lua
	validate.lua
	cfg.lua
	download.lua
	help.lua
	util.lua
	index.lua
	cache.lua
	add.lua
	refresh_cache.lua
	loader.lua
	admin_remove.lua
	fetch/hg.lua
	fetch/git_file.lua)

foreach(FN ${LUAROCKS_FILES})
	get_filename_component(filedir ${FN} PATH)
	install(FILES ${FN}
		DESTINATION ${LUADIR_RELATIVE}/luarocks/${filedir})
endforeach()

# Make site config
set(LUAROCKS_LUA_INCDIR ${INCDIR})
set(LUAROCKS_LUA_LIBDIR ${LIBDIR})
set(LUAROCKS_LUA_BINDIR ${BINDIR})
set(LUAROCKS_PREFIX ${CMAKE_INSTALL_PREFIX})
if(LUAROCKS_FORCE_CONFIG)
	set(LUAROCKS_FORCE_CONFIG true)
else()
	set(LUAROCKS_FORCE_CONFIG false)
endif()
configure_file(site_config.lua.in site_config.lua @ONLY)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/site_config.lua
	DESTINATION ${LUADIR_RELATIVE}/luarocks/)
