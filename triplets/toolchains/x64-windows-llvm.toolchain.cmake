# Get Program Files root to lookup possible LLVM installation
file(TO_CMAKE_PATH "$ENV{ProgramW6432}/LLVM/bin" LLVM_BIN_DIR)

# Set NO_DEFAULT_PATH to prevent the toolchain from picking up the copy of LLVM which ships with
# Visual Studio, which may be outdated
find_program(CLANG_C_EXECUTABLE NAMES "clang.exe" PATHS ${LLVM_BIN_DIR} NO_DEFAULT_PATH REQUIRED)
find_program(CLANG_CXX_EXECUTABLE NAMES "clang++.exe" PATHS ${LLVM_BIN_DIR} NO_DEFAULT_PATH REQUIRED)
find_program(CLANG_RC_EXECUTABLE NAMES "llvm-rc.exe" PATHS ${LLVM_BIN_DIR} NO_DEFAULT_PATH REQUIRED)
find_program(CLANG_LLD_EXECUTABLE NAMES "lld-link.exe" PATHS ${LLVM_BIN_DIR} NO_DEFAULT_PATH REQUIRED)

set(CMAKE_C_COMPILER ${CLANG_C_EXECUTABLE} CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILER ${CLANG_CXX_EXECUTABLE} CACHE STRING "" FORCE)
set(CMAKE_RC_COMPILER  ${CLANG_RC_EXECUTABLE} CACHE STRING "" FORCE)

set(CMAKE_LINKER_TYPE "lld")
set(CMAKE_C_USING_LINKER_MODE FLAG)
set(CMAKE_C_USING_LINKER_lld "-fuse-ld=lld")
set(CMAKE_CXX_USING_LINKER_MODE ${CMAKE_C_USING_LINKER_MODE})
set(CMAKE_CXX_USING_LINKER_lld ${CMAKE_C_USING_LINKER_lld})
set(CMAKE_OBJC_USING_LINKER_MODE ${CMAKE_C_USING_LINKER_MODE})
set(CMAKE_OBJC_USING_LINKER_lld ${CMAKE_C_USING_LINKER_lld})
set(CMAKE_OBJCXX_USING_LINKER_MODE ${CMAKE_C_USING_LINKER_MODE})
set(CMAKE_OBJCXX_USING_LINKER_lld ${CMAKE_C_USING_LINKER_lld})
