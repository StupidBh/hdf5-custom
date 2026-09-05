# CMake 4 Modernization Progress

This document records the implementation status of the
[CMake 4 modernization plan](CMakeModernization.md). The plan defines the
compatibility contract and target architecture; this file records what has
actually landed, what is being worked on, and what remains unverified.

## Current Snapshot

- Last updated: 2026-09-05
- Progress anchor: `0b9e21c34` (`cmake: Use MPI target includes for parallel tests`)
- Implementation commits after the plan was accepted: 123
- Current stage: paused at the target-scoped build infrastructure milestone;
  the platform-reduction handoff is complete and this work is ready to resume
- Overall state: the baseline and CMake 4 correctness stages are complete;
  target-scoped infrastructure is well under way, but more than half of the
  full modernization scope remains because dependency, test, install, package,
  consumer, and matrix validation work is not complete

No C or C++ implementation change is part of this work. Existing options,
targets, generated products, install layout, and consumer-visible behavior
remain compatibility requirements except where the separately approved
[project supported-platform reduction](refactoring/CMakePlatformSupportReduction.md)
first removes unsupported CMake toolchains and private options, then removes
source-level compatibility paths that exist only for rejected environments.
The retained target-system/compiler pairs are Windows/MSVC and Linux/GCC.
Generator, architecture, and exact compiler version are not central-firewall
inputs; Windows x64/MSVC 18 and Linux x86_64/GCC remain the release-validation
baselines. Java and Fortran remain unsupported, and the JNI discovery required
by the HDFS VFD remains in scope.

The platform-reduction support contract is anchored at `912fb436b`, its Stage 1
CMake implementation at `b317dedc9`, and its Stage 3 source implementation at
`74288cbaa`. Stages 1 through 4 are complete. The Stage 3 completion review was
accepted on 2026-09-05, and the separate
[Stage 4 plan](refactoring/CMakePlatformSupportReductionStage4.md) completed all
work packages that day at product implementation `f6ff66fed`. Its fresh
baselines, focused corrections, final product/consumer matrix, residual audit,
and stable handoff are recorded in the
[Stage 4 results](refactoring/CMakePlatformSupportReductionStage4Results.md). The
[Stage 3 results](refactoring/CMakePlatformSupportReductionStage3Results.md)
record the accepted Linux plugin filename restriction and the corrected
header comparison: expected text changes preserve effective declarations,
rather than leaving installed files byte-identical. This does not advance
the paused modernization work recorded below.

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
- Routed MPI include requirements for core, high-level, tool, utility, serial
  test, and parallel test libraries and executables through `MPI::MPI_C`
  instead of repeated path expressions.
- Preserved JNI discovery for the HDFS VFD.

### Platform and instrumentation behavior

- Migrated Windows, GNU, Clang, NVHPC, Intel, CRT, assertion, plugin, zlib-ng,
  include-path, and executable-stack requirements to target ownership for the
  affected targets.
- Kept MSVC compile flags out of linker options where they did not previously
  belong, while preserving compiler-driver propagation where it was part of
  existing behavior.
- Migrated code coverage and sanitizer compile/link instrumentation to scoped
  targets while preserving generated build reports.
- Migrated standalone example include directories, platform definitions,
  diagnostic formatting, warning suppression, linkage definitions, MPI include
  paths, and documented ANSI flags to `hdf5_examples_platform`.
- Migrated static-executable, legacy coverage, clang-cl executable-stack, and
  MPI link requirements away from project-level linker flag variables while
  preserving their established target sets and propagation behavior.

All implementation changes above were committed as independent checkpoints.
Each can be inspected or reverted with normal Git operations without replacing
the repository's CMake files as a single change.

## Active Work

Modernization implementation remains paused at the recorded anchor; the
platform-reduction direction has now reached its stable handoff, so this is the
next direction to resume. At the pause point, the project-level linker flag
batch was complete and the follow-on audit had classified the remaining flag
writes:

- the 32-bit toolchain files own architecture and linker search flags at the
  toolchain boundary;
- `CMAKE_REQUIRED_*` values and the saved/restored `CMAKE_C_FLAGS` values in
  feature checks are temporary probe state;
- custom `Developer` configuration flags define a build type rather than a
  project-wide target requirement; and
- the remaining C and C++ compiler flag mutations preserve user flag cleanup,
  warning suppression, legacy compiler initialization, and generated build
  reports. They require dedicated compatibility work and compiler-specific
  validation rather than mechanical removal.

The paused dependency work removes repeated MPI include expressions from
targets that already consume `MPI::MPI_C`. The supported C target batches for
core, high-level, tools, utilities, serial tests, and parallel tests are
complete. Remaining expressions need separate classification because they
belong to standalone examples, package configuration, dependency-specific
targets whose prerequisites are unavailable, or C++ targets. In particular,
parallel HDF5 and the C++ library are mutually exclusive unless
`HDF5_ALLOW_UNSUPPORTED` is enabled, so C++ MPI cleanup is not being validated
as a supported matrix row.

Resume by classifying the remaining MPI include expressions owned by
standalone examples, package configuration, dependency-specific targets, and
C++ targets. Then continue the dedicated compatibility work for the remaining
global C/C++ compiler-flag mutations. Keep the progress anchor at `0b9e21c34`
until the first new modernization implementation batch lands.

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
MSVC and Windows GNU configure/build probes, representative test execution,
and standalone example builds. Recent checkpoints specifically verified:

- all 17,560 records in the default MSVC contract remained unchanged across
  the scoped migrations;
- MinGW-w64 GCC and G++ 13.2 preserved the compile argument multisets of all 27
  affected targets and the exact `libhdf5.settings` SHA-256 value; `h5dump` and
  `hdf5_cpp-shared` built successfully, and `h5dump -V` reported version 2.3.0;
- the same 219-target MSVC AddressSanitizer instrumentation set, with `h5dump`
  and `CPP_testhdf5` passing;
- equivalent GNU compile and compiler-driver link option sets across all 121
  standalone example targets for the latest flag migrations;
- preserved MSVC warning suppression for the existing C example targets;
- successful representative GNU C, HL, C++, and C++ HL example runs;
- Microsoft MPI linker flag propagation for 19 executable and three shared
  library projects in every Visual Studio configuration, followed by a
  successful Release build, link, and run of `h5dump`;
- equivalent linker argument multisets for all 85 standalone example
  executables with Microsoft MPI, followed by a successful Release build of
  `ex_h5ex_d_alloc`;
- unchanged Microsoft MPI contracts across the imported-target include
  migrations: 1,295 core records, 1,409 high-level records, 2,176 tools
  records, and 8,212 serial-test records, followed by successful Release
  builds of each affected static and shared library;
- byte-identical generated Visual Studio projects after removing repeated MPI
  include expressions from 18 tool executable projects, 14 high-level
  executable and test projects, one utility test project, 36 tool-test
  projects, 142 core-test projects, and 21 parallel-test projects. Those
  projects retained 144, 112, 8, 288, 1,136, and 168 Microsoft MPI include
  records respectively through target propagation;
- successful MSVC 18 Release builds of all targets in those six batches except
  the OpenSSL-dependent signed-plugin targets, whose prerequisite is
  unavailable. Focused execution passed all 11 high-level tests, all three
  H5IMPORT fixture tests, all six selected H5COPY tests, all nine core API
  version tests, and all five selected parallel MPI tests and fixtures with a
  maximum of six MPI ranks; and
- a complete default MSVC 18 Release build and CTest run at
  `HDF_TEST_EXPRESS=3`: all 2,817 enabled tests passed and 37 configured tests
  remained disabled out of 2,854 registered tests.

The intervening platform-reduction Stage 1 validation established that all 12
firewall cases, root and standalone-example preset listing, default and
C++-enabled MSVC configurations, a 17,323-record no-delta File API comparison,
and clean source-package generation pass. Formatting commit `b22b55872` had
removed four `HDONE_ERROR(...)` statement terminators, but source repair
`a68b4cae4e` restored them before the current `HEAD`; the earlier blocker record
was stale. Stage 1 is now complete on Windows/MSVC. Fresh default combined,
static-only, shared-only, and Debug builds pass. The default full CTest run at
`HDF_TEST_EXPRESS=3` passes 2,816 enabled tests with 37 disabled out of 2,853
registered; the C++-enabled combined Release build passes 2,851 enabled tests
with 37 disabled out of 2,888 registered. Release and Debug installation,
static/shared exports, PDB placement, and a 164-entry CPack ZIP pass. Standalone
C, C++, and high-level examples pass 279 tests against both build-tree and
install-tree packages, and minimal `add_subdirectory()` and FetchContent
consumers build and run. All builds and tests use at most six parallel jobs.
Fresh thread-safe and multi-thread concurrency configurations each pass their
focused three-test fixture group. A vcpkg-exported Microsoft MPI SDK and the
installed runtime support a complete parallel Release build and a nine-test
focused MPI selection. Perl `5.42.3` is found after refreshing the process
environment.

At the Stage 1 checkpoint, optional environment gaps were pkg-config, system
zlib/libaec, external HDF5 filter plugins, `aws-c-s3`, JDK/JNI plus Hadoop/libhdfs, OpenSSL,
mpiFileUtils/libcircle/DTCMP, and NSIS or WiX. Bundled zlib/libaec generation
also exposed an export-set defect, subsequently fixed at `81e96c889` with
Linux/GCC and Windows/MSVC consumer validation. The
[Stage 2 results](refactoring/CMakePlatformSupportReductionStage2Results.md)
supersede that checkpoint's open-failure status and record passing Linux
pkg-config/wrappers, system/bundled compression, and available optional rows.
The six accepted Linux environment deferrals and Windows-specific gaps retain
their recorded scope; Linux validation does not close Windows-only gaps.
Affected rows still require repetition after modernization changes them.

This evidence freezes the current install, package, and consumer behavior for
the paused modernization. It does not complete modernization stages 7 and 8;
those checks must be repeated after their implementation changes.

MSVC 18 is the retained Windows validation toolchain. The earlier MinGW-w64
results are historical baseline evidence only; MinGW is no longer a supported
way to exercise GNU branches on Windows and those results do not constitute
Linux/GCC validation. Native Linux/GCC validators and passing evidence were
established by Stages 2 and 3; future execution must requalify its environment.
Clang, clang-cl, NVHPC, and Intel are outside the reduced
support matrix and are no longer validation gaps.

The CMake File API does not expose the additional target-level `LINK_FLAGS`
copy used to preserve historical MPI executable propagation. That check used
the generated Visual Studio projects and an actual link instead of relying on
the normalized File API contract alone.

The platform-reduction Stage 4 final audit and stable handoff are complete.
Still required before review or declaration of modernization completion:

- static-only, shared-only, combined-library, Debug, and Release coverage on
  GCC, plus repetition of the Windows rows after affected modernization work;
- repeat native Linux/GCC contract coverage after affected modernization work;
- repeat thread-safe and multi-thread concurrency configurations, and run a
  broader MPI matrix, after affected modernization changes;
- system and bundled compression, plugins, VOL, ROS3, HDFS, and subfiling after
  their modernization changes and where the required environment is available;
- install/export/package artifact comparison after those modernization stages
  change the implementation; and
- repeat external build-tree, install-tree, FetchContent, `add_subdirectory()`,
  and pkg-config consumer validation after affected changes. Linux pkg-config
  and wrappers have passing Stage 2/3 evidence; Windows availability remains a
  separate prerequisite check.

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
