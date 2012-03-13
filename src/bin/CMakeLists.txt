if(WIN32)
	foreach(fn luarocks luarocks-admin)
		install(FILES ${fn}
			DESTINATION ${BINDIR_RELATIVE}
			RENAME ${fn}.lua)
	endforeach()
else()
	install(PROGRAMS luarocks luarocks-admin
		DESTINATION ${BINDIR_RELATIVE})
endif()