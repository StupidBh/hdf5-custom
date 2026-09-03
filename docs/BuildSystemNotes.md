# HDF5 Build System Summary

HDF5 2.0 uses CMake 4.0 or later and requires out-of-source builds. The
primary configuration files are `CMakeLists.txt`, `CMakeBuildOptions.cmake`,
`CMakeTests.cmake`, `CMakeInstallation.cmake`, `CMakeVOL.cmake`, and
`CMakePlugins.cmake`.

## Supported Libraries

The repository builds the C library, the optional C++ wrapper, the high-level
C library, command-line tools, examples, VOL connectors, and VFDs. Static and
shared libraries are controlled by `BUILD_STATIC_LIBS` and
`BUILD_SHARED_LIBS`.

Common feature options include:

- `HDF5_BUILD_CPP_LIB`
- `HDF5_BUILD_HL_LIB`
- `HDF5_BUILD_TOOLS`
- `HDF5_ENABLE_PARALLEL`
- `HDF5_ENABLE_THREADSAFE`
- `HDF5_ENABLE_CONCURRENCY`
- `HDF5_ENABLE_ZLIB_SUPPORT`
- `HDF5_ENABLE_SZIP_SUPPORT`
- `HDF5_ENABLE_PLUGIN_SUPPORT`
- `HDF5_ENABLE_SUBFILING_VFD`
- `HDF5_ENABLE_HDFS`

## Presets

The preset files use layered hidden presets for build type, compiler, shared
or static libraries, and optional features. Typical workflows are:

```bash
cmake --workflow --preset ci-StdShar-GNUC --fresh
cmake --workflow --preset ci-StdShar-GNUC-S3 --fresh
cmake --workflow --preset ci-StdShar-MSVC --fresh
```

Build directories are normally created under `build/<presetName>` and install
directories under `install/<presetName>`.

## Tests And CI

CTest covers the core C library, C++ wrapper, high-level library, tools,
examples, VFDs, VOL connectors, and parallel MPI configurations. GitHub
Actions project-build jobs exercise Windows x64 with MSVC and Linux x86_64
with GCC. Separate workflows perform formatting, static analysis, release
packaging, and selected third-party integrations without expanding the
supported source-build matrix.

Use targeted CTest expressions while developing and a full preset workflow
before release:

```bash
ctest -R "VFD"
ctest -R "MPI|parallel"
ctest -R "H5_api_test"
```

## Packaging

CPack produces source archives and platform-specific binary packages.
Installations include the selected libraries, public headers, tools,
documentation, examples, and CMake package configuration. Optional external
compression libraries can be bundled when requested.
