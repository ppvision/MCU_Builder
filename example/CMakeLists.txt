cmake_minimum_required(VERSION 3.5)

SET(TARGET_PROCESSOR m4f)

SET(APP_NAME app_name)



include(cmake/util.cmake)
include(cmake/toolchain/toolchain-arm.cmake)

project(${APP_NAME} C ASM)


option(USB_CONSOLE "build for USB console, otherwise UART" OFF)
option(BUILD_TYPE  "build Debug version" ON)



if(BUILD_TYPE)
	SET(CMAKE_BUILD_TYPE Debug)
endif()



# import some lib
# include(lib/cmake_libs.cmake)


set(APP_NAME flashloader)
set(SRC_LIST User/main.c User/air105_it.c )


#PART ONE
list(APPEND SRC_LIST
#	one.c
)

#PART TWO
list(APPEND SRC_LIST
#	two.c
)


add_executable(${APP_NAME} ${SRC_LIST})
target_include_directories(${APP_NAME} PRIVATE 
#   dir	
)

# target_wrap_functions(${APP_NAME} printf)
# target_wrap_functions(${APP_NAME} vsprintf)
# target_link_options(${APP_NAME} PRIVATE "-Wl,--wrap=vsprintf2")



target_link_libraries(${APP_NAME} "TOOLCHAIN_gcc_${TARGET_PROCESSOR}" 
	
)
target_linker_file(${APP_NAME} ${CMAKE_CURRENT_LIST_DIR}/cmake/ld/air_105.ld)
