# Project Supported Platform Reduction Plan

## Status

- State: Stages 1 through 3 completed; Stage 4 in progress, Work Packages 4A and 4B complete
- Support contract approved: 2026-09-03
- Support-contract commit: `912fb436b`
- Admission-policy correction commit: `614dd74c0`
- CMake implementation commit: `b317dedc9`
- Stage 1 source compilation repair commit: `a68b4cae4e`
- Stage 2 C11 literal repair commit: `6ee2f392e`
- Bundled-compression repair implementation: `81e96c889`
- Coverage documentation correction: `d39cd5fa0`
- Stage 3 plan commit: `31cf74435`
- Stage 3 implementation commit: `74288cbaa`
- Current implementation commit: `ebdb99969`
- Last preceding documentation commit: `c6e2c2cb9`
- Stage 1 CMake implementation commits: 19
- Stage 3 source/header implementation commits: 14
- Stage 4 Work Package 4B implementation commits: 6
- Stage 3 status: Completed
- Stage 3 completion review accepted: 2026-09-05
- Current delivery stage: Stage 3 Completed; Stage 4 Work Packages 4A and 4B complete, next is 4C
- Stage 2 execution plan:
  [`CMakePlatformSupportReductionStage2.md`](CMakePlatformSupportReductionStage2.md)
- Stage 2 execution results:
  [`CMakePlatformSupportReductionStage2Results.md`](CMakePlatformSupportReductionStage2Results.md)
- Stage 3 execution plan:
  [`CMakePlatformSupportReductionStage3.md`](CMakePlatformSupportReductionStage3.md)
- Stage 3 execution results:
  [`CMakePlatformSupportReductionStage3Results.md`](CMakePlatformSupportReductionStage3Results.md)
- Stage 4 approved execution plan:
  [`CMakePlatformSupportReductionStage4.md`](CMakePlatformSupportReductionStage4.md)
- Stage 4 execution results:
  [`CMakePlatformSupportReductionStage4Results.md`](CMakePlatformSupportReductionStage4Results.md)
- Stage 4 audit recommendations and inherited boundaries accepted: 2026-09-05
- Stage 4 detailed plan and review clarifications approved: 2026-09-05
- Stage 4 execution requirements: prefer CLion MCP; maximum build/CTest
  parallelism 4 per physical host, shared by Windows and WSL on that host
- Stage 2 execution scope approved: 2026-09-04
- Stage 2 completion decision: 2026-09-04; six unavailable non-required optional configurations deferred
- Stages 3 and 4: Stage 3 Completed; Stage 4 in progress with 4A and 4B complete
- Stage 1 validated environment: Windows NT 10.0.26100 x64, Visual Studio 18
  2026 Insiders, MSVC 19.51.36256.0, Windows SDK 10.0.26100.0, and CMake 4.4.3
- Available local environment: native Linux x86_64 with GCC/G++
- Maximum Stage 3 build and test parallelism: 4

## Objective

Reduce the supported project implementation to two target-system/compiler
pairs. First, reduce the CMake build surface and mechanically reject every
other target-system/compiler pair before project logic can use an unsupported
compatibility path. Generator, target architecture, and exact compiler release
are validation dimensions, not central-firewall inputs.
Then remove source-level compatibility code that exists only for the rejected
platforms and compilers.

| Target system | Required compiler ID |
| --- | --- |
| Windows | `MSVC` |
| Linux | `GNU` |

The release-qualified validation baselines remain Windows x64 with MSVC using
a Visual Studio generator and Linux x86_64 with GCC/G++ using Ninja. The
baseline generators are not an exhaustive list of accepted CMake generators.
An architecture or generator outside those baselines may remain unvalidated,
but it is not rejected solely for that reason.

The delivery is intentionally split so each compatibility boundary can be
validated before the next one changes:

1. Stage 1 completes the CMake support-matrix reduction and Windows/MSVC
   validation. Linux/GCC CMake behavior is preserved by logical reduction, but
   native Linux/GCC validation is deferred.
2. Stage 2 validates that the Stage 1 CMake reduction preserved the core
   Linux/GCC build. It then discovers which optional configurations the
   supplied environment can support, validates every available row, and
   presents missing prerequisites to the user for a scope decision.
3. Stage 3 removed source and header compatibility code for unsupported
   platforms and compilers in 14 atomic implementation commits. Its complete
   Windows/MSVC and Linux/GCC gate passed at `74288cbaa`.
4. Stage 4 will perform the final project-level support audit. Its separate
   approved plan defines scope, focused defect repairs, evidence inheritance,
   dual-platform acceptance, and overall completion criteria.

Stage 1 may be completed without a native Linux environment. That milestone
means the CMake firewall and cleanup have landed, retained Windows behavior has
been validated, and the Linux/GCC path has been preserved by static reasoning.
It does not mean Linux/GCC has been tested or that the overall plan is complete.

Stages 2, 3, and 4 remain mandatory direction-level milestones. The overall
direction is not complete when the CMake layer has been reduced, or when its
first Linux validation passes. Detailed approval of the later stages is
deliberately deferred; their current direction does not authorize source or
header edits before a later plan review.

## Approved Policy

### Hard build boundary

The HDF5 source build accepts only the two target-system/compiler pairs in the
supported matrix. The policy uses the target system reported by
`CMAKE_SYSTEM_NAME`, not the host system, so cross-compilation does not bypass
the compiler-pair check.

- Windows requires compiler ID `MSVC`.
- Linux requires compiler ID `GNU`.
- C is validated immediately after the root `project()` call has completed
  language detection.
- C++ is validated whenever an optional entry point first enables C++.
- `HDF5_ALLOW_UNSUPPORTED` applies only to documented HDF5 feature
  combinations. It cannot bypass the target-system/compiler policy.
- Unsupported configurations fail with one diagnostic that names both accepted
  pairs and identifies the rejected target system or compiler.

The initial firewall does not impose an exact GCC release or an additional
MSVC compiler-version comparison. Compiler family and target system are the
compatibility boundary. The selected architectures and generators below define
validation baselines rather than the complete accepted surface.
Use exact `CMAKE_<LANG>_COMPILER_ID` comparisons: CMake's broader `MSVC`
boolean can also describe compilers that merely simulate the `cl` command-line
syntax.

### Validation baselines

The retained Windows baseline is Windows x64 with MSVC using a Visual Studio
generator and the SDK selected by that environment. Ninja, Ninja Multi-Config,
IDE-managed CMake profiles, and other generators are not rejected when they
detect compiler ID `MSVC`; they do not replace the Visual Studio baseline
unless separately validated and recorded.

The Linux baseline is Linux x86_64 with GCC/G++ and Ninja. Unix Makefiles
receives a focused configure/build check during Stage 2. Exact distribution
and tool versions must be recorded with the results but are not baseline
requirements. Other architectures or generators within the accepted pair may
be recorded, but they do not become release-qualified merely because the
firewall admits them.

A trusted native Linux/GCC validator is now available for Stage 2. A Windows
GCC or MinGW toolchain would not provide equivalent evidence: it targets the
Windows ABI, exposes Windows platform state, and is itself outside the
supported matrix. Linux validation may also run on a trusted CI runner, Linux
virtual machine, or Linux container that reports a native Linux x86_64 target
and uses GCC/G++. The exact environment and versions must be recorded with the
results.

### Consumer boundary

The firewall applies when configuring the HDF5 source tree and retained
standalone HDF5 example projects. Installed CMake package files must not
advertise that HDF5 itself can be built on removed environments. They must not,
however, reject an arbitrary downstream consumer compiler unless an existing
binary-compatibility rule independently requires that rejection. Build support
and the ability to consume a compatible prebuilt library are separate
contracts.

### Source boundary

After the CMake reduction has passed both retained platform gates,
project-owned C and C++ sources, private headers, installed headers,
generated-header templates, tests, and retained examples are reduced to the
same two-pair contract. Conditions, shims, and alternate implementations used
only by rejected platforms or compilers are removed.

Generic `_WIN32` versus POSIX implementation separation remains when it serves
the retained Windows/MSVC and Linux/GCC pairs. Architecture- and
generator-specific code reachable within either accepted pair is not
unsupported-only code and must be preserved or separately justified.
File-format constants, serialized representations, public ABI definitions
required on an accepted pair, and code needed to read files created on another
platform are compatibility behavior, not unsupported build support, and are
preserved.

## Compatibility Impact

This is an intentional breaking build and source portability change:

- MinGW, MSYS2, Cygwin, Clang and clang-cl, Intel, IntelLLVM, NVHPC, PGI,
  AOCC, Emscripten, macOS, BSD, and all other unlisted target-system/compiler
  pairs stop at configuration or lose their repository-provided entry point.
- Unsupported toolchain files, presets, cache options, dashboards, workflows,
  compiler dispatch, flags, platform packaging, and active documentation are
  removed.
- Windows/MinGW shared-library naming and static GCC runtime linkage behavior
  are removed.
- Cache options used only by removed toolchains are deleted instead of being
  retained as ignored aliases.
- Source and header compatibility branches, shims, and tests used only by
  rejected platforms or compilers are removed after the retained CMake matrix
  is validated. Installed headers are no longer required to compile with an
  unsupported toolchain.
- Existing HDF5 file-format compatibility, the C ABI on retained platforms,
  public target names, product components, and the existing Java/Fortran
  removal are unchanged.

Historical release notes remain unchanged. Current installation, option,
preset, example, and CMake usage documentation describe only the retained
matrix.

## Scope Boundaries

### Overall scope

- CMake entry points, modules, presets, toolchains, cache options, dashboards,
  workflows, packaging logic, and current build documentation.
- Project-owned C and C++ implementation files, private and installed headers,
  generated-header templates, tests, utilities, tools, and retained examples
  containing compatibility code solely for rejected environments.
- Windows/MSVC and Linux/GCC build, test, install, package, and consumer
  validation appropriate to each changed layer.

### Stage 1 scope

- Central validation for the root source build and retained standalone example
  entry points, limited to target-system/compiler pairs.
- Active `CMakeLists.txt`, `.cmake` modules, CMake package templates, presets,
  toolchain files, cache initialization, CTest/dashboard scripts, and CMake
  documentation.
- CI workflows whose project-build jobs use removed platforms or compilers.
- Compiler warning-data files used only by removed CMake compiler modules.
- Windows/MSVC contract, configure, build, test, install, package, and consumer
  validation that the available environment can execute.
- Static classification of every Linux/GCC-sensitive rewrite whose native
  validation is deferred.

### Explicitly out of Stage 1

- Changes to C or C++ implementation files and tests.
- Removal or rewriting of `__MINGW32__` or other platform guards in installed
  headers, public headers, private headers, or source files.
- Removal of architecture- or generator-specific behavior that remains
  reachable with MSVC on Windows or GNU on Linux.
- Removal of file-format constants, ABI compatibility definitions, generic
  `_WIN32`/POSIX source separation, or generated public-header placeholders.
- C17 or C++20 language migration.
- Java or Fortran restoration.
- Removal of C++, MPI, thread safety, concurrency, filters, plugins, VOL, VFD,
  tools, utilities, or retained examples merely because a local prerequisite
  is unavailable.
- Rewriting historical release notes that accurately describe earlier support.
- Treating a Windows GNU build, MinGW cross-build, synthetic script test, or
  cross-compilation probe as native Linux/GCC evidence.

The source and header items above are deferred from Stage 1, not excluded from
the overall direction. They are mandatory Stage 3 work after Stage 2
establishes a repeatable Linux/GCC validator. If that validator is unavailable,
the project may stop at the explicitly incomplete Stage 1 handoff rather than
substituting Windows GCC evidence or making unvalidated source changes.

## Retained-Pair Model

Mechanical CMake reductions use these two platform/compiler pairs. A condition
is simplified only after its result is recorded for both pairs. Architecture
and generator values vary within each pair and therefore cannot justify an
always-true or always-false reduction.

| CMake state | Windows/MSVC pair | Linux/GCC pair |
| --- | --- | --- |
| `CMAKE_SYSTEM_NAME` | `Windows` | `Linux` |
| C compiler ID | `MSVC` | `GNU` |
| C++ compiler ID, when enabled | `MSVC` | `GNU` |
| `WIN32` / project `WINDOWS` | true | false |
| `UNIX` | false | true |
| `MSVC` | true | false |
| `MINGW`, `MSYS`, `CYGWIN`, `APPLE` | false | false |
| Release-validation generator | Visual Studio generator | Ninja; Unix Makefiles focused check |
| Release-validation architecture | x64 | x86_64 |

The last two rows are baselines, not fixed truth values for accepted builds.
Conditions depending on them require separate classification.

### Mechanical reduction classes

Every active match is assigned to one of these classes before editing:

1. **Always false:** delete the branch and any file referenced only by it.
2. **Always true:** unwrap the branch and retain its body.
3. **Retained selector:** rewrite the condition to an explicit Windows or Linux
   selector.
4. **Mixed feature semantics:** remove unsupported alternatives but retain the
   feature probe or dependency decision needed by one accepted pair.
5. **Deferred source reference:** preserve and classify source guards during
   Stages 1 and 2 so Stage 3 can remove or justify them with source-level
   validation.
6. **Non-build reference:** preserve historical text, formatters, analyzers,
   shell portability, interoperability notes, or third-party content.

The following table is the starting rule set, not permission for blind textual
replacement:

| Existing condition family | Result on retained matrix | Default rewrite |
| --- | --- | --- |
| `MINGW`, `MSYS`, or `CYGWIN` | false on both rows | Delete branch |
| `NOT MINGW`, `NOT CYGWIN`, or `NOT APPLE` | true on both rows | Remove wrapper, retain body |
| `WIN32 AND NOT MINGW` | Windows only | Rewrite as explicit Windows logic |
| `MINGW OR NOT WINDOWS` | Linux only | Rewrite as explicit Linux logic |
| `UNIX AND NOT APPLE` | Linux only | Rewrite as explicit Linux logic |
| Apple, Darwin, BSD, or Emscripten branch | false on both rows | Delete branch |
| MSVC or Intel-on-Windows branch | Windows only | Retain the MSVC arm only |
| GNU or Clang branch | Linux only | Retain the GNU arm only |
| Unsupported compiler flag dispatch | false on both rows | Delete dispatch and private module |
| Windows plus MinGW generator expression | Windows only | Retain the Windows expression only |

A mixed condition is not removed merely because it contains an unsupported
name. For example, header checks, type-size checks, thread discovery, socket
libraries, `dl`, `m`, `rt`, RPATH, PIC, and static/shared naming can encode
retained Linux behavior. The unsupported arm is removed and the retained probe
is left intact until its result is logically established.

## Inventory and Classification

Re-run the inventory immediately before each work package. Search active CMake,
preset, workflow, package, and current-documentation files for at least:

```text
MINGW MSYS MSYS2 CYGWIN Clang AppleClang Intel IntelLLVM
NVHPC PGI AOCC APPLE Darwin FreeBSD OpenBSD NetBSD Emscripten
```

The initial inventory identifies these major ownership areas:

- `config/ConfigureChecks.cmake` for platform flags and mixed feature checks;
- `config/HDFMacros.cmake` and `config/HDF5Macros.cmake` for naming, imported
  locations, and platform link behavior;
- `config/flags/` for compiler dispatch and warning/option modules;
- `config/toolchain/` and `HDF5Examples/config/toolchain/` for unsupported
  compiler, cross-build, and 32-bit entry points;
- root and example `CMakePresets.json` plus hidden preset files;
- `CMakeBuildOptions.cmake`, cache initialization files, and current option
  documentation for private removed options;
- root/example CTest scripts and `.github/workflows/` for removed build jobs;
- root and standalone example CMake entry points for firewall coverage; and
- current installation, usage, preset, and packaging documentation.

Do not count a keyword match as removable until it is classified. In
particular, preserve `clang-format`, formatter workflows, and analyzer tooling
that do not compile HDF5 with an unsupported compiler. Preserve source-level
matches during Stages 1 and 2 and carry their classification into Stage 3.
Preserve factual historical release notes. Ignore generated build/install
trees and downloaded third-party content.

## Execution Principles

1. Land the central firewall before deleting compatibility paths.
2. Use exact compiler IDs; do not use `MSVC` alone where clang-cl or Intel
   front ends must be distinguished.
3. Reduce conditions against both retained states instead of performing a
   repository-wide keyword replacement.
4. Preserve Linux/GCC logic and architecture/generator variants within both
   accepted pairs structurally when native execution is unavailable.
5. Do not infer Linux correctness from Windows, MinGW, cross-compilation, or
   synthetic variable tests.
6. Keep one condition family, compiler family, entry-surface family, or
   documentation family per atomic commit.
7. Capture the affected MSVC File API or generated-project baseline before
   every behavior-changing batch and explain every retained-contract delta.
8. Leave source and public-header compatibility cleanup outside Stage 1, then
   complete it as mandatory Stage 3 work.
9. Record unavailable optional dependencies as validation gaps; do not remove
   the corresponding product feature.
10. Stage 1 can close with Linux validation deferred. The overall plan cannot
    close until Stages 2 through 4 pass.
11. Record every repository modification made while executing this plan as an
    atomic local Git commit after its required checks pass. Each commit has one
    reviewable purpose, is independently revertible, and excludes unrelated
    edits and generated artifacts. Pure validation produces no commit; portable
    evidence updates use focused `docs:` checkpoints.

## Completed Prerequisite: Support Contract

Commit `912fb436b` established the original support matrix, recorded the
breaking build change, selected the Windows validation generator, defined the
deferred Linux baseline, and updated the CMake modernization compatibility
contract. The 2026-09-04 admission-policy correction supersedes its generator
and architecture restrictions while retaining the two target-system/compiler
pairs. No source code changes are part of either contract definition.

## Stage 1: CMake Reduction and Windows/MSVC Validation

### Work Package 1A: Central CMake Firewall

Create one focused module under `config/cmake/`. Its public function validates
one or more enabled languages using the detected target system and exact
compiler ID. Call it only after the relevant `project()` or language-enabling
operation has completed. It must not reject a configuration based only on its
generator, architecture, or compiler version.

Apply the same implementation to:

- the root C project immediately after `project(HDF5 C)`;
- the first optional C++ entry points used by the main build;
- the retained standalone `HDF5Examples` C and C++ entry points; and
- any other entry point that repository documentation claims can be configured
  independently.

The distributed standalone examples must receive or locate the same policy
module. A small include wrapper is acceptable, but copying the validation
condition into multiple files is not. Subdirectories that cannot actually be
configured independently do not need duplicate checks after their parent has
validated the language.

The policy module must be side-effect free for accepted configurations. It
must not add cache options, definitions, flags, include paths, link libraries,
targets, or generated files.

#### Firewall tests

- Script-level positive cases for the two retained compiler pairs, including
  variations in generator and architecture. The synthetic Linux cases prove
  policy branching only; label them explicitly as not Linux configure/build
  validation.
- Script-level negative cases for unsupported operating systems, Windows with
  GNU or Clang, and Linux with MSVC or Clang.
- C and C++ compiler-ID cases.
- A check that `HDF5_ALLOW_UNSUPPORTED=ON` does not bypass rejection.
- A real default Windows/MSVC configuration, including an IDE-style profile
  that does not explicitly set `CMAKE_GENERATOR_PLATFORM`.
- A real unsupported compiler configuration only when such a compiler is
  installed and reaches language detection reliably.
- A before/after default MSVC File API comparison. The normalized contract must
  be identical because the accepted firewall is side-effect free.

#### Exit criteria

- Every supported source-build entry point reaches the same policy function.
- Accepted MSVC configuration behavior is unchanged.
- Negative diagnostics name both retained pairs and the rejected field.
- No unsupported compatibility implementation is deleted in this commit.

#### Commit boundary

`cmake: Reject unsupported platform compiler pairs`

### Work Package 1B: Remove Unsupported Entry Surfaces

After the firewall lands, remove repository-provided ways to select unsupported
builds:

- MinGW, Clang, Intel, PGI/NVHPC, and other unsupported toolchain files under
  both root and example configuration trees;
- Wine launchers and MinGW/MSYS cross-compilation helpers;
- repository-provided cross-compilation helpers that combine accepted and
  rejected compiler/platform paths and are not part of a retained validation
  workflow; their removal does not make architecture a firewall input;
- root and example configure, build, test, package, and workflow presets outside
  the retained release workflows, including Windows ARM and macOS presets; the
  removal of a convenience preset does not make its architecture a firewall
  rejection;
- unsupported CTest/dashboard selection paths; and
- unsupported CI build jobs and callers, without deleting formatter/analyzer
  workflows that remain useful.

Calling a deleted preset or repository toolchain path may report that the
entry no longer exists. Supplying an external but detectable unsupported
toolchain must reach the central firewall and report the supported matrix.

#### Validation

- Parse/list both root and example presets after each preset batch.
- Configure every retained Windows/MSVC preset that is meaningful locally.
- Confirm retained Linux/GCC presets reference only files that still exist.
- Search workflow callers for dangling `uses`, preset, and toolchain names.
- Confirm no deleted file is referenced by active CMake or current docs.

#### Commit boundaries

- `cmake: Remove unsupported toolchain entry points`
- `cmake: Remove unsupported build presets`
- `ci: Remove unsupported platform build workflows`

### Work Package 1C: Remove Unsupported Cache Options

Remove declarations, cache initialization, preset assignments, generated cache
documentation, and all consumers of options that have no behavior on the two
accepted pairs. This includes at least:

- `HDF5_MINGW_STATIC_GCC_LIBS`;
- the ineffective `HDF5_MSVC_NAMING_CONVENTION`, whose declaration requires
  MSVC while its implementation requires MinGW; and
- macOS/framework or unsupported compiler options confirmed to have no
  retained consumer.

Do not retain ignored compatibility aliases. Do not delete an option merely
because its name is platform-oriented if either accepted pair still consumes it.

#### Validation

- Configure the default MSVC build and inspect cache help/advanced state.
- Confirm removed names are absent from presets, cache initializers, current
  option documentation, generated settings, and active CMake.
- Compare the retained option and target contract, allowing only the approved
  deletion of unsupported options.

#### Commit boundary

Use one commit for MinGW-only options and a separate commit for other platform
families when their compatibility impact differs.

### Work Package 1D: Mechanically Reduce Platform Conditions

Process active CMake conditions in bounded ownership groups:

1. MinGW/MSYS runtime, ANSI stdio, socket, feature-check, and test behavior.
2. Windows library naming, DLL/import-library locations, and generator
   expressions.
3. Cygwin alternatives.
4. Apple/macOS, BSD, and Emscripten branches.
5. CTest/dashboard platform behavior.
6. Standalone example platform behavior.

For each group, record the two retained-pair truth values, classify the rewrite,
then change only that group. Preserve conditions whose result can vary by
architecture or generator within an accepted pair. Replace broad negative
selectors such as `NOT WINDOWS` with explicit Linux selectors where the policy
makes Linux the only possible result. Do not replace actual feature detection
with a platform assumption merely to reduce the number of checks.

#### Validation

- Capture affected MSVC File API records or generated Visual Studio project
  properties before editing.
- Reconfigure and compare compile definitions, include directories, compile
  options, link libraries/options, artifact names, generated files, and tests.
- Build the narrowest affected static/shared targets and run focused tests.
- For every Linux-sensitive edit, record its retained-state proof and mark
  native execution as deferred.
- Run a static reference check after each ownership group.

#### Exit criteria

- Active CMake logic contains no MinGW, MSYS2, Cygwin, Apple/macOS, BSD, or
  Emscripten behavior branch.
- Retained Windows behavior has no unexplained delta.
- Every Linux rewrite has a documented logical derivation and an explicit
  Stage 2 validation owner.

#### Commit boundaries

Keep feature checks, library naming, runtime linkage, test behavior, dashboard
logic, and example logic independently reviewable.

### Work Package 1E: Reduce Compiler Dispatch

Simplify compiler selection to exactly two outcomes:

- MSVC requirements for the retained Windows row; and
- GNU C/G++ requirements for the retained Linux row.

Remove Clang/AppleClang, Intel/IntelLLVM, NVHPC/PGI, AOCC, and other
unsupported dispatch arms, private flag modules, toolchain files, and warning
data referenced only by those modules. Preserve GNU modules and any genuinely
shared helper they use.

Review instrumentation separately:

- retain sanitizer behavior supported by MSVC or GCC;
- retain GCC coverage behavior;
- remove compile-toolchain selection for unsupported compilers; and
- retain `clang-format`, `clang-tidy`, and similar developer tools when they
  act as formatters or analyzers rather than the HDF5 build compiler.

#### Validation

- Configure MSVC with default warnings, developer warnings, and locally
  available sanitizers/instrumentation.
- Compare affected target option and link contracts.
- Statically trace every retained GNU include and helper to ensure no deleted
  module owns shared GCC behavior.
- Defer actual GCC option/link validation to Stage 2.

#### Commit boundaries

Use one commit per removed compiler family or one tightly coupled dispatch
family. Do not combine compiler cleanup with unrelated platform packaging.

### Work Package 1F: Current Documentation and Packaging Metadata

Update current installation, option, usage, example, preset, CI, and packaging
documentation to advertise only the retained target-system/compiler pairs and
to distinguish them from the narrower release-validation baselines. Remove
unsupported compiler/platform package names, framework/DMG paths, and
toolchain instructions from active documentation and CMake packaging logic.

Preserve:

- historical release notes;
- developer-tool references such as `clang-format`;
- downstream-consumer instructions that remain ABI-compatible; and
- source-level compatibility notes that remain factually present until Stage 3.

Generated settings, source/build package manifests, and installed CMake files
must not reference deleted files or claim unsupported source-build support.

#### Validation

- Search current docs separately from historical release material.
- Configure package generation on MSVC and inspect source/binary package file
  lists where locally available.
- Configure the distributed standalone examples using the retained shared
  policy module.
- Confirm installed package consumption is not over-constrained beyond existing
  ABI rules.

#### Commit boundary

`docs: Remove unsupported toolchain instructions`, with packaging behavior in a
separate `cmake:` commit when generated artifacts change.

### Work Package 1G: Windows/MSVC Validation Gate

Stage 1 finishes with the strongest locally available retained-platform gate.

#### Required core rows

- Default static plus shared Release configure and build.
- Static-only and shared-only Release configure and build.
- Default Debug configure and build.
- C++ enabled in at least one static and one shared configuration.
- Default Release full CTest suite at recorded `HDF_TEST_EXPRESS`, normally 3.
- Install tree and CMake package generation.
- At least one build-tree and one install-tree external consumer.
- Standalone retained C and C++ examples against a retained HDF5 build/package.

#### Optional rows when prerequisites are available

- Parallel HDF5 with Microsoft MPI.
- Thread-safe and multi-thread concurrency configurations within documented
  option constraints.
- System and bundled compression.
- Plugins, VOL, ROS3, HDFS, subfiling, and signed plugins.
- Packaging formats whose external tools are installed.

An unavailable optional prerequisite is recorded as a Stage 1 validation gap;
it does not authorize removing the feature and does not by itself prevent the
CMake-layer milestone when the affected logic was not changed.

#### Required comparisons

- File API cache/target contract for retained options and targets.
- Static/shared output names, DLL import libraries, PDB handling, runtime
  placement, install destinations, and exported targets.
- Registered test counts and fixture relationships.
- Build-tree, install-tree, `add_subdirectory()`, and FetchContent behavior that
  can be exercised locally.

Use out-of-source MSVC builds, set `CL=/utf-8`, and keep build and CTest
parallelism at or below 6. Record exact options and test express level.

### Stage 1 Completion Criteria

Stage 1 is complete when all of the following are true:

1. The central firewall accepts only the two approved target-system/compiler
   pairs, covers C and optional C++ entry points, and does not reject only on
   generator, architecture, or compiler version.
2. Active CMake source-build logic has only Windows/MSVC and Linux/GCC outcomes.
3. Unsupported toolchains, presets, build workflows, private options, compiler
   modules, platform packaging, and current support claims are removed.
4. Every remaining unsupported keyword match is classified as source-level,
   historical, developer tooling, shell portability, third-party content, or a
   defect with an owner.
5. Required Windows/MSVC core rows pass, with all retained-contract differences
   explained.
6. Linux/GCC-sensitive rewrites have explicit two-pair logical proofs and a
   Stage 2 validation checklist.
7. No C/C++ source or header compatibility guard was changed.
8. `REFACTORING_PROGRESS.md` distinguishes the accepted compiler pairs from
   the release-validation architectures and generators, and states exactly
   which Windows/MSVC and Linux/GCC gates remain incomplete.

The accepted Stage 1 status is:

> CMake platform/compiler reduction implemented; Windows/MSVC validated;
> Linux/GCC retained by logical reduction but not yet validated; architecture
> and generator remain outside the central firewall.

It must not be shortened to "platform reduction complete."

### Recorded Stage 1 Result

Stage 1 is complete because all completion criteria now pass, including the
required Windows/MSVC gate in criterion 5. The current status is:

> CMake platform/compiler reduction implemented; Windows/MSVC validated;
> Linux/GCC retained by logical reduction but not yet validated; architecture
> and generator remain outside the central firewall.

The implementation consists of the 19 focused CMake/CI commits from
`0adb08f4a` through `b317dedc9`; the admission-policy correction and current
support-documentation update are anchored at `614dd74c0`. No Stage 1 CMake
commit changes a C/C++ implementation file or header. The separate source
repair is anchored at `a68b4cae4e`.

#### Admission-policy correction

The 2026-09-04 correction separates source-build admission from release
qualification:

- the central firewall checks only target system and exact compiler ID;
- generator, architecture, and compiler version do not cause firewall
  rejection;
- the existing x64 Visual Studio and x86_64 Linux workflows remain the
  release-validation baselines;
- synthetic cases prove that generator and architecture variations within an
  accepted compiler pair reach normal project configuration; and
- previously removed architecture- or generator-specific CMake behavior is
  re-audited before Stage 3 and restored when it is still reachable within an
  accepted pair and affects product correctness.

The correction restored the MSVC ARM64 Debug option, ARM64 package naming, and
32-bit NSIS install-root selection. Architecture-specific presets, CI,
dashboard choices, and bundled cross-toolchain helpers remain outside the
release-validation surface; users may still supply another generator or
toolchain file that resolves to an accepted target-system/compiler pair.

#### Completed validation

- All 12 corrected synthetic firewall cases pass. They cover both accepted
  compiler pairs, generator and architecture variation, C and optional C++
  compiler checks, rejected target systems and compilers, and confirmation that
  `HDF5_ALLOW_UNSUPPORTED` cannot bypass the firewall.
- Root and standalone-example preset listing passes.
- Two Windows/MSVC CLion-style configures using the Visual Studio 18 2026
  generator without `-A x64` pass configure and generation with MSVC
  `19.51.36256.0`: the default C configuration and a configuration with
  `HDF5_BUILD_CPP_LIB=ON`. An empty `CMAKE_GENERATOR_PLATFORM` is no longer
  interpreted as an unsupported target architecture, and the optional C++
  compiler check follows the same pair-only policy.
- CLion reports no inspection problems in the firewall, its script-level
  tests, the restored MSVC architecture flags, or the restored installation
  architecture handling.
- The default cache retains `HDF5_BUILD_CPP_LIB=OFF` and
  `HDF_TEST_EXPRESS=3`.
- Clean before/after File API contracts contain 17,323 identical records.
- A source-package ZIP generated from a clean source tree has 4,092 entries and
  contains neither local build/IDE metadata nor deleted Cygwin documentation or
  unsupported-toolchain paths.
- Generated package metadata reports `Windows x64, using VISUAL STUDIO 2026`.
- A C++-enabled Windows/MSVC Release build with static and shared libraries,
  tests, tools, and retained examples completes using the Visual Studio 18 2026
  generator without an explicit `-A` argument.
- Full CTest at `HDF_TEST_EXPRESS=3` passes all 2,851 enabled tests with 37
  disabled out of 2,888 registered tests, using six parallel jobs.
- A fresh default Release configure and complete build passes with static and
  shared libraries, tests, tools, high-level libraries, and examples enabled
  and C++ disabled. Full CTest at `HDF_TEST_EXPRESS=3` passes all 2,816 enabled
  tests with 37 disabled out of 2,853 registered tests.
- Fresh static-only Release, shared-only Release, and default Debug builds pass.
  Each passes the same focused C, high-level, and tool smoke selection plus its
  fixtures: seven tests per configuration.
- The default Release output contains `hdf5.dll`, its `hdf5.lib` import library,
  and `libhdf5.lib`. Static-only omits the DLL and import library, shared-only
  omits the static library, and the high-level library follows the same naming
  and placement pattern.
- Debug output contains `hdf5.pdb`, `libhdf5.pdb`, high-level PDBs, and tool
  PDBs. Debug installation places library and tool PDBs with runtime artifacts
  in `bin`.
- Release installation of the C++-enabled combined build passes and contains
  C, high-level, C++, and C++ high-level static and shared libraries, runtime
  DLLs, tools, headers, package configuration, and separate static/shared
  export sets. The exported target files include all four library families.
- CPack ZIP generation passes. The 164-entry binary archive includes the
  expected C/C++ runtime and library artifacts.
- Standalone retained C, C++, and high-level examples configure and build
  against both the build-tree package and the installed package. Each tree
  passes all 279 registered tests.
- Minimal external `add_subdirectory()` and local-source FetchContent consumers
  each configure, build, link to `hdf5-static`, and pass their execution test.
- A user-provided vcpkg-exported Microsoft MPI SDK is usable with the installed
  Microsoft MPI runtime. Parallel HDF5 configures and completes a full Release
  build with 3,108 registered tests. A focused selection covering the core
  parallel library, MPI behavior, a parallel tool, and parallel examples passes
  all nine tests and fixtures.
- Fresh thread-safe and multi-thread concurrency configurations each build the
  shared library and `testhdf5`. The focused base test and its fixtures pass
  three of three tests in each configuration.
- CMake finds Strawberry Perl `5.42.3` after the process environment is
  refreshed. Perl is not a remaining prerequisite gap.

#### Resolved Windows blocker

Formatting commit `b22b55872` removed four trailing semicolons after
`HDONE_ERROR(...)` calls. The failure was recorded while it was current, but
source repair `a68b4cae4e` restored all four terminators before the current
`HEAD`. CLion now reports no errors in the four files, the static library target
builds, and the complete C++-enabled Release build and CTest pass. The previous
claim that current validation was blocked by those lines was stale.

Work Package 1G is closed. The default full suite covers the enabled in-tree
plugin and VOL tests. The remaining environment-limited optional rows are:

- direct pkg-config consumption, because `pkg-config` is not installed;
- system compression, because zlib and libaec development packages are absent;
- external filter plugins, because no HDF5 filter-plugin installation is
  available to supply `HDF5_PLUGINS_DIR`;
- ROS3, because the `aws-c-s3` development package is absent;
- HDFS, because a JDK/JNI and Hadoop/libhdfs installation are absent;
- signed plugins, because OpenSSL development files are absent;
- parallel tools, because mpiFileUtils, libcircle, and DTCMP are absent; and
- additional Windows installer formats, because NSIS and WiX are absent. ZIP
  packaging is validated.

Bundled zlib and libaec source retrieval and dependency configuration succeed,
but CMake generation fails because HDF5 export sets reference bundled `zlib`,
`aec-shared`, and `sz-shared` targets that are not themselves in an export set.
The initial Stage 1 diagnosis classified this as a non-environment optional-path
defect outside the reduction. That attribution was superseded by the
[Stage 2 diagnosis](CMakePlatformSupportReductionStage2Results.md#failure-classification):
build-tree export commit `99fbd083b` introduced the Stage 1 regression, and
`81e96c889` fixed it with passing Linux/GCC and Windows/MSVC checks. It is not a
current blocker. Subfiling is intentionally unavailable on Windows and remains a
Stage 2 Linux/parallel row. None of these optional gaps removes feature support,
invalidates the required Stage 1 gate, or substitutes for Stage 2 native
Linux/GCC validation.

#### Residual classification

- Active CMake matches are firewall rejection cases, `clang-format` and
  `clang-tidy` developer tooling, or AppleClang/macOS comments documenting
  retained generic `_Float16` feature probes.
- Current-documentation matches are explicit unsupported-platform policy,
  historical release or HPC descriptions, developer tooling, and Intel native
  datatype or file-format interoperability documentation.
- Sixty tracked C/C++ source or header files retain matches for mandatory Stage
  3 review: `APPLE=4`, `CLANG=234`, `CYGWIN=6`, `DARWIN=3`, `FREEBSD=4`,
  `INTEL=43`, `MACOS=12`, `MINGW=10`, `NETBSD=2`, and `PGI=4`.

#### Linux/GCC owner disposition

Every Stage 1 implementation commit was covered by Stage 2 native Linux/GCC
validation. The logical-review groups were:

- firewall and optional C++ enforcement: `0adb08f4a`, `865065e7b`;
- presets, toolchains, dashboards, and CI: `7263d8fde`, `49970ae08`,
  `41042a76c`, `76439467a`;
- MinGW and Cygwin option/platform/test paths: `b2c915c23`, `5c8d56a0e`,
  `401dda200`, `6007a43ec`;
- Apple, Emscripten, and UCB platform paths: `a627c243f`, `4c9193e7e`,
  `65df2d816`;
- compiler and instrumentation dispatch: `1780c6a3a`, `be753730b`,
  `81097024f`, `67c2bae01`;
- packaging and residual CMake paths: `7c9e4b0da`, `b317dedc9`.

Native execution of these groups and the admission-policy correction passed on
the release-qualified Linux baseline. Stage 2 is complete after the user
explicitly deferred the six unavailable non-required optional configurations.
Stage 3 subsequently completed at `74288cbaa`. Stage 4 Work Package 4A
qualified fresh baselines and reproduced its two required defects. Work Package
4B completed the repository contract audit and its six focused implementation
repairs at `ebdb99969`.

## Stage 2: Native Linux/GCC Validation

The self-contained execution plan is
[`CMakePlatformSupportReductionStage2.md`](CMakePlatformSupportReductionStage2.md).
Execution results are recorded in
[`CMakePlatformSupportReductionStage2Results.md`](CMakePlatformSupportReductionStage2Results.md).
Read both documents together with `REFACTORING_PROGRESS.md`; the Stage 1
sections above remain the compatibility contract and historical rationale
rather than the Stage 2 runbook.

Stage 2 has two validation layers:

1. A fixed native Linux/GCC core gate covering the default Release and Debug
   builds, static/shared forms, the directly affected optional C++ entry path,
   retained generators and examples, installation, packaging, consumers, and
   normalized CMake-contract review.
2. Environment-driven optional validation. Probe the supplied validator without
   changing it, execute every legal optional row whose prerequisites are
   already available, and present every missing prerequisite to the user for a
   test-or-defer decision.

Every available selected row must pass. A code failure is not an environment
gap; a Stage 1 regression must be corrected, while an independent defect needs
an explicit user scope decision. Every repository modification is an atomic,
independently revertible local commit. Passing Stage 2 establishes the
repeatable Linux/GCC validator required for later source-level work but does not
authorize that work or complete the overall direction.

## Stage 3: Source-Level Reduction

The completed self-contained execution plan is
[`CMakePlatformSupportReductionStage3.md`](CMakePlatformSupportReductionStage3.md).
It removes project-owned source and header compatibility code used only by
rejected platform/compiler pairs while preserving retained API, ABI,
file-format, architecture, and runtime behavior. All work packages and the
dual-platform final gate passed; detailed evidence is in
[`CMakePlatformSupportReductionStage3Results.md`](CMakePlatformSupportReductionStage3Results.md).
The completion review closed on 2026-09-05 with the Linux plugin filename
restriction explicitly accepted and the header-comparison evidence corrected.
Stage 3 is marked Completed.

## Stage 4: Final Project Audit Plan

The approved direction is a final repository-wide audit against the two-pair
support contract after source reduction. Stage 3 is Completed. The user accepted
the audit recommendations, inherited boundaries, and review clarifications on
2026-09-05. The separate [Stage 4 plan](CMakePlatformSupportReductionStage4.md)
is in progress. Work Packages 4A and 4B are complete, with evidence in the
[Stage 4 results](CMakePlatformSupportReductionStage4Results.md); Work Package
4C is next. Prefer CLion MCP and use the temporary Stage 4 build/CTest cap of
four per physical host, with Windows and WSL sharing the same budget. This
execution cap is not a repository default or product compatibility value.

The plan covers baseline capture, repository support consistency, focused
repairs of utility test registration and the optional API driver, delivered
products and consumers, and a final dual-platform gate. It preserves accepted
Stage 3 evidence limits and optional deferrals. Completing 4A and 4B does not
complete Stage 4 or resume general modernization.

## Stage 1 Planned Commit Sequence

1. `cmake: Reject unsupported platform compiler pairs`
2. `cmake: Remove unsupported toolchain entry points`
3. `cmake: Remove unsupported build presets`
4. `cmake: Remove MinGW-only cache options`
5. `ci: Remove unsupported platform build workflows`
6. `cmake: Simplify MinGW platform checks`
7. `cmake: Simplify Windows library naming`
8. `cmake: Remove MinGW runtime linkage branches`
9. Focused platform-family commits for Cygwin, Apple/BSD, and Emscripten logic
10. Focused compiler-family commits for Clang, Intel, NVHPC/PGI, and AOCC
11. `cmake: Remove unsupported platform packaging`
12. `docs: Remove unsupported toolchain instructions`
13. `docs: Record Windows platform-reduction validation`

Adjust ordering for proven dependencies, but keep each checkpoint buildable on
its stated validation environment. Do not combine all mechanical reductions in
one repository-wide commit.

## Stage 1 Stop Conditions

Stop only the affected batch and record the reason when:

- retained MSVC target, option, artifact, test, install, or consumer behavior
  changes without an approved compatibility reason;
- a condition cannot be assigned retained truth values without understanding a
  feature probe or dependency contract;
- deleting an unsupported compiler module would delete a helper still used by
  GNU C or G++;
- a public option or installed artifact change is outside the approved breaking
  build-system statement;
- a proposed edit reaches a C/C++ source file, installed header, or public
  header template; or
- a retained Linux path cannot be preserved structurally without native
  evidence.

The absence of native Linux/GCC alone is not a Stage 1 stop condition. It is an
explicit validation deferral. When a Linux-sensitive batch cannot be proven
statically, defer that batch rather than guessing or weakening the Stage 2
gate.

## Progress and Evidence Rules

After each coherent batch:

1. Update `REFACTORING_PROGRESS.md` with the newest implementation anchor.
2. Move only landed work into completed status.
3. Record exact configure/build/test evidence and the test express level for
   every executed retained-platform row.
4. Retain a visible list of Linux-sensitive commits awaiting Stage 2 until the
   core and selected optional evidence closes their validation ownership.
5. Record optional capability probes, missing prerequisites, and the user's
   test-or-defer decision without treating an unavailable feature as removed.
6. Do not include absolute local paths, transient build directories, generated
   logs, or machine-specific temporary files.
7. Use "Stage 1 complete", "CMake layer validated on both release baselines",
   "source reduction complete", and "overall plan complete" as distinct states.
