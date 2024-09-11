set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_LIBRARY_LINKAGE dynamic)
set(VCPKG_CRT_LINKAGE dynamic)

# Configure toolchain
set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/toolchains/x64-windows-llvm.toolchain.cmake")
set(VCPKG_LOAD_VCVARS_ENV ON)
