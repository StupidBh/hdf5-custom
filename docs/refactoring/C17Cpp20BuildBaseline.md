# Phase 2 C17 and C++20 Build Baseline Plan

## Status

- State: Approved
- Plan drafted: 2026-09-05
- Scope and completion boundaries confirmed: 2026-09-05
- Implementation authorized: Yes; approved by the user on 2026-09-05
- Planning baseline: `2e6ed711f`
- Execution baseline: `a1adbc32b`
- Implementation anchor: none
- Work Package 2A: Complete
- Execution record:
  [C17Cpp20BuildBaselineResults.md](C17Cpp20BuildBaselineResults.md)
- Portable handoff: [../../REFACTORING_PROGRESS.md](../../REFACTORING_PROGRESS.md)
- Related paused direction: [../CMakeModernization.md](../CMakeModernization.md)
- Required target pairs: Windows with compiler ID `MSVC`, and Linux with
  compiler ID `GNU`
- Release-validation baselines: Windows x64 with MSVC and a Visual Studio
  generator; Linux x86_64 with GCC/G++ and Ninja
- Secondary Linux generator check: Unix Makefiles
- Maximum active build and CTest parallelism: 4 in total per physical host
- Required full-suite test level: `HDF_TEST_EXPRESS=3`

This document defines a compatibility-changing language-build direction that
is separate from the paused behavior-preserving CMake 4 modernization. The
user approved the plan and its build-baseline versus public-header-baseline
distinction on 2026-09-05. Work Package 2A qualified the validators and selected
the execution baseline; Work Package 2B is the next implementation step.

The name "Phase 2" describes the next project-level refactoring direction. It
must not be confused with the completed Stage 2 Linux/GCC validation inside
the supported-platform reduction plan.

## Objective

Raise the language modes used to build the project-owned core library,
high-level library, opt-in C++ wrappers, tools, tests, plugins, and examples
from C11/C++11 or C99/C++11 to C17/C++20. Establish those modes coherently in
CMake and repair only the blockers that the new modes expose in configuration,
compilation, linking, or testing. Do not perform broad source modernization.

The completed Phase 2 result must satisfy all of the following:

1. Every in-scope, project-owned C translation unit in the core library,
   high-level library, tools, tests, plugins, or examples is compiled in C17 or
   a caller-selected later C mode. Exact C17 is the release baseline.
2. Every in-scope, project-owned C++ translation unit in the opt-in C++
   wrappers, tools, tests, plugins, or examples is compiled in C++20 or a
   caller-selected later C++ mode. Exact C++20 is the release baseline.
3. CMake feature probes that determine generated configuration for C targets
   run in the same effective C language mode as those targets.
4. The core library, high-level library, opt-in C++ wrappers, tools, tests,
   plugins, and examples use the intended baseline without changing the
   language requirements of third-party libraries or tools.
5. Public C and C++ declarations, ABI, exported symbols, filenames, install
   layout, package behavior, and HDF5 file-format behavior remain compatible.
6. Installed headers remain parseable by the existing C99 and C++11 consumer
   baselines during this phase. C17 and C++20 are build baselines here, not yet
   new public-header syntax baselines.
7. No unclassified configuration, compilation, test, generated-contract,
   consumer, ABI, or packaging delta remains.

## Fixed Direction Decisions

The following decisions are part of this plan and are not implementation-time
shortcuts:

1. C17 and C++20 are minimum project build standards, not optional feature
   switches. Do not add an `HDF5_USE_C11`, `HDF5_USE_CXX11`, or general legacy
   language-mode escape option.
2. A caller request below the applicable minimum must fail configuration with
   a direct diagnostic. A caller-selected later standard may be retained, but
   the release gate qualifies C17 and C++20 specifically and does not certify
   later standards.
3. Required-standard behavior is enabled; CMake must not silently decay to an
   older compiler mode.
4. Project-owned sources use strict ISO modes. C extensions and C++ extensions
   are disabled unless a separately classified retained dependency cannot be
   isolated from a required extension.
5. C++ remains opt-in. A C-only build must not locate, validate, or require a
   C++ compiler merely because the repository has a C++20 build baseline.
6. The installed C API and C++ API do not acquire C17/C++20-only declarations
   in this phase. Installed CMake targets, pkg-config files, and compiler
   wrappers must not force downstream language modes solely because the HDF5
   binaries were built with newer modes.
7. Standalone examples are project-owned validation products and move to
   C17/C++20. They test the new build baseline, while separate legacy consumer
   probes protect C99/C++11 header and linkage compatibility.
8. Third-party libraries and tools are outside the language migration scope,
   whether they are found from the system, fetched, or vendored. This includes
   compression libraries, MPI implementations, OpenSSL, AWS SDK components,
   Hadoop/libhdfs and JNI runtimes, KWSYS, Perl, and comparable prerequisites.
   Do not raise their language modes or patch their sources. Isolate their own
   declared modes when inherited directory state would otherwise affect them.
9. Source changes are limited to demonstrated configuration, compilation,
   linking, or test blockers caused by C17/C++20. Repairs must not actively
   introduce modern language or standard-library features. Prefer constructs
   already valid in the old and new modes; if a repair requires a broader
   source modernization, stop and defer it to a separately approved direction.
10. `HDF5_ALLOW_UNSUPPORTED` continues to apply only to documented HDF5
    feature combinations. It cannot bypass the language baseline or the
    target-system/compiler firewall.

## Current Implementation Facts

The planning baseline has four different standard-setting surfaces:

- `config/flags/HDFCompilerFlags.cmake` sets C11, requires it, and directly
  prepends `CMAKE_C11_STANDARD_COMPILE_OPTION` to `CMAKE_C_FLAGS`.
- `config/flags/HDFCompilerCXXFlags.cmake` enables C++, sets C++11, requires
  it, and disables C++ extensions.
- `HDF5Examples/config/cmake/HDFExampleMacros.cmake` independently sets C99
  and C++11 for retained standalone examples.
- `test/API/driver/CMakeLists.txt` sets C++11 while configuring KWSYS and adds
  a private `cxx_std_11` requirement to one project-owned helper.

The root includes `config/ConfigureChecks.cmake` before it includes the module
that currently sets C11. Consequently, not every configure-time probe is
guaranteed to use the same C mode as the product targets. Dependencies and
their atomics/thread checks are configured after the current C11 flag
mutation, creating a second probe regime in the same configuration.

The planning scan found no obvious use of C++20 keywords as code identifiers
and no obvious use of commonly removed facilities such as `std::auto_ptr`,
`std::unary_function`, `std::binary_function`, or dynamic exception
specifications. This is only a source inventory result. It is not compiler,
linker, runtime, or ABI evidence.

The C++ API exposes `std::string` through `H5std_string`. That makes cross-mode
C++ consumer checks mandatory even when the exported symbol set is unchanged.
The C configuration also controls complex-number, atomics, and threading
paths, so generated-header comparison is a behavioral gate rather than a
cosmetic check.

## Scope Boundaries

### In scope

- Root and retained standalone-example CMake language-standard ownership for
  project-owned targets.
- Project-owned core library, high-level library, opt-in C++ wrappers, tools,
  tests, plugins, examples, and their optional feature sources. This list is
  the complete language migration scope.
- CMake configure and feature probes whose result controls generated HDF5
  headers, sources, target composition, or runtime behavior.
- Exact standard-mode evidence for MSVC and GCC/G++.
- Local source repairs strictly required by C17 or C++20 compilation, linking,
  runtime tests, or preserved consumer compatibility.
- Generated `H5pubconf.h`, build settings, CMake File API, installed exports,
  pkg-config data, compiler wrappers, packages, public headers, symbol sets,
  and representative external consumers.
- HDF5-owned integration logic and available optional configurations affected
  by compiling project-owned code in the new modes, including parallel,
  subfiling, thread-safe, concurrency, compression, plugins, VOL/VFD paths,
  coverage, and packaging. Testing an integration does not place its
  third-party dependency in the language migration scope.
- Current build, installation, example, and release documentation, plus a
  user-visible changelog entry for the build baseline change.

### Out of scope

- Adopting C23, C++23, or later standards as release baselines.
- General use of C17 or C++20 language/library features in otherwise working
  source.
- Broad warning cleanup, formatting churn, ownership rewrites, RAII or smart
  pointer conversions, ranges, concepts, modules, coroutines, or `std::span`
  adoption.
- Raising the minimum syntax level of installed public headers from C99 or
  C++11, or advertising C17/C++20 as an installed usage requirement.
- Public API additions, removals, signature changes, ABI changes, file-format
  changes, library versioning, or changed error semantics.
- Compiler-version admission gates. Exact tool versions remain validation
  evidence rather than central firewall inputs.
- Reopening unsupported compiler, target-system, Java, or Fortran support.
- General target-scoped CMake modernization, dependency redesign, CTest
  redesign, or installation decomposition unrelated to the language baseline.
- Raising the build mode of, modifying, or modernizing third-party libraries
  and tools, including system compression libraries, MPI, OpenSSL, AWS SDK
  components, Hadoop/libhdfs/JNI, KWSYS, and Perl. HDF5's discovery, linkage,
  and runtime integration with them remains subject to regression validation.
- Publishing packages, pushing commits, or modifying external systems.

## Compatibility Contract

1. Preserve the accepted target pairs: Windows/MSVC and Linux/GNU. Preserve
   generator and architecture policy from the completed platform-reduction
   direction.
2. Preserve all cache option names, types, defaults, allowed values, and
   advanced status unless a language-baseline diagnostic must explicitly
   reject a lower requested standard.
3. Preserve all target names, output names, static/shared combinations, debug
   postfixes, library versions, plugin names, and output locations.
4. Preserve generated header names and effective public declarations. Every
   changed generated macro must have a recorded cause and behavioral review.
5. Preserve C and C++ calling conventions, public type sizes and alignments,
   exported symbol sets, and cross-language linkage.
6. Preserve build-tree and install-tree imported target names and dependencies.
   The new build standards remain private and must not appear accidentally in
   exported `INTERFACE_COMPILE_FEATURES`.
7. Preserve compiler-wrapper and pkg-config consumer behavior. Build reports
   must accurately state the modes used to build HDF5 without injecting those
   modes into unrelated consumer command lines.
8. Preserve standalone, `add_subdirectory()`, FetchContent, build-tree package,
   installed package, pkg-config, and compiler-wrapper consumption.
9. Preserve the ability of C99 consumers to include the installed C headers
   and link the C libraries, and of C++11 consumers to include the C and C++
   headers and link the C++ libraries, on both retained compiler families.
10. Preserve runtime results and HDF5 file-format compatibility. A standard
    mode does not authorize changing encoded representations or accepted
    files.
11. Preserve all legal optional feature combinations. Missing prerequisites
    may defer validation only through an explicit execution-time decision; they
    never authorize feature removal.
12. Preserve user-supplied compiler flags except for rejecting a contradictory
    request for a standard below the new minimum. Do not implement the baseline
    by fragile raw flag replacement.

## CMake Design Requirements

### Standard ownership and timing

- Establish the C minimum before any C configure check that contributes to
  generated project state.
- Establish the C++ minimum only as part of the existing opt-in C++ activation
  path, before any project-owned C++ target or C++ probe is created.
- Use CMake language-standard properties or compile features as the source of
  truth. Remove the direct C11 compile-option injection rather than replacing
  it with a direct C17 option.
- Set required-standard behavior and disable extensions coherently for both
  languages.
- Ensure first and repeated configuration produce identical standard
  properties, probe results, generated headers, and target contracts.

### Minimum and caller-selected modes

- With no caller selection, configure project-owned C targets for C17 and
  project-owned C++ targets for C++20.
- Reject an explicitly selected lower mode with an actionable message naming
  the required baseline.
- Retain an explicitly selected later mode rather than lowering it. Such a
  configuration is permitted but is not a release-validation substitute for
  the exact C17/C++20 rows.
- Validate C++ mode constraints only when a project-owned C++ path is enabled.

### Target and dependency boundaries

- Audit every project-owned target for its effective `C_STANDARD`,
  `CXX_STANDARD`, extension, and required-standard properties. No target may
  rely silently on a compiler default.
- Keep language requirements private to HDF5 build targets during this phase.
  Any new exported compile feature is an `INVESTIGATE` finding.
- Inventory all FetchContent, vendored, imported, and system dependency entry
  points. If directory-level standard variables leak into a dependency that
  does not declare the same baseline, isolate the dependency rather than edit
  its sources.
- Treat system tools such as Perl as external capabilities only. They receive
  no HDF5 language-standard requirement even when an HDF5 generation or test
  path invokes them.
- Keep KWSYS at its independently required mode while applying C++20 to the
  project-owned API driver executables.
- Apply C17/C++20 to retained standalone examples through their own entry
  point, not through assumptions about a parent HDF5 build tree.

### Probes and reporting

- Make standard-sensitive configure probes use the effective project mode.
  Pay particular attention to complex types, `<stdatomic.h>`, C threading,
  type sizes, attributes, and feature-test macros.
- Prove the active mode on Linux from compile commands and on Visual Studio
  from generated project properties or compiler command evidence.
- For MSVC C++ evidence, use `_MSVC_LANG` when `__cplusplus` is not configured
  to report the selected standard accurately.
- Audit `libhdf5.settings`, embedded build settings, pkg-config files, `h5cc`,
  and `h5c++`. Report the HDF5 build standard explicitly if raw standard flags
  are no longer present in reported global flags.
- Do not add a standard flag to installed consumer metadata unless a later
  public-header-baseline project explicitly approves that compatibility change.

## Findings and Repair Policy

Every finding must record its source file or target, triggering mode and
compiler, root cause, affected product/feature, compatibility impact, focused
reproducer, required validation, and one disposition:

- `FIX_BASELINE`: required to make existing project-owned behavior pass under
  C17/C++20 without changing public behavior.
- `KEEP_COMPAT`: retained compatibility code or older syntax that remains
  valid and does not block the new modes.
- `DEPENDENCY_EXCEPTION`: a non-project-owned dependency keeps its own standard
  mode through an explicit CMake scope boundary; HDF5 source is not exempted.
- `DEFER_SOURCE_MODERNIZATION`: optional cleanup or new-standard adoption that
  is unnecessary for the baseline and has a named future destination.
- `DEFER_ENVIRONMENT`: an optional row cannot run because a prerequisite is
  absent; record discovery evidence and obtain an explicit user decision.
- `INVESTIGATE`: ownership, behavior, or compatibility impact is unresolved;
  this blocks the affected work package.

Warnings alone are recorded and compared. They become `FIX_BASELINE` only when
they fail an agreed warnings-as-errors gate, reveal undefined or changed
behavior, or make generated/runtime results unreliable.

Allowed source repairs include private identifier changes for newly reserved
keywords, behavior-equivalent replacement of facilities rejected by the new
modes, missing standard headers, conforming declarations, and narrowly scoped
compiler differences. Use syntax and library facilities already valid in both
the old and new modes. Do not introduce concepts, ranges, modules, coroutines,
`std::span`, or other modern features as part of a blocker repair. A public
identifier conflict, public signature change, layout change, semantic rewrite,
or broader modernization crosses the stop line and requires a separate
decision.

## Risk Register

| ID | Risk | Required control |
| --- | --- | --- |
| `LS-01` | Current C feature probes run before the declared C11 baseline. Moving the standard earlier can change generated configuration. | Capture fresh pre-change probe results; compare every generated macro and classify all deltas. |
| `LS-02` | The raw C11 option in `CMAKE_C_FLAGS` conflates target compilation, reporting, and user flags. | Remove raw standard injection; prove exact target modes and separately preserve truthful build reporting. |
| `LS-03` | Directory-level standards can leak into fetched, vendored, or system dependency checks. | Inventory dependency target properties; isolate dependency standards and never raise or patch third-party implementations. |
| `LS-04` | C++20 can expose keyword, overload, lookup, removed-library, or standard-library ABI interactions not visible in text scans. | Run native MSVC/G++ builds and tests plus C++11/C++20 cross-mode installed consumers. |
| `LS-05` | Complex, atomics, and thread probes may select different implementation paths. | Repeat generated-header, thread-safe, concurrency, parallel, and subfiling gates on fresh caches. |
| `LS-06` | Imported targets or wrappers could accidentally force downstream C17/C++20. | Compare exports, pkg-config, wrapper output, and consumers using both legacy and new modes. |
| `LS-07` | Cached configure checks can hide a mode-dependent result. | Use fresh build trees for every baseline and final gate; first/repeat configure is a separate stability check. |
| `LS-08` | Strict C17 can reveal GNU-extension dependence in examples or optional paths. | Compile every available project-owned path with extensions off; classify rather than silently enable extensions globally. |
| `LS-09` | Standard switches can change optimization, inline emission, mangling, or diagnostics without source edits. | Compare C/C++ symbols, public layouts, representative runtime behavior, and warning sets on both pairs. |
| `LS-10` | A standard change affects every optional compiled path, invalidating broad inheritance of old evidence. | Rediscover capabilities and rerun every available affected row; explicitly decide each missing prerequisite. |

## Atomic Local Commit Discipline

Every repository modification must be committed locally as an atomic,
independently revertible checkpoint after its required checks pass. Never
leave a standard-switch commit that is known not to configure or build on a
required pair.

The exploratory standard probe therefore runs in an ephemeral source copy
outside the tracked working tree. It may alter the copied standard declarations
to discover failures, but it produces no repository change and no product
evidence. Repository fixes identified by that probe are then implemented in
the real tree one at a time, kept compatible with both the old and new modes,
validated, and committed before the final standard switch.

For each repository commit:

1. Address one blocker family, one language-standard ownership change, or one
   coherent documentation/evidence update.
2. Keep the implementation, focused reproducer or test, changelog entry when
   required, and directly required documentation together.
3. Do not combine C17 repairs, C++20 repairs, unrelated CMake modernization,
   formatting, dependency upgrades, or warning cleanup.
4. Inspect the exact staged paths and diff; do not include unrelated user
   changes, IDE state, build output, logs, or local evidence directories.
5. Run `git diff --check` and format touched C/C++ sources with the repository
   formatter before committing.
6. Use an imperative sentence-case subject no longer than 72 characters, with
   a useful `cmake:`, package, `c++:`, `test:`, or `docs:` scope.
7. Record exact focused checks in the commit body for non-trivial changes.
8. Correct a failed checkpoint with a focused follow-up or normal revert. Do
   not erase unrelated checkpoints or leave a broken commit as the intended
   continuation point.

Pure validation creates no implementation commit. Portable evidence is added
in focused `docs:` commits after the tested implementation anchor is fixed. All
commits remain local during this direction; do not push them as part of plan
execution.

## Resource and Execution Rules

- Prefer the CLion MCP project, search, inspection, patch, and execution tools
  when they provide the required operation. A command-line fallback is allowed
  when the IDE service does not expose the required evidence.
- Reuse an existing CLion integrated terminal for successive commands. Do not
  leave superseded terminal, build, test, server, or debugger sessions running.
- No build or CTest invocation may request more than four parallel jobs.
- The total number of active build and CTest jobs on one physical host must not
  exceed four. Do not run a four-job Windows workload and a four-job WSL
  workload concurrently on the same host.
- Use `cmake --build ... --parallel 4` and `ctest ... -j 4` as the normal upper
  bound. A failing or memory-intensive workload may use fewer jobs.
- Configure, inspection, packaging, and consumer commands that do not create
  compiler/test worker pools do not consume this parallel job budget, but they
  must not overlap in a way that makes evidence ambiguous.
- Use fresh out-of-source trees for baseline, probe confirmation, and final
  gates. Never commit or describe transient absolute build paths in portable
  documentation.
- Record actual compiler, CMake, generator, architecture, SDK/runtime, and
  dependency versions as evidence. Do not turn those observed versions into
  firewall inputs.
- Use `HDF_TEST_EXPRESS=3` for required full-suite results and report enabled,
  disabled, skipped, and failed counts.

## Execution Topology

The required hosts are:

| Host | Required configuration | Purpose |
| --- | --- | --- |
| Windows | x64, MSVC, Visual Studio generator, `/utf-8` | Release baseline, C++20, Debug/static/shared, install/package, consumers, optional Windows paths, generated project standard properties. |
| Linux | x86_64, GCC/G++, Ninja | Release baseline, C17/C++20 compile commands, full tests, consumers, pkg-config/wrappers, optional Linux paths, packages. |
| Linux secondary | Same GCC/G++, Unix Makefiles | Focused generator-independence configure/build/test check. |

Windows and Linux must test the same tracked implementation anchor. A result
from a locally modified source tree, a copied probe tree, or different commits
is diagnostic only and cannot close a work package.

## Baseline and Evidence Set

Before implementation, capture fresh C11/C++11 behavior at the planning
successor selected for execution:

- cache option contract and first/repeated configure stability;
- complete target and registered-test inventories;
- effective C and C++ standard flags/properties for every project-owned target;
- `H5pubconf.h`, other generated public headers, and build settings;
- default and C++-enabled CMake File API contracts;
- static/shared artifacts, filenames, exported targets, and install manifests;
- C, high-level, C++, and high-level C++ exported symbol sets;
- installed-header hashes and normalized effective declaration captures;
- public type size/alignment probes used by representative consumers;
- pkg-config records plus `h5cc` and `h5c++` `-show`/`-showconfig` output;
- representative build-tree, install-tree, `add_subdirectory()`, FetchContent,
  pkg-config, and compiler-wrapper consumers;
- full default and C++ CTest results at express level 3; and
- binary/source package manifests and representative HDF5 file round trips.

The results record must distinguish raw text, normalized declarations, target
properties, symbol names, ABI/layout evidence, runtime results, and file-format
checks. Equal counts never establish equal content.

## Execution Order

Execute Work Packages 2A through 2H in order. C and C++ have separate readiness
and switch gates so a C++20 issue cannot obscure C17 results. A later package
may reuse earlier evidence only when it identifies the tested commit and the
later changes cannot affect that evidence.

## Work Package 2A: Approval and Validator Qualification

### Work

1. Review and explicitly approve this plan and its build-baseline versus
   public-header-baseline distinction.
2. Select the execution baseline commit and require a clean tracked tree apart
   from known unrelated user changes.
3. Qualify Windows/MSVC and Linux/GCC validators and record exact versions.
4. Confirm four-job host-wide parallel accounting and available storage.
5. Discover optional prerequisites without installing packages or changing
   external systems.
6. Create the results-document skeleton and findings ledger only after
   execution is authorized.

### Exit criteria and commit boundary

- The plan state is `Approved`, the execution anchor and both validators are
  recorded, and no unresolved scope decision remains.
- Optional rows are classified as available or missing before build work.
- Approval and qualification evidence form one focused documentation commit.

## Work Package 2B: Freeze the Pre-Migration Contract

### Work

1. Produce fresh default and C++ Release builds on both pairs without changing
   language standards.
2. Capture the complete baseline/evidence set above.
3. Confirm actual C11/C++11 target modes rather than inferring them from CMake
   source assignments.
4. Run the full enabled default and C++ suites at express level 3.
5. Establish legacy C99 and C++11 installed consumers for later cross-mode
   comparison.

### Exit criteria and commit boundary

- Required baseline builds and tests pass at one tracked commit.
- Every captured artifact has a comparison method and normalization rule.
- Failures are either corrected before migration in separate ordinary-defect
  commits or block the phase; they are not reclassified as standard failures.
- Validation output remains untracked. The portable baseline summary is one
  focused `docs:` commit.

## Work Package 2C: External Standard Probe and Findings Ledger

### Work

1. Create an ephemeral source copy outside the repository from the exact 2B
   anchor.
2. Change only standard ownership needed to request strict C17 and C++20 in
   that copy.
3. Configure and build default and C++ Release products on both pairs with at
   most four active jobs.
4. Inspect standard properties for every project-owned target and identify
   dependency leakage.
5. Run focused tests sufficient to distinguish compiler blockers from runtime
   regressions.
6. Record each finding with the repair-policy fields and disposition. Do not
   copy exploratory source edits back into the repository.

### Exit criteria and commit boundary

- Every probe failure has a reproducer and disposition; no `INVESTIGATE` item
  remains before readiness repairs start.
- C and C++ findings are separated, as are project and dependency ownership.
- The copied tree is diagnostic only. A portable findings update is committed
  as documentation; there is no probe implementation commit.

## Work Package 2D: C17 Readiness Repairs

### Work

1. Implement each `FIX_BASELINE` C repair independently in the real tree.
2. Keep every repair compilable under both the current C11 mode and strict C17.
3. Add a focused reproducer or test for changed behavior and cover failure
   paths where applicable.
4. Validate the affected target on both MSVC and GCC in both modes before the
   repair commit lands.
5. Leave optional cleanup as `DEFER_SOURCE_MODERNIZATION`.

### Exit criteria and commit boundaries

- All known C17 blockers are fixed without public API, ABI, or format changes.
- Each blocker family is one atomic source/test/documentation commit.
- The repository still passes its current C11 focused gates after every repair.
- The external C17 probe passes for the repaired target before proceeding.

## Work Package 2E: Establish the C17 CMake Baseline

### Work

1. Move C standard ownership ahead of all standard-sensitive C probes.
2. Set the default/minimum to C17, require it, disable C extensions, reject a
   lower explicit request, and retain an explicit later request.
3. Remove raw C11 standard-option injection and reconcile truthful build
   reporting without exporting a consumer requirement.
4. Apply C17 to every project-owned C target in the core library, high-level
   library, tools, tests, plugins, and examples.
5. Isolate non-project dependencies that would otherwise inherit C17 without
   declaring it.
6. Add focused CMake checks for exact standard ownership, first/repeat
   configure stability, and absence of leaked installed compile features.

### Exit criteria and commit boundary

- Fresh default C Release configure/build/focused tests pass on both pairs.
- Every project-owned C target is proven to use C17; no raw C11/C99 standard
  site remains except a documented legacy consumer or dependency exception.
- Generated configuration deltas are completely classified and acceptable.
- C99 installed consumers still compile, link, and run.
- The C17 switch, focused CMake tests, required documentation, and changelog
  form one buildable atomic commit. If this cannot be achieved, do not commit
  the switch; return to 2D.

## Work Package 2F: C++20 Readiness Repairs

### Work

1. Repeat the blocker process for project-owned C++ and mixed C/C++ headers.
2. Keep repairs compilable under current C++11 and strict C++20 until the
   switch lands.
3. Test public `H5Cpp.h` inclusion and representative C API inclusion from
   both C++11 and C++20.
4. Validate affected C++ targets on native MSVC and G++ and compare symbols for
   each repaired library.
5. Treat public names newly reserved by C++20 as a stop condition rather than
   silently changing the installed API.

### Exit criteria and commit boundaries

- All known C++20 blockers are fixed with preserved public declarations and
  symbol sets.
- Each blocker family is an independently revertible commit with focused
  old/new-mode evidence.
- Current C++11 focused builds continue to pass until the baseline switch.

## Work Package 2G: Establish the C++20 CMake Baseline

### Work

1. Set the opt-in C++ default/minimum to C++20, require it, disable extensions,
   reject a lower explicit request, and retain an explicit later request.
2. Apply C++20 to the opt-in C++ wrappers and every project-owned C++ target in
   tools, tests, plugins, and examples.
3. Keep KWSYS and other dependencies on their own standard contracts.
4. Prove that C-only configurations remain independent of a C++ compiler.
5. Add focused standard-property, opt-in activation, and export-leakage checks.
6. Compare C++ symbols, public declarations, layouts, build settings, package
   metadata, and C++11/C++20 consumers.

### Exit criteria and commit boundary

- Fresh C++ Release configure/build/focused tests pass on both pairs.
- Every project-owned C++ target is proven to use C++20, while C-only builds do
  not enable C++.
- C++11 and C++20 installed consumers both compile, link, and run on each pair.
- No unapproved C++ ABI, export, or consumer metadata delta remains.
- The C++20 switch, focused tests, required documentation, and changelog form
  one buildable atomic commit. If it cannot pass, return to 2F.

## Work Package 2H: Full Product, Optional, and Handoff Gate

### Required matrix

| Row | Windows/MSVC | Linux/GCC | Required evidence |
| --- | --- | --- | --- |
| Default Release | Required | Required | Fresh configure, full build, full CTest, exact C17 proof. |
| C++ Release | Required | Required | Fresh configure, full build, full CTest, exact C17/C++20 proof. |
| Debug | Required | Required | Build plus fixture-aware focused smoke tests. |
| Static-only | Required | Required | Build, install, artifact and consumer checks. |
| Shared-only | Required | Required | Build, install, runtime and consumer checks. |
| Combined static/shared | Required | Required | Target, export, package, and consumer consistency. |
| Developer warnings | Required | Required | `HDF5_ENABLE_DEV_WARNINGS=ON`; build and warning-delta review. |
| Standalone examples | Required | Required | C17 C, C++20 C++, and high-level configure/build/test. |
| Legacy consumers | Required | Required | Installed C99 and C++11 header/link/runtime checks. |
| Baseline consumers | Required | Required | Installed C17 and C++20 header/link/runtime checks. |
| Integration styles | Required | Required | Build/install package, `add_subdirectory()`, FetchContent; pkg-config/wrappers where supported. |
| Thread-safe/concurrency | Applicable | Required | Fresh configure/build and focused thread tests; generated atomics/thread macros reviewed. |
| Parallel/subfiling | Environment-dependent | Required when available | Build and focused MPI/VFD tests; C++ remains outside supported parallel combination. |
| System compression | Required when available | Required | Validate HDF5 discovery, linkage, filters, install, and consumers without changing the system libraries' standards. |
| Bundled compression/plugins | Required when network/dependencies permit | Required | Isolate third-party modes; validate HDF5-owned build, loading/failure behavior, exports, and packages. |
| Coverage | Not applicable to MSVC baseline | Required | Instrumented build/test and counter cleanup with four-job cap. |
| Binary packages | ZIP | TGZ plus available native formats | Manifest, metadata, runtime, and consumer checks. |
| Unix Makefiles | Not applicable | Required focused row | Configure, representative build, and tests independent of Ninja. |

Every optional path that compiles project-owned code is affected by the new
baseline. Re-run each available row. The six historical Stage 2 environment
deferrals are context, not automatic evidence inheritance. Perform fresh
capability discovery; record missing prerequisites and obtain an explicit user
decision for each required or deferred row.

### Final comparison

1. Compare cache, target, test, generated-header, build-settings, install,
   export, pkg-config, wrapper, symbol, layout, package, and consumer records
   against 2B.
2. Allowlist only intentional standard-mode/reporting changes and approved
   blocker repairs.
3. Run full default and C++ suites on both pairs at `HDF_TEST_EXPRESS=3`.
4. Run representative cross-platform file creation/read checks to protect the
   HDF5 format boundary.
5. Repeat first/repeated configuration checks and ensure clean source-package
   input.
6. Confirm all required commands respected the four-job host-wide maximum.

### Exit criteria and commit boundaries

- Every required matrix row passes at one implementation anchor or has an
  explicit, approved environment disposition that does not conceal a product
  failure.
- Every finding is closed or explicitly deferred outside the baseline; no
  `INVESTIGATE` item remains.
- No public API, ABI, installed-header minimum, file-format, or unsupported
  platform change is bundled into the result.
- `C17Cpp20BuildBaselineResults.md`, current documentation, and
  `REFACTORING_PROGRESS.md` identify exact evidence, limitations, final
  implementation anchor, and next continuation point.
- Evidence and handoff updates are focused documentation commits made after
  the tested implementation commits; validation output stays untracked.

## Per-Commit Gates

| Commit type | Minimum pre-commit gate |
| --- | --- |
| Plan/evidence only | Link/path review, factual anchor review, `git diff --check`. |
| C readiness repair | Old-mode and strict-C17 compile of affected targets on MSVC/GCC, focused tests, formatting, `git diff --check`. |
| C17 CMake switch | Fresh default Release configure/build/focused tests on both pairs, standard-property audit, generated-header comparison, C99 consumer. |
| C++ readiness repair | C++11 and C++20 compile of affected targets on MSVC/G++, focused tests, symbol comparison, formatting, `git diff --check`. |
| C++20 CMake switch | Fresh C++ Release configure/build/focused tests on both pairs, opt-in C-only check, standard/export audit, C++11/C++20 consumers. |
| Optional integration repair | Narrow affected configuration on both applicable pairs, positive/failure-path tests, install/consumer check when exported. |
| Final documentation | Verify cited commits and counts, cross-link plan/results/handoff, `git diff --check`. |

Focused gates keep commits reviewable; they do not replace Work Package 2H.
Evidence may be inherited only when the later diff cannot affect the checked
surface and the results record says why.

## Failure Handling and Stop Conditions

Stop the affected work package and record an `INVESTIGATE` finding when:

- a public identifier becomes invalid under C++20;
- a fix would change a public function signature, callback type, class layout,
  exception contract, symbol, calling convention, or installed declaration;
- C17/C++20 changes complex, atomic, thread, type-size, or other generated
  configuration in a way whose runtime or ABI impact is not understood;
- a retained dependency requires a source patch rather than a CMake scope
  boundary;
- a required legacy C99/C++11 consumer fails and restoring it would conflict
  with the intended build baseline;
- an HDF5 format, reference file, encoded bytes, or cross-platform read result
  changes unexpectedly;
- the standard switch cannot be made as a buildable atomic commit after known
  readiness repairs;
- a required pair fails while the other passes and the correction would create
  compiler-specific public behavior; or
- resource limits, stale caches, mixed commits, or local modifications make
  evidence attribution unreliable.

Do not weaken the baseline, enable extensions globally, suppress a required
test, modify expected output, or defer a failing required row merely to close
the phase. Revert the focused switch or keep it uncommitted, repair the root
cause under the old/new dual-mode gate, and repeat the affected package.

## Candidate Commit Sequence

The exact blocker count is determined by Work Package 2C, but the intended
history shape is:

1. `docs: Plan the C17 and C++20 build baseline`
2. `docs: Record the language migration baseline`
3. One commit per C17 readiness blocker, using the owning package scope
4. `cmake: Raise the C build baseline to C17`
5. One commit per C++20 readiness blocker, using `c++:` or the owning scope
6. `cmake: Raise the C++ build baseline to C++20`
7. Focused optional-path repair commits only when the new modes expose a real
   project defect
8. `docs: Record C17 and C++20 product validation`
9. `docs: Complete the language build baseline handoff`

The standard-switch commits must not precede their readiness repairs in local
history. Each candidate subject is illustrative and must still describe the
actual focused change.

## Completion Criteria

Phase 2 is complete only when:

- the plan has been approved and every work package has passed;
- exact C17 and C++20 modes are proven for every applicable project-owned
  target in the core library, high-level library, opt-in C++ wrappers, tools,
  tests, plugins, and examples on both release baselines;
- C-only configurations remain C++-independent;
- configure probes and product targets use coherent effective modes;
- third-party libraries and tools retain their own language ownership and are
  not modified as part of the migration;
- all required product, optional, install, package, and consumer gates pass
  within the four-job execution limit;
- C99/C++11 legacy consumers and C17/C++20 baseline consumers pass;
- generated/public declarations, C/C++ ABI, symbols, filenames, and HDF5 file
  behavior remain compatible;
- every difference and environment gap has an explicit disposition;
- all repository changes exist as atomic, independently revertible local
  commits; and
- the results record and portable handoff point to the tested final
  implementation anchor without machine-specific paths or transient logs.

Completion establishes C17 and C++20 as the project-owned build baselines and
proves the existing supported functionality through the bounded validation
matrix. It does not complete broad source modernization, introduce modern
syntax as an incidental goal, or authorize a later public-header minimum
change without a new compatibility plan.
