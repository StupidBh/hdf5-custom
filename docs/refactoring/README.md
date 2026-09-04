# Refactoring Plans

This directory contains detailed execution plans for individual refactoring
directions that intentionally change repository organization, compatibility,
or supported behavior.

Each plan must define its scope, compatibility impact, ordered implementation
phases, validation gates, deferred work, and completion criteria. A plan may be
`Proposed`, `In progress`, `Blocked`, or `Complete`. Creating a plan does not
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
  proposed execution plan for removing unsupported-only source compatibility
  while preserving API, ABI, file-format, and retained-pair behavior.
