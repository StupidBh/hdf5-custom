# Autotools Compatibility Note

This fork has no Autotools configure or build entry point. Autotools option
names found in older HDF5 release notes, external articles, or downstream
scripts must not be treated as supported aliases.

Use [INSTALL_CMake_options.md](INSTALL_CMake_options.md) for the current CMake
cache variables and defaults. Common conceptual replacements include:

| Former build concern | Current CMake setting |
| --- | --- |
| Enable parallel HDF5 | `HDF5_ENABLE_PARALLEL=ON` |
| Enable zlib or SZIP-compatible filters | `HDF5_ENABLE_ZLIB_SUPPORT=ON` or `HDF5_ENABLE_SZIP_SUPPORT=ON` |
| Select the default compatibility API | `HDF5_DEFAULT_API_VERSION=<version>` |
| Select test intensity | `HDF_TEST_EXPRESS=0..3` |
| Treat warnings as errors | `HDF5_ENABLE_WARNINGS_AS_ERRORS=ON` |

These are conceptual mappings, not command-line compatibility aliases. Some
old Autotools features were removed with unsupported languages or platforms
and have no replacement. Always verify a setting in `CMakeBuildOptions.cmake`,
the top-level `CMakeLists.txt`, and the relevant subdirectory CMake file.

For supported configure, build, test, and install commands, see
[INSTALL_CMake.md](INSTALL_CMake.md).
