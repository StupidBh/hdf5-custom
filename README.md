<div align="center">

![HDF5 Logo][logo]

</div>

# HDF5 Custom

This repository is a CMake-only fork of upstream HDF5 `develop`. It contains
the HDF5 C library and file-format implementation, the high-level C library,
opt-in C++ wrappers, command-line tools and utilities, and retained examples.

Java and Fortran sources, bindings, examples, build options, packaging, and CI
are intentionally absent. Python files under `HDF5Examples/` are example
programs, not a Python binding maintained by this repository.

## Build Scope

CMake 4.0 or later is required. Source builds accept exactly these
target-system/compiler pairs:

- Windows with compiler ID `MSVC`
- Linux with compiler ID `GNU`

Generator, architecture, and exact compiler version are not central admission
checks. Release validation uses Windows x64 with Visual Studio 18 2026 and
Linux x86_64 with GCC/G++ and Ninja, plus a focused Unix Makefiles check.

The default build enables static and shared libraries, tests, tools,
utilities, the high-level library, and examples. C++, parallel HDF5, thread safety,
multi-thread concurrency, and external compression filters are off by
default.

```bash
cmake -S . -B build
cmake --build build --parallel 6
ctest --test-dir build --output-on-failure -j 6
```

Use [the installation index](docs/INSTALL.md) for a short overview and
[the CMake build guide](docs/INSTALL_CMake.md) for the full supported workflow.
The current source tree and `CMakeBuildOptions.cmake` are authoritative when
prose and implementation differ.

## Documentation

- [CMake options](docs/INSTALL_CMake_options.md)
- [Using an installed HDF5 package](docs/USING_HDF5_CMake.md)
- [Building the standalone examples](docs/USING_CMake_Examples.md)
- [Parallel HDF5 and HPC notes](docs/README_HPC.md)
- [Current changes](release_docs/CHANGELOG.md)
- [HDF5 architecture notes](docs/doxygen/dox/TechnicalNotes.dox)
- [HDF5 file-format specification](docs/doxygen/dox/FileFormatSpec.dox)

Published HDF5 documentation and community resources are available from
[The HDF Group](https://www.hdfgroup.org/) and the
[HDF5 documentation portal](https://support.hdfgroup.org/documentation/hdf5/latest/).

## Contributing and Security

See [CONTRIBUTING.md](CONTRIBUTING.md) for the repository workflow and
[SECURITY.md](SECURITY.md) for private vulnerability reporting. User-visible
changes and user-reported fixes require an entry in
`release_docs/CHANGELOG.md`.

The code is distributed under the terms in [LICENSE](LICENSE). Citation
metadata is provided in [CITATION.cff](CITATION.cff), including DOI
[10.5281/zenodo.17808558](https://doi.org/10.5281/zenodo.17808558).

[logo]: docs/doxygen/img/HDF5.png
