string(REPLACE "." "_" MAKE_VERSION ${VERSION})

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gnustep/libs-gui
    REF "gui-${MAKE_VERSION}"
    SHA512 7e07b3122b9200567d288ec2c6cac219760bd87117352565cab22aa27f3986de8642ee6bb1f639d6a53bc800caec9ff91e42b3785e25184e125b1a1b00b3c1a1
    HEAD_REF master
    PATCHES
        # https://github.com/gnustep/libs-gui/pull/288
        0001-Mark-PACKAGE_SCOPE-as-public-on-Windows.patch
        # Invoking make_services in a msys shell fails, so disable building tools for now:
        # [..]/buildtrees/gnustep-gui/x64-windows-llvm-dbg/Tools/obj/make_services.exe: error while loading shared libraries: api-ms-win-crt-heap-l1-1-0.dll: cannot open shared object file: No such file or directory
        0001-Disable-building-Tools.patch
        0001-Add-APPKIT_EXPORT_CLASS-statements.patch
        0001-GSMemoryPanel-Only-call-GSDebug-in-debug-mode.patch
        # https://github.com/gnustep/libs-gui/pull/290
        45edc31c3c4bf14f2a257339ca0743e292b7bc96.diff
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
