get_filename_component(_useluarocks_mod_dir "${CMAKE_CURRENT_LIST_FILE}" PATH)
message(STATUS "Loaded luarocks in-place: ${_useluarocks_mod_dir}")

function(luarocks_install _target _rock _rockstree)
	file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/luarocks)
	set(LUAROCKS_BUILDTREE_EXTRAPATH)
	if(TARGET "${LUA_INTERPRETER}")
		set(LUAROCKS_BUILDTREE_LUA_INTERPRETER "$<TARGET_FILE:${LUA_INTERPRETER}>")
		set(LUAROCKS_BUILDTREE_LUA_INTERPRETER_DIR "$<TARGET_FILE_DIR:${LUA_INTERPRETER}>")
	else()
		set(LUAROCKS_BUILDTREE_LUA_INTERPRETER "${LUA_INTERPRETER}")
		get_filename_component(LUAROCKS_BUILDTREE_LUA_INTERPRETER_DIR "${LUAROCKS_BUILDTREE_LUA_INTERPRETER}" PATH)
	endif()
	list(APPEND LUAROCKS_BUILDTREE_EXTRAPATH "${LUAROCKS_BUILDTREE_LUA_INTERPRETER_DIR}")

	if(TARGET ${LUA_LIBRARY})
		set(LUAROCKS_BUILDTREE_LUA_LIBDIR "$<TARGET_FILE_DIR:${LUA_LIBRARY}>")
		list(APPEND LUAROCKS_BUILDTREE_EXTRAPATH "$<TARGET_FILE_DIR:${LUA_LIBRARY}>")
	else()
		get_filename_component(LUAROCKS_BUILDTREE_LUA_LIBDIR "${LUA_LIBRARY}" PATH)
		list(APPEND LUAROCKS_BUILDTREE_EXTRAPATH "${LUAROCKS_BUILDTREE_LUA_LIBDIR}")
	endif()
	set(LUAROCKS_BUILDTREE_SRC_DIR "${_useluarocks_mod_dir}/src")

	if(WIN32)
		# Path to unixy utilities
		list(APPEND LUAROCKS_BUILDTREE_EXTRAPATH "${_useluarocks_mod_dir}/win32/bin")
		set(DELIM ";")
	else()
		string(REPLACE ";" ":" LUAROCKS_BUILDTREE_EXTRAPATH "${LUAROCKS_BUILDTREE_EXTRAPATH}")
		set(DELIM ":")
	endif()

	configure_file("${_useluarocks_mod_dir}/luarocks_install.cmake.in" "${CMAKE_CURRENT_BINARY_DIR}/luarocks_install.cmake" @ONLY)
	set(STAMPFILE "${_rockstree}/../${_target}.stamp")
	add_custom_command(OUTPUT "${STAMPFILE}"
		COMMAND
			"${CMAKE_COMMAND}"
			"--debug-output"
			"-DLUA_INTERPRETER:FILEPATH=${LUAROCKS_BUILDTREE_LUA_INTERPRETER}"
			"-DLUAROCKS_SRC_DIR:PATH=${LUAROCKS_BUILDTREE_SRC_DIR}"
			"-DEXTRAPATH:STRING=${LUAROCKS_BUILDTREE_EXTRAPATH}"
			"-DLUA_LIBDIR:PATH=${LUAROCKS_BUILDTREE_LUA_LIBDIR}"
			"-DROCKS_TREE:PATH=${_rockstree}"
			"-DROCK:STRING=${_rock}"
			"-DLUA_BINDIR:PATH=${LUAROCKS_BUILDTREE_LUA_INTERPRETER_DIR}"
			-P
			"${CMAKE_CURRENT_BINARY_DIR}/luarocks_install.cmake"
			WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
		COMMAND
			"${CMAKE_COMMAND}"
			-E
			touch
			"${STAMPFILE}"
		COMMENT "Running LuaRocks to install ${_rock} to ${_rockstree}"
		DEPENDS ${LUA_INTERPRETER} ${LUA_LIBRARY} "${CMAKE_CURRENT_BINARY_DIR}/luarocks_install.cmake" "${LUAROCKS_SITECONFIG_BUILDLOCATION}/luarocks/site_config.lua"
		VERBATIM
	)
	add_custom_target(${_target} ALL DEPENDS "${STAMPFILE}")
endfunction()
