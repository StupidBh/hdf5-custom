v2.3.0 --- Unreleased

# 🔺 HDF5 Changelog
All notable changes to this project will be documented in this file. This document describes the differences between this release and the previous
HDF5 release, platforms tested, and known problems in this release.

Released 2.x notes are archived in [HISTORY-2.X.md](HISTORY-2.X.md). Earlier
upstream history is available from the corresponding upstream release tags.

# 🔗 Quick Links
* [HDF5 documentation](https://support.hdfgroup.org/documentation/hdf5/latest/)
* [Official HDF5 releases](https://support.hdfgroup.org/downloads/index.html)
* [Changes from Release to Release and New Features in the HDF5-2.x.y](https://support.hdfgroup.org/releases/hdf5/documentation/release_specific_info.md)
* [Getting help, questions, or comments](https://github.com/HDFGroup/hdf5#help-and-support)

## 📖 Contents
* [Executive Summary](#execsummary)
* [Breaking Changes](#breaking-changes)
* [Bug Fixes](#bug-fixes)
* [Platforms Tested](#platforms-tested)
* [Known Problems](#known-problems)

<a id="execsummary"></a>
# 🔆 Executive Summary: HDF5 Version 2.3.0

## Acknowledgements:

We would like to thank the many HDF5 community members who contributed to this release of HDF5.

<a id="breaking-changes"></a>
# ⚠️ Breaking Changes

## High-level libraries and h5watch have been removed

The complete high-level C and C++ product has been removed, including its
headers, libraries, examples, tests, CMake components, pkg-config files, and
the HL-dependent `h5watch` tool. The `HDF5_BUILD_HL_LIB` and
`HDF5_DIMENSION_SCALES_NEW_REF` CMake options and the `h5cc -nohl` switch are
no longer accepted product interfaces. The core C library, retained tools, and
HDF5 file-format compatibility are unchanged.

## Native C++ wrappers have been removed

The native HDF5 C++ wrapper product has been removed, including its sources,
headers, libraries, tests, examples, CMake option and package component,
`h5c++` wrapper, pkg-config metadata, ABI report, and install/package
artifacts. The core C API and ABI, retained tools, and HDF5 file-format
compatibility are unchanged. C++ applications and header-only wrappers can
continue to consume the public C API.

## CMake builds now require C17 for project-owned C sources

The CMake build now compiles HDF5-owned C libraries, tools, tests, plugins, and
examples in strict C17 mode. `CMAKE_C_STANDARD` defaults to `17`; an explicit
older value is rejected, while a compiler-supported later value is retained.
Configure-time feature checks use the same mode as the HDF5 targets. Bundled
third-party projects keep their own language settings, and installed targets do
not pass a C17 requirement to applications. The installed C headers retain
their C99 consumer compatibility baseline.

## CMake builds now support only Windows/MSVC and Linux/GCC

The CMake source-build firewall now accepts Windows with compiler ID `MSVC`
and Linux with compiler ID `GNU`. Generator, architecture, and exact compiler
version do not cause firewall rejection. Release validation remains based on
Windows x64 with MSVC 18 and Visual Studio 18 2026, plus Linux x86_64 with
GCC/G++ and Ninja or Unix Makefiles. MinGW, MSYS2, Cygwin, Clang and clang-cl,
Intel, NVHPC, AOCC, macOS, BSD, Emscripten, and other target-system/compiler
pairs are no longer supported and fail during CMake configuration. Source and
header compatibility implementations used only by those rejected pairs have
also been removed.

The Parallel HDF5 setup guide now makes clear that MPI compiler wrappers must
still resolve to a supported compiler ID. Cray-specific guidance is labeled as
historical and no longer implies an additional supported compiler family.

The unused AIX-only `H5__LARGE_FILES` generated-header template entry has been
removed. It was neither defined nor consumed by retained builds.

Linux plugin discovery now uses the `lib*.so` filename convention. Files named
with the macOS-style `.dylib` suffix are no longer discovered, even if their
contents are valid Linux ELF plugins. Linux plugin build outputs are unchanged.

The MinGW-only `HDF5_MINGW_STATIC_GCC_LIBS` option is removed. The ineffective
`HDF5_MSVC_NAMING_CONVENTION` option is also removed; it was exposed only for
MSVC while its implementation required MinGW, so it could not affect a
supported build. These build-system changes do not alter HDF5 file-format
compatibility or the C ABI on retained platforms.

## Java and Fortran product modules removed

The Java and Fortran libraries, examples, tests, build options, packaging,
and CI entry points are no longer part of this fork. The JNI discovery used
by the optional HDFS VFD and C-level file-format compatibility types such as
`H5T_FORTRAN_S1` remain available because they serve retained C library
functionality.

<a id="bug-fixes"></a>
# 🪲 Bug Fixes

## Library

### Restored large MPI datatype construction

   Large MPI datatype construction now queries the input datatype extent on
   every successful path. A formatting-only change had accidentally moved two
   extent queries into error branches, leaving displacement calculations with
   uninitialized values and causing parallel I/O verification failures,
   invalid-datatype errors, or crashes.

### Restored compilation of four error-cleanup paths

   Restore missing statement terminators after `HDONE_ERROR` calls in event-set,
   fixed-array, fractal-heap, and datatype cleanup paths. Their accidental removal
   prevented the core C library from compiling.

### Fixed memory leaks and ID reference count issues when pushing an error to an error stack that is full

   When an error is pushed to an error stack, the library may make a copy of the file
   and function strings to ensure that they exist for the same duration as the error
   stack entry. When an error stack is full, the library simply makes any further pushes
   no-ops, but previously gave no information to calling code that this happened. This
   caused calling code to assume that the duplicated strings were owned by an error stack
   entry that was never pushed, leaking the duplicated strings. Additionally, IDs
   associated with the error stack entry were left with incremented reference counts,
   resulting in an infinite loop while closing the library.

### Library shutdown no longer aborts on a detected infinite loop

   When the library detects that it cannot make progress closing itself (an "infinite loop closing library"), it no longer calls `abort()`. The abort behaved inconsistently, only firing when automatic error message display was enabled. Additionally, terminating the entire host process on a shutdown-time condition is undesirable for applications that embed HDF5. The library now reports the condition (when error display is enabled) and returns without aborting.

   Fixes GitHub issue #6531

### Fixed a crash when reading a chunked dataset whose chunk rank does not match the dataspace rank

   The chunk layout's stored dimensionality was validated against the dataspace rank at creation time, but not at open time, so a file whose stored chunk rank disagreed with its dataspace rank was not caught. The resulting inconsistent selection ranks during chunk I/O caused a divide-by-zero in the hyperslab iterator. The chunk dimensionality is now also validated on open, and such a dataset is rejected with an error instead of crashing.

   Fixes GitHub issue #6491

   Fixes CVE-2026-19025

## Configuration

### Fixed the C17 parallel-tools build

   Enabling `HDF5_BUILD_PARALLEL_TOOLS` unnecessarily activated a C++ compiler
   because the h5dwalk test subproject did not declare its language. The
   subproject now explicitly enables only C. The
   h5dwalk argument handling also no longer performs incompatible `char **` to
   `const char **` conversions rejected by strict C17 compilers. Its MPI-IO
   output path now initializes the striping hint correctly, advances through
   multiple output buffers, and safely participates in collective writes on
   ranks with no local data.

### Restored the optional API test driver

   The optional `h5_api_test_driver` target could not find its generated API
   test configuration header and contained a misspelled process-cleanup macro.
   Its target now owns the required HDF5 include directories, and all allocation
   failure paths use the defined cleanup macro. Cross-platform process tests
   cover successful and failed clients, launch failure, timeout, and cleanup.

### Stabilized utility-dependent test registration

   `HDF5_BUILD_UTILS` is now declared before the test tree consumes it, so a
   fresh configure and unchanged repeat configures register the same targets
   and tests. Mirror VFD tests are registered only when both the VFD and its
   server utilities are enabled, and CTest now starts and stops the required
   mirror server through a fixture.

### Corrected GCC coverage target documentation

   The Linux/GCC coverage instructions incorrectly told users to build an
   unregistered `ccov` report target. The documented workflow now matches the
   implementation: HDF5 targets are instrumented, tests produce GCC coverage
   counters, `ccov-clean` resets them, and report generation is external.

### Fixed bundled zlib and libaec CMake package exports

   Builds that fetched zlib or libaec could fail during CMake generation after
   build-tree package exports were enabled, because static HDF5 targets referred
   to dependency targets that were not exported. Build-tree packages now load
   dedicated exports for fetched compression targets before loading HDF5, and
   bundled subprojects reuse HDF5's fetched zlib instead of defining conflicting
   targets and output files. Static and shared consumers can use both build-tree
   and installed packages with bundled compression enabled.

### Preserved C-compatible integer literals during formatting

   Disable binary and decimal literal separators in the clang-format
   configuration and restore undecorated integer literals throughout C sources,
   headers, tests, and C++ tests. The separator syntax introduced by an earlier
   formatting pass is not valid in the C and C++ language modes used by supported
   Linux/GCC configurations, which prevented them from compiling.

### Excluded local build data from source packages

   CPack source archives could include in-tree build directories and local IDE
   metadata, producing oversized and machine-specific packages. Source package
   generation now excludes common CMake build trees, CPack staging data, and
   local CLion, Visual Studio, and Codex metadata.

### Restored build-tree CMake package consumption

   The generated build-tree `hdf5-config.cmake` referenced install-tree include
   and target paths, so external projects could locate the package but could not
   configure against it. The build tree now exports its targets and version file
   alongside a configuration that references the source and generated headers.

### Fixed version handling in installed CMake package version configuration file

   The installed CMake package version configuration file for the library previously used `SameMinorVersion` for the version compatibility logic, causing a `find_package(HDF5 X.Y.Z)` call to fail unless the version of a located HDF5 installation matched both `X` and `Y` of the version number exactly (i.e., releases with a greater minor version number weren't considered backward compatible). This reflected the version compatibility of HDF5 releases prior to version 2.0.0, but doesn't reflect the version compatibility of HDF5 version 2.0.0+ releases. The version compatibility logic now uses `SameMajorVersion`, so a `find_package(HDF5 X.Y.Z)` call will accept all versions of HDF5 where the major version matches `X` (i.e., only releases with a greater major version number will be rejected as not backward compatible).

## Tools

### Fixed an issue with quoting of data values in h5ls and h5dump when displaying as ASCII characters

   When using the `-s` (h5ls) or `-r` (h5dump) option to display 1-byte integer datasets and
   attributes as ASCII characters, a closing double-quote character for data values was dropped
   in some cases. This double-quote character has been restored and similar formatting issues
   have been fixed for cases where elements wrap to new lines according to the particular tool's
   column limit setting.

<a id="platforms-tested"></a>
# ☑️ Platforms Tested

The supported release-validation baselines are Windows x64 with MSVC using
Visual Studio 18 2026 and Linux x86_64 with GCC/G++ using Ninja, plus a focused
Unix Makefiles check. Exact completed configurations and test results must be
recorded before this release is finalized; the support policy alone is not
evidence that validation passed.

<a id="known-problems"></a>
# ⛔ Known Problems

- When performing implicit datatype conversion on specific non-IEEE floating-point format data, HDF5 may improperly convert some data values:

   When performing I/O operations using a non-IEEE floating-point format datatype, HDF5 may improperly convert some data values due to incomplete handling of non-IEEE types. Such types include the following pre-defined datatypes:

    H5T_FLOAT_F8E4M3
    H5T_FLOAT_F8E5M2
    H5T_FLOAT_F6E2M3
    H5T_FLOAT_F6E3M2
    H5T_FLOAT_F4E2M1

   If possible, an application should perform I/O with these datatypes using an in-memory type that matches the specific floating-point format and perform explicit data conversion outside of HDF5, if necessary. Otherwise, read/written values should be verified to be correct.

- CMake files do not behave correctly with paths containing spaces

   Do not use spaces in paths because the required escaping for handling spaces results in very complex and fragile build files.

- At present, metadata cache images may not be generated by parallel applications. Parallel applications can read files with metadata cache images, but since this is a collective operation, a deadlock is possible if one or more processes do not participate.

- The subsetting option in `ph5diff` currently will fail and should be avoided

   The subsetting option works correctly in serial `h5diff`.

- File space may not be released when overwriting or deleting certain nested variable length or reference types.

Known problems in previous releases can be found in
[HISTORY-2.X.md](HISTORY-2.X.md). Report new upstream HDF5 problems through
the [HDF Help Desk](https://help.hdfgroup.org/).
