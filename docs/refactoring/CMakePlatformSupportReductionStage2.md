# Stage 2 Native Linux/GCC Validation Plan

## Status

- State: core gate passed; available optional rows executed; user decisions
  pending
- Scope approved: 2026-09-04
- Parent compatibility plan:
  [`CMakePlatformSupportReduction.md`](CMakePlatformSupportReduction.md)
- Portable handoff: [`../../REFACTORING_PROGRESS.md`](../../REFACTORING_PROGRESS.md)
- Execution results:
  [`CMakePlatformSupportReductionStage2Results.md`](CMakePlatformSupportReductionStage2Results.md)
- Required target pair: Linux with compiler ID `GNU`
- Release-qualified baseline: Linux x86_64 with GCC/G++ and Ninja
- Secondary generator check: Unix Makefiles
- Maximum build and CTest parallelism: 6

## Purpose

Stage 2 determines whether the Stage 1 CMake platform/compiler reduction
preserved the core native Linux/GCC build. It is not an exhaustive
qualification of every optional HDF5 feature.

The stage has two validation layers:

1. A fixed core gate that must pass on every accepted validator.
2. Environment-driven optional validation. Detect the optional prerequisites
   already available, run every legal row supported by them, and present the
   missing prerequisites to the user for a test-or-defer decision.

Passing Stage 2 establishes the repeatable Linux/GCC validator needed before
source-level compatibility reduction can be planned. It does not authorize
source or header cleanup and does not complete the overall platform-reduction
direction.

## Scope Boundaries

Stage 2 validates the current CMake and generated product behavior. It may fix
a Linux/GCC regression introduced by Stage 1 in a focused commit. It does not:

- install missing packages, start external services, add credentials, or
  otherwise change the validator without the user's decision;
- require every optional feature to be made available;
- remove a feature merely because its prerequisites are absent;
- treat Windows GCC, MinGW, cross-compilation, or synthetic variables as native
  Linux/GCC evidence; or
- begin the later source/header compatibility reduction.

Downloading a bundled dependency during a selected build is ordinary execution
of that row, but network or local-archive access must first be classified as
available.

## Atomic Local Commit Discipline

Every repository modification made while executing this plan must be recorded
as an atomic local Git commit after its required checks pass. Each commit must:

- have one reviewable purpose and be independently revertible;
- include the implementation, focused tests, and required documentation for
  that one behavior when they belong to the same change;
- leave the affected supported configuration buildable at the stated checkpoint;
- exclude unrelated user changes, generated build/install trees, downloaded
  dependencies, logs, and editor metadata; and
- follow the repository commit-subject and body conventions.

Pure configure, build, test, inspection, and capability-probe work does not
create a commit. Portable evidence updates are committed as focused `docs:`
checkpoints. A failed Stage 2 batch is corrected by a new focused commit or
reverted at its own commit boundary; do not rewrite completed Stage 1 history or
accumulate unrelated fixes in an uncommitted worktree.

Before each commit, inspect the exact diff, run `git diff --check`, apply any
required formatter to touched source files, run the narrowest required checks,
and confirm that only intended paths are staged.

## Execution Order

Run Stage 2 in this order:

1. Qualify and record the validator and tested source state.
2. Run the complete core Linux/GCC gate.
3. Probe optional capabilities without changing the environment.
4. Run every optional row whose complete prerequisite set is available.
5. Diagnose every failure and rerun corrected rows as required.
6. Present all missing prerequisites to the user with the coverage each would
   unlock.
7. Run any additional rows selected after the user supplies prerequisites.
8. Record the final result and the repeatable continuation point in
   `REFACTORING_PROGRESS.md`.

Do not begin optional rows before the core gate is green. Use a fresh
out-of-source build and install directory for every configuration so cache
values and artifacts cannot leak between rows.

## Validator Qualification

Before configuring any row, record:

- the tested Git commit and whether the tracked checkout is clean;
- distribution, kernel, libc, and target architecture;
- CMake, CTest, GCC, G++, Ninja, and Make versions;
- the GCC and G++ target triples;
- the configured `HDF_TEST_EXPRESS` level; and
- the build and test parallelism.

The compiler target triples must describe a native Linux/GNU target. Any
trusted environment satisfying the release-qualified baseline may execute
Stage 2. Record its exact distribution and tool versions as result evidence;
those observations do not redefine the version-independent baseline. The
validator must remain accessible and repeatable for later work.

## Core Gate

The following rows are required regardless of which optional dependencies are
installed. Options not shown remain at their repository defaults.

| ID | Generator and configuration | Required behavior |
| --- | --- | --- |
| `LNX-CORE-REL` | Ninja, Release, `BUILD_STATIC_LIBS=ON`, `BUILD_SHARED_LIBS=ON` | Configure and build all default targets. Run the complete enabled CTest suite with `HDF_TEST_EXPRESS=3`; record passed, failed, and disabled counts. |
| `LNX-CORE-DBG` | Ninja, Debug, static plus shared | Configure and build all default targets. Run the focused C, high-level, and tool smoke selection with its fixtures. |
| `LNX-STATIC` | Ninja, Release, static on and shared off | Configure and build, verify that only the expected library form is emitted, and run the focused smoke selection. |
| `LNX-SHARED` | Ninja, Release, static off and shared on | Configure and build, verify that only the expected library form is emitted, and run the focused smoke selection. |
| `LNX-CPP` | Ninja, Release, static plus shared, `HDF5_BUILD_CPP_LIB=ON`, parallel/thread-safe/concurrency off | Configure and build, then run focused C++, C++ high-level, and compiler-admission checks. This row directly covers Stage 1 C++ changes. |
| `LNX-MAKE` | Unix Makefiles, Release, default options | Configure and build all default targets, then run the focused smoke selection. A second full CTest suite is not required. |
| `LNX-EXAMPLES` | Standalone retained examples | Configure, build, and test the C, C++, and high-level entry points against both build-tree and installed CMake packages. |
| `LNX-CONSUMERS` | Default Release products | Validate build-tree and install-tree `find_package` consumers plus minimal `add_subdirectory()` and local-source FetchContent consumers. |
| `LNX-INSTALL` | Default Release install | Verify static/shared exports, installed headers, tools, CMake package metadata, library placement, and shared-library resolution. |
| `LNX-PACKAGE` | Default Release CPack | Generate and inspect the TGZ binary package. Other package generators are optional rows. |
| `LNX-CONTRACT` | Pre-Stage-1 and current default Ninja Release configures | Capture normalized CMake contracts in the same environment and classify every delta. Approved unsupported-surface removal is allowed; retained Linux targets, flags, tests, generated files, and package metadata may have no unexplained change. |

Use `config/cmake/scripts/HDF5BuildContract.cmake` for the normalized configure
contract. The exact pre-reduction configure anchor is `b22b55872`, the parent of
the first Stage 1 CMake implementation commit. That anchor contains the known
source-formatting compilation regression later repaired by `a68b4cae4e`, so it
is a configure-contract reference, not a requirement to complete a historical
build or install. Current build, test, install, package, and consumer behavior
is validated directly at the tested Stage 2 commit.

Root and standalone-example preset files must list successfully. Execute at
least the retained baseline GNU configure/build path. A preset that also
enables optional features is selected only when capability discovery confirms
all of its prerequisites.

## Core Acceptance Checks

In addition to each row's build and test result, record the following where
applicable:

- static and shared output names and the absence of a disabled library form;
- shared-library `SONAME`, build/install RPATH or RUNPATH, and runtime dependency
  resolution;
- PIC compile behavior for libraries used by shared objects;
- installed CMake target names, locations, components, and dependency metadata;
- representative C, C++, and high-level consumers linked to the intended static
  or shared target; and
- registered test counts and fixture relationships for the full and focused
  selections.

The real unsupported-compiler rejection is not part of the fixed core gate. Run
it as an optional capability row when an unsupported Linux compiler is already
available and reaches CMake language detection reliably.

## Optional Capability Discovery

An optional capability is available only when every external prerequisite can
be used without changing the validator. Repository source and ordinary CMake
feature checks are not missing environment. If a selected configure later
reveals an absent external prerequisite, record the concrete probe and classify
the row as missing environment rather than retrying with ad hoc changes.

Probe at least the following groups:

| Capability group | Availability evidence | Coverage unlocked |
| --- | --- | --- |
| pkg-config wrappers | `pkg-config` is executable and the installed `.pc` files are discoverable | Compile and run representative programs with `h5cc`, `h5c++`, `h5hlcc`, and `h5hlc++`; exercise `-show` and `-showconfig`. |
| System compression | CMake can find usable zlib and libaec development packages | Separate system zlib/libaec configure, build, focused filter tests, install metadata, and consumer checks. |
| Bundled compression | Required archives are locally available or outbound retrieval succeeds under the validator's network policy | Bundled zlib/libaec configure, build, focused filter tests, package/export, and consumer checks. |
| Parallel HDF5 | A supported OpenMPI or MPICH compiler wrapper, launcher, headers, and libraries are usable | Parallel configure/build and focused MPI tests. |
| Parallel tools | MPI plus mpiFileUtils, libcircle, DTCMP, and other documented dependencies are usable | Focused parallel-tool build and tests. |
| Subfiling | Supported MPI-3 and thread-operation prerequisites are usable | Separate subfiling configure/build and focused VFD tests. |
| Thread-safe | Repository thread discovery succeeds | Supported thread-safe configuration and focused tests. |
| Multi-thread concurrency | Repository thread discovery succeeds | Separate supported concurrency configuration and focused tests. |
| External filters and plugins | Required filter-plugin installation and plugin directory are available | External plugin configure/build and focused loading tests. |
| ROS3 | Required aws-c-s3 development package and any test service configuration are available | ROS3 configure/build and focused tests that the available service permits. |
| HDFS | JDK/JNI, Hadoop/libhdfs, and required runtime configuration are available | HDFS configure/build and focused VFD tests. |
| Signed plugins | OpenSSL development files and required signing inputs are available | Signed-plugin configure/build and focused positive/failure tests. |
| GCC coverage | `lcov`, `genhtml`, and the documented GCC coverage prerequisites are executable | Debug coverage configure/build, focused tests, and report-target generation. |
| Additional packages | The generator-specific external tools are executable | STGZ and, when available, DEB or RPM generation and archive-content checks. |
| Unsupported compiler rejection | An unsupported native Linux compiler is already installed | Real root and, where useful, optional C++ firewall rejection without an `HDF5_ALLOW_UNSUPPORTED` bypass. |

This table defines discovery coverage, not a requirement to provision every
dependency. Add another row when the environment exposes a retained optional
feature not listed here.

## Optional Row Rules

For each available capability:

1. Create a separate configuration using a documented, supported option set.
2. Configure and build the narrowest complete affected target set.
3. Run focused positive and failure-path tests with their fixtures.
4. Validate affected install, export, package, wrapper, or consumer metadata.
5. Record exact prerequisite versions and the result.

Do not combine C++ with parallel, thread-safe, or concurrency configurations.
Do not combine parallel with thread-safe or concurrency, and do not combine the
mutually exclusive thread-safe and concurrency modes. `HDF5_ALLOW_UNSUPPORTED`
must remain off except in a test whose explicit purpose is to verify a separate
documented option contract; it never bypasses the target-system/compiler
firewall.

## Result States

Every executed or discovered row receives exactly one state:

- `PASS`: prerequisites were available and configure, build, focused tests, and
  required artifact checks passed.
- `FAIL`: prerequisites were available but current source behavior failed. This
  is a code result, not an environment gap.
- `SKIP_MISSING_ENV`: an external program, development package, service,
  credential, archive, network route, or runtime condition was absent.

Do not use a generic skipped or deferred state without the missing prerequisite
or user decision that justifies it.

## Failure Handling

For every `FAIL`, record the failing phase, exact row, root cause, relationship
to Stage 1, and rerun result.

- A Linux/GCC regression introduced by Stage 1 must be fixed in a focused
  commit. Rerun the affected Linux rows and the affected Windows/MSVC contract
  checks. Restore retained GNU behavior without restoring an unsupported
  platform or compiler path.
- An independent pre-existing defect remains a real failed row. Diagnose and
  report it to the user before expanding the task into an unrelated repair. The
  row must pass, or the user must explicitly remove that independent defect
  from the selected Stage 2 validation scope, before Stage 2 can close.
- An unavailable external prerequisite is `SKIP_MISSING_ENV`, not `FAIL`, and
  follows the missing-environment decision process below.

The known bundled zlib/libaec export-set generation defect is a code defect,
not a missing environment. If bundled prerequisites are available and that
behavior reproduces, report it as `FAIL` under these rules.

## Missing-Environment Decision

After every currently available optional row has run, present all
`SKIP_MISSING_ENV` rows to the user. Each entry must contain:

| Field | Required content |
| --- | --- |
| Feature or row | The optional configuration that could not run |
| Missing prerequisite | Exact program, package, archive, service, credential, or runtime condition |
| Detection evidence | The failed read-only probe or CMake discovery result |
| Coverage unlocked | Configure, build, tests, packages, or consumers that would run if supplied |
| Environment change | What would need to be installed, configured, downloaded, or started |
| Recommendation | Whether the additional evidence is high value for the current platform-reduction risk |

The user then chooses whether to supply the prerequisite for another validation
pass or explicitly defer the row. Do not infer that choice from the feature's
default value or from its availability on another platform.

## Evidence Record

Maintain one portable result entry per row with:

- row identifier, tested commit, generator, build type, and all non-default
  options;
- prerequisite names and versions;
- normalized configure, build, test, install, package, and consumer commands;
- CTest express level plus passed, failed, and disabled counts;
- artifact and consumer assertions;
- final result state, failure classification, and owner where applicable; and
- the user's decision for every missing-environment or independent-defect row.

Use placeholders rather than absolute local paths in recorded commands. Keep
transient logs, build directories, install trees, downloaded content, and
machine-specific files out of the repository. Summarize completed evidence and
all unresolved decisions in `REFACTORING_PROGRESS.md`.

## Exit Criteria

Stage 2 passes only when all of the following are true:

1. Every core Linux/GCC row passes with exact, portable evidence.
2. Every optional row supported by the supplied environment passes, unless the
   user explicitly removes an independent pre-existing defect from the selected
   validation scope after reviewing its diagnosis.
3. Every missing-environment row has been presented to the user and is either
   subsequently tested or explicitly deferred by the user.
4. No Stage 1 Linux/GCC regression remains open.
5. Windows/MSVC remains green after every cross-platform correction.
6. The retained CMake contract has no unexplained Linux/GCC delta.
7. The qualified Linux/GCC validator and execution record are repeatable for
   the separately planned source-reduction stage.

The accepted completion statement is:

> The Linux/GCC core path and every optional row supported by the supplied
> environment pass; unavailable optional prerequisites have explicit user
> decisions; the Stage 1 CMake layer is validated on both retained baselines.

Do not shorten this to "platform reduction complete." Source-level reduction
and the final audit remain future, separately reviewed stages.
