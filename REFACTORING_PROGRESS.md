# Refactoring Progress

Last updated: 2026-09-03

## Purpose

This file is the portable handoff for the active refactoring direction. It
records what is already complete, what remains, where work should resume, and
which validation is still missing so the refactoring can continue on another
machine without reconstructing its state from chat history or local build
artifacts.

The detailed implementation plan for the current direction is
[`docs/CMakeModernizationProgress.md`](docs/CMakeModernizationProgress.md). The
target architecture and compatibility contract are defined in
[`docs/CMakeModernization.md`](docs/CMakeModernization.md).

## Active Direction

- Direction: CMake 4 build-system modernization
- Status: In progress
- Implementation anchor: `0b9e21c34`
- Implementation commits after plan acceptance: 123

The project is CMake 4-ready, but its complete build organization is not yet
modernized. The correct current description is "CMake 4.0 baseline complete;
build-system modernization in progress."

## Completed

- Raised active project entry points and retained standalone examples and
  scripts to a CMake 4.0 minimum.
- Completed the repeatable CMake File API baseline and the CMake 4 correctness
  work, including removed APIs, unreachable version branches, invalid empty
  commands, and obsolete policy setup.
- Added internal target-scoped build, warning, assertion, platform, dependency,
  and sanitizer infrastructure without exporting the internal targets.
- Migrated broad core, high-level, C++, tool, utility, test, performance, and
  example target families to scoped compile, platform, and instrumentation
  requirements.
- Centralized major build options and moved HDFS, signed-plugin, MPI, Threads,
  and subfiling discovery into the dependency module.
- Routed MPI include requirements through `MPI::MPI_C` for the completed
  supported C batches covering core, high-level, tool, utility, serial-test,
  and parallel-test libraries and executables.
- Preserved the supported product surface, option names, generated products,
  installation layout, and consumer-visible behavior in the completed batches.

## Remaining

- Finish classifying the remaining global compiler flag mutations. Preserve
  toolchain-owned flags, temporary feature-check state, and build-type state;
  migrate only genuine target requirements.
- Complete product dependency and target-name migration for the remaining core,
  high-level, C++, tool, utility, test, and example paths.
- Convert supported external dependencies to consistent imported-target and
  modern FetchContent flows for system, bundled, local, and offline use.
- Modernize CTest helpers, fixtures, resource locks, launchers,
  expected-failure handling, environment setup, MPI execution, and standalone
  example tests.
- Separate install, export, package configuration, pkg-config, runtime
  dependency, component, and CPack logic from the root coordinator.
- Validate build-tree and install-tree `find_package`, `add_subdirectory()`,
  FetchContent, pkg-config, and standalone-example consumers.
- Remove transitional helpers, unused macros, target-name variables, and
  remaining directory-global state after all callers have migrated.
- Reduce the root `CMakeLists.txt` to option loading, platform and dependency
  setup, target orchestration, testing, installation, and packaging
  coordination.

## Continuation Point

Resume from implementation anchor `0b9e21c34`; do not repeat the completed MPI
target-include batches. The next dependency pass should re-audit the remaining
direct `MPI_C_INCLUDE_DIRS` uses and classify them before editing:

- consumer-facing compatibility variables and package configuration;
- standalone C and C++ examples;
- targets gated by unavailable OpenSSL, mirror VFD, MFU, or CIRCLE
  prerequisites; and
- the unsupported C++ plus parallel combination, which requires
  `HDF5_ALLOW_UNSUPPORTED=ON` and is not a supported validation row.

For each selected batch, capture a generated-build baseline first, make one
scoped change, compare the affected target contracts or generated project
files, build the affected targets, run the narrowest relevant CTest set, and
commit the implementation atomically. Update this handoff only after a coherent
batch, not after every individual commit.

## Validation State

- Primary validated toolchain: MSVC 18 on Windows, Release configuration.
- Complete default MSVC result: 2,817 enabled tests passed and 37 configured
  tests remained disabled at `HDF_TEST_EXPRESS=3`.
- Latest MPI target-include batches: affected Visual Studio projects remained
  byte-identical, affected targets built successfully, and focused Microsoft
  MPI tests passed with no more than six MPI ranks.
- Supplementary coverage: MinGW-w64 exercises GNU branches on Windows only. It
  is neither the primary Windows validation nor Linux/GCC validation.
- Unavailable or incomplete coverage: native Linux/GCC, Clang or clang-cl,
  NVHPC, Intel, broader optional dependencies, installation and package
  contracts, and external consumer configurations.

When continuing on a machine that provides a missing toolchain or dependency,
use it to close the corresponding validation gap and record the exact supported
configuration and result here.

## Handoff Updates

After each coherent refactoring batch:

1. Move completed work out of `Remaining` and summarize it under `Completed`.
2. Set `Implementation anchor` to the newest implementation commit and update
   the implementation commit count.
3. Record newly completed validation and retain every unresolved matrix gap.
4. Update `Continuation Point` so another machine can start with a concrete,
   non-duplicative next action.
5. Do not include absolute local paths, transient build-directory names, local
   logs, or other machine-specific state.
