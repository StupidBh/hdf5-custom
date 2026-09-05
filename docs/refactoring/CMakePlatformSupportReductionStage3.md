# Stage 3 Source and Header Platform Reduction Plan

## Status

- State: Completed
- Plan drafted: 2026-09-04
- Scope approved: 2026-09-04
- Execution started: 2026-09-04
- Execution completed: 2026-09-05
- Completion review accepted: 2026-09-05
- Execution authorized: yes
- Plan commit: `31cf74435`
- Parent compatibility plan:
  [CMakePlatformSupportReduction.md](CMakePlatformSupportReduction.md)
- Portable handoff: [../../REFACTORING_PROGRESS.md](../../REFACTORING_PROGRESS.md)
- Completed prerequisite:
  [CMakePlatformSupportReductionStage2Results.md](CMakePlatformSupportReductionStage2Results.md)
- Execution results:
  [CMakePlatformSupportReductionStage3Results.md](CMakePlatformSupportReductionStage3Results.md)
- Source implementation baseline: `81e96c889`
- Final implementation anchor: `74288cbaa`
- Required target pairs: Windows with compiler ID `MSVC`, and Linux with
  compiler ID `GNU`
- Release-qualified baselines: Windows x64 with MSVC and a Visual Studio
  generator; Linux x86_64 with GCC/G++ and Ninja
- Secondary Linux generator check: Unix Makefiles
- Maximum build and CTest parallelism: 4

The user approved execution on 2026-09-04. Work Packages 3A through 3F and the
complete dual-platform validation gate finished on 2026-09-05. Detailed
implementation, compatibility, and validation evidence is recorded in the
Stage 3 results document. The completion review is closed after confirming the
Linux plugin filename restriction and correcting the header comparison
evidence. The separate [Stage 4 plan](CMakePlatformSupportReductionStage4.md)
is now Proposed; Stage 4 execution has not started.

## Purpose

Stage 3 aligns project-owned C and C++ source and header implementation with the
support boundary already established and validated by Stages 1 and 2. It removes
compatibility branches, shims, workarounds, tests, and alternate implementations
that exist only for rejected target-system/compiler pairs.

Stage 3 does not redefine the support boundary. The accepted endpoint remains:

| Target system | Required compiler ID |
| --- | --- |
| Windows | `MSVC` |
| Linux | `GNU` |

Generator, architecture, and exact compiler release remain validation
dimensions rather than central-firewall inputs. Source behavior reachable
through an accepted pair is not unsupported merely because it is outside the
release-qualified x64 or x86_64 baseline.

Passing Stage 3 means that the source and header layer implements the same
two-pair contract as the CMake layer. It does not complete the overall
platform-reduction direction. Stage 4 remains a separate final project audit
with its own plan and approval.

## Inherited Successes and Fixed Invariants

Stage 3 starts from completed, passing work and must preserve it.

### Stage 1

- The central CMake firewall accepts only Windows/`MSVC` and
  Linux/`GNU`, using exact compiler IDs.
- Generator, architecture, and compiler version do not independently reject an
  accepted pair.
- Unsupported toolchains, presets, CI jobs, compiler dispatch, packaging paths,
  cache options, and active CMake compatibility paths were removed in 19
  focused implementation commits.
- Windows/MSVC default, Debug, static-only, shared-only, C++, full CTest,
  install, ZIP package, standalone example, and consumer validation passed.
- Supported-pair architecture behavior restored by the admission-policy
  correction, including MSVC ARM64 Debug flags, ARM64 package naming, and
  32-bit NSIS install-root behavior, remains part of the contract.

### Stage 2

- The native Linux/GCC core matrix passed for default Release and Debug,
  static-only, shared-only, C++, Ninja, Unix Makefiles, examples, consumers,
  install, TGZ packaging, and normalized contract comparison.
- The default Ninja Release suite passed 2,819 tests with zero failures and 37
  disabled tests out of 2,856 registered tests at `HDF_TEST_EXPRESS=3`.
- Available wrapper, system-compression, bundled-compression, parallel,
  subfiling, thread-safe, concurrency, external-plugin, coverage, STGZ, and DEB
  rows passed.
- The bundled-compression export regression was repaired at `81e96c889`,
  and its Linux/GCC and Windows/MSVC consumer checks passed.
- Six unavailable, non-required optional configurations were explicitly
  deferred: parallel tools, ROS3, HDFS, signed plugins, RPM packaging, and a
  real unsupported native Linux compiler.

These results are regression baselines, not historical context that Stage 3 may
discard. A Stage 3 change that affects a previously passing row owns the
corresponding rerun.

## Scope Boundaries

### In scope

- Project-owned C and C++ implementation files in `src/`, `hl/`,
  `c++/`, `tools/`, and retained examples.
- Private, package-private, public, and installed headers.
- Generated-header templates and project-owned generated C sources, together
  with their canonical generator inputs.
- Serial and parallel tests containing unsupported-only compatibility behavior.
- Platform and compiler conditions, attributes, pragmas, shims, typedefs,
  wrappers, alternate implementations, and workarounds used only by rejected
  pairs.
- Focused CMake source-list or generation updates only when required by an
  approved source/header removal. Such changes must not alter the Stage 1
  firewall or support matrix.
- Current documentation and the changelog when source portability or installed
  header behavior changes are user visible.

### Out of scope

- Any change to the two accepted target-system/compiler pairs.
- Treating release-qualified generators, architectures, or compiler versions as
  exhaustive accepted values.
- C17 or C++20 migration, broad modernization, unrelated warning cleanup, or
  style-only refactoring.
- Restoring Java or Fortran.
- Removing C++, MPI, thread safety, concurrency, compression, plugins, VOL,
  VFD, tools, utilities, or retained examples because a prerequisite is
  unavailable.
- Rewriting historical release notes that accurately describe an earlier
  release.
- Stage 4 final repository audit work.

## Compatibility Preservation Rules

Every candidate must be evaluated semantically. Keyword presence is never
sufficient evidence for removal.

The following behavior is protected:

1. Generic `_WIN32` versus POSIX separation required by the two accepted
   pairs.
2. Architecture-specific behavior reachable with Windows/MSVC or Linux/GNU,
   including non-baseline architectures.
3. Generator-independent source behavior within an accepted pair.
4. Public C and C++ API names, exported symbols, ABI layout, library versioning,
   and supported-pair macro expansions.
5. HDF5 file-format constants, serialized representations, byte-order aliases,
   and the ability to read files created on another platform.
6. Feature probes and fallbacks that remain necessary on either accepted pair.
7. Developer tooling directives such as `clang-format` and
   `clang-tidy` when they do not select the HDF5 build compiler.
8. Third-party content and factual historical or interoperability comments.

For example, `H5T_INTEL_*` names describe public little-endian predefined
datatypes. They are file-format and API compatibility names, not Intel compiler
support, and must remain. Likewise, text such as "unlike Intel" in an endianness
description is not a source-build compatibility path.

An installed header may lose an unsupported compiler branch only when its
declarations, layout, and expansion on both accepted pairs are unchanged or the
change is an explicitly approved part of this breaking portability direction.
No public symbol deletion or file-format change is approved by this plan.

On 2026-09-05, the user explicitly confirmed retaining the Stage 3 Linux
plugin filename restriction: discovery accepts the retained `lib*.so`
convention and skips `.dylib` filenames, including ELF plugins renamed with
that suffix. This is an accepted filename-contract narrowing, not a change
to the generated Linux plugin format or a requirement to restore macOS support.

## Atomic Local Commit Discipline

Every repository modification made while executing this plan must be recorded
as an atomic local Git commit after its required checks pass. Each commit must:

- have one reviewable purpose and be independently revertible;
- include the implementation, focused positive and failure-path tests, and
  required documentation for that one behavior;
- leave both affected supported pairs buildable at the stated checkpoint;
- exclude unrelated user changes, generated build/install trees, downloaded
  dependencies, logs, local validation clones, and editor metadata;
- use an imperative, sentence-case subject no longer than 72 characters,
  without a trailing period;
- use a useful project scope such as `H5T:`, `hl:`,
  `tools:`, `test:`, or `docs:` where appropriate; and
- include a body for non-trivial changes describing the removed compatibility
  behavior, retained behavior, ABI or file-format impact, and exact tests.

Before each commit:

1. Inspect the exact diff and staged paths.
2. Run `git diff --check`.
3. Format every touched C/C++ file with the repository
   `.clang-format`.
4. Run the narrowest required Windows/MSVC and Linux/GCC checks.
5. Confirm that generated files, build trees, logs, IDE metadata, and unrelated
   user changes are not staged.

Pure inspection, inventory, configure, build, test, and comparison work creates
no commit. Portable plan or evidence changes use focused `docs:` commits.
Do not rewrite completed Stage 1 or Stage 2 history. If a committed checkpoint
later fails a broader gate, correct it in a new focused commit or revert that
checkpoint at its own boundary.

## Execution Topology

The Windows and Linux evidence must come from their native target pairs at the
same tested Git commit.

- Use the Windows checkout to implement reviewed batches and run Visual Studio
  plus MSVC validation.
- Before committing, apply the exact intended diff to a clean validation
  checkout at the same parent commit on the WSL native filesystem. Confirm that
  its tracked content matches the intended commit tree, then run the required
  Linux/GNU focused checks there.
- After the Windows and Linux pre-commit gates pass, create the atomic local
  commit from that exact diff. Work-package and final evidence is then recorded
  from clean checkouts at the resulting commit SHA on both platforms.
- A build or test run on a Windows-mounted filesystem is useful diagnostically
  but is not the preferred release evidence for permission, locking, path, and
  POSIX I/O behavior.
- Do not share CMake caches, build trees, install prefixes, dependency trees, or
  package directories between Windows and Linux.
- Use a fresh out-of-source build and install directory for every matrix row.
- Keep build and CTest parallelism at or below four.
- Record the exact Git commit, clean-checkout state, target triple, operating
  system, CMake, compiler, generator, and `HDF_TEST_EXPRESS` value.

Windows and Linux focused checks may run independently against the identical
candidate tree, but neither result substitutes for the other. Windows GCC,
MinGW, cross-compilation, and synthetic compiler variables are not native
Linux/GCC evidence.

## Inventory and Classification Ledger

The last completed residual audit identified 60 tracked C/C++ source or header
files as candidates, with these keyword counts:

| Keyword family | Recorded matches |
| --- | ---: |
| `APPLE` | 4 |
| `CLANG` | 234 |
| `CYGWIN` | 6 |
| `DARWIN` | 3 |
| `FREEBSD` | 4 |
| `INTEL` | 43 |
| `MACOS` | 12 |
| `MINGW` | 10 |
| `NETBSD` | 2 |
| `PGI` | 4 |

These counts are search leads, not a removal quota. They include false
positives and protected compatibility content, especially formatter directives,
public datatype aliases, CPU/endianness terminology, and comments.

Before the first implementation edit, regenerate the inventory from tracked
source, header, template, test, tool, and retained-example files. Each semantic
condition or reference receives exactly one classification:

| Classification | Meaning |
| --- | --- |
| `REMOVE_UNSUPPORTED` | Entire behavior is reachable only on a rejected pair and can be deleted. |
| `SIMPLIFY_RETAINED` | Remove unsupported alternatives while preserving the Windows/MSVC or Linux/GNU behavior. |
| `KEEP_API_FORMAT` | Required for public API, ABI, serialized data, byte order, or cross-platform file compatibility. |
| `KEEP_RETAINED_VARIANT` | Required by an architecture, feature probe, or runtime variant reachable on an accepted pair. |
| `KEEP_TOOLING_HISTORY` | Developer tooling, third-party content, or factual historical/interoperability text. |
| `INVESTIGATE` | Ownership or supported-pair behavior is not yet proven; no edit is allowed. |

The portable ledger records:

- file and line or symbol;
- exact condition, macro, identifier, or text;
- owning package and visibility boundary;
- truth value and selected behavior on both accepted pairs;
- classification and rationale;
- public ABI or file-format impact;
- canonical generator input when the file is generated;
- affected build/test/install/package/consumer rows; and
- planned commit boundary.

No implementation work package may start with an `INVESTIGATE` item in
its scope. Resolve the item or stop and request review.

The regenerated inventory, protected keep set, and resolved classification
ledger are recorded in
[CMakePlatformSupportReductionStage3Results.md](CMakePlatformSupportReductionStage3Results.md).
Work Package 3A closed with no `INVESTIGATE` items.

## Pre-Implementation Contract Capture

Work Package 3A captures a clean pre-Stage-3 contract at the approved execution
anchor before changing source or headers:

- normalized CMake/File API contract using
  `config/cmake/scripts/HDF5BuildContract.cmake`;
- installed public and generated header manifests and content hashes;
- Windows DLL exports and Linux shared-library dynamic symbols;
- library names, versions, `SONAME`, import libraries, and package
  metadata;
- registered default and C++ test counts and fixture relationships;
- representative public C and C++ compile consumers;
- source and binary package manifests; and
- the current residual-match classification ledger.

The Stage 3 comparison anchor is the clean source state immediately before the
first Stage 3 implementation commit, derived from implementation
`81e96c889` plus approved documentation checkpoints. The older
pre-Stage-1 anchor remains useful only for the already completed CMake
reduction; it is not the source/ABI comparison anchor for Stage 3.

## Execution Order

Execute Stage 3 in this order:

1. Approve this plan and mark it `In progress`.
2. Qualify both validators and capture the pre-implementation contract.
3. Regenerate and fully classify the source/header inventory.
4. Lock the protected API, ABI, and file-format keep set.
5. Execute compiler-family work packages.
6. Execute platform-runtime and generated-header work packages.
7. Remove remaining unsupported-only test, tool, and example branches.
8. Run the residual audit and classify every remaining match.
9. Run the complete dual-platform validation gate.
10. Create the portable Stage 3 results record, update the parent plan and
    `REFACTORING_PROGRESS.md`, and stop before Stage 4.

Do not begin a later work package while an earlier package has an unexplained
contract delta or failed required row.

## Work Package 3A: Baseline and Protected Contract

### Work

- Qualify the Windows/MSVC and Linux/GCC validators at the same clean commit.
- Capture the contracts listed above.
- Complete the classification ledger for all candidates.
- Identify generated outputs and their canonical `.l`, `.y`,
  template, or generation-script sources.
- Bind every planned edit to focused tests and a commit boundary.
- Mark public names and serialized behavior that must remain.

Known protected examples include `H5T_INTEL_*` in the C API and matching
C++ `PredType` constants. Known investigation areas include qsort
signatures, generated type-size configuration, compiler attributes, plugin path
iteration, direct I/O test guards, and public `ssize_t` handling.

### Exit criteria

- Both validators are repeatable at the same commit.
- Baseline artifacts are recorded with portable commands and no transient
  paths.
- Every candidate has a non-`INVESTIGATE` classification.
- Every proposed edit has a test owner and commit boundary.

### Commit boundary

Inventory and validation alone create no commit. A portable classification or
plan correction uses a focused `docs:` checkpoint after review.

## Work Package 3B: Unsupported Compiler Branches

### Work

Reduce compiler-selection logic to exact behavior required by MSVC and GCC.
Initial ownership includes:

- `src/H5warnings.h`: remove Clang-only diagnostic paths while preserving
  GCC diagnostic pragmas and formatter directives;
- `src/H5private.h`: simplify `__clang__` and
  `__INTEL_COMPILER` attribute/workaround branches to supported GCC or
  MSVC behavior;
- `src/H5Tnative.c`: remove the PGI 19.10 table-storage workaround;
- `hl/src/H5LTanalyze.l` and `hl/src/H5LTparse.y`, plus generated
  outputs: remove unsupported compiler pragmas at their canonical source; and
- any additional exact compiler macro found by the regenerated inventory.

Do not treat the GCC-compatible spelling of a pragma, public
`H5T_INTEL_*` identifiers, or `clang-format` text as compiler
support.

### Validation

- Configure and compile default C on both supported pairs.
- Compile C++ on both supported pairs because private/public headers may be
  consumed by C++ targets.
- Build and run focused high-level datatype parser tests after lexer/parser
  changes.
- Run focused native datatype/conversion tests after `H5Tnative.c`
  changes.
- Configure with developer warnings enabled on both compilers and classify
  every new warning.
- Confirm generated lexer/parser output is reproducible from its tracked input.

### Commit boundaries

Use separate commits for Clang, Intel compiler, and PGI/NVHPC compatibility
families unless the ledger proves that generated input and output form one
inseparable behavior. Tests travel with the behavior they validate.

## Work Package 3C: Unsupported POSIX Platform Variants

### Work

Remove Apple/Darwin, BSD, and Cygwin runtime variants while retaining the
Windows/MSVC and Linux/GNU implementations:

- reduce qsort compatibility in `src/H5system.c` and
  `src/H5private.h` to Windows `qsort_s`, Linux GNU
  `qsort_r`, and any proven retained fallback;
- remove Apple Universal Binary type-size and endianness overrides from
  `src/H5pubconf.h.in` in favor of configured supported-pair values;
- remove Cygwin-only directory, plugin-path, pipe, and test-driver behavior;
- preserve feature-based POSIX checks such as `H5_HAVE_FCNTL`,
  `H5_HAVE_FLOCK`, and `H5_HAVE_QSORT_REENTRANT` when they remain
  meaningful on Linux/GNU; and
- retain generic Windows/POSIX separation used by both accepted pairs.

Do not assume an Apple/BSD keyword makes an entire function removable. Remove
only the unsupported selector or alternate implementation.

### Validation

- Run focused sorting and callback-context tests, including failure paths.
- Run core, plugin-path, dynamically loaded filter, and directory-iteration
  tests on Linux and Windows where applicable.
- Verify generated size, alignment, and endianness macros against compiler
  observations on both baselines.
- Run affected API driver, pipe, and tool tests.
- Compare public generated headers before and after on both supported pairs.

### Commit boundaries

Keep qsort behavior, Apple generated-header overrides, and Cygwin behavior in
separate commits. A shared implementation and its declarations remain in the
same commit.

## Work Package 3D: MinGW and Windows Public Portability Guards

### Work

Collapse Windows branches that exclude MinGW into the supported MSVC behavior.
Initial ownership includes:

- `src/H5public.h` public `ssize_t` handling;
- `src/H5win32defs.h` and related Win32 portability definitions;
- Windows VFD, path, direct-I/O, atomic test, and performance-test guards; and
- any `MINGW` or `MSYS` source/header match classified as
  unsupported-only.

Public declarations, structure layout, calling conventions, export macros, and
MSVC static/shared behavior must remain unchanged.

### Validation

- Compile minimal C and C++ programs that include installed public headers on
  Windows/MSVC and Linux/GCC.
- Build Windows static-only, shared-only, and combined configurations.
- Compare Windows DLL exports, import libraries, public structure sizes, and
  representative macro expansions.
- Run affected atomic, VFD, direct-I/O, and performance-tool compile/tests.
- Verify Linux public headers and consumers have no delta caused by the Windows
  simplification.

### Commit boundaries

Keep installed public-header behavior separate from test-only cleanup unless a
test is the focused regression coverage for that header change. Split VFD,
atomic, and performance-tool changes when they have independent behavior.

## Work Package 3E: Remaining Tests, Tools, and Examples

### Work

- Remove unsupported-only guards in `test/`, `testpar/`,
  `tools/`, and retained examples that are not already owned by an
  implementation commit.
- Preserve tests for generic Windows/POSIX behavior and architecture variants
  within accepted pairs.
- Preserve file-format interoperability data and tests even when their names
  mention an unsupported platform or CPU family.
- Add focused regression coverage beside the affected module using the modern
  `h5test.h` harness. Do not add new cases to the legacy
  `testhdf5` aggregate.
- Delete an entire source file only when the ledger proves it has no
  supported-pair, compatibility, generation, or packaging owner.

### Validation

- Build every affected test and tool target on both supported pairs.
- Run the narrowest matching CTest selections with fixtures.
- Run standalone examples when their source or public headers change.
- Inspect source and binary package manifests after any file deletion.
- Confirm no CMake target references a deleted file.

### Commit boundaries

Test changes that validate an implementation change belong to that
implementation commit. Standalone dead test/tool/example branches use separate
`test:`, `tools:`, or example-scoped commits.

## Work Package 3F: Residual and Compatibility Audit

### Work

- Repeat the full tracked-file inventory using the original keyword families
  and exact preprocessor macro searches.
- Record every remaining match and its keep classification.
- Search installed headers separately from private source.
- Review public C symbols, C++ constants/classes, generated headers, package
  exports, and file-format aliases for accidental removal.
- Review current documentation and `release_docs/CHANGELOG.md` for the
  completed source portability change without rewriting historical releases.
- Create `CMakePlatformSupportReductionStage3Results.md` when execution
  evidence first exists.

### Exit criteria

- No unsupported-only compiler or platform implementation remains.
- No match remains unclassified.
- Remaining matches are required API/file-format compatibility, retained-pair
  variants, developer tooling, third-party content, or factual history.
- The source package contains no deleted source/header path.

### Commit boundary

Use a focused final implementation cleanup commit only if the residual audit
finds a missed item with its own tests. Record final portable evidence in a
separate `docs:` checkpoint.

## Per-Commit and Work-Package Gates

Every implementation commit must pass:

| ID | Required check |
| --- | --- |
| `S3-DIFF` | Exact diff review, `git diff --check`, formatting, and staged-path inspection |
| `S3-WIN-FOCUSED` | MSVC configure/build of affected targets and narrowest matching CTest selection with fixtures |
| `S3-LNX-FOCUSED` | GCC configure/build of affected targets and narrowest matching CTest selection with fixtures |
| `S3-HEADER` | Required after installed/generated header changes: C and C++ compile consumers on both pairs |
| `S3-CONTRACT` | Required after target/source-list, public-header, export, package, or generated-product changes |

At each work-package boundary, build the default Release products on both pairs
and run the focused C, high-level, tool, and affected-package tests. A work
package cannot close with an unexplained warning, artifact delta, or skipped
affected test.

## Final Dual-Platform Gate

Stage 3 cannot complete until these fresh, clean-checkout rows pass at the same
implementation commit.

### Windows/MSVC

- Default Release with static and shared libraries and complete enabled CTest
  at `HDF_TEST_EXPRESS=3`.
- Default Debug, static-only Release, and shared-only Release builds plus
  focused smoke selections.
- C++-enabled static and shared build plus focused C++ and C++ high-level tests.
- Install tree, package configuration, ZIP package, standalone C/C++/high-level
  examples, and build/install/source-tree consumers.
- Synthetic compiler-admission cases to prove Stage 1 remains intact.
- Previously passing Windows optional rows affected by Stage 3, including
  parallel, thread-safe, concurrency, or bundled compression when applicable.

### Linux/GCC

- Default Ninja Release with static and shared libraries and complete enabled
  CTest at `HDF_TEST_EXPRESS=3`.
- Default Debug, static-only Release, shared-only Release, and C++-enabled rows
  plus their focused selections.
- Unix Makefiles default Release configure/build and focused smoke selection.
- Install tree, TGZ package, standalone C/C++/high-level examples, wrappers,
  and build/install/source-tree consumers.
- Previously passing Stage 2 optional rows affected by Stage 3. By default,
  rerun system and bundled compression, parallel, subfiling, thread-safe,
  concurrency, external plugins, coverage, STGZ, and DEB; omit a row only when
  the ledger proves it is unaffected and records the rationale.

### Contract and compatibility

- Compare the normalized CMake contract to the pre-Stage-3 anchor. No firewall,
  option, target, flag, test-registration, generated-product, or package delta
  may remain unexplained.
- Compare installed headers and exported C/C++ symbols. No public symbol,
  supported-pair declaration, ABI layout, or library version may change.
- Run datatype, conversion, object-copy/reference, and representative
  cross-platform file compatibility tests.
- Verify library names, Windows import libraries, Linux `SONAME` and
  RUNPATH, static/shared exports, and package dependency metadata.
- Inspect source and binary package manifests for removed or unintended files.

Test counts are recorded and compared with the Stage 1 and Stage 2 baselines.
An intentional removal of an unsupported-only test may change a count only when
the exact test and reason are documented; enabled supported behavior may not
silently disappear.

## Deferred Optional Rows

The six Stage 2 `SKIP_MISSING_ENV` decisions carry into Stage 3 only while
their implementation paths are untouched:

- parallel tools requiring mpiFileUtils, libcircle, and DTCMP;
- ROS3 requiring aws-c-s3 and service inputs;
- HDFS requiring JDK/JNI, Hadoop, and libhdfs;
- signed plugins requiring OpenSSL development/signing inputs;
- RPM packaging requiring `rpmbuild`; and
- real rejection with an installed unsupported native Linux compiler.

If a Stage 3 batch changes one of these product paths, the existing deferral is
not sufficient evidence for that change. Stop and present the missing
prerequisite, coverage unlocked, environment change, and recommendation to the
user. The row must be enabled and tested or explicitly removed from the Stage 3
scope; absence never authorizes feature removal.

## Failure Handling

Every executed row receives one result:

- `PASS`: required configure, build, tests, and contract checks passed.
- `FAIL`: prerequisites were present but current behavior failed.
- `SKIP_MISSING_ENV`: an external prerequisite was absent and the row was
  not required by a changed path.

For every `FAIL`, record the exact commit, row, phase, diagnostic, root
cause, relationship to the Stage 3 batch, correction or revert, and rerun
result.

- A regression caused by the current uncommitted batch is corrected before that
  batch is committed.
- A regression discovered after an atomic checkpoint is fixed in a new focused
  commit or the checkpoint is reverted.
- An independent pre-existing defect is diagnosed and reported before the task
  expands into unrelated repair.
- A missing program or package is not a code failure, but it cannot excuse an
  unvalidated changed path.
- Never restore a rejected compiler/platform path merely to make a test pass.

## Stop Conditions

Stop the affected batch and request review when:

- a proposed edit changes the Stage 1 firewall, supported pair matrix, or
  generator/architecture admission policy;
- a public C/C++ symbol, ABI layout, calling convention, library version, or
  file-format representation would change;
- a named compatibility constant such as `H5T_INTEL_*` appears removable
  only because of its platform/CPU name;
- a condition cannot be assigned supported-pair truth values;
- generated output has no identified canonical source or cannot be reproduced;
- an architecture or runtime variant within an accepted pair would be lost;
- an optional feature is unreachable only because its prerequisite is missing;
- the required Windows or Linux validator is unavailable for an affected
  change; or
- a change expands into broad modernization or an unrelated defect repair.

## Candidate Commit Sequence

The classification ledger may split or reorder these subjects, but it may not
collapse unrelated compiler/platform families into a repository-wide cleanup:

1. `docs: Add Stage 3 source reduction plan`
2. `H5: Remove unsupported Clang compiler branches`
3. `H5: Remove Intel compiler compatibility branches`
4. `H5T: Remove the PGI compiler workaround`
5. `H5: Reduce qsort portability to supported systems`
6. `H5: Remove Apple generated-header overrides`
7. `H5PL: Remove Cygwin plugin path handling`
8. `H5: Simplify Windows MSVC portability guards`
9. Focused `test:`, `tools:`, or example commits for remaining
   unsupported-only branches
10. `docs: Record Stage 3 source reduction results`

Each actual subject must remain at most 72 characters. When one behavior spans
core, high-level, generated output, and tests, use one ownership-focused commit
with a body explaining the coupled files rather than separating generated
artifacts from their source.

## Evidence Record

The Stage 3 results document records:

- tested implementation commit and clean-checkout state;
- validator versions, target triples, generators, configurations, and
  `HDF_TEST_EXPRESS`;
- one result row per commit and final matrix configuration;
- focused and full CTest counts with fixture behavior;
- header, symbol, ABI, file-format, artifact, package, and consumer comparisons;
- the final classification of every residual keyword match;
- failure diagnoses, corrective commits, and rerun results;
- inherited optional deferrals and any new explicit user decision; and
- the exact continuation point for Stage 4 planning.

Commands use `<src>`, `<build-root>`, `<install-root>`, and
similar placeholders. Do not record absolute local paths, transient directories,
logs, downloaded content, credentials, or machine-specific IDE state.

After each coherent batch, update `REFACTORING_PROGRESS.md` with the newest
implementation anchor, completed work, validation state, unresolved gaps, and a
non-duplicative continuation point.

## Exit Criteria

Stage 3 passes only when all of the following are true:

1. Every tracked source/header candidate is classified and no
   `INVESTIGATE` item remains.
2. Unsupported-only compiler and platform branches, shims, workarounds, tests,
   and alternate implementations are removed.
3. Every remaining platform/compiler keyword match has a recorded protected or
   non-build rationale.
4. Public API, ABI, library versioning, and HDF5 file-format compatibility are
   unchanged.
5. Generic Windows/POSIX and accepted-pair architecture/runtime variants remain
   intact.
6. Every implementation commit passed its focused Windows/MSVC and Linux/GCC
   gates.
7. The complete final dual-platform gate passes with no unexplained contract,
   artifact, test, package, or consumer delta.
8. Previously passing optional paths affected by Stage 3 pass again; every
   unavailable affected prerequisite has an explicit user scope decision.
9. The results document and `REFACTORING_PROGRESS.md` contain portable,
   current evidence and the Stage 4 continuation point.
10. Every repository modification is present in an atomic, independently
    revertible local commit with no generated or unrelated content.

The accepted completion statement is:

> Source and header compatibility code now implements the Windows/MSVC and
> Linux/GNU support contract; protected API, ABI, file-format, and
> supported-pair variants remain intact; affected Stage 1 and Stage 2 validation
> rows pass on both baselines.

Do not shorten this to "platform reduction complete." The separate
[Stage 4 plan](CMakePlatformSupportReductionStage4.md) is Proposed for review;
its final audit remains unexecuted.
