# find * -name "*.lua" | sed "s/^/\t/"

set(LUAROCKS_FILES
	add.lua
	admin_remove.lua
	build/builtin.lua
	build/make.lua
	build/command.lua
	build/cmake.lua
	build.lua
	cache.lua
	cfg.lua
	command_line.lua
	deps.lua
	dir.lua
	download.lua
	fetch/cvs.lua
	fetch/git.lua
	fetch/git_file.lua
	fetch/sscm.lua
	fetch/svn.lua
	fetch/hg.lua
	fetch.lua
	fs/unix/tools.lua
	fs/win32/tools.lua
	fs/lua.lua
	fs/unix.lua
	fs/win32.lua
	fs.lua
	help.lua
	index.lua
	install.lua
	lint.lua
	list.lua
	loader.lua
	make.lua
	make_manifest.lua
	manif_core.lua
	manif.lua
	new_version.lua
	pack.lua
	path.lua
	persist.lua
	purge.lua
	refresh_cache.lua
	remove.lua
	repos.lua
	require.lua
	search.lua
	show.lua
	tools/tar.lua
	tools/zip.lua
	tools/patch.lua
	type_check.lua
	unpack.lua
	util.lua
	validate.lua)

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
