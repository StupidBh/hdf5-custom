# HDF5 CMake Developer Instrumentation

The modules in this directory provide compiler instrumentation and developer
helper targets. HDF5 source builds accept Windows/MSVC and Linux/GNU. The
instrumentation release-validation baselines are:

- Windows x64 with MSVC 18 and Visual Studio 18 2026.
- Linux x86_64 with GCC/G++ and Ninja or Unix Makefiles.

Names such as `clang-format` and `clang-tidy` refer to standalone developer
tools. They do not make Clang a supported HDF5 build compiler.

## MSVC AddressSanitizer

`sanitizers.cmake` supports AddressSanitizer only, and only with MSVC. Enable
the HDF5 integration and select the sanitizer:

```powershell
cmake -S . -B build-msvc18-asan -G "Visual Studio 18 2026" -A x64 -DHDF5_ENABLE_SANITIZERS=ON -DHDF5_USE_SANITIZER=Address
cmake --build build-msvc18-asan --config Debug --parallel 6
ctest --test-dir build-msvc18-asan -C Debug --output-on-failure -j 6
```

Any other `HDF5_USE_SANITIZER` value is rejected. The module applies
`/fsanitize=address` through target-scoped compile options and records it in
the generated build settings.

## GCC Coverage

`code-coverage.cmake` supports GCC coverage through gcov, lcov, and genhtml.
Use it only on Linux with GCC. A Debug build gives the most useful results.

Enable both the repository integration option and the module option:

```bash
cmake -S . -B build-gcc-coverage -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_C_COMPILER=gcc \
  -DCMAKE_CXX_COMPILER=g++ \
  -DHDF5_ENABLE_COVERAGE=ON \
  -DCODE_COVERAGE=ON
cmake --build build-gcc-coverage --parallel 6
ctest --test-dir build-gcc-coverage --output-on-failure -j 6
cmake --build build-gcc-coverage --target ccov --parallel 6
```

Configuration fails when `lcov` or `genhtml` is unavailable. Coverage output
is written to `<build-dir>/ccov`.

The module exposes these helpers to CMake code:

- `add_code_coverage()` instruments targets in the current directory and
  below.
- `target_code_coverage(<target> ...)` instruments one target and can add it
  to report targets with `AUTO` or `ALL`.
- `add_code_coverage_all_targets(...)` creates the merged report targets.
- `ccov-clean` resets counters.
- `ccov` generates reports for targets registered with `AUTO`.
- `ccov-all` generates a merged HTML report for targets registered with
  `ALL`.
- `ccov-all-capture` creates the merged lcov data file.

`target_code_coverage` accepts visibility selection and exclusion patterns;
refer to the comments in `code-coverage.cmake` for the complete function
contract.

## Dependency Graphs

`dependency-graph.cmake` uses Graphviz `dot` to render a CMake target graph:

```cmake
include(config/sanitizer/dependency-graph.cmake)
gen_dep_graph(png TARGET_NAME hdf5-dependencies OUTPUT_DIR "${CMAKE_BINARY_DIR}")
```

`gen_dep_graph(<format> ...)` accepts:

- `ADD_TO_DEP_GRAPH` to add the generated target to the aggregate
  `dep-graph` target.
- `TARGET_NAME <name>` to set the custom target and output basename.
- `OUTPUT_DIR <path>` to select the output directory.

The output format is any format supported by the installed `dot` executable.

## Static Analysis Tools

`tools.cmake` locates and configures developer analyzers:

- `clang_tidy(<arguments>)` and `reset_clang_tidy()`.
- `include_what_you_use(<arguments>)` and
  `reset_include_what_you_use()`.
- `cppcheck(<arguments>)` and `reset_cppcheck()`.

Enable module loading with `HDF5_ENABLE_ANALYZER_TOOLS=ON`. Each enabling
function applies to targets defined after the call until its reset function is
called. Configuration reports an error when a requested tool is not installed.

These analyzers inspect code compiled by the retained MSVC or GCC toolchain;
their presence does not change the selected compiler.

## Formatting

`formatting.cmake` supplies:

- `clang_format(<target-name> <targets-or-files>...)`, which creates a custom
  formatting target and attaches it to the aggregate `format` target.
- `cmake_format(<target-name> <files>...)`, which creates a custom formatting
  target and attaches it to the aggregate `cmake-format` target.

Enable the repository integration with `HDF5_ENABLE_FORMATTERS=ON`. Missing
formatters are reported during configuration, and targets are created only
when the relevant executable and input files are available.

Run formatting only on intentionally edited files. Generated build and install
trees must remain outside the repository.
