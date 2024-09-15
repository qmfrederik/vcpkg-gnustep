string(REPLACE "." "_" MAKE_VERSION ${VERSION})

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gnustep/libs-back
    REF "back-${MAKE_VERSION}"
    SHA512 518a6fe9926c4008e5d39319dce4fa38d7328390517663aaa9e89e99c1b456bcd08b69baa793546d0f365c69f14f27f6c6f1417da5013fae5c26d7429f2f8304
    HEAD_REF master
    PATCHES
        0001-Windows-compatibility.patch
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

# gnustep-headless does not include headers
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

# gnustep-headless is a bundle which is installed into lib\GNUstep\Bundles
set(VCPKG_POLICY_ALLOW_DLLS_IN_LIB enabled)

# gnustep-headless includes gpbs[.exe], which is a runtime tool and installed into bin.
set(VCPKG_POLICY_ALLOW_EXES_IN_BIN enabled)
