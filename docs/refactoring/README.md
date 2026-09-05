# Refactoring Plans

This directory contains detailed execution plans for individual refactoring
directions that intentionally change repository organization, compatibility,
or supported behavior.

Each plan must define its scope, compatibility impact, ordered implementation
phases, validation gates, deferred work, and completion criteria. A plan may be
`Proposed`, `Approved`, `In progress`, `Blocked`, or `Complete`. Creating a plan does not
make it active and does not authorize skipping its validation gates.

The root-level [`REFACTORING_PROGRESS.md`](../../REFACTORING_PROGRESS.md) is the
portable continuation record. It identifies the active or planned direction,
summarizes completed and remaining work, and points to the relevant detailed
plan in this directory.

## Plans

- [CMake supported platform reduction](CMakePlatformSupportReduction.md):
  reduce the supported project implementation to Windows/MSVC and Linux/GCC
  through staged CMake and source/header work.
- [Stage 2 native Linux/GCC validation](CMakePlatformSupportReductionStage2.md):
  validate the reduced CMake layer on the retained Linux/GCC baseline; complete.
- [Stage 2 validation results](CMakePlatformSupportReductionStage2Results.md):
  record the completed core, optional, deferred, and cross-platform evidence.
- [Stage 3 source/header reduction](CMakePlatformSupportReductionStage3.md):
  Completed; source compatibility reduction with the accepted Linux plugin
  filename restriction and preserved API, ABI, and file-format behavior.
- [Stage 3 validation results](CMakePlatformSupportReductionStage3Results.md):
  record the completed dual-platform gate, corrected header evidence, and
  accepted completion review on 2026-09-05.
- [Stage 4 final project audit](CMakePlatformSupportReductionStage4.md):
  Approved, execution not started; repository/product support consistency, focused defect repairs,
  evidence inheritance, final dual-platform gates, and modernization handoff.

The Stage 4 plan and review clarifications were approved on 2026-09-05.
Work Package 4A is the next execution action. Prefer CLion MCP and limit
build/CTest parallelism to four per physical host, shared by Windows and WSL
on that host. Execution has not started; Stage 3 completion does not complete
the overall direction.
