# Build and Install HDF5 with CMake

This repository uses CMake as its only build system and requires CMake 4.0 or later. Build outside the source tree.

## Supported Source-Build Environments

The HDF5 source tree accepts exactly these target-system/compiler pairs:

| Target system | Required CMake compiler ID |
|---------------|----------------------------|
| Windows       | `MSVC`                     |
| Linux         | `GNU`                      |

Generator, target architecture, and exact compiler version are not checked by
the source-build firewall. The release-validation baselines are Windows x64
with the MSVC toolset from Visual Studio 18 2026 using the Visual Studio 18
2026 generator, and Linux x86_64 with GCC/G++ using Ninja plus a focused Unix
Makefiles check. Other generators and architectures within an accepted pair
may be unvalidated; admission does not make them release-qualified.

MinGW, MSYS2, Cygwin, Clang and clang-cl, Intel compilers, NVHPC, AOCC, macOS,
BSD, Emscripten, and other target-system/compiler pairs are outside the
source-build contract.

The check uses the CMake target system, so a toolchain file or cross-compilation does not bypass it.
`HDF5_ALLOW_UNSUPPORTED` applies only to documented HDF5 feature combinations;
it cannot override the target-system/compiler policy.

This policy governs building HDF5 itself and the retained standalone HDF5 example projects. An independent application
may consume an installed HDF5 package with another toolchain when that toolchain is compatible with the package's ABI.

## Prerequisites

- CMake 4.0 or later.
- An MSVC toolchain on Windows. Visual Studio 18 2026 x64 is the release baseline.
- GCC and G++ on Linux. Ninja on x86_64 is the release baseline, with an
  additional Unix Makefiles check.
- Optional dependencies required by enabled features, such as MPI, zlib, libaec, AWS CRT libraries, or Java/JNI for the
  HDFS VFD.

JNI discovery for `HDF5_ENABLE_HDFS` is required by libhdfs. It does not add Java bindings to this repository.

## Workflow Presets

List presets available on the current host:

```console
cmake --list-presets=all
```

The root source tree retains these workflow presets:

| Workflow             | Environment      | Purpose                                      |
|----------------------|------------------|----------------------------------------------|
| `ci-StdShar-MSVC`    | Windows x64/MSVC | Standard configure, build, test, and package |
| `ci-StdShar-GNUC`    | Linux x86_64/GCC | Standard configure, build, test, and package |
| `ci-StdShar-GNUC-S3` | Linux x86_64/GCC | Standard workflow with the ROS3 VFD          |

Run the matching workflow from the repository root:

```powershell
cmake --workflow --preset ci-StdShar-MSVC --fresh
```

```bash
cmake --workflow --preset ci-StdShar-GNUC --fresh
```

The S3 workflow is Linux-only:

```bash
cmake --workflow --preset ci-StdShar-GNUC-S3 --fresh
```

Host conditions hide configure presets that cannot run on the current platform. Build, test, and package preset names
may still appear in
`--list-presets=all`; their configure preset remains authoritative.

Preset build trees are created under `../build/<preset-name>` and install prefixes under `../install/<preset-name>`. The
retained presets limit builds to six jobs and tests to four jobs.

Individual preset steps can also be run separately:

```console
cmake --preset ci-StdShar-GNUC --fresh
cmake --build --preset ci-StdShar-GNUC
ctest --preset ci-StdShar-GNUC
cpack --preset ci-StdShar-GNUC
```

Use `ci-StdShar-MSVC` in the same commands on Windows.

## Manual Windows Build

Use a PowerShell or Visual Studio developer shell with an MSVC toolchain
available. The following command is the release-validation baseline, not a
generator or architecture requirement. Setting `CL` to `/utf-8` prevents
locale-dependent test failures on Windows systems whose active code page is
not UTF-8.

```powershell
$env:CL = "/utf-8"
cmake -S . -B build-msvc18 -G "Visual Studio 18 2026" -A x64 -DCMAKE_INSTALL_PREFIX="$PWD/install-msvc18"
cmake --build build-msvc18 --config Release --parallel 6
ctest --test-dir build-msvc18 -C Release --output-on-failure -j 6
cmake --install build-msvc18 --config Release
cpack --config build-msvc18/CPackConfig.cmake -C Release
```

IDE-managed profiles such as CLion may use another CMake generator or omit
`-A x64`; configuration is accepted when CMake detects target system Windows
and compiler ID `MSVC`.

Visual Studio is a multi-configuration generator. Use the same configuration name for build, test, install, and package
commands.

## Manual Linux Build

The Ninja form is:

```bash
cmake -S . -B build-gcc-ninja -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=gcc \
  -DCMAKE_CXX_COMPILER=g++ \
  -DCMAKE_INSTALL_PREFIX="$PWD/install-gcc"
cmake --build build-gcc-ninja --parallel 6
ctest --test-dir build-gcc-ninja --output-on-failure -j 6
cmake --install build-gcc-ninja
cpack --config build-gcc-ninja/CPackConfig.cmake
```

For Make, replace `-G Ninja` with `-G "Unix Makefiles"`. A single-configuration generator reads `CMAKE_BUILD_TYPE`
during configuration.

## Library and Product Options

The current CMake files are the source of truth for options. The most commonly used options are:

| Option                       | Default | Effect                            |
|------------------------------|---------|-----------------------------------|
| `BUILD_STATIC_LIBS`          | `ON`    | Build static HDF5 libraries       |
| `BUILD_SHARED_LIBS`          | `ON`    | Build shared HDF5 libraries       |
| `HDF5_ONLY_SHARED_LIBS`      | `OFF`   | Force a shared-only library build |
| `BUILD_TESTING`              | `ON`    | Build the test programs           |
| `HDF5_BUILD_TOOLS`           | `ON`    | Build command-line tools          |
| `HDF5_BUILD_HL_LIB`          | `ON`    | Build the high-level C library    |
| `HDF5_BUILD_CPP_LIB`         | `OFF`   | Build the C++ wrappers            |
| `HDF5_BUILD_EXAMPLES`        | `ON`    | Build retained examples           |
| `HDF5_BUILD_DOC`             | `OFF`   | Build documentation               |
| `HDF5_ENABLE_PARALLEL`       | `OFF`   | Enable MPI support                |
| `HDF5_ENABLE_THREADSAFE`     | `OFF`   | Enable the thread-safe library    |
| `HDF5_ENABLE_CONCURRENCY`    | `OFF`   | Enable multi-thread concurrency   |
| `HDF5_ENABLE_ZLIB_SUPPORT`   | `OFF`   | Enable the zlib filter            |
| `HDF5_ENABLE_SZIP_SUPPORT`   | `OFF`   | Enable the libaec/SZIP filter     |
| `HDF5_ENABLE_PLUGIN_SUPPORT` | `OFF`   | Enable filter plugins             |
| `HDF5_ENABLE_ROS3_VFD`       | `OFF`   | Enable the ROS3 VFD               |
| `HDF5_ENABLE_HDFS`           | `OFF`   | Enable the HDFS VFD               |

The default build produces static and shared libraries, tests, tools, the high-level library, and examples. C++, MPI,
thread safety, concurrency, and external compression filters are opt-in.

Set cache entries with `-D<name>=<value>`:

```console
cmake -S . -B build-custom <supported-generator-options> -DHDF5_BUILD_CPP_LIB=ON
```

Thread safety, concurrency, MPI, C++, and the high-level library have documented compatibility constraints. See
[INSTALL_CMake_options.md](INSTALL_CMake_options.md) before combining them.

### External dependencies

`HDF5_ALLOW_EXTERNAL_SUPPORT` accepts `NO`, `GIT`, or `TGZ` and controls where supported external dependency sources may
be obtained. Enabling an external download does not broaden the platform/compiler matrix.

For compression dependencies and filter plugins, see
[INSTALL_Filters.md](INSTALL_Filters.md). For ROS3, see
[INSTALL_S3.md](INSTALL_S3.md).

## Instrumentation

### MSVC AddressSanitizer

AddressSanitizer is the only retained compiler sanitizer configuration. It requires Windows x64/MSVC:

```powershell
$env:CL = "/utf-8"
cmake -S . -B build-msvc18-asan -G "Visual Studio 18 2026" -A x64 -DHDF5_ENABLE_SANITIZERS=ON -DHDF5_USE_SANITIZER=Address
cmake --build build-msvc18-asan --config Debug --parallel 6
ctest --test-dir build-msvc18-asan -C Debug --output-on-failure -j 6
```

### GCC coverage

Coverage is available only on Linux with GCC and requires `lcov` and
`genhtml`. Use a Debug build and enable both the HDF5 integration option and the coverage module option:

```bash
cmake -S . -B build-gcc-coverage -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_C_COMPILER=gcc \
  -DCMAKE_CXX_COMPILER=g++ \
  -DHDF5_ENABLE_COVERAGE=ON \
  -DCODE_COVERAGE=ON
cmake --build build-gcc-coverage --parallel 6
ctest --test-dir build-gcc-coverage --output-on-failure -j 6
```

The build instruments HDF5 targets and test execution writes GCC coverage
counter data beside their object files. The top-level HDF5 build provides the
`ccov-clean` target to reset those counters, but it does not provide an HTML
report target. Use an external gcov/lcov workflow when a report is required.
See [the instrumentation README](../config/sanitizer/README.md) for details.

`HDF5_ENABLE_DEV_WARNINGS=ON` enables the repository's stricter compiler diagnostics. There is no
`HDF5_ENABLE_DEVELOPER_MODE` option and the default Visual Studio configuration list does not contain a `Developer`
configuration.

## Install and Package

Set `CMAKE_INSTALL_PREFIX` during configuration and install with
`cmake --install`, as shown above. Disable CPack setup with
`HDF5_NO_PACKAGES=ON` when packaging is not needed.

The generated `CPackConfig.cmake` creates the binary package formats available for the retained platform and installed
packaging tools. The workflow presets run the matching package preset automatically.

Never use a build or install directory as a source directory, and do not place generated build or install trees in the
repository.

## Use an Installed HDF5 Package

A CMake application can locate the installed package in config mode:

```cmake
find_package(HDF5 CONFIG REQUIRED COMPONENTS C)
```

Pass the install prefix through `CMAKE_PREFIX_PATH` or set `HDF5_ROOT` if CMake cannot locate it. Select static or
shared components and imported targets according to the generated package configuration.

The source-build firewall is not injected into downstream projects. Consumers remain subject to the installed library's
ABI, runtime-library, architecture, configuration, and static/shared compatibility requirements. See
[USING_HDF5_CMake.md](USING_HDF5_CMake.md) for application examples.

## Test Selection

`HDF_TEST_EXPRESS` ranges from `0` (most exhaustive) through `3` (quickest and the normal default). Record its
configured value with test results.

Use CTest filters for focused runs:

```console
ctest --test-dir <build-dir> -C Release -N -R <pattern>
ctest --test-dir <build-dir> -C Release --output-on-failure -j 6 -R <pattern>
```

Omit `-C Release` for a single-configuration Linux build.
