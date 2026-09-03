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
  reduce the supported CMake build matrix to Windows/MSVC and Linux/GCC.
