v2.3.0 --- July X , 2026

# 🔺 HDF5 Changelog
All notable changes to this project will be documented in this file. This document describes the differences between this release and the previous
HDF5 release, platforms tested, and known problems in this release.

For releases prior to version 2.0.0, please see the release.txt file and for more details check the HISTORY*.txt files in the HDF5 source.

# 🔗 Quick Links
* [HDF5 documentation](https://support.hdfgroup.org/documentation/hdf5/latest/)
* [Official HDF5 releases](https://support.hdfgroup.org/downloads/index.html)
* [Changes from Release to Release and New Features in the HDF5-2.x.y](https://support.hdfgroup.org/releases/hdf5/documentation/release_specific_info.md)
* [Getting help, questions, or comments](https://github.com/HDFGroup/hdf5#help-and-support)

## 📖 Contents
* [Executive Summary](CHANGELOG.md#execsummary)
* [Breaking Changes](CHANGELOG.md#%EF%B8%8F-breaking-changes)
* [Deprecations](CHANGELOG.md#-deprecations)
* [New Features & Improvements](CHANGELOG.md#-new-features--improvements)
* [Bug Fixes](CHANGELOG.md#-bug-fixes)
* [Support for new platforms and languages](CHANGELOG.md#-support-for-new-platforms-and-languages)
* [Platforms Tested](CHANGELOG.md#%EF%B8%8F-platforms-tested)
* [Known Problems](CHANGELOG.md#-known-problems)

# 🔆 Executive Summary: HDF5 Version 2.3.0


## Performance Enhancements:


## Significant Advancements:


## Enhanced Features:


## Acknowledgements:

We would like to thank the many HDF5 community members who contributed to this release of HDF5.

# ⚠️ Breaking Changes

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

The combined standalone examples project now applies the same compiler-pair
check when its optional C++ examples enable the C++ language. This closes an
entry point that previously validated only the C compiler. Enabling example
warning suppression now also applies `/w` to MSVC C++ examples instead of only
to their C counterparts, and the compile-only switch is no longer passed to
the MSVC linker.

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


# 🪦 Deprecations


# 🚀 New Features & Improvements

## Configuration


## Library

## Parallel Library

## C++ Library

## Tools

## High-Level APIs

## C Packet Table API

## Internal header file

## Documentation


# 🪲 Bug Fixes

## Library

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
   headers, tests, and C++11 tests. The separator syntax introduced by an earlier
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

### Fixed the C++ examples failing to compile when built standalone

  The standalone examples build used C++98, but `H5public.h` includes
  `<cinttypes>`, which requires C++11. This affected any C++ translation unit
  including `hdf5.h`, and did not match the HDF5 C++ library itself, which is
  built as C++11. The C++ examples did not compile, against either static or
  shared HDF5. The examples are now built as C++11.

  Only the standalone build was affected. Examples built as part of the HDF5
  build inherit the library's own C++ standard.

### Fixed the examples skipping the HL and C++ programs in some configurations

  When built standalone against an installed HDF5, the examples chose between
  the shared and static HL and C++ libraries using `BUILD_SHARED_LIBS`,
  while the C library used `H5EXAMPLE_USE_SHARED_LIBS`. Since
  `H5EXAMPLE_USE_SHARED_LIBS` determines which component is requested from
  `find_package`, and therefore which `HDF5_<linkage>_<lang>_FOUND` variables
  exist, `BUILD_SHARED_LIBS` could not select a linkage on its own. With
  `H5EXAMPLE_USE_SHARED_LIBS` on and `BUILD_SHARED_LIBS` unset, those examples
  were disabled with a "libs not found" message even though the libraries were
  installed and had been found. The selection now uses
  `H5EXAMPLE_USE_SHARED_LIBS`, matching the C library.

  Builds driven through `CTestScript.cmake` were not affected, since its cache
  file forces `BUILD_SHARED_LIBS` on. This affected cases where the examples
  were built directly without that cache file.

## Tools

### Fixed an issue with quoting of data values in h5ls and h5dump when displaying as ASCII characters

   When using the `-s` (h5ls) or `-r` (h5dump) option to display 1-byte integer datasets and
   attributes as ASCII characters, a closing double-quote character for data values was dropped
   in some cases. This double-quote character has been restored and similar formatting issues
   have been fixed for cases where elements wrap to new lines according to the particular tool's
   column limit setting.

## Performance

## High-Level Library

## Documentation

## C++ APIs

## Testing

# ✨ Support for new platforms and languages

# ☑️ Platforms Tested

A table of platforms tested can be seen on the [wiki](https://github.com/HDFGroup/hdf5/wiki/Platforms-Tested).
Current test results are available [here](https://my.cdash.org/index.php?project=HDF5).

# ⛔ Known Problems

- When performing implicit datatype conversion on specific non-IEEE floating-point format data, HDF5 may improperly convert some data values:

   When performing I/O operations using a non-IEEE floating-point format datatype, HDF5 may improperly convert some data values due to incomplete handling of non-IEEE types. Such types include the following pre-defined datatypes:

    H5T_FLOAT_F8E4M3
    H5T_FLOAT_F8E5M2
    H5T_FLOAT_F6E2M3
    H5T_FLOAT_F6E3M2
    H5T_FLOAT_F4E2M1

   If possible, an application should perform I/O with these datatypes using an in-memory type that matches the specific floating-point format and perform explicit data conversion outside of HDF5, if necessary. Otherwise, read/written values should be verified to be correct.

- When the library detects and builds in support for the _Float16 datatype, an issue has been observed on at least one MacOS 14 system where the library fails to initialize due to not being able to detect the byte order of the _Float16 type [#4310](https://github.com/HDFGroup/hdf5/issues/4310):

     #5: H5Tinit_float.c line 308 in H5T__fix_order(): failed to detect byte order
     major: Datatype
     minor: Unable to initialize object

   If this issue is encountered, support for the _Float16 type can be disabled with a configuration option:

     `CMake: HDF5_ENABLE_NONSTANDARD_FEATURE_FLOAT16=OFF`

- When HDF5 is compiled with NVHPC versions 23.5 - 23.9 (additional versions may also be applicable) and with -O2 (or higher) and -DNDEBUG, test failures occur in the following tests:

   - H5PLUGIN-filter_plugin
   - H5TEST-flush2
   - H5TEST-testhdf5-base
   - MPI_TEST_t_filters_parallel

  Also, NVHPC will fail to compile the test/tselect.c test file with a compiler error of `use of undefined value` when the optimization level is -O2 or higher.

   This is confirmed to be a [bug in the nvc compiler](https://forums.developer.nvidia.com/t/hdf5-no-longer-compiles-with-nv-23-9/269045) that has been fixed as of 23.11. If you are using an affected version of the NVidia compiler, the work-around is to set the optimization level to -O1.

- CMake files do not behave correctly with paths containing spaces

   Do not use spaces in paths because the required escaping for handling spaces results in very complex and fragile build files.

- At present, metadata cache images may not be generated by parallel applications. Parallel applications can read files with metadata cache images, but since this is a collective operation, a deadlock is possible if one or more processes do not participate.

- The subsetting option in `ph5diff` currently will fail and should be avoided

   The subsetting option works correctly in serial `h5diff`.

- Several tests currently fail on certain platforms:
   MPI_TEST-t_bigio fails with spectrum-mpi on ppc64le platforms.

   MPI_TEST-t_subfiling_vfd and MPI_TEST_EXAMPLES-ph5_subfiling fail with
   cray-mpich on theta and with XL compilers on ppc64le platforms.

- File space may not be released when overwriting or deleting certain nested variable length or reference types.

Known problems in previous releases can be found in the HISTORY*.txt files in the HDF5 source. Please report any new problems found to <a href="mailto:help@hdfgroup.org">help@hdfgroup.org</a>.
