# set_default
#
# Define a variable to a default value if otherwise unset.
#
# Priority for new value is:
# - Existing cmake value (ie set with cmake -D, or already set in CMakeLists)
# - Value of any non-empty environment variable of the same name
# - Default value as provided to function
#

function(set_default variable default_value)
    if(NOT ${variable})
        if(DEFINED ENV{${variable}} AND NOT "$ENV{${variable}}" STREQUAL "")
            set(${variable} $ENV{${variable}} PARENT_SCOPE)
        else()
            set(${variable} ${default_value} PARENT_SCOPE)
        endif()
    endif()
endfunction()

# spaces2list
#
# Take a variable whose value was space-delimited values, convert to a cmake
# list (semicolon-delimited)
#
# Note: do not use this for directories or full paths, as they may contain
# spaces.
#
# TODO: look at cmake separate_arguments, which is quote-aware
function(spaces2list variable_name)
    string(REPLACE " " ";" tmp "${${variable_name}}")
    set("${variable_name}" "${tmp}" PARENT_SCOPE)
endfunction()

# lines2list
#
# Take a variable with multiple lines of output in it, convert it
# to a cmake list (semicolon-delimited), one line per item
#
function(lines2list variable_name)
    string(REGEX REPLACE "\r?\n" ";" tmp "${${variable_name}}")
    string(REGEX REPLACE ";;" ";" tmp "${tmp}")
    set("${variable_name}" "${tmp}" PARENT_SCOPE)
endfunction()


# move_if_different
#
# If 'source' has different md5sum to 'destination' (or destination
# does not exist, move it across.
#
# If 'source' has the same md5sum as 'destination', delete 'source'.
#
# Avoids timestamp updates for re-generated files where content hasn't
# changed.
function(move_if_different source destination)
    set(do_copy 1)
    file(GLOB dest_exists ${destination})
    if(dest_exists)
        file(MD5 ${source} source_md5)
        file(MD5 ${destination} dest_md5)
        if(source_md5 STREQUAL dest_md5)
            set(do_copy "")
        endif()
    endif()

    if(do_copy)
        message("Moving ${source} -> ${destination}")
        file(RENAME ${source} ${destination})
    else()
        message("Not moving ${source} -> ${destination}")
        file(REMOVE ${source})
    endif()

endfunction()


# add_compile_options variant for C++ code only
#
# This adds global options, set target properties for
# component-specific flags
function(add_cxx_compile_options)
    foreach(option ${ARGV})
        # note: the Visual Studio Generator doesn't support this...
        add_compile_options($<$<COMPILE_LANGUAGE:CXX>:${option}>)
    endforeach()
endfunction()

# add_compile_options variant for C code only
#
# This adds global options, set target properties for
# component-specific flags
function(add_c_compile_options)
    foreach(option ${ARGV})
        # note: the Visual Studio Generator doesn't support this...
        add_compile_options($<$<COMPILE_LANGUAGE:C>:${option}>)
    endforeach()
endfunction()

# add_compile_options variant for ASM code only
#
# This adds global options, set target properties for
# component-specific flags
function(add_asm_compile_options)
    foreach(option ${ARGV})
        # note: the Visual Studio Generator doesn't support this...
        add_compile_options($<$<COMPILE_LANGUAGE:ASM>:${option}>)
    endforeach()
endfunction()


function(add_module_search_path)
    foreach(dir ${ARGV})
        list(APPEND CMAKE_MODULE_PATH ${dir})
    endforeach()
endfunction()


# Remove duplicates from a string containing compilation flags
function(remove_duplicated_flags FLAGS UNIQFLAGS)
    set(FLAGS_LIST "${FLAGS}")
    # Convert the given flags, as a string, into a CMake list type
    separate_arguments(FLAGS_LIST)
    # Remove all the duplicated flags
    list(REMOVE_DUPLICATES FLAGS_LIST)
    # Convert the list back to a string
    string(REPLACE ";" " " FLAGS_LIST "${FLAGS_LIST}")
    # Return that string to the caller
    set(${UNIQFLAGS} "${FLAGS_LIST}" PARENT_SCOPE)
endfunction()


macro(target_wrap_functions target FUNC)
        set(func -Wl,--wrap=${FUNC})
        target_link_options(${target} PRIVATE ${func} )
endmacro()

macro (target_linker_file target linkerfile)
    set_target_properties(${target} PROPERTIES TI_LINKER_COMMAND_FILE "${linkerfile}")
    if(NOT ${TI_LINKER_MAP_FILE})
        set(TI_LINKER_MAP_FILE,"${target}.map")
        set_target_properties(${target} PROPERTIES TI_LINKER_MAP_FILE "${target}.map")
    endif()
endmacro ()

# add map file generation for the given target
function(add_map_output TARGET)
    get_target_property(target_type ${TARGET} TYPE)
    if ("EXECUTABLE" STREQUAL "${target_type}")
        target_link_options(${TARGET} PRIVATE "-Wl,-Map,$<IF:$<BOOL:$<TARGET_PROPERTY:OUTPUT_NAME>>,$<TARGET_PROPERTY:OUTPUT_NAME>,$<TARGET_PROPERTY:NAME>>${CMAKE_EXECUTABLE_SUFFIX}.map")
    endif ()
endfunction()


function(add_hex_output TARGET)
    add_custom_command(TARGET ${TARGET} POST_BUILD COMMAND ${CMAKE_OBJCOPY} -Oihex $<TARGET_FILE:${TARGET}> $<IF:$<BOOL:$<TARGET_PROPERTY:${TARGET},OUTPUT_NAME>>,$<TARGET_PROPERTY:${TARGET},OUTPUT_NAME>,$<TARGET_PROPERTY:${TARGET},NAME>>.hex
        VERBATIM)
endfunction()

function(add_bin_output TARGET)
    add_custom_command(TARGET ${TARGET} POST_BUILD COMMAND ${CMAKE_OBJCOPY} -Obinary $<TARGET_FILE:${TARGET}> $<IF:$<BOOL:$<TARGET_PROPERTY:${TARGET},OUTPUT_NAME>>,$<TARGET_PROPERTY:${TARGET},OUTPUT_NAME>,$<TARGET_PROPERTY:${TARGET},NAME>>.bin
        VERBATIM)
endfunction()

function(add_dis_output TARGET)
    add_custom_command(TARGET ${TARGET} POST_BUILD
            COMMAND ${CMAKE_OBJDUMP} -h $<TARGET_FILE:${TARGET}> > $<IF:$<BOOL:$<TARGET_PROPERTY:${TARGET},OUTPUT_NAME>>,$<TARGET_PROPERTY:${TARGET},OUTPUT_NAME>,$<TARGET_PROPERTY:${TARGET},NAME>>.dis
            COMMAND ${CMAKE_OBJDUMP} -d $<TARGET_FILE:${TARGET}> >> $<IF:$<BOOL:$<TARGET_PROPERTY:${TARGET},OUTPUT_NAME>>,$<TARGET_PROPERTY:${TARGET},OUTPUT_NAME>,$<TARGET_PROPERTY:${TARGET},NAME>>.dis
            VERBATIM)
endfunction()

function(add_extra_outputs TARGET)
    add_hex_output(${TARGET})
    add_bin_output(${TARGET})
endfunction()
