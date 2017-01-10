
# Set paths
set(UTIL_PATHS
	${CMAKE_CURRETN_SOURCE_DIR}/util/util1
	${CMAKE_CURRETN_SOURCE_DIR}/util/util2
	)

# Add subdirectiories
foreach(UTIL_PATH ${UTIL_PATHS})
	add_subdirectory
endforeach()
