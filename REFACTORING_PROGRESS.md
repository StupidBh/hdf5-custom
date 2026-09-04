# Refactoring Progress

Last updated: 2026-09-04

## Purpose

This file is the portable handoff for the active refactoring direction. It
records what is already complete, what remains, where work should resume, and
which validation is still missing so the refactoring can continue on another
machine without reconstructing its state from chat history or local build
artifacts.

The detailed implementation plan for the current direction is
[`docs/refactoring/CMakePlatformSupportReduction.md`](docs/refactoring/CMakePlatformSupportReduction.md).
The self-contained execution plan for the completed Linux validation stage is
[`docs/refactoring/CMakePlatformSupportReductionStage2.md`](docs/refactoring/CMakePlatformSupportReductionStage2.md).
Its portable execution record is
[`docs/refactoring/CMakePlatformSupportReductionStage2Results.md`](docs/refactoring/CMakePlatformSupportReductionStage2Results.md).
The active self-contained Stage 3 source/header reduction plan is
[`docs/refactoring/CMakePlatformSupportReductionStage3.md`](docs/refactoring/CMakePlatformSupportReductionStage3.md).
Its in-progress execution record is
[`docs/refactoring/CMakePlatformSupportReductionStage3Results.md`](docs/refactoring/CMakePlatformSupportReductionStage3Results.md).
It intentionally changes the compatibility contract by first reducing the
CMake matrix and then removing source-level support outside Windows/MSVC and
Linux/GCC. The underlying target architecture and the paused
behavior-preserving modernization state remain recorded in
[`docs/CMakeModernization.md`](docs/CMakeModernization.md) and
[`docs/CMakeModernizationProgress.md`](docs/CMakeModernizationProgress.md).

## Active Direction

- Direction: Project supported-platform reduction
- Status: Stage 1 and Stage 2 complete; Stage 3 Work Package 3B in progress.
- Original support-contract anchor: `912fb436b`
- Admission-policy correction anchor: `614dd74c0`
- CMake implementation anchor: `b317dedc9`
- Stage 1 source compilation repair anchor: `a68b4cae4e`
- Stage 2 C11 literal repair anchor: `6ee2f392e`
- Coverage documentation correction anchor: `d39cd5fa0`
- Stage 3 plan anchor: `31cf74435`
- Current implementation anchor: `81e96c889`
- Last preceding documentation anchor: `31cf74435`
- Stage 1 CMake implementation commits: 19
- Stage 1 completion state: complete
- Stage 2 execution scope: complete; core gate, bundled compression, system
  compression, and coverage passed; six non-required optional rows were
  explicitly deferred by the user
- Stage 3 execution state: approved; Work Package 3A baseline and inventory
  complete, with Work Package 3B compiler reduction next
- Later-stage detailed planning: Stage 4 remains unplanned

The approved endpoint accepts two target-system/compiler pairs: Windows with
compiler ID `MSVC`, and Linux with compiler ID `GNU`. Generator, architecture,
and exact compiler release are validation dimensions rather than central
firewall inputs. The release-qualified baselines remain Windows x64 with MSVC
and a Visual Studio generator, plus Linux x86_64 with GCC/G++ and Ninja, with a
focused Unix Makefiles check. The CMake firewall and unsupported CMake-path
reduction have landed, the over-constrained admission policy is corrected, and
the required Windows/MSVC Stage 1 validation gate has passed. The Stage 2
Linux/GCC core gate and the bundled- and system-compression rows pass, and all
optional rows supported by the supplied validator environment have run. Stage
2 is complete after the user explicitly deferred the six unavailable optional
configurations as non-required. The Stage 3 source/header reduction plan is
approved and Work Package 3A is complete; source/header edits have not started,
and the Stage 4 final audit remains unplanned.

## Completed

- Approved the Windows/MSVC and Linux/GCC support contract and documented the
  unsupported target-system/compiler combinations.
- Defined the Linux validation baseline as Linux x86_64 with GCC/G++ and Ninja,
  with a separate Unix Makefiles configure/build check; exact validator versions
  are result evidence rather than baseline requirements.
- Retained a Visual Studio generator and Linux Ninja/Unix Makefiles as validation
  baselines without using generator or architecture as a configure-time gate.
- Defined source-level removal as a required follow-on stage rather than an
  optional review after CMake reduction.
- Added one central target-system/compiler firewall for the root build and
  retained standalone C and C++ example entry points.
- Corrected the firewall so IDE-managed profiles, Ninja with MSVC, an omitted
  `-A` argument, and non-baseline architectures are not rejected solely for
  their generator or architecture.
- Re-audited the architecture-dependent CMake behavior removed under the
  original x64-only policy. Restored MSVC ARM64 Debug flags, ARM64 package
  naming, and 32-bit NSIS install-root handling. Architecture-specific presets,
  CI, dashboard selections, and bundled cross-toolchain helpers remain outside
  the release-validation surface without becoming firewall inputs.
- Removed unsupported toolchains, presets, dashboard choices, CI build jobs,
  cache options, platform conditions, compiler dispatch, sanitizer presets,
  packaging branches, and residual active CMake paths in 19 focused commits.
- Updated current installation, option, example, preset, sanitizer, package,
  and consumer documentation to distinguish the retained compiler pairs from
  the narrower release-validation matrix.
- Kept Stage 1 out of C/C++ implementation files and headers. Their remaining
  compatibility references are classified for mandatory Stage 3 work.
- Completed Work Package 1G on the retained Windows/MSVC baseline: default,
  static-only, shared-only, Debug, C++, full CTest, install, binary package,
  standalone example, and external-consumer rows all passed.
- Approved a self-contained Stage 2 execution plan with a fixed Linux/GCC core
  gate, read-only optional-capability discovery, validation of every available
  optional row, and explicit user decisions for missing prerequisites.
- Required every repository modification during plan execution to land as an
  atomic, independently revertible local commit after its checks pass; pure
  validation produces no commit, while portable evidence uses focused `docs:`
  checkpoints.
- Qualified an Ubuntu 26.04.1 x86_64 WSL2 validator with GCC/G++ 15.2.0,
  CMake/CTest 4.2.3, Ninja 1.13.2, GNU Make 4.4.1, and native GNU target
  triples.
- Repaired pre-Stage-1 C++ integer separators left in C sources, then passed
  every fixed Stage 2 core row: full default Release CTest, Debug, static-only,
  shared-only, C++, Unix Makefiles, examples, consumers, install, TGZ package,
  and normalized contract comparison.
- Passed available parallel, subfiling, thread-safe, concurrency, external
  plugin, STGZ, and DEB optional rows. A fresh Windows/MSVC default Release
  build and the matching seven-test smoke selection also passed after the C11
  repair.
- Corrected the compiler-wrapper contract to the intentionally consolidated
  `h5cc` and `h5c++` interface and marked its fully exercised Stage 2 row as
  passed.
- Repaired the Stage 1 bundled-compression export regression. Fetched zlib and
  libaec targets are now available to build-tree package consumers, bundled
  plugins reuse HDF5's zlib without target or archive collisions, and static
  and shared build/install consumers pass on Linux/GCC. The retained preset,
  focused compression tests, TGZ package, and fresh Windows/MSVC static path
  also pass.
- Corrected the Stage 1 GCC coverage documentation to match the implemented
  contract: target instrumentation, generated GCC counter data, and the
  `ccov-clean` reset target are supported; report generation is external. The
  validated coverage row now passes.
- Passed the system-compression row with Ubuntu zlib 1.3.1 and libaec 1.1.5
  development packages staged in an isolated external prefix. The full build,
  29 focused tests, install metadata, and static/shared consumers against both
  package locations passed without a FetchContent dependency build.
- Recorded the user's decision to defer the six unavailable optional
  configurations because they are not required, satisfying the last Stage 2
  exit gate.
- Recorded the exact Stage 2 evidence, deferred prerequisites, and continuation
  point in the portable results document.
- Drafted the self-contained Stage 3 source/header reduction plan with
  compatibility protections, atomic commit boundaries, dual-platform gates,
  stop conditions, and explicit exit criteria.
- Approved the Stage 3 plan and fixed its maximum build and CTest parallelism
  at four jobs.
- Qualified fresh Windows/MSVC and WSL Linux/GCC validators at the same tracked
  Stage 3 baseline, then captured default and C++ builds, focused tests,
  installs, package manifests, normalized contracts, installed-header hashes,
  and C/C++ exported-symbol baselines.
- Regenerated the tracked source/header inventory and resolved every candidate
  into an implementation or protected-compatibility classification. No
  `INVESTIGATE` item remains, so Work Package 3A is complete.

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

- Execute Stage 3 Work Packages 3B through 3F using their atomic commit and
  dual-platform validation boundaries.
- Prepare the Stage 4 final-audit plan only after Stage 3 completes.
- Resume the remaining target-scoped modernization work only after this
  compatibility-changing direction reaches a stable handoff point.

## Continuation Point

Execute Stage 3 Work Package 3B from the completed pre-implementation contract.
Begin with the Clang-only compiler branches, preserve the protected keep set,
and create each atomic implementation commit only after its focused
Windows/MSVC and Linux/GCC checks pass.

## Validation State

- Current status: Stage 2 complete. The core gate, bundled compression, system
  compression, and coverage pass, and all optional rows supported by the
  supplied Linux/GCC environment executed successfully. The six unavailable,
  non-required optional rows are explicitly deferred.
- The qualified validator was Ubuntu 26.04.1 LTS under WSL2 on x86_64 with
  glibc 2.43, GCC/G++ 15.2.0 targeting `x86_64-linux-gnu`, CMake/CTest/CPack
  4.2.3, Ninja 1.13.2, GNU Make 4.4.1, `HDF_TEST_EXPRESS=3`, and at most six
  parallel jobs. The tracked validation checkout was clean at `6ee2f392e`.
- The default Ninja Release build passed its full suite: 2,819 passed, zero
  failed, and 37 disabled out of 2,856 registered tests. Debug, static-only,
  shared-only, C++, and Unix Makefiles builds plus their focused selections all
  passed. Standalone examples passed 279/279 tests against both build-tree and
  installed packages; install, TGZ, and four consumer modes passed.
- The normalized pre-Stage-1/current contracts differed only by approved
  MinGW and Linux-irrelevant MSVC cache removal plus sanitizer help wording;
  retained Linux targets, flags, tests, generated files, and package metadata
  had no unexplained delta.
- Available optional rows passed for OpenMPI parallel HDF5, subfiling,
  thread-safe and concurrency modes, remotely retrieved external plugins,
  STGZ, and DEB. Detailed commands, counts, artifacts, and versions are in the
  Stage 2 results document.
- The supported `h5cc` and `h5c++` wrappers passed, including default high-level
  linkage and `-nohl`; obsolete four-wrapper documentation was corrected. The
  bundled-compression export regression is fixed and its rerun passed. The
  coverage documentation now matches the implemented instrumentation and
  counter-reset behavior; no failed Stage 2 row remains.
- Bundled zlib 1.3.2 and libaec 1.1.6 passed the retained preset build and 49
  focused compression/plugin tests. Static and shared build-tree/install-tree
  consumers found DEFLATE and SZIP, and the TGZ package contained the expected
  libraries and CMake exports.
- Ubuntu zlib 1.3.1 and libaec 1.1.5 packages passed the non-FetchContent
  system-compression path: 3,161 build steps, 29 focused tests, installation,
  dependency metadata, and four static/shared build/install consumers.
- Missing-environment rows are mpiFileUtils/libcircle/DTCMP, ROS3 aws-c-s3,
  JDK/Hadoop/libhdfs, OpenSSL development/signing inputs, `rpmbuild`, and a real
  unsupported native Linux compiler. The user explicitly deferred every row
  because these configurations are not required.
- A fresh post-repair Windows x64 default Release build passed with CMake 4.4.3,
  Visual Studio 18 2026, MSVC 19.51.36256.0/toolset 14.51.36231, and
  `CL=/utf-8`; its focused selection passed 7/7 with fixtures.
- A fresh Windows/MSVC bundled-compression configuration and Release build also
  passed after `81e96c889`. Static consumers configured, linked, and ran against
  both build-tree and installed packages; multi-config dependency imports used
  the expected configuration-specific library paths.
- The completed local baseline was Windows NT `10.0.26100` x64, Visual Studio
  18 2026 Insiders, MSVC `19.51.36256.0` from toolset `14.51.36231`, Windows
  SDK `10.0.26100.0`, and CMake `4.4.3`. Configures used the Visual Studio 18
  2026 generator without an explicit platform, `CL=/utf-8`,
  `HDF_TEST_EXPRESS=3`, and at most six parallel jobs.
- All 12 corrected synthetic firewall cases passed. They cover both accepted
  compiler pairs, generator and architecture variation, rejected target
  systems and compilers, optional C++, and the non-bypass behavior of
  `HDF5_ALLOW_UNSUPPORTED`.
- Root and standalone-example preset listing passed.
- Two Windows/MSVC CLion-style configures using the Visual Studio 18 2026
  generator without `-A x64` passed configure and generation with MSVC
  `19.51.36256.0`: the default C configuration and a configuration with
  `HDF5_BUILD_CPP_LIB=ON`. This proves the reported empty
  `CMAKE_GENERATOR_PLATFORM` no longer causes a false rejection and that the
  optional C++ compiler check follows the same pair-only policy.
- CLion reported no inspection problems in the firewall, its script-level
  tests, the restored MSVC architecture flags, or the restored installation
  architecture handling.
- The default cache retained `HDF5_BUILD_CPP_LIB=OFF` and
  `HDF_TEST_EXPRESS=3`.
- The clean before/after default File API contracts contained 17,323 identical
  records.
- Clean source-package ZIP generation passed. Its 4,092-entry manifest included
  the expected root and refactoring files and excluded local build/IDE data and
  deleted Cygwin or unsupported-toolchain paths.
- Generated package metadata reports `Windows x64, using VISUAL STUDIO 2026`.
- Formatting commit `b22b55872` removed four `HDONE_ERROR(...)` statement
  terminators, but `a68b4cae4e` restored them before the current `HEAD`. The
  current source contains all four semicolons, CLion reports no errors in those
  files, and the earlier blocker record was stale.
- A C++-enabled Windows/MSVC Release build with static and shared libraries,
  tests, tools, and retained examples completed successfully using the Visual
  Studio 18 2026 generator without an explicit `-A` argument.
- Full CTest at `HDF_TEST_EXPRESS=3` passed all 2,851 enabled tests with 37
  disabled out of 2,888 registered tests, using six parallel jobs.
- A fresh default Release configure and complete build passed with static and
  shared libraries, tests, tools, high-level libraries, and examples enabled
  and C++ disabled. Full CTest passed all 2,816 enabled tests with 37 disabled
  out of 2,853 registered tests.
- Fresh static-only Release, shared-only Release, and default Debug builds
  passed. Each configuration passed the same focused C, high-level, and tool
  smoke selection plus its fixtures: seven tests per configuration.
- Artifact checks confirmed the default Release build emits `hdf5.dll`, its
  `hdf5.lib` import library, and `libhdf5.lib`; static-only omits the DLL and
  import library; shared-only omits the static library. The high-level library
  follows the same pattern. Debug emits and installs HDF5 and tool PDB files in
  `bin`.
- Release installation of the C++-enabled combined build passed and installed
  C, high-level, C++, and C++ high-level static and shared libraries, runtime
  DLLs, tools, headers, package configuration, and static/shared export sets.
  CPack ZIP generation passed; the archive contains 164 entries, including the
  expected C/C++ runtime and library artifacts.
- Standalone retained C, C++, and high-level examples configured, built, and
  passed all 279 registered tests against both the build-tree package and the
  installed package.
- Minimal external `add_subdirectory()` and local-source FetchContent consumers
  each configured, built, linked to `hdf5-static`, and passed their execution
  test.
- A user-provided vcpkg-exported Microsoft MPI SDK was paired with the installed
  Microsoft MPI runtime. Parallel HDF5 configured and completed a full Release
  build with 3,108 registered tests. A focused core-library, MPI, parallel-tool,
  and parallel-example selection passed all nine tests and fixtures.
- Fresh thread-safe and multi-thread concurrency configurations each built the
  shared library and `testhdf5`; the focused base test and its fixtures passed
  three of three tests in each configuration.
- After refreshing the process environment, CMake found Strawberry Perl
  `5.42.3`; Perl is not a remaining environment gap.

## Residual Audit

- Active CMake keyword matches are limited to firewall rejection tests,
  `clang-format`/`clang-tidy` developer tooling, and AppleClang/macOS comments
  that explain retained generic `_Float16` feature probes.
- Current-documentation matches are explicit unsupported-platform declarations,
  historical release or HPC descriptions, developer analyzer/formatter names,
  and Intel native-datatype or file-format interoperability documentation.
- Sixty tracked C/C++ source or header files remain as candidates for the future
  source-reduction inventory:
  `APPLE=4`, `CLANG=234`, `CYGWIN=6`, `DARWIN=3`, `FREEBSD=4`, `INTEL=43`,
  `MACOS=12`, `MINGW=10`, `NETBSD=2`, and `PGI=4`.
- All 19 commits in `0adb08f4a..b317dedc9` and the admission-policy correction
  passed their Stage 2 native Linux/GCC ownership checks. Their static proofs
  reduce removed selectors according to the Windows/MSVC and Linux/GCC pair
  table in the detailed plan. The architecture/generator re-audit restored
  product behavior needed by admitted Windows/MSVC variants while leaving
  release-validation presets, CI, dashboards, and bundled cross-toolchain
  helpers baseline-scoped.

The qualified Linux/GCC validator is repeatable for later work. Preserve its
versioned, normalized Stage 2 record; dual-platform CMake validation is
complete, with the six non-required unavailable configurations explicitly
deferred. Stage 3 is approved, but source-level removal must wait for the Work
Package 3A baseline and classification gate.

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
6. Distinguish the Windows CMake milestone, dual-platform CMake validation,
   source reduction, and final project completion.
7. Commit every repository modification as an atomic, independently revertible
   local checkpoint after its required checks pass. Never include unrelated
   user changes or generated artifacts.
