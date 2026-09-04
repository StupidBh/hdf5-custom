# Project Supported Platform Reduction Plan

## Status

- State: Stage 1 implementation complete; admission-policy correction implemented; Windows validation in progress
- Support contract approved: 2026-09-03
- Support-contract commit: `912fb436b`
- Admission-policy correction commit: pending
- CMake implementation commit: `b317dedc9`
- Source compilation repair commit: `a68b4cae4e`
- Current documentation commit: `6ad3399ec`
- Stage 1 CMake implementation commits: 19
- Current delivery stage: Stage 1 - remaining Windows/MSVC validation
- Primary available environment: Windows x64 with MSVC 18
- Unavailable local environment: native Linux x86_64 with GCC/G++
- Maximum local build and test parallelism: 6

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

The release-qualified validation baselines remain Windows x64 with the MSVC
toolset supplied by Visual Studio 18 2026 and Linux x86_64 with GCC/G++. The
baseline generators are not an exhaustive list of accepted CMake generators.
An architecture or generator outside those baselines may remain unvalidated,
but it is not rejected solely for that reason.

The delivery is intentionally split so each compatibility boundary can be
validated before the next one changes:

1. Stage 1 completes the CMake support-matrix reduction and Windows/MSVC
   validation. Linux/GCC CMake behavior is preserved by logical reduction, but
   native Linux/GCC validation is deferred.
2. Stage 2 validates the retained CMake and product behavior on native
   Linux/GCC using a trusted external environment.
3. Stage 3 removes source and header compatibility code for unsupported
   platforms and compilers, with every batch validated on both release
   baselines.
4. Stage 4 audits the whole repository against the final project-level support
   contract.

Stage 1 may be completed without a native Linux environment. That milestone
means the CMake firewall and cleanup have landed, retained Windows behavior has
been validated, and the Linux/GCC path has been preserved by static reasoning.
It does not mean Linux/GCC has been tested or that the overall plan is complete.

Stages 2, 3, and 4 are mandatory. The overall direction is not complete when
the CMake layer has been reduced, or when its first Linux validation passes.
It is complete only after the source-level reduction and final dual-platform
audit pass.

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
compatibility boundary. The pinned tool versions, architectures, and generators
below define validation baselines rather than the complete accepted surface.
Use exact `CMAKE_<LANG>_COMPILER_ID` comparisons: CMake's broader `MSVC`
boolean can also describe compilers that merely simulate the `cl` command-line
syntax.

### Validation baselines

The retained Windows baseline is Windows x64 with the MSVC 18 toolset supplied
by Visual Studio 18 2026, the `Visual Studio 18 2026` generator, and the Windows
SDK selected by that environment. Ninja, Ninja Multi-Config, IDE-managed CMake
profiles, and other generators are not rejected when they detect compiler ID
`MSVC`; they do not replace the Visual Studio baseline unless separately
validated and recorded.

The deferred Linux baseline is Ubuntu 24.04 LTS on x86_64, CMake 4.0.3,
GCC/G++ 13.3.0, and Ninja 1.11.1. Unix Makefiles receives a focused
configure/build check during Stage 2. Later patch releases and other
architectures or generators within the accepted pair may be recorded, but they
do not become release-qualified merely because the firewall admits them.

The current local machine does not provide native Linux/GCC. Installing a
Windows GCC or MinGW toolchain does not close this gap: it targets the Windows
ABI, exposes Windows platform state, and is itself outside the supported
matrix. Linux validation may run on a trusted CI runner, Linux virtual machine,
or Linux container that reports a native Linux x86_64 target and uses GCC/G++.
The exact environment and versions must be recorded with the results.

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
| Release-validation generator | Visual Studio 18 2026 | Ninja; Unix Makefiles focused check |
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

## Completed Prerequisite: Support Contract

Commit `912fb436b` established the original support matrix, recorded the
breaking build change, selected the Windows validation generator, pinned the
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

Use out-of-source MSVC 18 builds, set `CL=/utf-8`, and keep build and CTest
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

Stage 1 is not marked complete because completion criterion 5 has not passed.
The current status is:

> CMake platform/compiler reduction and admission-policy correction
> implemented; a C++-enabled Windows/MSVC Release build and full CTest pass;
> remaining Windows/MSVC rows are incomplete and Linux/GCC native validation is
> deferred.

The implementation consists of the 19 focused CMake/CI commits from
`0adb08f4a` through `b317dedc9`; current support-documentation cleanup is
anchored at `6ad3399ec`. No Stage 1 commit changes a C/C++ implementation file
or header. The separate source repair is anchored at `a68b4cae4e`. The
admission-policy correction is implemented in the current working tree; its
commit anchor remains pending.

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

#### Resolved Windows blocker

Formatting commit `b22b55872` removed four trailing semicolons after
`HDONE_ERROR(...)` calls. The failure was recorded while it was current, but
source repair `a68b4cae4e` restored all four terminators before the current
`HEAD`. CLion now reports no errors in the four files, the static library target
builds, and the complete C++-enabled Release build and CTest pass. The previous
claim that current validation was blocked by those lines was stale.

The remaining Windows work is the rest of the Work Package 1G matrix, including
default, static-only, shared-only, and Debug rows plus install, binary-package,
standalone installed-example, and external-consumer validation.

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

#### Deferred Linux/GCC owners

Every Stage 1 implementation commit remains owned by Stage 2 native Linux/GCC
validation. The logical-review groups are:

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

Native execution of these groups waits for the user-provided Linux environment.
The admission-policy correction also requires Stage 2 confirmation with the
pinned Linux baseline. Stage 2, Stage 3, and Stage 4 have not started.

## Stage 2: Deferred Native Linux/GCC Validation

Stage 2 runs on the pinned native Linux baseline or a trusted equivalent CI
runner. Record distribution, architecture, CMake, GCC, G++, generator/build
tool, MPI, and optional dependency versions before testing.

### Required configurations

- Default static plus shared Debug and Release builds.
- Static-only and shared-only Release builds.
- C++ enabled with both retained library forms across the exercised rows.
- Parallel HDF5 with a supported OpenMPI or MPICH configuration.
- Thread-safe and multi-thread concurrency configurations within documented
  constraints.
- Available system and bundled compression configurations.
- Install tree, pkg-config, CMake package, and external consumer builds.
- Standalone retained C and C++ examples.
- Both Ninja and Unix Makefiles configure/build coverage.

### Required checks

- Full default Release CTest suite at the recorded `HDF_TEST_EXPRESS` level.
- Focused tests for every optional row.
- Build-tree and install-tree `find_package` consumers.
- `add_subdirectory()` and FetchContent consumers.
- Installed wrapper scripts and pkg-config metadata.
- Static/shared SONAME, RPATH, PIC, system-library, and installation behavior.
- A real unsupported Linux compiler rejection when such a compiler is
  available.

### Failure handling

If Stage 2 exposes a lost GCC path, fix it in a focused commit and rerun the
affected Windows/MSVC contract checks. Restore retained GNU behavior, not the
removed unsupported platform or compiler family. Record every failure, root
cause, correction, and rerun result in the progress handoff.

### Stage 2 exit criteria

- All required Linux/GCC rows have recorded results.
- No Linux/GCC failure remains deferred without an owner.
- MSVC remains green after cross-platform corrections.
- The CMake-layer audit passes on both retained platforms.

Passing Stage 2 establishes the validator required for source-level work. It
does not complete the overall project platform-reduction direction.

## Stage 3: Mandatory Source-Level Reduction

Stage 3 removes project-owned source compatibility paths that cannot be reached
by either accepted pair. It starts only after Stage 2 provides a repeatable
Linux/GCC validation environment. That environment may be remote; it need not
run on the primary Windows development machine. Every behavior-changing batch
must pass the affected checks on Windows/MSVC and Linux/GCC before the next
source family is removed.

### Work Package 3A: Source Inventory and Baselines

Inventory project-owned C and C++ sources, private headers, installed headers,
generated-header templates, tests, tools, utilities, and retained examples for
at least the unsupported platform and compiler macros identified by the CMake
inventory. For every match, record:

- its truth value on the Windows/MSVC and Linux/GCC pairs, including whether
  architecture or generator changes that result;
- whether it changes compiled code, declarations, layout, calling convention,
  serialization, file interpretation, or only diagnostics;
- its public-header, ABI, or file-format impact;
- the focused tests and consumers that cover the retained behavior; and
- the Windows and Linux contract baseline used for its removal batch.

Classify generic `_WIN32`/POSIX selectors, architecture-specific behavior
reachable within an accepted pair, generator-specific build behavior, and
cross-platform file-reading logic as retained behavior. A macro name associated
with a removed platform is not by itself evidence that the surrounding
declaration or constant is removable.

### Work Package 3B: Internal Implementations and Tests

Remove unsupported-only conditions, shims, workarounds, and alternate
implementations from private headers, C and C++ implementation files, tests,
tools, utilities, and retained examples. Process one platform or compiler
family at a time. Unwrap branches that are always true across both accepted
pairs and their admitted architecture/generator variants, delete branches that
are always false, and keep explicit Windows/Linux selectors where both retained
implementations differ.

Update or remove tests that exist only for a rejected environment, but retain
portable behavior tests that still exercise a supported row. Add focused
coverage when removing a conditional would otherwise leave retained behavior
unverified.

### Work Package 3C: Installed and Generated Headers

Review installed headers and generated public-header templates separately from
private implementation cleanup. Remove unsupported compiler attributes,
calling-convention alternatives, type shims, and preprocessor paths only after
confirming that neither accepted pair nor the installed-package consumer
contract uses them.

Public-header edits require an explicit source-compatibility statement and a
`release_docs/CHANGELOG.md` entry. They must not change retained ABI layout,
symbol visibility, exported declarations, file-format constants, or the
ability to read valid files produced on other systems.

### Stage 3 Validation

- Format every touched C and C++ file with the repository formatter.
- Build affected static and shared libraries on Windows/MSVC and Linux/GCC.
- Run focused positive and failure-path tests on both release baselines.
- Re-run public-header compile consumers for C and C++ when installed or
  generated headers change.
- Compare affected ABI, exported-symbol, generated-header, install, and package
  contracts.
- Run the full default Release CTest suite on both release baselines after the final
  source batch, recording `HDF_TEST_EXPRESS`.
- Run `git diff --check` and classify every remaining unsupported macro match.

Windows GCC, MinGW, cross-compilation, and synthetic preprocessor definitions
do not satisfy any Stage 3 Linux validation requirement.

### Stage 3 Exit Criteria

1. No project-owned source or header branch exists solely to support a rejected
   platform or compiler.
2. Every remaining unsupported keyword match is historical text, developer
   tooling, third-party content, an interoperability requirement, or an
   explicitly justified retained contract.
3. Generic Windows/POSIX separation and file-format interoperability remain
   intact.
4. All affected Windows/MSVC and Linux/GCC builds, tests, installed-header
   consumers, and contract comparisons pass.
5. User-visible source portability changes are recorded in the changelog.

## Stage 4: Final Project Audit

Search active CMake, workflows, current documentation, project-owned sources,
headers, tests, tools, utilities, and examples for removed platform and compiler
families. Confirm that:

1. Windows/MSVC and Linux/GCC are the only advertised and accepted
   target-system/compiler pairs, while release-qualified architectures and
   generators are identified separately as validation baselines.
2. No repository entry point or project-owned implementation path exists solely
   for a rejected environment.
3. Both release baselines pass the final configure, build, test, install,
   package, and consumer gates after the last source change.
4. Current documentation and package metadata agree with the project-level
   policy, while historical release notes remain intact.
5. All remaining matches have a written classification and no retained-platform
   failure is deferred.
6. `REFACTORING_PROGRESS.md` records final implementation anchors and exact
   validation evidence.

Only after Stage 4 may the overall project platform-reduction direction be
marked complete.

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

## Stage 3 Planned Commit Sequence

The exact families depend on the Stage 3 inventory, but the minimum reviewable
sequence is:

1. `docs: Record source platform reduction inventory`
2. Focused `src:`, `test:`, `tools:`, `hl:`, `c++:`, or `examples:` commits for
   each unsupported platform/compiler family
3. A separate public-header compatibility commit when installed declarations
   change
4. `docs: Record project platform-reduction validation`

Do not combine private implementation cleanup, installed-header changes, and
unrelated platform families in one commit.

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

## Stage 3 Stop Conditions

Stop only the affected source batch when:

- the repeatable Linux/GCC validator required by Stage 2 is unavailable;
- retained behavior, ABI, file-format interpretation, or public declarations
  cannot be distinguished from unsupported portability code;
- architecture- or generator-specific behavior remains reachable within an
  accepted target-system/compiler pair;
- an unsupported macro also selects behavior used by a retained compiler;
- focused coverage cannot establish the retained behavior before deletion; or
- either release baseline has an unexplained contract or test regression.

These conditions require narrower analysis or restored validation capacity;
they do not authorize Windows GCC as substitute evidence or removal by textual
search alone.

## Progress and Evidence Rules

After each coherent batch:

1. Update `REFACTORING_PROGRESS.md` with the newest implementation anchor.
2. Move only landed work into completed status.
3. Record exact Windows configure/build/test evidence and the test express
   level.
4. Retain a visible list of Linux-sensitive commits awaiting Stage 2.
5. Record optional dependency gaps without treating them as removed features.
6. Do not include absolute local paths, transient build directories, generated
   logs, or machine-specific temporary files.
7. Use "Stage 1 complete", "CMake layer validated on both release baselines",
   "source reduction complete", and "overall plan complete" as distinct states.
