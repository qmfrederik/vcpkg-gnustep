find_package(PkgConfig)

pkg_check_modules(PC_OBJC REQUIRED libobjc)
pkg_check_modules(PC_GNUSTEP_BASE REQUIRED gnustep-base)
pkg_check_modules(PC_GNUSTEP_GUI REQUIRED gnustep-gui)

# These variables should always be set when using GNUstep
list(APPEND GNUSTEP_COMPILE_DEFINITIONS "GNUSTEP=1")
list(APPEND GNUSTEP_COMPILE_DEFINITIONS "GNUSTEP_BASE_LIBRARY=1")
list(APPEND GNUSTEP_COMPILE_DEFINITIONS "GNUSTEP_GUI_LIBRARY=1")
list(APPEND GNUSTEP_COMPILE_DEFINITIONS "GNUSTEP_RUNTIME=1")
list(APPEND GNUSTEP_COMPILE_DEFINITIONS "GNU_GUI_LIBRARY=1")

list(APPEND GNUSTEP_COMPILE_DEFINITIONS $<$<CONFIG:Debug>:GSWARN>)
list(APPEND GNUSTEP_COMPILE_DEFINITIONS $<$<CONFIG:Debug>:GSDIAGNOSE>)

# On Windows, GNUSTEP_WITH_DLL is always set
if(WIN32)
    list(APPEND GNUSTEP_COMPILE_DEFINITIONS "GNUSTEP_WITH_DLL=1")
endif()

message(STATUS "GNUstep configuration:")

# Make sure we are using native Objective C exceptions
if ("${PC_GNUSTEP_GUI_CFLAGS}" MATCHES "-D_NATIVE_OBJC_EXCEPTIONS")
    message(STATUS "  Using native Objective-C exceptions")
    list(APPEND GNUSTEP_COMPILE_DEFINITIONS "_NATIVE_OBJC_EXCEPTIONS=1")
    list(APPEND GNUSTEP_COMPILE_OPTIONS "-fexceptions")
    list(APPEND GNUSTEP_COMPILE_OPTIONS "-fobjc-exceptions")
else()
    message(FATAL_ERROR " GNUstep is not configured to use native Objective-C exceptions")
endif()

# Make sure we are using the non-fragile ABI
if ("${PC_GNUSTEP_GUI_CFLAGS}" MATCHES "-D_NONFRAGILE_ABI")
    message(STATUS "  Using the non-fragile ABI")
    list(APPEND GNUSTEP_COMPILE_DEFINITIONS "_NONFRAGILE_ABI=1")
else()
    message(FATAL_ERROR " GNUstep is not configured to use the non-fragile ABI")
endif()

# Make sure we are using objective C runtime 2.0 or later
string(REGEX MATCH "-fobjc-runtime=gnustep-([0-9\.]*)" OBJECTIVE_C_RUNTIME "${PC_GNUSTEP_GUI_CFLAGS}")
if(OBJECTIVE_C_RUNTIME)
    set(GNUSTEP_OBJECTIVE_C_RUNTIME "${CMAKE_MATCH_1}")

    if (GNUSTEP_OBJECTIVE_C_RUNTIME VERSION_GREATER_EQUAL 2.0)
        message(STATUS "  Runtime ABI gnustep-${GNUSTEP_OBJECTIVE_C_RUNTIME}")
        list(APPEND GNUSTEP_COMPILE_OPTIONS "${OBJECTIVE_C_RUNTIME}")
    else ()
        message(FATAL_ERROR "  Using outdated GNUstep runtime ABI gnustep-${GNUSTEP_OBJECTIVE_C_RUNTIME}")
    endif()
else()
    message(FATAL_ERROR "  Could not determine the Objective C runtime.")
endif()

# Make sure we are using a constant string class
string(REGEX MATCH "-fconstant-string-class=([a-zA-Z]*)" CONSTANT_STRING_CLASS "${PC_GNUSTEP_GUI_CFLAGS}")
if(CONSTANT_STRING_CLASS)
    set(GNUSTEP_CONSTANT_STRING "${CMAKE_MATCH_1}")
    message(STATUS "  Constant string class ${GNUSTEP_CONSTANT_STRING}")
    list(APPEND GNUSTEP_COMPILE_OPTIONS "${CONSTANT_STRING_CLASS}")
else()
    message(WARNING "  Could not identify the constant string class, defaulting to NSConstantString")
    list(APPEND GNUSTEP_COMPILE_OPTIONS "-fconstant-string-class=NSConstantString")
endif()

# Make sure we are using the blocks runtime
if ("${PC_GNUSTEP_GUI_CFLAGS}" MATCHES "-fblocks")
    message(STATUS "  Blocks support enabled")
    list(APPEND GNUSTEP_COMPILE_OPTIONS "-fblocks")
else()
    message(FATAL_ERROR " GNUstep is not configured with blocks support")
endif()

# Find the Objective-C, libs-base and libs-gui headers
find_path(OBJECTIVE_C_INCLUDE_DIRECTORY "objc/objc.h" HINTS ${PC_OBJC_INCLUDEDIR})
list(APPEND GNUSTEP_INCLUDE_DIRECTORIES ${OBJECTIVE_C_INCLUDE_DIRECTORY})

find_path(FOUNDATION_INCLUDE_DIRECTORY "Foundation/Foundation.h" HINTS ${PC_GNUSTEP_GUI_INCLUDE_DIRS})
list(APPEND GNUSTEP_INCLUDE_DIRECTORIES ${FOUNDATION_INCLUDE_DIRECTORY})

find_path(GUI_INCLUDE_DIRECTORY "AppKit/AppKit.h" HINTS ${PC_GNUSTEP_GUI_INCLUDE_DIRS})
list(APPEND GNUSTEP_INCLUDE_DIRECTORIES ${GUI_INCLUDE_DIRECTORY})
list(REMOVE_DUPLICATES GNUSTEP_INCLUDE_DIRECTORIES)

# Find the Objective-C, libs-base and libs-gui libraries
find_library(GNUSTEP_LIBOBJC objc HINTS ${PC_OBJC_LIBRARY_DIRS} REQUIRED)
find_library(GNUSTEP_BASE gnustep-base HINTS ${PC_GNUSTEP_GUI_LIBRARY_DIRS} REQUIRED)
find_library(GNUSTEP_GUI gnustep-gui HINTS ${PC_GNUSTEP_GUI_LIBRARY_DIRS} REQUIRED)

add_library(GNUstep::ObjC INTERFACE IMPORTED)
target_include_directories(GNUstep::ObjC INTERFACE ${OBJECTIVE_C_INCLUDE_DIRECTORY})
target_compile_options(GNUstep::ObjC INTERFACE ${GNUSTEP_COMPILE_OPTIONS})
target_compile_definitions(GNUstep::ObjC INTERFACE ${GNUSTEP_COMPILE_DEFINITIONS})
target_link_libraries(GNUstep::ObjC INTERFACE ${GNUSTEP_LIBOBJC})

add_library(GNUstep::Base INTERFACE IMPORTED)
target_include_directories(GNUstep::Base INTERFACE ${FOUNDATION_INCLUDE_DIRECTORY})
target_link_libraries(GNUstep::Base INTERFACE ${GNUSTEP_BASE})

add_library(GNUstep::GUI INTERFACE IMPORTED)
target_include_directories(GNUstep::GUI INTERFACE ${GUI_INCLUDE_DIRECTORY})
target_link_libraries(GNUstep::GUI INTERFACE ${GNUSTEP_GUI})

target_link_libraries(GNUstep::Base INTERFACE GNUstep::ObjC)
target_link_libraries(GNUstep::GUI INTERFACE GNUstep::Base)

function(target_copy_gnustep_libraries target)
    set(GNUstep_bindir "${VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/$<IF:$<CONFIG:Debug>,debug/,>bin")

    if(WIN32)
        add_custom_command(
            TARGET ${target}
            POST_BUILD
                COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${GNUstep_bindir}/objc.dll" "${CMAKE_CURRENT_BINARY_DIR}"
                COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${GNUstep_bindir}/gnustep-base-1_30.dll" "${CMAKE_CURRENT_BINARY_DIR}"
                COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${GNUstep_bindir}/libxml2.dll" "${CMAKE_CURRENT_BINARY_DIR}"
                COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${GNUstep_bindir}/ffi-8.dll" "${CMAKE_CURRENT_BINARY_DIR}"
                COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${GNUstep_bindir}/libcurl$<IF:$<CONFIG:Debug>,-d,>.dll" "${CMAKE_CURRENT_BINARY_DIR}"
                COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${GNUstep_bindir}/libxslt.dll" "${CMAKE_CURRENT_BINARY_DIR}"
                COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${GNUstep_bindir}/dispatch.dll" "${CMAKE_CURRENT_BINARY_DIR}"
                COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${GNUstep_bindir}/iconv-2.dll" "${CMAKE_CURRENT_BINARY_DIR}"
                COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${GNUstep_bindir}/zlib$<IF:$<CONFIG:Debug>,d,>1.dll" "${CMAKE_CURRENT_BINARY_DIR}"
                COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${GNUstep_bindir}/liblzma.dll" "${CMAKE_CURRENT_BINARY_DIR}"
                COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${GNUstep_bindir}/getopt.dll" "${CMAKE_CURRENT_BINARY_DIR}")
    endif()
endfunction()
