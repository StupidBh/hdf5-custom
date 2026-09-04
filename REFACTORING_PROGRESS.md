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
The self-contained execution plan for the active Linux validation stage is
[`docs/refactoring/CMakePlatformSupportReductionStage2.md`](docs/refactoring/CMakePlatformSupportReductionStage2.md).
It intentionally changes the compatibility contract by first reducing the
CMake matrix and then removing source-level support outside Windows/MSVC and
Linux/GCC. The underlying target architecture and the paused
behavior-preserving modernization state remain recorded in
[`docs/CMakeModernization.md`](docs/CMakeModernization.md) and
[`docs/CMakeModernizationProgress.md`](docs/CMakeModernizationProgress.md).

## Active Direction

- Direction: Project supported-platform reduction
- Status: Stage 1 complete; CMake platform/compiler reduction implemented and
  Windows/MSVC validated; native Linux/GCC validation is deferred.
- Original support-contract anchor: `912fb436b`
- Admission-policy correction anchor: `614dd74c0`
- CMake implementation anchor: `b317dedc9`
- Source compilation repair anchor: `a68b4cae4e`
- Last landed documentation anchor: `614dd74c0`
- Stage 1 CMake implementation commits: 19
- Stage 1 completion state: complete
- Stage 2 execution scope: approved; awaiting a trusted native Linux/GCC
  validator
- Later-stage detailed planning: deferred until Stage 2 results are available

The approved endpoint accepts two target-system/compiler pairs: Windows with
compiler ID `MSVC`, and Linux with compiler ID `GNU`. Generator, architecture,
and exact compiler release are validation dimensions rather than central
firewall inputs. The release-qualified baselines remain Windows x64 with MSVC
18 and Visual Studio 18 2026, plus Linux x86_64 with GCC/G++ and Ninja, with a
focused Unix Makefiles check. The CMake firewall and unsupported CMake-path
reduction have landed, the over-constrained admission policy is corrected, and
the required Windows/MSVC Stage 1 validation gate has passed. Stage 2 native
Linux validation, Stage 3 source/header reduction, and Stage 4 final audit have
not started.

## Completed

- Approved the Windows/MSVC and Linux/GCC support contract and documented the
  unsupported target-system/compiler combinations.
- Fixed the deferred Linux validation baseline at Ubuntu 24.04 LTS x86_64,
  CMake 4.0.3, GCC/G++ 13.3.0, and Ninja 1.11.1, with a separate Unix
  Makefiles configure/build check.
- Retained Visual Studio 18 2026 and Linux Ninja/Unix Makefiles as validation
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

- Establish a trusted native Linux x86_64 GCC/G++ validator for Stage 2;
  Windows GCC or MinGW is not substitute evidence.
- Run the fixed Stage 2 core gate, then probe the supplied environment and run
  every optional row whose complete prerequisite set is already available.
- Present every missing optional prerequisite and the coverage it would unlock
  to the user, then run or explicitly defer each row according to that decision.
- After Stage 2 passes, prepare the detailed source/header reduction plan for
  separate review; the later source-removal and final-audit execution details
  are intentionally not approved yet.
- Resume the remaining target-scoped modernization work only after this
  compatibility-changing direction reaches a stable handoff point.

## Continuation Point

Stop after the completed Stage 1 milestone. Do not begin source/header cleanup.
When the user supplies a trusted native Linux/GCC environment, begin Stage 2
from `docs/refactoring/CMakePlatformSupportReductionStage2.md`: qualify the
validator, complete the fixed core gate, discover optional capabilities without
changing the environment, and validate every available legal row. Then present
missing prerequisites to the user for a test-or-defer decision. Stage 3 remains
unplanned and requires a separate review after Stage 2 passes.

## Validation State

- Current status: Stage 1 complete; CMake platform/compiler reduction
  implemented and Windows/MSVC validated; native Linux/GCC validation is
  deferred.
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
- The default full suite already exercised the enabled in-tree plugin and VOL
  tests. Environment-limited optional rows are direct pkg-config consumption,
  system zlib and libaec, external filter plugins, ROS3, HDFS, signed plugins,
  parallel tools based on mpiFileUtils, and extra Windows installer formats.
  The missing prerequisites are respectively `pkg-config`, the system
  compression development packages, an HDF5 filter-plugin installation,
  `aws-c-s3`, a JDK/JNI plus Hadoop/libhdfs, OpenSSL development files,
  mpiFileUtils/libcircle/DTCMP, and NSIS or WiX.
  These are Stage 1 Windows-environment results and must be probed again rather
  than assumed missing on the supplied Linux validator.
- Bundled zlib and libaec downloads and dependency configuration succeeded, but
  CMake generation failed because the HDF5 export sets reference bundled
  `zlib`, `aec-shared`, and `sz-shared` targets that are not in an export set.
  This is a non-environment optional-path defect, not a Stage 1 platform-
  reduction regression. If bundled compression prerequisites are available on
  Linux, Stage 2 records a reproduced failure as `FAIL`, not missing
  environment. Subfiling is tested when Stage 2 discovery finds its Linux MPI
  and thread prerequisites; otherwise it is presented for user decision.
- Historical MinGW-w64 results are baseline evidence only; MinGW is now outside
  the support contract and cannot substitute for native Linux/GCC validation.
- Installing GCC on Windows is not planned as a validation step because it does
  not exercise the Linux ABI or Linux CMake platform state.
- Native Linux/GCC validation remains deferred until the user supplies the
  required environment.

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
- All 19 commits in `0adb08f4a..b317dedc9` retain a Stage 2 native Linux/GCC
  validation owner. Their static proofs reduce removed selectors according to
  the Windows/MSVC and Linux/GCC pair table in the detailed plan. The
  admission-policy correction also remains owned by Stage 2 baseline
  validation. The architecture/generator re-audit restored product behavior
  needed by admitted Windows/MSVC variants while leaving release-validation
  presets, CI, dashboards, and bundled cross-toolchain helpers baseline-scoped.

Native Linux/GCC validation may run on a trusted CI runner, Linux virtual
machine, or native-target Linux container. Record the exact environment and
versions here. Run the fixed core gate before optional discovery, test every
available optional row, and record the user's decision for every missing
prerequisite. Source-level removal must wait until that validator is repeatable
and a later-stage plan has received separate review.

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
