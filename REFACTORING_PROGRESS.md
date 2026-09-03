# Refactoring Progress

Last updated: 2026-09-03

This file is the root-level status entry point for the current CMake refactoring.
The detailed implementation ledger is
[`docs/CMakeModernizationProgress.md`](docs/CMakeModernizationProgress.md), and
the target architecture and compatibility contract are defined in
[`docs/CMakeModernization.md`](docs/CMakeModernization.md).

## Current Assessment

The project is CMake 4-ready, but the build organization is not yet fully
modernized.

- The minimum supported CMake version is 4.0.
- Baseline capture and CMake 4 correctness work are complete.
- Target-scoped build infrastructure and product, dependency, test, and example
  migrations are still in progress.
- Installation, export, packaging, and removal of transitional build machinery
  have not started as dedicated stages.

Accordingly, the current state must be described as "CMake 4.0 baseline
complete; build-system modernization in progress," not as a completed CMake
modernization.

## Stage Summary

| Stage | Status |
| --- | --- |
| Baseline contract | Complete |
| CMake 4 correctness | Complete |
| Target-scoped infrastructure | In progress |
| Product target migration | In progress |
| Dependency modernization | In progress |
| Test and example modernization | In progress |
| Installation and packaging separation | Not started |
| Transitional machinery removal | Not started |

The current detailed progress anchor is `0b9e21c34`, with 123 implementation
commits recorded after the modernization plan was accepted.

## Validation Boundary

MSVC 18 is the primary Windows validation toolchain. MinGW-w64 is used only as
a supplementary check for GNU compiler branches on Windows and does not count
as Linux/GCC validation.

The default MSVC 18 Release build and test suite has passed at
`HDF_TEST_EXPRESS=3`. Recent target-scoped MPI migrations also passed focused
MSVC Release builds and Microsoft MPI tests with no more than six MPI ranks.

Native Linux/GCC, Clang or clang-cl, NVHPC, Intel, broader optional dependency
matrices, installation/package contracts, and external consumer configurations
remain unverified or incomplete. These gaps prevent declaring the refactoring
complete.

## Completion Criteria

The modernization can be declared complete only after the remaining stages in
the detailed progress ledger are complete, transitional global state and
compatibility machinery have been removed where appropriate, supported build
and dependency matrices have been validated, and build-tree, install-tree, and
package consumers have passed their contract checks.

Update this file after each coherent refactoring batch whenever the overall
assessment, stage status, validation boundary, progress anchor, or completion
criteria changes.
