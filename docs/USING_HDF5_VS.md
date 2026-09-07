# Using HDF5 in a Visual Studio Project

HDF5 itself must be built with CMake. On Windows, this repository supports an
MSVC compiler; the release-validation baseline uses Visual Studio 18 2026 and
x64. For a downstream application, a CMake project using the installed HDF5
package is preferred because it carries include paths, definitions, and
transitive libraries automatically. See
[USING_HDF5_CMake.md](USING_HDF5_CMake.md).

For an existing Visual Studio project that cannot use CMake:

1. Match the HDF5 package architecture, build configuration, and MSVC runtime
   ABI. Do not mix Debug and Release libraries.
2. Add the installation's `include` directory to the compiler include path and
   its `lib` directory to the linker search path.
3. Select the libraries for the components actually installed. Use
   `libhdf5.settings` and the files in the package's `lib` directory as the
   source of truth; optional compression and parallel libraries are
   configuration-dependent.
4. When linking the shared C library, define `H5_BUILT_AS_DYNAMIC_LIB` for the
   consumer and make the HDF5 DLLs available through the application's runtime
   search path. Do not define it for a static link.
5. Link any required external dependency libraries using versions compatible
   with those recorded in `libhdf5.settings`.

Run a small read/write program before integrating the package into a larger
application. The standalone examples in `HDF5Examples/` provide suitable
smoke tests; their build procedure is documented in
[USING_CMake_Examples.md](USING_CMake_Examples.md).
