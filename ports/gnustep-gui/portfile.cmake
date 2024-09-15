string(REPLACE "." "_" MAKE_VERSION ${VERSION})

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gnustep/libs-gui
    REF "gui-${MAKE_VERSION}"
    SHA512 43010bb2bdf714ee63ce6c91c4d951f1c259a66420e9a7b514de8f377d33f48c2960cbfa81c011af589e6ad9a99e8dee1fad6cd54ac4b447952122f3a1b2e13b
    HEAD_REF master
    PATCHES
        0001-Mark-PACKAGE_SCOPE-as-public-on-Windows.patch
        # Invoking make_services in a msys shell fails, so disable building tools for now:
        # [..]/buildtrees/gnustep-gui/x64-windows-llvm-dbg/Tools/obj/make_services.exe: error while loading shared libraries: api-ms-win-crt-heap-l1-1-0.dll: cannot open shared object file: No such file or directory
        0001-Disable-building-Tools.patch
        # tiff.m: Only include unistd.h if it exists
        # https://github.com/gnustep/libs-gui/pull/352
        0001-Only-include-unistd.h-if-it-exists.patch
)

vcpkg_list(SET options)

if (VCPKG_TARGET_IS_WINDOWS)
endif ()

vcpkg_configure_gnustep(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${options}
)

vcpkg_install_gnustep()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.LIB")

# Remove empty directories
file(
    REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/lib/GNUstep/Themes"
    "${CURRENT_PACKAGES_DIR}/lib/GNUstep/Themes"
)

# GNUstep Makefiles go in share/ and are different for release and debug configurations
set(VCPKG_POLICY_ALLOW_DEBUG_SHARE enabled)
