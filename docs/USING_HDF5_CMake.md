# Using an Installed HDF5 Package with CMake

This guide is for downstream CMake applications. The repository's supported
source-build matrix applies when building HDF5 itself; a downstream project
may use another toolchain only when it is ABI-compatible with the installed
HDF5 package.

Point CMake at the installation prefix with `CMAKE_PREFIX_PATH` or
`HDF5_ROOT`, then request the components and library form the application
needs. The generated package exposes component library variables such as
`HDF5_C_SHARED_LIBRARY` and `HDF5_C_STATIC_LIBRARY`.

```cmake
cmake_minimum_required(VERSION 4.0)
project(hdf5_example C)

find_package(HDF5 CONFIG REQUIRED COMPONENTS C shared)

add_executable(hdf5_example hdf5_example.c)
target_link_libraries(hdf5_example PRIVATE ${HDF5_C_SHARED_LIBRARY})
```

Configure and build out of source:

```bash
cmake -S . -B build -DCMAKE_PREFIX_PATH=<hdf5-install-prefix>
cmake --build build --parallel 6
ctest --test-dir build --output-on-failure -j 6
```

Use `static` instead of `shared` and link
`${HDF5_C_STATIC_LIBRARY}` for the static C library. Other package components
include `CXX` and `Tools`, but they are available only when the HDF5
installation was built with the corresponding products. Consult
`libhdf5.settings` in the installation for the exact feature set.

When using shared libraries, the HDF5 runtime directory must be visible to the
loader, normally through `PATH` on Windows or an install-time/runtime search
path on Linux. Runtime filter and VOL plugins are found through
`HDF5_PLUGIN_PATH` when they are not installed in the configured default
plugin directory.

The generated target names depend on the package namespace selected while
building HDF5. Using the component variables above avoids hard-coding that
namespace. A manual build leaves `HDF_PACKAGE_NAMESPACE` empty by default;
the supplied release presets set it to `hdf5::`.

For the retained standalone examples and their presets, see
[USING_CMake_Examples.md](USING_CMake_Examples.md). For building HDF5 itself,
see [INSTALL_CMake.md](INSTALL_CMake.md).
