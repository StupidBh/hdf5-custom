# This CMake toolchain file configures cross-compilation settings for building HDF5 on non-native platforms.
# Copy this file and rename it (e.g., to crosscompile-myplatform.cmake).
# Replace the placeholder values with actual values for your target system and compilers.
# Then use this file with CMake by specifying it with the -DCMAKE_TOOLCHAIN_FILE option.

# Set the target system name for cross-compiling
set (CMAKE_SYSTEM_NAME system_name)

# Specify the compiler vendor and compilers for C and C++
set (CMAKE_COMPILER_VENDOR "compiler_name")
set (CMAKE_C_COMPILER compiler_cc)
set (CMAKE_CXX_COMPILER compiler_c++)

# Optional: Specify an emulator for running binaries during cross-compilation
set (CMAKE_CROSSCOMPILING_EMULATOR "")
