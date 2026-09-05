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

- [Phase 2 C17 and C++20 build baseline](C17Cpp20BuildBaseline.md):
  Proposed; raise project-owned build modes to C17/C++20, repair only
  demonstrated blockers, preserve C99/C++11 installed-header compatibility,
  and validate both retained compiler pairs with at most four active jobs.
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
  Complete; repository/product support consistency, focused defect repairs,
  evidence inheritance, final dual-platform gates, and modernization handoff.
- [Stage 4 execution results](CMakePlatformSupportReductionStage4Results.md):
  completed Work Packages 4A through 4F, final product/consumer matrix,
  residual/package audit, optional evidence limits, and handoff.

The Stage 4 plan and review clarifications were approved on 2026-09-05, and all
work packages completed that day at product implementation `f6ff66fed`. The
overall supported-platform reduction direction is complete. Its four-job
build/CTest limit was temporary for that execution and is not a permanent
default or validation reference. The separate CMake modernization remains
incomplete at its existing anchor. The proposed Phase 2 language-build plan is
the current design continuation; creating it does not authorize implementation.
