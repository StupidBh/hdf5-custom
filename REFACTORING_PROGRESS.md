# Refactoring Progress

Last updated: 2026-09-03

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
- Status: CMake platform reduction implemented; Windows/MSVC validation blocked by
  pre-existing C syntax errors; Linux/GCC native validation deferred.
- Support-contract anchor: `912fb436b`
- CMake implementation anchor: `b317dedc9`
- Current documentation anchor: `6ad3399ec`
- Stage 1 CMake implementation commits: 19
- Stage 1 completion state: blocked at the required Windows/MSVC build gate

The approved endpoint supports Windows x64 with MSVC 18 and the Visual Studio
18 2026 generator, plus Linux x86_64 with GCC/G++ and Ninja or Unix Makefiles.
The CMake firewall and unsupported CMake-path reduction have landed. Stage 2
native Linux validation, Stage 3 source/header reduction, and Stage 4 final
audit have not started.

## Completed

- Approved the Windows/MSVC and Linux/GCC support contract and documented the
  unsupported platform, compiler, and generator combinations.
- Fixed the deferred Linux validation baseline at Ubuntu 24.04 LTS x86_64,
  CMake 4.0.3, GCC/G++ 13.3.0, and Ninja 1.11.1, with a separate Unix
  Makefiles configure/build check.
- Declared Visual Studio 18 2026 as the only supported Windows generator;
  Ninja with MSVC is outside the supported matrix.
- Defined source-level removal as a required follow-on stage rather than an
  optional review after CMake reduction.
- Added one central platform/compiler/generator firewall for the root build and
  retained standalone C and C++ example entry points.
- Removed unsupported toolchains, presets, dashboard choices, CI build jobs,
  cache options, platform conditions, compiler dispatch, sanitizer presets,
  packaging branches, and residual active CMake paths in 19 focused commits.
- Updated current installation, option, example, preset, sanitizer, package,
  and consumer documentation to describe only the retained build matrix.
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

- Resolve the four pre-existing C syntax errors introduced by `b22b55872` in a
  separately authorized source change, then rerun the required Stage 1
  Windows/MSVC build, test, install, binary-package, example, and consumer rows.
- Establish a trusted native Linux x86_64 GCC/G++ validator for Stage 2;
  Windows GCC or MinGW is not substitute evidence.
- Inventory and remove source/header compatibility code used only by rejected
  platforms and compilers, including a separate installed-header review.
- Validate every source-removal batch on both retained rows and complete the
  final project-wide support audit.
- Run the deferred native Linux/GCC CMake matrix on the pinned baseline before
  starting source removal, then keep Linux/GCC validation available for each
  source batch.
- Resume the remaining target-scoped modernization work only after this
  compatibility-changing direction reaches a stable handoff point.

## Continuation Point

Stop at Stage 1. Do not begin native Linux validation or source/header cleanup.
After the pre-existing source syntax blocker has a separately authorized fix,
resume at Work Package 1G and run the complete Windows/MSVC validation matrix.
When the user supplies a trusted native Linux/GCC environment, begin Stage 2
only after recording the Windows result; Stage 3 remains gated on repeatable
validation on both retained rows.

## Validation State

- Current status: CMake platform reduction implemented; Windows/MSVC validation
  blocked by pre-existing C syntax errors; Linux/GCC native validation deferred.
- The 12 synthetic firewall cases passed, covering both accepted state models,
  rejected systems, compilers, generators and architectures, optional C++, and
  the non-bypass behavior of `HDF5_ALLOW_UNSUPPORTED`.
- Root and standalone-example preset listing passed.
- Default and C++-enabled Windows x64 configurations passed with Visual Studio
  18 2026 and MSVC `19.51.36256.0`.
- The default cache retained `HDF5_BUILD_CPP_LIB=OFF` and
  `HDF_TEST_EXPRESS=3`.
- The clean before/after default File API contracts contained 17,323 identical
  records.
- Clean source-package ZIP generation passed. Its 4,092-entry manifest included
  the expected root and refactoring files and excluded local build/IDE data and
  deleted Cygwin or unsupported-toolchain paths.
- Generated package metadata reports `Windows x64, using VISUAL STUDIO 2026`.
- The default Release build stops at missing semicolons after `HDONE_ERROR(...)`
  in `src/H5ESint.c:676`, `src/H5FAdblock.c:306`,
  `src/H5HFiblock.c:936`, and `src/H5T.c:2966`. Git attributes all four lines
  to the pre-Stage 1 formatting commit `b22b55872`.
- Because the core library cannot build, current CTest, install, binary-package,
  standalone-example, and external-consumer results are unavailable. The older
  full default result of 2,817 passed and 37 disabled tests at
  `HDF_TEST_EXPRESS=3` remains historical baseline evidence, not Stage 1 proof.
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
  the Windows/MSVC and Linux/GCC state table in the detailed plan.

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
