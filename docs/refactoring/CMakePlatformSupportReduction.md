# CMake Supported Platform Reduction Plan

## Status

- State: Proposed
- Planning baseline: `3d4e59b21`
- Primary available environment: Windows with MSVC 18
- Unavailable local environment: Linux with GCC
- Maximum local build and test parallelism: 6

## Objective

Reduce the supported CMake build matrix to two platform and compiler pairs:

| Platform | Supported compiler | Primary generator |
| --- | --- | --- |
| Windows | MSVC | Visual Studio 18 2026, x64 |
| Linux | GCC | Ninja or Unix Makefiles |

Remove Windows/MinGW and MSYS2 build support. After the full plan is complete,
other operating-system and compiler combinations are rejected as unsupported
instead of being accepted through unverified compatibility branches.

This is an intentional compatibility change. It is separate from the existing
behavior-preserving CMake 4 modernization plan, whose current contract retains
existing toolchains and options.

## Motivation

- The maintained deployment environments are Windows/MSVC and Linux/GCC.
- MinGW-specific feature checks, library naming, runtime linkage, presets,
  toolchains, workflows, and documentation increase the cost of every CMake
  refactoring batch.
- A smaller explicit matrix makes target-scoped modernization, dependency
  ownership, installation, packaging, and consumer validation more rigorous.
- Unsupported combinations should fail early with a clear diagnostic instead
  of appearing supported because dormant compatibility code remains.

## Compatibility Impact

The following changes are intentional and must be documented as breaking build
system changes:

- MinGW and MSYS2 configurations stop at configure time.
- MinGW toolchain files, presets, cache options, CTest paths, and CI workflows
  are removed.
- MinGW-specific shared-library naming and static GCC runtime linkage behavior
  are removed.
- CMake cache options used only by MinGW are removed rather than retained as
  ignored compatibility aliases.
- Clang, clang-cl, Intel, NVHPC, AOCC, Cygwin, macOS, BSD, Emscripten, and other
  platform/compiler combinations cease to be supported by the project CMake
  build unless separately restored by a future approved plan.
- Existing HDF5 file-format compatibility, C ABI on retained platforms, public
  target names, product components, and Java/Fortran removal are unchanged.

Historical release notes must remain unchanged. Current installation, option,
and usage documentation must be updated to describe only the retained matrix.

## Scope Boundaries

### In scope

- Top-level and standalone-project toolchain validation.
- MinGW/MSYS2 CMake options, toolchains, presets, feature checks, target
  properties, link requirements, dashboards, workflows, and current docs.
- Compiler dispatch and flag modules for toolchains removed from the supported
  matrix.
- Install/package metadata and examples that advertise removed toolchains.
- Tests that prove unsupported toolchains fail with an actionable message.
- MSVC validation now and Linux/GCC validation on another machine before the
  plan can be completed.

### Out of scope

- C17 or C++20 language migration.
- Java or Fortran restoration.
- Removal of product features such as C++, MPI, thread safety, filters, VOL,
  VFDs, tools, or examples merely because they require additional validation.
- Unrelated source cleanup or formatting.
- Rewriting historical release notes that truthfully describe earlier MinGW
  support.

Source-level `__MINGW32__` branches are not removed in the first CMake batches.
They affect installed headers and source portability and therefore require a
separate, explicitly reviewed compatibility commit after the build entry points
reject MinGW.

## Current Inventory

The planning baseline contains MinGW or MSYS references in these active areas:

- 19 CMake, preset, and configuration files, with approximately 60 matching
  expressions;
- four C/header files containing `__MINGW32__` compatibility conditions;
- `config/toolchain/mingw64.cmake` and its Wine launcher;
- the matching `HDF5Examples` toolchain files and 32-bit toolchain branches;
- `.github/workflows/msys2.yml`, `.github/workflows/cross-compile.yml`, and the
  MSYS2 caller in `.github/workflows/call-workflows.yml`;
- current option, installation, example, preset, and CMake usage documentation;
  and
- the public `HDF5_MINGW_STATIC_GCC_LIBS` cache option plus the apparently
  inconsistent `HDF5_MSVC_NAMING_CONVENTION` MinGW naming path.

Re-run the inventory at implementation start. Do not treat references in
historical release notes as active support.

## Execution Principles

1. Change the support contract before deleting compatibility code.
2. Keep Windows/MSVC behavior identical until a phase explicitly says
   otherwise.
3. Preserve Linux/GCC paths structurally while Linux validation is unavailable.
4. Do not infer Linux correctness from MinGW or MSVC results.
5. Separate option removal, platform checks, target linkage, documentation,
   workflow removal, and source cleanup into reviewable commits.
6. Capture a baseline before each behavior-affecting batch and compare the
   retained MSVC targets afterward.
7. Stop a batch if retained MSVC contracts change unexpectedly or a change
   cannot be classified without Linux/GCC evidence.
8. Never mark this plan complete until the external Linux/GCC gate passes.

## Phase 0: Approve the Support Contract

### Changes

- Update `AGENTS.md` to name Windows/MSVC and Linux/GCC as the only supported
  platform/compiler combinations.
- Update the CMake modernization compatibility contract and validation matrix
  so they no longer promise Clang or MinGW compatibility.
- Add a user-visible entry to `release_docs/CHANGELOG.md` describing the
  removed build environments and cache options.
- Decide and document the retained Linux baseline before Linux validation:
  distribution, architecture, GCC/G++ versions, generator, and CMake version.
- Decide whether Ninja with MSVC remains supported in addition to the Visual
  Studio generator. Compiler support and generator support must not be
  conflated implicitly.

### Exit criteria

- The supported and unsupported combinations are stated consistently in
  repository policy, plans, user documentation, and the changelog.
- The retained Linux/GCC baseline is concrete enough for another machine to
  execute without making a new policy decision.

### Commit boundary

One documentation-only commit. Do not remove code or options in this phase.

## Phase 1: Add Central Toolchain Validation

### Design

Create one focused module under `config/cmake/` that validates the platform and
compiler after language detection. The conceptual policy is:

```cmake
if (WIN32)
  # Accept CMAKE_<LANG>_COMPILER_ID == MSVC only.
elseif (CMAKE_SYSTEM_NAME STREQUAL "Linux")
  # Accept CMAKE_<LANG>_COMPILER_ID == GNU only.
else ()
  # Reject the platform with a clear diagnostic.
endif ()
```

Validate C when the root project starts and validate C++ when the optional C++
language is enabled. Do not rely only on the `MSVC` convenience variable when
the policy intends to distinguish MSVC from clang-cl or Intel front ends.

Apply the same policy to retained standalone examples and other supported
standalone entry points. Reuse the module instead of copying the conditions.

### Tests

- Windows/MSVC configuration succeeds.
- A deliberately unsupported Windows compiler configuration reaches the policy
  check and reports the accepted combinations when such a compiler is
  available.
- Unsupported-platform diagnostics are covered by a CMake script-level test if
  they cannot be exercised reliably on the current machine.
- The default MSVC File API contract remains unchanged except for the newly
  documented support-policy metadata, if any.

### Exit criteria

- Every supported project entry point applies the same validation.
- Failure messages name both supported combinations and do not suggest that
  MinGW, clang-cl, or other toolchains are usable.

### Commit boundary

Keep the validation module and its focused tests in one commit. Do not delete
MinGW implementation branches yet.

## Phase 2: Remove MinGW Entry Surfaces

### Changes

- Remove `config/toolchain/mingw64.cmake` and
  `config/toolchain/mingw-w64-x86-64-wine.sh`.
- Remove the matching toolchains under `HDF5Examples/config/toolchain/`.
- Remove MinGW branches from the main and example `build32.cmake` files while
  preserving retained Linux/GCC behavior.
- Remove MinGW/MSYS configure and build presets.
- Remove `HDF5_MINGW_STATIC_GCC_LIBS` from option declarations, cache init
  files, presets, and current option documentation.
- Audit `HDF5_MSVC_NAMING_CONVENTION`. Remove it in a separate commit if it is
  confirmed to have no retained MSVC behavior; otherwise rename or redefine it
  only through a separately approved compatibility decision.
- Remove MSYS2 and MinGW cross-compilation workflow entry points without
  modifying unrelated retained jobs.

### Tests

- Configure all retained MSVC presets.
- Confirm removed preset and option names are absent from current generated
  cache documentation.
- Confirm the unsupported-toolchain diagnostic is authoritative; users must
  not fall through to a missing toolchain-file error presented as accidental
  breakage.

### Exit criteria

- No supported entry point or current documentation advertises MinGW/MSYS2.
- Removed cache options do not remain as ignored no-op compatibility settings.
- Historical release notes remain intact.

### Commit boundaries

Use separate commits for toolchain/preset deletion, cache option removal, and
workflow removal. Documentation can accompany the behavior it describes.

## Phase 3: Simplify MinGW-Aware CMake Logic

### Changes

- Replace retained `WIN32 AND NOT MINGW` branches with Windows/MSVC logic only
  after the central policy gate is active.
- Remove standalone `if(MINGW)` branches for ANSI stdio, static GCC runtimes,
  socket libraries, feature checks, and test behavior.
- Simplify `$<PLATFORM_ID:MinGW>` and Windows/MinGW generator expressions to the
  retained Windows platform expression.
- Simplify shared/static library naming and imported-location handling in
  `config/HDFMacros.cmake` for the two retained platforms.
- Re-evaluate `MINGW OR NOT WINDOWS` conditions individually. On the retained
  matrix they often become Linux-only checks, but they must not be rewritten
  mechanically if they also encode feature detection semantics.
- Remove Cygwin-only alternatives encountered in the same condition only when
  the new support contract clearly makes them unreachable.

### Validation method

For each bounded condition family:

1. Capture affected MSVC generated project files or File API records.
2. Change one condition family.
3. Reconfigure with MSVC 18.
4. Compare target compile definitions, includes, link libraries, artifacts,
   output names, and registered tests.
5. Build affected static and shared targets.
6. Run the narrowest relevant tests.

### Exit criteria

- Active CMake files contain no MinGW behavior branches.
- Retained Windows/MSVC generated behavior is unchanged unless the phase has an
  explicitly documented correction.
- Linux/GCC-sensitive rewrites remain pending when they cannot be proven from
  feature semantics or external validation.

### Commit boundaries

Separate feature checks, library naming, runtime linkage, test behavior, and
CTest script cleanup. Avoid a repository-wide search-and-replace commit.

## Phase 4: Remove Other Unsupported Toolchain Paths

This phase enforces the "only Windows/MSVC and Linux/GCC" part of the policy.
It is broader than MinGW removal and must remain independently reviewable.

### Changes

- Remove compiler dispatch and flag modules used only by Clang, clang-cl,
  Intel, NVHPC, PGI, AOCC, and other unsupported compilers.
- Remove toolchain files and presets used only by unsupported combinations.
- Remove unsupported macOS, BSD, Cygwin, Emscripten, and compiler-specific CI
  matrix jobs while retaining workflow infrastructure used by MSVC or GCC.
- Simplify sanitizer and coverage selection only where it concerns compiler
  support. Keep `clang-format` and similar developer tools when they are used as
  formatters or analyzers rather than build compilers.
- Preserve GNU logic shared by Linux/GCC and cross-architecture Linux/GCC until
  it has passed the Linux validation gate.

### Exit criteria

- Compiler and platform dispatch have exactly two supported outcomes.
- No retained GCC path depends on a deleted common module.
- Current presets, workflows, and user docs advertise only the retained matrix.

### Commit boundaries

Use one commit per compiler family or platform family. Do not combine this
phase with MinGW feature-check cleanup.

## Phase 5: Review Source-Level MinGW Guards

### Changes

- Review the four source/header files that mention `__MINGW32__`.
- Remove redundant test-only guards after the CMake entry point rejects MinGW.
- Treat changes to installed public headers, especially `src/H5public.h`, as
  public compatibility changes and document their effect explicitly.
- Keep generic `_WIN32` and POSIX separation needed by MSVC and Linux/GCC.

### Exit criteria

- Every retained or removed MinGW source guard has a documented reason.
- Public header behavior on Windows/MSVC and Linux/GCC remains correct.
- Source changes are formatted and tested independently from CMake cleanup.

## Phase 6: Complete Current Documentation and Packaging Cleanup

### Changes

- Remove MinGW/MSYS generators and options from current installation, usage,
  example, and preset documentation.
- Update package and binary naming explanations for the retained platforms.
- Ensure generated settings and package configuration do not advertise removed
  compiler/platform support.
- Preserve factual historical release notes.

### Exit criteria

- A current-doc search finds no statement that MinGW, Clang, Intel, macOS, BSD,
  or other removed combinations are supported.
- Package consumers receive a clear diagnostic for unsupported combinations.

## Phase 7: Windows/MSVC Validation Gate

This phase can be completed on the currently available machine.

### Required configurations

- Default static plus shared Release build.
- Static-only and shared-only Release builds.
- Default Debug build.
- C++ enabled in at least one static and one shared configuration.
- Parallel HDF5 with Microsoft MPI where supported.
- Thread-safe and multi-thread concurrency configurations according to their
  documented compatibility constraints.
- System and bundled compression configurations available on Windows.
- Install tree, CMake package, and at least one external consumer build.

### Required commands

Use out-of-source MSVC 18 builds, set `CL=/utf-8`, and keep build and CTest
parallelism at or below 6. Record exact options for every non-default row.

### Required comparisons

- File API contract for retained cache options and targets.
- Static/shared output names, DLL import libraries, PDB handling, runtime
  placement, install destinations, and exported targets.
- Registered test counts and fixture relationships.
- Build-tree and install-tree consumer behavior.

### Exit criteria

- All required MSVC rows configure and build.
- The full default MSVC 18 Release CTest suite passes.
- Focused optional-feature tests pass for every exercised row.
- No unexplained retained-contract difference remains.

Passing this gate does not complete the plan while Linux/GCC remains untested.

## Phase 8: Deferred Linux/GCC Validation Gate

This phase must run on another machine or a trusted CI runner with a native
Linux/GCC environment.

### Record before testing

- Linux distribution and version.
- Architecture.
- CMake, GCC, and G++ versions.
- Generator and build tool versions.
- MPI and optional dependency versions used by each row.

### Required configurations

- Default static plus shared Debug and Release builds.
- Static-only and shared-only Release builds.
- C++ enabled in at least one static and one shared configuration.
- Parallel HDF5 with at least one supported OpenMPI or MPICH configuration.
- Thread-safe and multi-thread concurrency configurations according to their
  documented constraints.
- Available system and bundled compression configurations.
- Install tree, pkg-config, CMake package, and external consumer builds.
- Standalone retained C and C++ examples.

### Required checks

- Full default Release CTest suite at the recorded `HDF_TEST_EXPRESS` level.
- Focused tests for every optional row.
- Build-tree and install-tree `find_package` consumers.
- `add_subdirectory()` and FetchContent consumers.
- Installed wrapper scripts and pkg-config metadata.
- Clear rejection of an unsupported Linux compiler when one is available.

### Failure handling

If a retained GCC path fails because an earlier Windows-only phase removed
shared behavior, fix it in a focused commit and rerun the affected MSVC checks.
Do not restore MinGW or another unsupported platform as an incidental fix.

### Exit criteria

- All required Linux/GCC rows have recorded results.
- No Linux/GCC failure is deferred without an owner and explicit follow-up.
- MSVC remains green after any cross-platform correction.

## Phase 9: Completion Audit

### Checks

- Search active CMake, preset, workflow, and current documentation files for
  MinGW, MSYS2, Cygwin, unsupported operating systems, and unsupported compiler
  dispatch.
- Classify every remaining match as historical text, a developer tool name, or
  a defect.
- Confirm removed options are absent from generated cache help and package
  documentation.
- Confirm supported configurations fail neither policy checks nor package
  consumer checks.
- Confirm unsupported configurations fail early and clearly.
- Update `REFACTORING_PROGRESS.md` with final anchors and validation evidence.

### Completion criteria

This plan is complete only when:

1. Windows/MSVC and Linux/GCC are the only advertised and accepted CMake build
   combinations.
2. MinGW/MSYS2 entry points and active compatibility branches are removed.
3. Other unsupported compiler/platform build paths are removed or rejected by
   the central policy.
4. Both retained platform gates pass, including install and consumer checks.
5. Current documentation, presets, CI, and package metadata agree with the
   policy.
6. Remaining source-level compatibility guards are either removed or explicitly
   justified.

## Planned Commit Sequence

1. `docs: Define the supported CMake platform matrix`
2. `cmake: Reject unsupported platform compiler pairs`
3. `cmake: Remove MinGW toolchain entry points`
4. `cmake: Remove MinGW-only cache options`
5. `cmake: Simplify MinGW platform checks`
6. `cmake: Simplify Windows library naming`
7. `cmake: Remove MinGW runtime linkage branches`
8. `ci: Remove MinGW and MSYS2 workflows`
9. Compiler- or platform-specific commits for other removed toolchains
10. `docs: Remove unsupported toolchain instructions`
11. Optional source-level compatibility commits
12. `docs: Record MSVC platform-reduction validation`
13. `docs: Record Linux GCC platform-reduction validation`

Adjust the sequence when dependency analysis requires it, but keep each commit
buildable for the validation environment stated in its message.

## Stop Conditions

Stop the current batch and record the reason when:

- a retained MSVC contract changes without an approved compatibility reason;
- a condition mixes MinGW handling with Linux/GCC semantics that cannot be
  established without the deferred environment;
- deleting an unsupported compiler module breaks a module shared by GCC;
- a public option or installed artifact change was not covered by the approved
  compatibility statement; or
- the next step requires Linux/GCC evidence that is not available locally.

These conditions block only the affected batch. They do not justify weakening
the retained Linux/GCC gate or treating Windows-only validation as complete.
