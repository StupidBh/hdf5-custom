# CMake 4 Modernization Plan

## Objective

Modernize the HDF5 build around CMake 4.0 concepts and target-scoped usage requirements without changing the
HDF5 source implementation, supported features, generated products, or consumer-visible build behavior. CMake
versions older than 4.0 and compatibility workarounds for their policies are outside the supported scope.

The modernization is intentionally incremental. It must not be implemented as a repository-wide replacement of
the CMake files. Every implementation step is committed separately, leaves the branch buildable for its stated
configuration, and can be reverted with a normal `git revert` without reverting later unrelated work.

The C17 and C++20 language migration is a separate project. This work must not raise the C or C++ language mode,
change source code to accommodate build-system changes, or conflate language diagnostics with CMake cleanup.

## Compatibility Contract

The following behavior is frozen before build logic is changed:

The separately approved
[project supported-platform reduction](refactoring/CMakePlatformSupportReduction.md)
supersedes this contract for platform/compiler support, generator support, and
cache options and source compatibility paths used only by removed toolchains.
The retained matrix is Windows x64 with MSVC 18 and the Visual Studio 18 2026
generator, plus Linux x86_64 with GCC/G++ and Ninja or Unix Makefiles. Other
combinations are no longer compatibility requirements.

The support contract is anchored at `912fb436b`, its Stage 1 CMake
implementation at `b317dedc9`, and its current support-documentation update at
`6ad3399ec`. The CMake reduction is implemented, but Windows/MSVC validation is
blocked by pre-existing C syntax errors and native Linux/GCC validation is
deferred. The modernization remains paused; this status does not start the
platform plan's source-reduction stages.

- Cache options keep their names, types, defaults, allowed values, and advanced/non-advanced status unless a
  separately approved compatibility change says otherwise.
- Static and shared library targets, executable targets, test targets, output names, prefixes, suffixes, version
  properties, debug postfixes, and output directories remain stable.
- Generated headers and sources keep their names, content semantics, generation order, and build/install
  locations.
- Public compile definitions, include directories, transitive link dependencies, and platform libraries remain
  equivalent for build-tree and install-tree consumers.
- Install components, destinations, runtime dependencies, RPATH behavior, package archives, DLL import libraries,
  PDB handling, and plugin locations remain stable.
- Export set names, imported target names, `HDF_PACKAGE_NAMESPACE`, `find_package(HDF5)` behavior, package version
  compatibility, build-tree package use, and pkg-config files remain stable.
- Standalone builds, `add_subdirectory()` integration, FetchContent integration, installed-package consumers, and
  the retained examples remain supported.
- C, high-level, C++, tools, utilities, tests, MPI, thread safety, compression filters, plugins, VOL connectors,
  ROS3, HDFS, and platform VFDs retain their existing valid option combinations.
- Java and Fortran remain removed. HDFS JNI discovery remains because libhdfs requires JNI.

Binary files do not need to be byte-for-byte identical. ABI, exported symbols, filenames, directory layout,
runtime behavior, and file-format behavior do need to remain compatible.

## Target Architecture

The root `CMakeLists.txt` becomes a thin coordinator. Project-wide responsibilities move, in reviewable steps,
to focused modules under `config/cmake/`:

- `HDF5Options.cmake` declares and validates user-facing options.
- `HDF5PlatformChecks.cmake` performs feature and platform detection.
- `HDF5Dependencies.cmake` discovers or provides external dependencies.
- `HDF5CompilerOptions.cmake` defines compiler, warning, optimization, and sanitizer requirements.
- `HDF5Testing.cmake` provides common CTest setup and test helpers.
- `HDF5Install.cmake` owns install directories, exports, and package configuration.
- `HDF5Packaging.cmake` owns CPack and source/binary package behavior.

Internal `INTERFACE` libraries carry target-scoped configuration while remaining absent from the installed public
API unless export correctness requires otherwise:

- `hdf5_build_options`
- `hdf5_warnings`
- `hdf5_assertions`
- `hdf5_platform`
- `hdf5_dependencies`
- `hdf5_sanitizers`

Existing public and internal product target names remain unchanged during the migration. Target variables such as
`HDF5_LIB_TARGET` are removed only after all consumers have migrated and a dedicated compatibility check proves
that doing so does not affect external subprojects. Static and shared libraries are not consolidated into an
object library in the initial migration because they can require different DLL definitions, position-independent
code, usage requirements, and link behavior.

## Atomic Commit Protocol

Each implementation commit follows these rules:

1. Address one build-system behavior or one narrowly bounded target family.
2. Avoid opportunistic formatting, source changes, and unrelated CMake cleanup.
3. Record the focused configure, build, test, install, or consumer checks run for that commit.
4. Keep compatibility shims only when a later identified commit removes them.
5. Pass `git diff --check` and at least one relevant CMake 4 configure before commit.
6. Leave generated build trees, install trees, logs, IDE metadata, and local contract snapshots untracked.
7. Use an imperative `cmake:` or `docs:` subject that describes the single migration step.

Commits are made directly as observable local checkpoints. A failed phase is corrected with a new focused commit
or reverted at its own commit boundary; completed unrelated phases are not rolled back with it.

## Implementation Sequence

### 1. Freeze the baseline

Capture normalized manifests for cache options, configured targets, artifacts, generated files, installed files,
exported targets, pkg-config metadata, and registered tests. Add repeatable contract-capture and comparison tools
before changing organization logic.

Use `config/cmake/scripts/HDF5BuildContract.cmake` to capture a local baseline. Contract files belong in an
ignored build tree, not in source control. Register the File API query before configuring:

```powershell
cmake "-DHDF5_CONTRACT_ACTION=QUERY" `
  "-DHDF5_CONTRACT_BUILD_DIR=build-msvc18" `
  -P config/cmake/scripts/HDF5BuildContract.cmake
cmake -S . -B build-msvc18 -G "Visual Studio 18 2026" -A x64
```

After building and installing, capture the baseline and compare a later capture with it:

```powershell
cmake "-DHDF5_CONTRACT_ACTION=CAPTURE" `
  "-DHDF5_CONTRACT_BUILD_DIR=build-msvc18" `
  "-DHDF5_CONTRACT_INSTALL_DIR=build-msvc18-install" `
  "-DHDF5_CONTRACT_CONFIG=Release" `
  "-DHDF5_CONTRACT_OUTPUT=build-msvc18/contracts/baseline.txt" `
  -P config/cmake/scripts/HDF5BuildContract.cmake
cmake "-DHDF5_CONTRACT_ACTION=COMPARE" `
  "-DHDF5_CONTRACT_BASELINE=build-msvc18/contracts/baseline.txt" `
  "-DHDF5_CONTRACT_CURRENT=build-msvc18/contracts/current.txt" `
  -P config/cmake/scripts/HDF5BuildContract.cmake
```

### 2. Establish CMake 4 correctness

Remove policy settings and version branches made unreachable by the 4.0 minimum. Replace removed APIs, including
the deprecated single-argument `FetchContent_Populate()` form, while preserving dependency population and
configuration order. Each policy/API family is a separate commit.

### 3. Introduce target-scoped infrastructure

Add the internal `INTERFACE` targets without changing consumers, then migrate one category of usage requirements
at a time: common definitions, include paths, platform libraries, warnings, optimization, and sanitizers. Compare
compile and link command semantics at each step.

### 4. Migrate product targets

Migrate the core `src/` static and shared targets first. Continue in separate commits for `hl/`, `c++/`, `tools/`,
and `utils/`. Tests and examples move only after the libraries they consume are stable.

### 5. Modernize dependencies

Move zlib, zlib-ng, libaec, MPI, threads, HDFS, CURL/ROS3, plugins, and VOL connectors to imported targets and
modern FetchContent flows. Preserve system-vs-bundled selection, offline/local archives, target aliases, package
exports, and install ownership.

### 6. Modernize testing and examples

Replace directory-global test configuration with target/test properties and shared helpers. Validate standalone
examples, build-tree examples, installed examples, MPI launch behavior, fixtures, resource locks, environment
modifications, and expected-failure tests.

### 7. Separate installation and packaging

Move install/export/package logic out of the root coordinator without changing its evaluated values. Validate the
install tree, CMake package, pkg-config files, wrapper scripts, CPack components, and package filenames.

### 8. Remove transitional machinery

Remove unused global flag mutations, obsolete helper macros, and target-name indirection only after all callers
have migrated. Update presets, CI, and user documentation to describe the final CMake 4 organization.

## Validation Matrix

Per-commit checks are selected according to the affected behavior. Milestone checks cover:

| Dimension | Required coverage |
| --- | --- |
| Library form | static only, shared only, static and shared |
| Components | C, HL, C++, tools, utilities, tests, examples |
| Toolchain | Windows x64/MSVC 18 with Visual Studio 18 2026; Linux x86_64/GCC and G++ with Ninja or Unix Makefiles |
| Configuration | Debug and Release |
| Concurrency | default serial, thread-safe, multi-thread concurrency, MPI |
| Dependencies | system and bundled zlib/libaec where available, plugins, VOL |
| VFD features | platform defaults and available ROS3/HDFS configurations |
| Consumption | build tree, install tree, `find_package`, pkg-config, FetchContent, `add_subdirectory` |
| Windows | DLL exports/import libraries, runtime placement, PDB handling |

The full MSVC 18 Release CTest suite is required before review and at major migration milestones. Optional feature
rows that cannot run locally must at least configure in an available matching environment and remain covered by CI.

## Completion Criteria

The modernization is complete when the root file is a coordinator, supported configuration is target-scoped,
obsolete pre-4.0 branches and policy workarounds are gone, all compatibility-contract comparisons pass, the full
validation matrix has recorded results, and no transitional helper remains without a documented owner and removal
phase.
