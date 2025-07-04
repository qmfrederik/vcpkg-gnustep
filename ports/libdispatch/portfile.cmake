vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apple/swift-corelibs-libdispatch
    REF "swift-${VERSION}-RELEASE"
    SHA512 48c106685ef3046bacd4dba9eb021d1dea3fd9b26e7b1d427fcd1880888e01da23b819012bf39cb317afd1450c6d69ed43d4bf939ad8d313f5db422716863803
    HEAD_REF main
    PATCHES
        0001-Use-CMAKE_C_COMPILER_FRONTEND_VARIANT-to-detect-msvc.patch
        0001-Fix-Windows-compatibility.patch
        0001-Use-external-BlocksRuntime.patch
)

set(libobjc_name "libobjc.so")

if(VCPKG_TARGET_IS_WINDOWS)
    set(libobjc_name "objc.lib")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-D BUILD_SHARED_LIBS=YES"
        "-D BlocksRuntime_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include"
        "-D BUILD_TESTING=NO"
    OPTIONS_RELEASE
        "-D BlocksRuntime_LIBRARIES=${CURRENT_INSTALLED_DIR}/lib/${libobjc_name}"
    OPTIONS_DEBUG
        "-D BlocksRuntime_LIBRARIES=${CURRENT_INSTALLED_DIR}/debug/lib/${libobjc_name}"
)
vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
