

SET(CMAKE_SYSTEM_NAME Generic)
SET(CMAKE_SYSTEM_PROCESSOR arm)


IF(WIN32)
    SET(TOOLCHAIN_EXT ".exe")
ELSE()
    SET(TOOLCHAIN_EXT "")
ENDIF()

# EXECUTABLE EXTENSION
SET (CMAKE_EXECUTABLE_SUFFIX_C ".elf")

if(NOT GCC_ARMCOMPILER)
    SET(TOOLCHAIN_DIR $ENV{ARMGCC_DIR})
ELSE()
    SET(TOOLCHAIN_DIR ${GCC_ARMCOMPILER})
ENDIF()

STRING(REGEX REPLACE "\\\\" "/" TOOLCHAIN_DIR "${TOOLCHAIN_DIR}")
IF(NOT TOOLCHAIN_DIR)
    MESSAGE(FATAL_ERROR "***Please set ARMGCC_DIR in envionment variables***")
ENDIF()
MESSAGE(STATUS "TOOLCHAIN_DIR: " ${TOOLCHAIN_DIR})


SET(TARGET_TRIPLET "arm-none-eabi")
SET(TOOLCHAIN_BIN_DIR ${TOOLCHAIN_DIR}/bin)
SET(TOOLCHAIN_INC_DIR ${TOOLCHAIN_DIR}/${TARGET_TRIPLET}/include)
SET(TOOLCHAIN_LIB_DIR ${TOOLCHAIN_DIR}/${TARGET_TRIPLET}/lib)



SET(CMAKE_C_COMPILER   ${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gcc${TOOLCHAIN_EXT})
SET(CMAKE_CXX_COMPILER ${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-g++${TOOLCHAIN_EXT})
SET(CMAKE_ASM_COMPILER ${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gcc${TOOLCHAIN_EXT})

MESSAGE(STATUS "CMAKE_C_COMPILER: " ${CMAKE_C_COMPILER})


SET(CMAKE_AR     ${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gcc-ar${TOOLCHAIN_EXT})
SET(CMAKE_RANLIB ${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gcc-ranlib)



SET(CMAKE_C_COMPILER_WORKS 1)
SET(CMAKE_CXX_COMPILER_WORKS 1)
# Disable compiler checks.

set(CMAKE_C_COMPILER_ID_RUN   TRUE)
set(CMAKE_C_COMPILER_FORCED   TRUE)
set(CMAKE_CXX_COMPILER_FORCED TRUE)


SET(CMAKE_FIND_ROOT_PATH ${TOOLCHAIN_DIR}/${TARGET_TRIPLET} ${EXTRA_FIND_PATH})


if(NOT TARGET_PROCESSOR)
    message(FATAL_ERROR "you need set TARGET_PROCESSOR =>" "m0 m0plus m33 m4 m4f m7")
    return()
else ()
    # -Wl,-A,
    add_compile_options(-std=c99 -Wno-format -Wno-unused-function -Wno-maybe-uninitialized -Wunused-but-set-variable)
    add_link_options(-mthumb  -Wl,--print-memory-usage  -static --specs=nano.specs -Wl,--gc-sections -Wl,--check-sections  -Wl,--no-whole-archive -nostartfiles)
    # if(TARGET_PROCESSOR STREQUAL "m0")
    #     add_compile_options(-mcpu=cortex-m0 -mfloat-abi=soft)
    #     add_link_options(-mcpu=cortex-m0 -mfloat-abi=soft)
    # elseif(TARGET_PROCESSOR STREQUAL "m0plus")
    #     add_compile_options(-mcpu=cortex-m0plus -mfloat-abi=soft)
    #     add_link_options(-mcpu=cortex-m0plus -mfloat-abi=soft)

    # elseif(TARGET_PROCESSOR STREQUAL "m4")
    #     add_compile_options(-mcpu=cortex-m4 -mfloat-abi=soft )
    #     add_link_options(-mcpu=cortex-m4 -mfloat-abi=soft )
    # elseif(TARGET_PROCESSOR STREQUAL "m4f")
    #     message("TARGET_PROCESSOR is m4f")
    #     add_compile_options(-mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16)
    #     add_link_options(-mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16)
    # elseif(TARGET_PROCESSOR STREQUAL "m33")
    #     add_compile_options(-mcpu=cortex-m33 -mfloat-abi=hard -mfpu=fpv4-sp-d16)
    #     add_link_options(-mcpu=cortex-m33 -mfloat-abi=hard -mfpu=fpv4-sp-d16)
    # elseif(TARGET_PROCESSOR STREQUAL "m7")
    #     add_compile_options(-mcpu=cortex-m7 -mfloat-abi=hard -mfpu=fpv4-sp-d16)
    #     add_link_options(-mcpu=cortex-m7 -mfloat-abi=hard -mfpu=fpv4-sp-d16)
    # endif()

endif()


if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_compile_options(-g -ggdb -O0 -gstrict-dwarf)
else()
    add_compile_options(-Os)
endif()

#在默认情况下，GCC编译器会将所有函数的代码放在同一个代码段中。这意味着在链接时，
#整个代码段都必须被加载到内存中，即使其中只有一部分代码被实际使用。
#而使用 -ffunction-sections 选项，编译器将每个函数放入单独的代码段中，
#链接器则可以仅加载需要的代码段，从而减少可执行文件或共享库的大小，并提高程序的运行效率

#使用 -ffunction-sections 选项可能会增加程序的编译时间，
#因为编译器必须为每个函数生成单独的代码段。此外，一些程序可能需要一些额外的配置才能正确地使用该选项，
#例如在使用动态链接器时需要添加 -Wl,--gc-sections 选项，以便让链接器自动删除未使用的代码和数据段

#-Wl,--gc-sections 选项告诉链接器在链接过程中从目标文件中删除未使用的部分。
#这可以显著减小最终可执行文件的大小，并减少程序的内存使用。
#需要注意的是，使用此选项可能会有一些潜在的缺点。
#它可能会导致某些调试信息被删除，从而使调试更加困难。
#它还可能会删除可能被程序的其他部分（如插件或库）使用的代码和数据。
#因此，使用此选项时需要小心，并对结果进行彻底的测试，以确保程序能够正常工作

if (NOT TARGET TOOLCHAIN_gcc)
    add_library(TOOLCHAIN_gcc INTERFACE IMPORTED)
    # message(FATAL_ERROR "TOOLCHAIN_gcc" "m0 m0plus m33 m4 m4f m7")
    target_compile_options(TOOLCHAIN_gcc INTERFACE 
        $<$<COMPILE_LANGUAGE:C>:-ffunction-sections -fdata-sections -fstack-usage -fsingle-precision-constant>
        $<$<AND:$<COMPILE_LANGUAGE:C>,$<CONFIG:Release>>:-O2>
        $<$<AND:$<COMPILE_LANGUAGE:C>,$<CONFIG:Debug>>:-g -ggdb -O0 -gstrict-dwarf>
    )

    target_link_options(
        TOOLCHAIN_gcc
        INTERFACE
        # If linker-file property exists, add linker file
        $<$<NOT:$<STREQUAL:$<TARGET_PROPERTY:TI_LINKER_COMMAND_FILE>,>>:-Wl,-T,$<TARGET_PROPERTY:TI_LINKER_COMMAND_FILE>>
        # If map-file property exists, set map file
        $<$<NOT:$<STREQUAL:$<TARGET_PROPERTY:TI_LINKER_MAP_FILE>,>>:-Wl,-Map,$<TARGET_PROPERTY:TI_LINKER_MAP_FILE>>
        # --specs=nano.specs
        # -specs=nosys.specs
        # Disables 0x10000 sector allocation boundaries, which interfere
        # with the SPE layouts and prevent proper secure operation
        # --nmagic
    )

    add_library(TOOLCHAIN_gcc_m0 INTERFACE IMPORTED)
    target_link_libraries(TOOLCHAIN_gcc_m0 INTERFACE TOOLCHAIN_gcc -mcpu=cortex-m0 -mfloat-abi=soft)
    target_compile_options(TOOLCHAIN_gcc_m0 INTERFACE -mcpu=cortex-m0 -mfloat-abi=soft)
    # add_library(CMakeCommon::gcc_m0p ALIAS TOOLCHAIN_gcc_m0)

    add_library(TOOLCHAIN_gcc_m0p INTERFACE IMPORTED)
    target_link_libraries(TOOLCHAIN_gcc_m0p INTERFACE TOOLCHAIN_gcc -mcpu=cortex-m0plus -mfloat-abi=soft)
    target_compile_options(TOOLCHAIN_gcc_m0p INTERFACE -mcpu=cortex-m0plus -mfloat-abi=soft)
    # add_library(CMakeCommon::gcc_m0p ALIAS TOOLCHAIN_gcc_m0p)

    add_library(TOOLCHAIN_gcc_m4 INTERFACE IMPORTED)
    target_link_libraries(TOOLCHAIN_gcc_m4 INTERFACE TOOLCHAIN_gcc -mcpu=cortex-m4 -mfloat-abi=soft)
    target_compile_options(TOOLCHAIN_gcc_m4 INTERFACE -mcpu=cortex-m4 -mfloat-abi=soft)
    # add_library(CMakeCommon::gcc_m4 ALIAS TOOLCHAIN_gcc_m4)

    add_library(TOOLCHAIN_gcc_m4f INTERFACE IMPORTED)
    target_link_libraries(TOOLCHAIN_gcc_m4f INTERFACE TOOLCHAIN_gcc -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16)
    target_compile_options(TOOLCHAIN_gcc_m4f INTERFACE -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16)
    # add_library(CMakeCommon::gcc_m4f ALIAS TOOLCHAIN_gcc_m4f)

    add_library(TOOLCHAIN_gcc_m33f INTERFACE IMPORTED)
    target_link_libraries(TOOLCHAIN_gcc_m33f INTERFACE TOOLCHAIN_gcc -mcpu=cortex-m33 -mfloat-abi=hard -mfpu=fpv5-sp-d16)
    target_compile_options(TOOLCHAIN_gcc_m33f INTERFACE -mcpu=cortex-m33 -mfloat-abi=hard -mfpu=fpv5-sp-d16)
    # add_library(CMakeCommon::gcc_m33f ALIAS TOOLCHAIN_gcc_m33f)

    add_library(TOOLCHAIN_gcc_m7 INTERFACE IMPORTED)
    target_link_libraries(TOOLCHAIN_gcc_m7 INTERFACE TOOLCHAIN_gcc -mcpu=cortex-m7 -mfloat-abi=hard -mfpu=fpv5-sp-d16)
    target_compile_options(TOOLCHAIN_gcc_m7 INTERFACE -mcpu=cortex-m7 -mfloat-abi=hard -mfpu=fpv5-sp-d16)
endif ()


# -fvisibility=hidden -Wall -Wextra
remove_duplicated_flags("-fvisibility=hidden ${CMAKE_C_FLAGS}" UNIQ_CMAKE_C_FLAGS)
set(CMAKE_C_FLAGS "${UNIQ_CMAKE_C_FLAGS}" CACHE STRING "C Compiler Base Flags" FORCE)


remove_duplicated_flags("-fvisibility=hidden -Wall -Wextra ${CMAKE_CXX_FLAGS}" UNIQ_CMAKE_CXX_FLAGS)
set(CMAKE_CXX_FLAGS "${UNIQ_CMAKE_CXX_FLAGS}" CACHE STRING "C++ Compiler Base Flags" FORCE)


message("CMAKE_EXE_LINKER_FLAGS  ${CMAKE_EXE_LINKER_FLAGS}")
remove_duplicated_flags("${CMAKE_EXE_LINKER_FLAGS}" UNIQ_CMAKE_SAFE_EXE_LINKER_FLAGS)
set(CMAKE_EXE_LINKER_FLAGS "${UNIQ_CMAKE_SAFE_EXE_LINKER_FLAGS}" CACHE STRING "Linker Base Flags" FORCE)
