# CMake 4 Modernization Progress

This document records the implementation status of the
[CMake 4 modernization plan](CMakeModernization.md). The plan defines the
compatibility contract and target architecture; this file records what has
actually landed, what is being worked on, and what remains unverified.

## Current Snapshot

- Last updated: 2026-09-03
- Progress anchor: `7f0613c4f` (`cmake: Scope standalone example ANSI flags`)
- Implementation commits after the plan was accepted: 104
- Current stage: target-scoped build infrastructure and removal of remaining
  directory-global compiler and linker state
- Overall state: the baseline and CMake 4 correctness stages are complete;
  target-scoped infrastructure is well under way, but more than half of the
  full modernization scope remains because dependency, test, install, package,
  consumer, and matrix validation work is not complete

No C or C++ implementation change is part of this work. Existing options,
targets, generated products, install layout, and consumer-visible behavior
remain compatibility requirements. Java and Fortran remain unsupported, and
the JNI discovery required by the HDFS VFD remains in scope.

## Stage Status

| Stage | Status | Current result |
| --- | --- | --- |
| 1. Freeze the baseline | Complete | A repeatable File API contract snapshot and comparison tool is available. |
| 2. Establish CMake 4 correctness | Complete | The minimum is 4.0; unreachable version branches, removed APIs, invalid empty commands, and obsolete policy setup were addressed. |
| 3. Introduce target-scoped infrastructure | In progress | Internal configuration targets exist and most project targets receive compiler, platform, and instrumentation requirements through scoped helpers. Remaining global flag families are being migrated separately. |
| 4. Migrate product targets | In progress | Core, HL, C++, tools, utilities, and their tests have begun using scoped requirements. Full dependency and target-name migration is not complete. |
| 5. Modernize dependencies | In progress | Major discovery and validation blocks have named ownership, but all dependencies have not yet been converted to imported-target-only flows. |
| 6. Modernize testing and examples | In progress | Test and example targets use scoped build/platform hooks in several areas. CTest registration, fixtures, runners, and environment handling still need structural modernization. |
| 7. Separate installation and packaging | Not started | Install exports, package configuration, pkg-config, components, and CPack still require focused migration and contract checks. |
| 8. Remove transitional machinery | Not started | Compatibility helpers, target-name variables, remaining directory state, and root coordination logic stay until their consumers have migrated. |

Commit count is not a completion metric. Later stages cover wider configuration
matrices and external consumer contracts than the narrowly scoped commits in
the current stage.

## Completed Work

### Baseline and CMake 4 behavior

- Raised active project entry points, retained standalone examples, scripts,
  CI configuration, and documentation to a CMake 4.0 minimum.
- Added `config/cmake/scripts/HDF5BuildContract.cmake` to query the CMake File
  API and capture normalized cache, target, artifact, usage-requirement, test,
  generated-file, export, and install records.
- Replaced deprecated single-argument `FetchContent_Populate()` flows.
- Removed CMake-version branches that cannot be reached with a 4.0 minimum.
- Replaced invalid empty custom commands and removed obsolete policy setup.
- Set the required policy behavior for generated CTest scripts.

### Target-scoped build infrastructure

- Added internal `INTERFACE` targets for build options, warnings, assertions,
  platform requirements, dependencies, and sanitizer instrumentation.
- Kept those internal targets out of public install exports and contract noise.
- Added central helpers that apply requirements to a named target without
  changing its public link interface.
- Split C and C++ warning/build options by compile language and preserved their
  established ordering.
- Migrated compile options for core, HL, C++, tools, utilities, serial tests,
  parallel tests, API tests, performance tests, and related helper targets.

### Options and dependencies

- Centralized library naming, signed-plugin, subfiling, default API, map API,
  and `h5cc` options and their validation.
- Encapsulated thread-safe, concurrency, compression, and parallel-tool option
  validation without changing cache option names or defaults.
- Moved HDFS, signed-plugin, MPI, Threads, and subfiling discovery into the
  dependency module.
- Classified system, public, and compression dependencies and routed core and
  representative serial/parallel test targets through explicit ownership.
- Preserved JNI discovery for the HDFS VFD.

### Platform and instrumentation behavior

- Migrated Windows, GNU, CRT, assertion, plugin, zlib-ng, include-path, and
  executable-stack requirements to target ownership for the affected targets.
- Kept MSVC compile flags out of linker options where they did not previously
  belong, while preserving compiler-driver propagation where it was part of
  existing behavior.
- Migrated code coverage and sanitizer compile/link instrumentation to scoped
  targets while preserving generated build reports.
- Migrated standalone example include directories, platform definitions,
  diagnostic formatting, warning suppression, linkage definitions, MPI include
  paths, and documented ANSI flags to `hdf5_examples_platform`.

All implementation changes above were committed as independent checkpoints.
Each can be inspected or reverted with normal Git operations without replacing
the repository's CMake files as a single change.

## Active Work

The current batch removes the last clearly identified project-level global
compiler and linker mutations while preserving their exact compile and
compiler-driver link propagation. The remaining known groups are:

- `BUILD_STATIC_EXECS` static link behavior;
- the legacy code-coverage fallback in the root project;
- remaining GNU, Clang, NVHPC, and Intel compiler flag mutations;
- the clang-cl executable stack linker option;
- MPI linker flags in the main project; and
- MPI linker flags in the standalone examples.

Toolchain-file flags and temporary `CMAKE_REQUIRED_*` values used by feature
checks are audited separately. They are not automatically considered global
project-state defects because they may be the correct CMake ownership boundary.

## Remaining Work

- Finish the global-state audit and migrate each valid project requirement to
  a target-scoped compile, link, definition, or include property.
- Complete product-target dependency migration for core, HL, C++, tools,
  utilities, tests, and examples while retaining static/shared behavior.
- Convert supported external dependencies to consistent imported targets and
  modern FetchContent flows, including system, bundled, local, and offline use.
- Modernize CTest helpers, fixtures, resource locks, launchers, expected-failure
  tests, environment changes, MPI execution, and standalone example tests.
- Separate install, export, package configuration, pkg-config, runtime
  dependency, component, and CPack logic from the root coordinator.
- Validate build-tree and install-tree `find_package`, `add_subdirectory()`,
  FetchContent, pkg-config, and standalone-example consumers.
- Remove transitional helper functions, unused macros, target-name variables,
  and directory-global state only after every caller has migrated.
- Reduce the root `CMakeLists.txt` to option loading, platform/dependency setup,
  target orchestration, testing, installation, and packaging coordination.
- Update CI, presets, and user documentation for the final organization.

## Validation Status

Completed checks include repeated normalized contract comparisons, focused
MSVC and GNU configure/build probes, representative test execution, and
standalone example builds. Recent checkpoints specifically verified:

- unchanged default MSVC contract data across the scoped migrations;
- unchanged GNU coverage contract data;
- the same 219-target MSVC AddressSanitizer instrumentation set, with `h5dump`
  and `CPP_testhdf5` passing;
- equivalent GNU compile and compiler-driver link option sets across all 121
  standalone example targets for the latest flag migrations;
- preserved MSVC warning suppression for the existing C example targets; and
- successful representative GNU C, HL, C++, and C++ HL example runs.

Still required before review or declaration of completion:

- the full 2,854-test MSVC 18 Release CTest suite after the current milestone;
- static-only, shared-only, and combined-library configurations;
- Debug and Release coverage on MSVC, GCC, and Clang;
- thread-safe, multi-thread concurrency, and MPI configurations;
- system and bundled compression, plugins, VOL, ROS3, HDFS, and subfiling where
  the required environment is available;
- install/export/package artifact comparison; and
- external build-tree, install-tree, FetchContent, `add_subdirectory()`, and
  pkg-config consumer validation.

Passing a focused contract comparison does not mark an untested matrix row as
complete.

## Update Rules

Update this file after each coherent batch of atomic commits, not after every
single commit. Each update must:

1. advance the progress anchor to an existing commit;
2. move work between active, completed, and remaining sections based on landed
   behavior rather than intent;
3. record material validation performed and retain explicit gaps;
4. avoid local absolute paths, transient build-directory names, timing data,
   and generated logs; and
5. remain a documentation-only atomic commit.
