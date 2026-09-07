# Installing HDF5

This fork is built with CMake only and requires CMake 4.0 or later. Source
builds are supported for exactly these target-system/compiler pairs:

- Windows with compiler ID `MSVC`
- Linux with compiler ID `GNU`

Generator, architecture, and exact compiler version are not admission checks.
The release-validation baselines are Windows x64 with Visual Studio 18 2026
and Linux x86_64 with GCC/G++ using Ninja, plus a focused Unix Makefiles
check.

For the complete build, test, install, and preset workflows, use
[INSTALL_CMake.md](INSTALL_CMake.md). The available cache variables and their
defaults are documented in
[INSTALL_CMake_options.md](INSTALL_CMake_options.md); the CMake source remains
the final authority.

## Quick Start

The default configuration builds the static and shared C libraries, tests,
tools, utilities, and examples. Parallel HDF5, thread safety, multi-thread
concurrency, and external compression filters are off by default.

```bash
cmake -S . -B build
cmake --build build --parallel 6
ctest --test-dir build --output-on-failure -j 6
cmake --install build --prefix <install-prefix>
```

On Windows, use the supported Visual Studio generator and configuration:

```powershell
cmake -S . -B build-msvc18 -G "Visual Studio 18 2026" -A x64
$env:CL = "/utf-8"
cmake --build build-msvc18 --config Release --parallel 6
ctest --test-dir build-msvc18 -C Release --output-on-failure -j 6
cmake --install build-msvc18 --config Release --prefix <install-prefix>
```

The supplied `ci-StdShar-GNUC` and `ci-StdShar-MSVC` workflow presets are
release-oriented configurations. They enable additional components, including
common compression and plugin features, and therefore are not equivalent to
the default configuration above.

## Optional Dependencies

- zlib supplies the deflate filter.
- libaec supplies the SZIP-compatible filter.
- MPI is required for parallel HDF5.
- AWS CRT libraries are required for the read-only S3 (ROS3) VFD.
- OpenSSL is required when signed plugins are enabled.

See [INSTALL_Filters.md](INSTALL_Filters.md),
[INSTALL_S3.md](INSTALL_S3.md), and
[PLUGIN_SIGNATURE_README.md](PLUGIN_SIGNATURE_README.md) for feature-specific
requirements. A configured installation records its actual feature set in
`libhdf5.settings` and its generated CMake package files.

Prebuilt upstream releases are available from the
[HDF5 releases page](https://github.com/HDFGroup/hdf5/releases). Questions can
be posted to the [HDF Forum](https://forum.hdfgroup.org/) or the
[HDF Help Desk](https://help.hdfgroup.org/).
