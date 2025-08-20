string(REPLACE "." "_" MAKE_VERSION ${VERSION})

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gnustep/libs-back
    REF "back-${MAKE_VERSION}"
    SHA512 0bf9b39e7cfe704039c02cc302c091fa8c2a71aa8600be497aca025712bc9a805038310aaddba00dc523e1743dba76f3bba5cdf6d36e3b08c89bb5c18ace6175
    HEAD_REF master
    PATCHES
)

vcpkg_configure_gnustep(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        "--enable-graphics=headless"
        "--enable-server=headless"
        "--without-freetype"
        "--with-name=headless"
        ${options}
)

vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}/tools/gnustep-base/")
vcpkg_add_to_path("${CURRENT_INSTALLED_DIR}/bin/")

vcpkg_install_gnustep()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.LIB")

# the gpbs utility, its manpage, and the various fonts are not relevant for a headless installation
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/man/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/GNUstep/Fonts")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/GNUstep/Fonts")

# gnustep-headless does not include headers
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

# gnustep-headless is a bundle which is installed into lib\GNUstep\Bundles
set(VCPKG_POLICY_ALLOW_DLLS_IN_LIB enabled)

# gnustep-headless includes gpbs[.exe], which is a runtime tool and installed into bin.
set(VCPKG_POLICY_ALLOW_EXES_IN_BIN enabled)
