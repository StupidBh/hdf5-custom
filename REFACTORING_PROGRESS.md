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
It intentionally changes the compatibility contract by first reducing the
CMake matrix and then removing source-level support outside Windows/MSVC and
Linux/GCC. The underlying target architecture and the paused
behavior-preserving modernization state remain recorded in
[`docs/CMakeModernization.md`](docs/CMakeModernization.md) and
[`docs/CMakeModernizationProgress.md`](docs/CMakeModernizationProgress.md).

## Active Direction

- Direction: Project supported-platform reduction
- Status: CMake platform/compiler reduction and admission-policy correction
  implemented; a C++-enabled Windows/MSVC Release build and full CTest pass;
  remaining Windows/MSVC rows are incomplete and Linux/GCC native validation is
  deferred.
- Original support-contract anchor: `912fb436b`
- Admission-policy correction anchor: `614dd74c0`
- CMake implementation anchor: `b317dedc9`
- Source compilation repair anchor: `a68b4cae4e`
- Current documentation anchor: `614dd74c0`
- Stage 1 CMake implementation commits: 19
- Stage 1 completion state: in progress at the remaining Windows/MSVC validation
  gates

The approved endpoint accepts two target-system/compiler pairs: Windows with
compiler ID `MSVC`, and Linux with compiler ID `GNU`. Generator, architecture,
and exact compiler release are validation dimensions rather than central
firewall inputs. The release-qualified baselines remain Windows x64 with MSVC
18 and Visual Studio 18 2026, plus Linux x86_64 with GCC/G++ and Ninja, with a
focused Unix Makefiles check. The CMake firewall and unsupported CMake-path
reduction have landed, and the over-constrained admission policy is corrected
in the current working tree. Stage 2 native Linux validation, Stage 3
source/header reduction, and Stage 4 final audit have not started.

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

- Complete the remaining Stage 1 Windows/MSVC matrix, including the default,
  static-only, shared-only, and Debug rows plus install, binary-package,
  standalone-example, and external-consumer validation.
- Establish a trusted native Linux x86_64 GCC/G++ validator for Stage 2;
  Windows GCC or MinGW is not substitute evidence.
- Inventory and remove source/header compatibility code used only by rejected
  platforms and compilers, including a separate installed-header review.
- Validate every source-removal batch on both release baselines and complete the
  final project-wide support audit.
- Run the deferred native Linux/GCC CMake matrix on the pinned baseline before
  starting source removal, then keep Linux/GCC validation available for each
  source batch.
- Resume the remaining target-scoped modernization work only after this
  compatibility-changing direction reaches a stable handoff point.

## Continuation Point

Stop at Stage 1. Do not begin native Linux validation or source/header cleanup.
Resume at Work Package 1G and run the remaining Windows/MSVC validation matrix.
When the user supplies a trusted native Linux/GCC environment, begin Stage 2
only after recording the complete Windows result; Stage 3 remains gated on
repeatable validation on both release baselines.

## Validation State

- Current status: CMake platform/compiler reduction and admission-policy
  correction implemented; a C++-enabled Windows/MSVC Release build and full
  CTest pass; remaining Windows/MSVC rows are incomplete and Linux/GCC native
  validation is deferred.
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
- Install, binary-package, standalone installed-example, and external-consumer
  rows have not yet been rerun. The older full default result of 2,817 passed
  and 37 disabled tests remains historical baseline evidence rather than proof
  for those outstanding rows.
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
- Sixty tracked C/C++ source or header files remain for Stage 3 classification:
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
versions here. Source-level removal must wait until that validator is
repeatable; the local Windows machine may still complete the explicitly
incomplete Stage 1 milestone.

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
