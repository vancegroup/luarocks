project(luarocks)
cmake_minimum_required(VERSION 2.8)

###
# Configuration Options
###

# LUA_VERSION
if(NOT DEFINED LUAROCKS_LUA_VERSION)
	set(LUAROCKS_LUA_VERSION 5.1 CACHE STRING "Use specific Lua version: 5.1 or 5.2 (EXPERIMENTAL)")
endif()
foreach(ACCEPTABLE_VERSION 5.1 5.2)
	if(LUAROCKS_LUA_VERSION STREQUAL "${ACCEPTABLE_VERSION}")
		set(LUA_VERSION_VALIDATED ON)
	endif()
endforeach()
if(NOT LUA_VERSION_VALIDATED)
	message(ERROR "Invalid value for LUAROCKS_LUA_VERSION: ${LUAROCKS_LUA_VERSION}")
endif()

# ROCKS_TREE
if(NOT DEFINED LUAROCKS_ROCKS_TREE)
	set(LUAROCKS_ROCKS_TREE "" CACHE PATH
	"Root of the local tree of installed rocks. Leave empty for the default: the prefix. Relative paths are interpreted relative to the install prefix.")
endif()

# LUA_SUFFIX
if(NOT DEFINED LUAROCKS_LUA_SUFFIX)
	set(LUAROCKS_LUA_SUFFIX "" CACHE STRING
	"Versioning suffix to use in Lua filenames. Empty is the default.")
endif()

# SYSCONFDIR
if(NOT DEFINED LUAROCKS_SYSCONFDIR)
	set(LUAROCKS_SYSCONFDIR "etc/luarocks" CACHE PATH
	"Location where the config file should be installed. Default is etc/luarocks. Relative paths are interpreted relative to the install prefix.")
endif()

# FORCE_CONFIG
option(LUAROCKS_FORCE_CONFIG
	"Use a single config location. Do not use the $LUAROCKS_CONFIG variable or the user's home directory. Useful to avoid conflicts when LuaRocks is embedded within an application."
	OFF)

if(WIN32)
	option(LUAROCKS_INSTALL_BUNDLED_LUA "Should we use the Lua binaries bundled with LuaRocks?" ON)
endif()

###
# Search for Dependencies
###

if(WIN32)
	set(LUAROCKS_DOWNLOADER wget)
	set(LUAROCKS_MD5CHECKER md5sum)
else()
	find_program(WGET_EXECUTABLE wget)
	find_program(CURL_EXECUTABLE curl)
	if(WGET_EXECUTABLE)
		set(DOWNLOADER_DEFAULT "wget")
	elseif(CURL_EXECUTABLE)
		set(DOWNLOADER_DEFAULT "curl")
	endif()

	if(NOT DEFINED LUAROCKS_DOWNLOADER)
		if(NOT DOWNLOADER_DEFAULT)
			message(FATAL_ERROR "Could not find curl or wget, and LUAROCKS_DOWNLOADER not defined!")
		endif()
		set(LUAROCKS_DOWNLOADER "${DOWNLOADER_DEFAULT}" CACHE STRING
			"Whether to use wget or curl as downloader.")
	endif()

	find_program(MD5SUM_EXECUTABLE md5sum)
	find_program(MD5_EXECUTABLE md5)
	find_program(OPENSSL_EXECUTABLE openssl)

	if(MD5SUM_EXECUTABLE)
		set(CHECKER_DEFAULT "md5sum")
	elseif(MD5_EXECUTABLE)
		set(CHECKER_DEFAULT "md5")
	elseif(OPENSSL_EXECUTABLE)
		set(CHECKER_DEFAULT "openssl")
	endif()
	if(NOT DEFINED LUAROCKS_MD5CHECKER)
		if(NOT CHECKER_DEFAULT)
			message(FATAL_ERROR "Could not find md5sum, md5, or openssl utility, and LUAROCKS_MD5CHECKER not defined!")
		endif()
		set(LUAROCKS_MD5CHECKER "${CHECKER_DEFAULT}" CACHE STRING
			"Whether to use md5sum, md5, or openssl utility as MD5 checker.")
	endif()
endif()

if(NOT LUAROCKS_INSTALL_BUNDLED_LUA)
	find_package(Lua51 REQUIRED)
	find_program(LUA_INTERPRETER lua${LUAROCKS_LUA_SUFFIX})
	if(NOT LUA_INTERPRETER)
		message(FATAL_ERROR "Need a Lua interpreter!")
	endif()
endif()


if(WIN32)
	if(MSVC)
		set(LUAROCKS_UNAME_S WindowsNT)
	else()
		set(LUAROCKS_UNAME_S MINGW)
	endif()
	set(LUAROCKS_UNAME_M x86)
else()
	set(LUAROCKS_UNAME_S ${CMAKE_SYSTEM_NAME})
	if(NOT DEFINED LUAROCKS_UNAME_M)
		execute_process(COMMAND uname -m
			OUTPUT_VARIABLE LUAROCKS_UNAME_M
			OUTPUT_STRIP_TRAILING_WHITESPACE)
		set(LUAROCKS_UNAME_M "${LUAROCKS_UNAME_M}" CACHE STRING "")
		mark_as_advanced(LUAROCKS_UNAME_M)
	endif()
endif()

# Make all possibly-relative paths absolute (but don't overwrite the cache
foreach(POSSIBLY_RELATIVE LUAROCKS_ROCKS_TREE LUAROCKS_SYSCONFDIR)
	set(_rel OFF)
	if("${${POSSIBLY_RELATIVE}}" STREQUAL "")
		set(_rel ON)
	elseif(NOT IS_ABSOLUTE "${${POSSIBLY_RELATIVE}}")
		set(_rel ON)
	endif()
	if(_rel)
		message(STATUS "Detected that ${POSSIBLY_RELATIVE}='${${POSSIBLY_RELATIVE}}' is relative")
		get_filename_component(${POSSIBLY_RELATIVE} "${CMAKE_INSTALL_PREFIX}/${${POSSIBLY_RELATIVE}}" ABSOLUTE)
	endif()
endforeach()


# Analysis for site_config

# TODO these are often wrong on other platforms
set(PREFIX "${CMAKE_INSTALL_PREFIX}")
set(BINDIR_RELATIVE .)
get_filename_component(BINDIR "${CMAKE_INSTALL_PREFIX}/${BINDIR_RELATIVE}" ABSOLUTE)

#set(LIBDIR_RELATIVE .)
#get_filename_component(LIBDIR "${CMAKE_INSTALL_PREFIX}/${LIBDIR_RELATIVE}" ABSOLUTE)
get_filename_component(LIBDIR "${LUA_LIBRARY}" PATH)

set(LUADIR_RELATIVE lua)
get_filename_component(LUADIR "${CMAKE_INSTALL_PREFIX}/${LUADIR_RELATIVE}" ABSOLUTE)

if(LUAROCKS_INSTALL_BUNDLED_LUA)
	set(LUA_INTERPRETER "${BINDIR}/lua5.1.exe")
	set(INCDIR_RELATIVE include)
	set(LIBDIR "${BINDIR}")
	set(LUA_INCLUDE_DIR "${CMAKE_INSTALL_PREFIX}/${INCDIR_RELATIVE}")
	add_subdirectory(win32/lua5.1)
endif()

#set(INCDIR_RELATIVE include)
#get_filename_component(INCDIR "${CMAKE_INSTALL_PREFIX}/${INCDIR_RELATIVE}" ABSOLUTE)
set(INCDIR "${LUA_INCLUDE_DIR}")


get_filename_component(LUA_INTERPRETER_BASENAME "${LUA_INTERPRETER}" NAME)
if(NOT LUA_INTERPRETER_BASENAME STREQUAL "lua")
	set(LUAROCKS_INTERPRETER_LINE "LUA_INTERPRETER=[[${LUA_INTERPRETER_BASENAME}]]")
endif()

get_filename_component(LUA_INTERPRETER_DIR "${LUA_INTERPRETER}" PATH)

message(STATUS "Installation prefix: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "LuaRocks configuration directory: ${LUAROCKS_SYSCONFDIR}")
message(STATUS "Using Lua from: ${LUA_INCLUDE_DIR}")


# Generate launcher scripts
file(RELATIVE_PATH LUADIR_RELATIVE_TO_BINDIR "${BINDIR}" "${LUADIR}")
file(TO_NATIVE_PATH "${LUADIR_RELATIVE_TO_BINDIR}" LUADIR_RELATIVE_TO_BINDIR)
message(STATUS "LUADIR_RELATIVE_TO_BINDIR ${LUADIR_RELATIVE_TO_BINDIR}")
file(TO_NATIVE_PATH "${LUA_INTERPRETER_DIR}" LUA_INTERPRETER_DIR)

if(WIN32)
	foreach(SCRIPTNAME luarocks luarocks-admin)
		configure_file("${CMAKE_CURRENT_SOURCE_DIR}/launcher.bat.in" "${CMAKE_CURRENT_BINARY_DIR}/${SCRIPTNAME}.bat")
		install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${SCRIPTNAME}.bat"
			DESTINATION ${BINDIR_RELATIVE})
	endforeach()
	add_subdirectory(win32/bin)
endif()

file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/buildtree")
file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/buildtree/luarocks")
set(LUAROCKS_SITECONFIG_BUILDLOCATION "${CMAKE_CURRENT_BINARY_DIR}/buildtree" CACHE INTERNAL "" FORCE)

if(MSVC)
	set(WRAPPER "${CMAKE_CURRENT_SOURCE_DIR}/win32/bin/rclauncher.obj")
else()
	set(WRAPPER "${CMAKE_CURRENT_SOURCE_DIR}/win32/bin/rclauncher.o")
endif()


configure_file(buildtree_site_config.lua.in "${CMAKE_CURRENT_BINARY_DIR}/buildtree/luarocks/site_config.lua" @ONLY)

add_subdirectory(src/bin)
add_subdirectory(src/luarocks)


