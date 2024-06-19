
SET(CMAKE_SYSTEM_NAME Generic)
SET(CMAKE_SYSTEM_PROCESSOR riscv)

if(TARGET_PROCESSOR MATCHES "riscv64")
  set(CMAKE_SYSTEM_PROCESSOR riscv64)
elseif(TARGET_PROCESSOR MATCHES "riscv32")
  set(CMAKE_SYSTEM_PROCESSOR riscv)
endif()

IF(WIN32)
    SET(TOOLCHAIN_EXT ".exe")
ELSE()
    SET(TOOLCHAIN_EXT "")
ENDIF()

# EXECUTABLE EXTENSION
SET (CMAKE_EXECUTABLE_SUFFIX_C ".elf")

if(NOT TOOLCHAIN_DIR)
    if(NOT GCC_RISCVCOMPILER)
        SET(TOOLCHAIN_DIR $ENV{RISCVGCC_DIR})
    ELSE()
        SET(TOOLCHAIN_DIR ${GCC_RISCVCOMPILER})
    ENDIF()
ENDIF()

STRING(REGEX REPLACE "\\\\" "/" TOOLCHAIN_DIR "${TOOLCHAIN_DIR}")
IF(NOT TOOLCHAIN_DIR)
    MESSAGE(FATAL_ERROR "***Please set RISCVGCC_DIR in envionment variables***")
ENDIF()
MESSAGE(STATUS "TOOLCHAIN_DIR: " ${TOOLCHAIN_DIR})


#SET(TARGET_TRIPLET "riscv-none-elf")
# SET(TARGET_TRIPLET "riscv-none-embed")

SET(TOOLCHAIN_BIN_DIR ${TOOLCHAIN_DIR}/bin)
SET(TOOLCHAIN_INC_DIR ${TOOLCHAIN_DIR}/${TARGET_TRIPLET}/include)
SET(TOOLCHAIN_LIB_DIR ${TOOLCHAIN_DIR}/${TARGET_TRIPLET}/lib)



SET(CMAKE_C_COMPILER   ${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gcc${TOOLCHAIN_EXT})
SET(CMAKE_CXX_COMPILER ${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-g++${TOOLCHAIN_EXT})
SET(CMAKE_ASM_COMPILER ${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gcc${TOOLCHAIN_EXT})


SET(CMAKE_AR      ${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gcc-ar${TOOLCHAIN_EXT})
SET(CMAKE_RANLIB  ${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gcc-ranlib)
SET(CMAKE_OBJCOPY ${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-objcopy)
SET(CMAKE_OBJDUMP ${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-objdump)


MESSAGE(STATUS "CMAKE_C_COMPILER: " ${CMAKE_C_COMPILER})
MESSAGE(STATUS "CMAKE_ASM_COMPILER: " ${CMAKE_ASM_COMPILER})



SET(CMAKE_C_COMPILER_WORKS 1)
SET(CMAKE_CXX_COMPILER_WORKS 1)
# Disable compiler checks.

set(CMAKE_C_COMPILER_ID_RUN   TRUE)
set(CMAKE_C_COMPILER_FORCED   TRUE)
set(CMAKE_CXX_COMPILER_FORCED TRUE)



SET(CMAKE_FIND_ROOT_PATH ${TOOLCHAIN_DIR}/${TARGET_TRIPLET} ${EXTRA_FIND_PATH})


if(NOT TARGET_PROCESSOR)
    message(FATAL_ERROR "you need set TARGET_PROCESSOR =>" "riscv32 riscv64")
    return()
else ()

    add_compile_options(
        -fno-jump-tables
        -fno-common
        -fms-extensions
        -ffunction-sections
        -fdata-sections
        -fsigned-char
        -fmessage-length=0
        -Wall
        -Wchar-subscripts
        -Wformat
        -Wundef
        -Winit-self
        -Wignored-qualifiers
        -fstrict-volatile-bitfields
        -fshort-enums
        -MMD
        -Wno-error=unused-variable
        -Wno-error=format=
        -Wno-error=unused-function
        -Wno-error=implicit-function-declaration
        -Wno-error=deprecated-declarations
        # -Wno-error=absolute-value
        # -Wno-error=type-limits
        # -Wno-error=cpp -Wextra
        -Wno-format -Wno-unused-function -Wno-maybe-uninitialized -Wunused-but-set-variable -Wuninitialized
    )

    add_link_options(
        -Wl,--cref
        -fms-extensions
        -ffunction-sections
        -fdata-sections
        -fno-common
        -Wl,--print-memory-usage
        -Wl,--gc-sections 
        -Wl,--check-sections 
    )

    if(TARGET_PROCESSOR STREQUAL "riscv32")
        add_compile_options(-march=rv32imac -mabi=ilp32)
        add_link_options(-march=rv32imac -mabi=ilp32)
    elseif(TARGET_PROCESSOR STREQUAL "riscv32f")
        add_compile_options(-march=rv32imaf -mabi=ilp32f)
        add_link_options(-march=rv32imaf -mabi=ilp32f)
    endif()
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

#for **newlib-nano** is available using the `--specs=nano.specs` option. 
#For better results, this option must be added to both compile and link time.

# 在使用riscv-none-embed-gcc 编译时 要加上参数-march=rv32imac -mabi=ilp32来指定内核和二进制接口类型

## nosys.specs
#If no syscalls are needed, `--specs=nosys.specs` can be used at link time to provide empty implementations for the POSIX system calls.

if (NOT TARGET TOOLCHAIN_gcc)
    add_library(TOOLCHAIN_gcc INTERFACE IMPORTED)
    target_compile_options(TOOLCHAIN_gcc INTERFACE 
        $<$<COMPILE_LANGUAGE:C>: -std=gnu99 -ffunction-sections -fdata-sections -fstack-usage >
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
        -nostartfiles -Os
        --specs=nosys.specs
        --specs=nano.specs
        -lnosys
        #-lc_nano
        -fstrict-volatile-bitfields
        # Disables 0x10000 sector allocation boundaries, which interfere
        # with the SPE layouts and prevent proper secure operation
        # --nmagic
    )

# without     -nostartfiles >>in function `_start':  (.text+0x8): undefined reference to `__bss_start'
    add_library(TOOLCHAIN_gcc_riscv32 INTERFACE IMPORTED)
    target_link_libraries(TOOLCHAIN_gcc_riscv32 INTERFACE TOOLCHAIN_gcc -march=rv32imac -mabi=ilp32)
    target_compile_options(TOOLCHAIN_gcc_riscv32 INTERFACE  -march=rv32imac -mabi=ilp32)


    add_library(TOOLCHAIN_gcc_riscv32f INTERFACE IMPORTED)
    target_link_libraries(TOOLCHAIN_gcc_riscv32f INTERFACE TOOLCHAIN_gcc -march=rv32imaf -mabi=ilp32f)
    target_compile_options(TOOLCHAIN_gcc_riscv32f INTERFACE  -march=rv32imaf -mabi=ilp32f)

endif ()


# -fvisibility=hidden -Wall -Wextra
remove_duplicated_flags("-fvisibility=hidden ${CMAKE_C_FLAGS}" UNIQ_CMAKE_C_FLAGS)
set(CMAKE_C_FLAGS "${UNIQ_CMAKE_C_FLAGS}" CACHE STRING "C Compiler Base Flags" FORCE)


remove_duplicated_flags("-fvisibility=hidden -Wall -Wextra ${CMAKE_CXX_FLAGS}" UNIQ_CMAKE_CXX_FLAGS)
set(CMAKE_CXX_FLAGS "${UNIQ_CMAKE_CXX_FLAGS}" CACHE STRING "C++ Compiler Base Flags" FORCE)


message("CMAKE_EXE_LINKER_FLAGS  ${CMAKE_EXE_LINKER_FLAGS}")
remove_duplicated_flags("${CMAKE_EXE_LINKER_FLAGS}" UNIQ_CMAKE_SAFE_EXE_LINKER_FLAGS)
set(CMAKE_EXE_LINKER_FLAGS "${UNIQ_CMAKE_SAFE_EXE_LINKER_FLAGS}" CACHE STRING "Linker Base Flags" FORCE)
