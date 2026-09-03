# Refactoring Progress

Last updated: 2026-09-03

## Purpose

This file is the portable handoff for the active refactoring direction. It
records what is already complete, what remains, where work should resume, and
which validation is still missing so the refactoring can continue on another
machine without reconstructing its state from chat history or local build
artifacts.

The detailed implementation plan for the current direction is
[`docs/refactoring/CMakePlatformSupportReduction.md`](docs/refactoring/CMakePlatformSupportReduction.md).
It intentionally changes the compatibility contract by reducing the CMake
matrix to Windows/MSVC and Linux/GCC. The underlying target architecture and
the paused behavior-preserving modernization state remain recorded in
[`docs/CMakeModernization.md`](docs/CMakeModernization.md) and
[`docs/CMakeModernizationProgress.md`](docs/CMakeModernizationProgress.md).

## Active Direction

- Direction: CMake supported-platform reduction
- Status: In progress; support contract approved and Phase 1 is next
- Planning anchor: `c70273f0c`
- Behavior implementation anchor: none
- Behavior implementation commits after support-contract approval: 0

The CMake build now supports Windows x64 with MSVC 18 and the Visual Studio 18
2026 generator, plus Linux x86_64 with GCC/G++ and Ninja or Unix Makefiles.
The platform gate and compatibility-code removals have not landed yet, so the
source still contains unsupported paths that must not be mistaken for support.

## Completed

- Approved the Windows/MSVC and Linux/GCC support contract and documented the
  unsupported platform, compiler, and generator combinations.
- Fixed the deferred Linux validation baseline at Ubuntu 24.04 LTS x86_64,
  CMake 4.0.3, GCC/G++ 13.3.0, and Ninja 1.11.1, with a separate Unix
  Makefiles configure/build check.
- Declared Visual Studio 18 2026 as the only supported Windows generator;
  Ninja with MSVC is outside the supported matrix.

The completed CMake 4 modernization foundation remains available at
implementation anchor `0b9e21c34` and is detailed in
`docs/CMakeModernizationProgress.md`. In summary, that work:

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

- Add and test one central platform/compiler/generator validation module for
  the root project and retained standalone examples.
- Remove MinGW/MSYS2 toolchains, presets, workflows, private cache options,
  active CMake branches, and current documentation in bounded commits.
- Remove other unsupported compiler and operating-system dispatch without
  disturbing shared Linux/GCC behavior.
- Review source-level MinGW guards separately, especially installed public
  headers.
- Complete the required Windows/MSVC build, test, install, package, and
  consumer matrix.
- Run the deferred native Linux/GCC matrix on the pinned baseline before
  declaring the direction complete.
- Resume the remaining target-scoped modernization work only after this
  compatibility-changing direction reaches a stable handoff point.

## Continuation Point

Implement Phase 1 from
`docs/refactoring/CMakePlatformSupportReduction.md`: add one reusable module
under `config/cmake/` that validates C after root-project language detection
and validates C++ when enabled. Apply it to retained standalone entry points,
add script-level negative-policy tests, and prove the default MSVC configure
contract is unchanged apart from the policy itself. Do not delete MinGW paths
in the same commit.

## Validation State

- Retained locally available toolchain: MSVC 18 on Windows x64 with the Visual
  Studio 18 2026 generator.
- Complete default MSVC result: 2,817 enabled tests passed and 37 configured
  tests remained disabled at `HDF_TEST_EXPRESS=3`.
- Latest MPI target-include batches: affected Visual Studio projects remained
  byte-identical, affected targets built successfully, and focused Microsoft
  MPI tests passed with no more than six MPI ranks.
- Historical MinGW-w64 results are baseline evidence only; MinGW is now outside
  the support contract and cannot substitute for native Linux/GCC validation.
- Unavailable or incomplete retained coverage: native Linux/GCC, broader
  optional dependencies, installation and package contracts, and external
  consumer configurations.

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
