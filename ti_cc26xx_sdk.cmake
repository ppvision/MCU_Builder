# XDC_INSTALL_DIR       
# SYSCONFIG_TOOL        
# GCC_ARMCOMPILER  
# TICLANG_ARMCOMPILER   
# GCC_ARMCOMPILER       


# if (DEFINED ENV{XDC_INSTALL_DIR} AND (NOT XDC_INSTALL_DIR))
#     set(XDC_INSTALL_DIR $ENV{XDC_INSTALL_DIR})
#     message("Using XDC_INSTALL_DIR from environment ('${XDC_INSTALL_DIR}')")
# else ()
#     MESSAGE(FATAL_ERROR "***Please set XDC_INSTALL_DIR in envionment variables***")
# endif ()

if (DEFINED ENV{CC26XX_SDK_DIR} AND (NOT CC26XX_SDK_DIR))
    set(CC26XX_SDK_DIR $ENV{CC26XX_SDK_DIR})
    message("Using CC26XX_SDK_DIR from environment ('${CC26XX_SDK_DIR}')")
else ()
    MESSAGE(FATAL_ERROR "***Please set CC26XX_SDK_DIR in envionment variables***")
endif ()


if (DEFINED ENV{SYSCONFIG_TOOL} AND (NOT SYSCONFIG_TOOL))
    set(SYSCONFIG_TOOL $ENV{SYSCONFIG_TOOL})
    message("Using SYSCONFIG_TOOL from environment ('${SYSCONFIG_TOOL}')")
else ()
    MESSAGE(FATAL_ERROR "***Please set SYSCONFIG_TOOL in envionment variables***")
endif ()


if (DEFINED ENV{FREERTOS_INSTALL_DIR} AND (NOT FREERTOS_INSTALL_DIR))
    set(FREERTOS_INSTALL_DIR $ENV{FREERTOS_INSTALL_DIR})
    message("Using FREERTOS_INSTALL_DIR from environment ('${FREERTOS_INSTALL_DIR}')")
else ()
    MESSAGE(FATAL_ERROR "***Please set FREERTOS_INSTALL_DIR in envionment variables***")
endif ()


if (DEFINED ENV{GCC_ARMCOMPILER} AND (NOT GCC_ARMCOMPILER))
    set(GCC_ARMCOMPILER $ENV{GCC_ARMCOMPILER})
    message("Using GCC_ARMCOMPILER from environment ('${GCC_ARMCOMPILER}')")
else ()
    MESSAGE(FATAL_ERROR "***Please set GCC_ARMCOMPILER in envionment variables***")
endif ()
