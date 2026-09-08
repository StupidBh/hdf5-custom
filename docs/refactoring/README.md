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

- [Stage 5 core C17 internal modernization](CoreC17Modernization.md):
  Proposed multi-round plan; each round preserves all installed headers,
  API/ABI, the fixed HighFive C dependency inventory and file behavior. System
  compression requires full suites with test-inventory reconciliation: Windows
  uses supplied dependency forms and Linux covers all four HDF5/compression
  shared/static combinations. MPI/thread
  extensions are secondary with explicit coverage limits. Implementation has not started.
  Maximum build/CTest parallelism is six per host; Windows dependencies come
  from `3rdparty`, and Linux dependencies are obtained through WSL.

- [HighFive HDF5 API dependency audit](HighFiveHDF5ApiDependencyAudit.md):
  Complete snapshot audit; records the 147 HDF5 C function dependencies,
  public-header and feature dependencies, and the absence of native C++ and HL
  dependencies. The audited headers are tracked as repository input but remain
  outside the HDF5 build, install, export, and binary-package products.
- [Roadmap Stage 4 native C++ and HL product removal](NativeCppHlRemoval.md):
  Complete; physically removed `c++/`, complete `hl/`, and their build, test,
  install, export, package, wrapper, tool, example, and documentation
  contracts while preserving the retained core C product and the two required
  business profiles.
- [Roadmap Stage 4 execution results](NativeCppHlRemovalResults.md):
  Work Package 4A baseline, contract-freeze, implementation, validation, and
  closeout evidence for the native C++ and HL product removal.
- [Phase 2 C17 and C++20 build baseline](C17Cpp20BuildBaseline.md):
  Complete; project-owned core, HL, opt-in C++, tools, tests, plugins, and
  examples build as C17/C++20, demonstrated blockers are repaired, third-party
  implementations remain isolated, and the final matrix respected the
  four-job limit.
- [Phase 2 C17 and C++20 execution results](C17Cpp20BuildBaselineResults.md):
  completed validator qualification, capability discovery, baseline evidence,
  findings, implementation anchors, optional dispositions, and final product
  validation.
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
incomplete and paused at its existing anchor. The Phase 2 language-build
direction is complete at implementation `c38e58ed8`; it has no remaining
implementation, validation, or decision gate.

The native C++ and HL product removal was approved on 2026-09-06 and completed
on 2026-09-08. Its numbering is independent of the completed Stage 4 audit
within the supported-platform reduction plan. The former C++20 internal-
modernization plan was abandoned and deleted before implementation. A new
bounded core C17 modernization direction is proposed as roadmap Stage 5 on
2026-09-08; its implementation and validation have not started. Stages 6 and 7
remain future plan to be determined. HighFive remains an external product whose
public C interface needs constrain compatibility, not an implementation target.
