# Building and Testing the HDF5 Examples

`HDF5Examples/` is a standalone CMake project for validating an installed
HDF5 package. It requires CMake 4.0 or later and follows the same source-build
platform policy as the library: Windows/MSVC or Linux/GNU.

Set `HDF5_ROOT` or `CMAKE_PREFIX_PATH` to the HDF5 installation. The requested
examples must match components present in that installation.

## Preset Workflow

Run a workflow from the `HDF5Examples` directory:

```bash
cmake --workflow --preset ci-StdShar-GNUC --fresh
```

Use `ci-StdShar-MSVC` on Windows. These presets configure, build, and test a
shared-library example set. Their build and install trees are created under
`build/<presetName>` and `install/<presetName>` in the parent directory of the
examples source tree.

Individual preset stages are also available:

```bash
cmake --preset ci-StdShar-GNUC
cmake --build --preset ci-StdShar-GNUC
ctest --preset ci-StdShar-GNUC
```

## Manual Workflow

```bash
cmake -S HDF5Examples -B build-examples \
  -DCMAKE_PREFIX_PATH=<hdf5-install-prefix> \
  -DH5EXAMPLE_BUILD_TESTING=ON \
  -DH5EXAMPLE_USE_SHARED_LIBS=ON
cmake --build build-examples --parallel 6
ctest --test-dir build-examples --output-on-failure -j 6
```

On Windows, add `-G "Visual Studio 18 2026" -A x64` when configuring and
`--config Release`/`-C Release` to the build and test commands.

## Standalone Options

| Option | Default | Purpose |
| --- | --- | --- |
| `H5EXAMPLE_BUILD_TESTING` | `OFF` | Register and run example tests |
| `H5EXAMPLE_USE_SHARED_LIBS` | `ON` | Prefer shared HDF5 libraries |
| `H5EXAMPLE_BUILD_FILTERS` | `OFF` | Build plugin filter examples |
| `H5EXAMPLE_ENABLE_PARALLEL` | `OFF` | Build parallel examples with MPI |
| `H5EXAMPLE_BUILD_PYTHON` | `OFF` | Run retained Python examples |
| `H5EXAMPLE_DISABLE_COMPILER_WARNINGS` | `OFF` | Suppress example compiler warnings |

Compatibility API selectors named `H5EXAMPLE_USE_16_API` through
`H5EXAMPLE_USE_200_API` are also available. They select the corresponding
legacy API mapping; they do not add language bindings.

The installed example bundle may also include the legacy
`HDF5_Examples.cmake` CTest driver. Presets or direct CMake commands are the
preferred interfaces because their cache values are visible and reproducible.
Python files under `HDF5Examples/` are example programs, not a maintained
Python library binding.

For downstream package discovery and linking, see
[USING_HDF5_CMake.md](USING_HDF5_CMake.md).
