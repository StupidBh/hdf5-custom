# Stage 4 Final Project Support Audit Plan

## Status

- State: In progress; Work Packages 4A through 4C complete
- Plan drafted: 2026-09-05
- Audit recommendations and inherited boundaries accepted: 2026-09-05
- Detailed plan and review clarifications accepted: 2026-09-05
- Execution requirements confirmed: temporary maximum parallelism 4; prefer CLion MCP
- Execution started: 2026-09-05
- Execution results:
  [CMakePlatformSupportReductionStage4Results.md](CMakePlatformSupportReductionStage4Results.md)
- Parent compatibility plan:
  [CMakePlatformSupportReduction.md](CMakePlatformSupportReduction.md)
- Portable handoff: [../../REFACTORING_PROGRESS.md](../../REFACTORING_PROGRESS.md)
- Completed prerequisite:
  [CMakePlatformSupportReductionStage3Results.md](CMakePlatformSupportReductionStage3Results.md)
- Stage 3 final implementation anchor: `74288cbaa`
- Stage 3 accepted completion record: `7e50c3c17`
- Stage 4 planning baseline: `7e50c3c17`
- Stage 4 current implementation anchor: `8d7aa0432`
- Required target pairs: Windows with compiler ID `MSVC`, and Linux with
  compiler ID `GNU`
- Release-validation baselines: Windows x64 with MSVC and a Visual Studio
  generator; Linux x86_64 with GCC/G++ and Ninja
- Secondary Linux generator check: Unix Makefiles
- Temporary maximum build and CTest parallelism: 4 in total per physical host
- Required final test level: `HDF_TEST_EXPRESS=3`

The user accepted the plan's review clarifications and confirmed the execution
requirements on 2026-09-05. Execution has started, and Work Package 4A is
complete at the reviewed `cafdc38e9` baseline. Work Package 4B is also complete
at implementation anchor `ebdb99969`: the repository entry points, current
support claims, presets, workflows, packaging, and residual selectors are
classified, and the discovered gaps are repaired. Work Package 4C is complete
at implementation anchor `8d7aa0432`; utility registration is stable and the
legal Linux mirror test runs with its server fixtures. Stage 3 remains
Completed. Work Package 4D is the next execution action; no repeated plan
approval is needed for work within these boundaries.

## Purpose

Stage 4 closes the project supported-platform reduction direction by auditing
the complete repository and delivered products against the two-pair contract.
It connects the CMake, source/header, documentation, CI, packaging, and consumer
evidence already established by Stages 1 through 3 and resolves defects that
prevent a reliable final acceptance statement.

Completion means that active support claims and reachable project-owned
implementation agree, retained behavior has current validation, and every
finding has an explicit disposition. It does not mean that unsupported-platform
keywords disappear or that all possible retained feature combinations were run.

The separate CMake 4 modernization remains paused. Target-scoped dependency
migration, general CTest redesign, installation/packaging decomposition, and
root-coordinator cleanup remain in that direction. Its stage numbers must not
be confused with this platform-reduction plan's four stages. C17/C++20 migration
is also outside this plan.

## Inherited Successes and Evidence Limits

### Stage 1

- Nineteen focused CMake/CI implementation commits removed unsupported build
  entry points, private options, compiler/platform dispatch, and packaging paths.
- The central firewall checks target system and exact C/C++ compiler IDs.
  Generator, architecture, and exact compiler version are not admission gates.
- Windows/MSVC default, Debug, static-only, shared-only, C++, full CTest,
  install, ZIP, standalone-example, and external-consumer rows passed.
- The admission-policy correction restored reachable MSVC ARM64 Debug flags,
  ARM64 package naming, and 32-bit NSIS install-root handling.

### Stage 2

- Linux/GCC default Release and Debug, static-only, shared-only, C++, Ninja,
  Unix Makefiles, examples, consumers, install, TGZ, and contract checks passed.
- The default suite passed 2,819 tests with 37 disabled out of 2,856 registered.
- Available wrappers, system and bundled compression, parallel, subfiling,
  thread-safe, concurrency, external plugins, coverage, STGZ, and DEB rows passed.
- The bundled-compression export regression was repaired at `81e96c889`;
  coverage documentation was corrected at `d39cd5fa0`. These are closed defects.
- Six unavailable, non-required optional rows have explicit user deferrals.

### Stage 3

- Fourteen atomic implementation commits removed project-owned unsupported-only
  source/header branches, with final implementation at `74288cbaa`.
- Final default Release CTest passed 2,816 enabled Windows tests and 2,818
  enabled Linux tests, with 37 disabled on each platform. Both used express
  level 3 and at most four build or test jobs.
- Debug, static-only, shared-only, C++, examples, consumers, installation,
  packaging, admission, affected thread modes, and plugin checks passed.
- The residual source/header ledger has no `INVESTIGATE` item. Generated Bison
  skeleton and vendored `uthash.h` selectors remain protected content.
- Linux plugin discovery retains the `lib*.so` convention and skips `.dylib`
  filenames, even when they contain ELF plugins. The user accepted this change.
- Corrected header evidence establishes preserved effective declarations on
  both pairs. LF normalization and edits to `H5public.h` and `H5pubconf.h`
  explain expected text differences. Raw file equality is not the contract.
- The old Windows C++ baseline installation was incomplete. No complete
  101-to-101 byte comparison is established by that artifact. C++ source,
  preprocessing, build, consumer, and exported-symbol evidence remains valid
  within its recorded scope; none is a claim of an exhaustive ABI audit.

Stage 4 must cite the exact preceding result and tested commit when inheriting
evidence. Equal test or manifest counts alone never establish content equality.
An express-level-3 full enabled suite is not an exhaustive-level-0 run.

## Scope Boundaries

### In scope

- All tracked project files, including root and standalone CMake entry points,
  modules, presets, CI, dashboard scripts, toolchains, current documentation,
  release metadata, source, headers, templates, tests, tools, and examples.
- Generated build/install package metadata, public export sets, wrappers,
  pkg-config files, source/binary package manifests, and representative consumers.
- Semantic reclassification of residual platform/compiler references and
  cross-checking active claims against reachable implementation.
- Focused corrections of platform-reduction regressions, missed unsupported-only
  paths, inaccurate current support claims, and evidence defects.
- Two named pre-existing defects needed for trustworthy final validation:
  configure-order dependence of utility test registration, and the optional
  API driver's known include-path and process-cleanup defects.
- Portable findings, final evidence, known limitations, and a concrete handoff
  to the paused modernization direction.

### Out of scope

- Changing the two accepted compiler pairs or making release-validation
  architectures, generators, or exact tool versions additional admission gates.
- Adding public API, changing ABI, file-format representations, library
  versioning, or adopting another C/C++ language standard.
- Restoring Java or Fortran modules, or removing retained optional features
  because a dependency or runtime is unavailable.
- General modernization, broad warning/style cleanup, dependency upgrades,
  or independent product defects without a direct final-audit dependency.
- Rewriting factual historical release notes or editing third-party/generated
  skeleton content merely to reduce keyword counts.
- Publishing packages, changing external services, pushing commits, or starting
  the next refactoring direction as an automatic consequence of this audit.

## Fixed Compatibility Boundaries

1. Use `CMAKE_SYSTEM_NAME` and exact compiler IDs for source-build admission.
   `HDF5_ALLOW_UNSUPPORTED` concerns feature combinations and cannot bypass it.
2. Preserve architecture, generator, feature-probe, and runtime variants that
   remain reachable through either accepted pair, including non-baseline ones.
   Admission alone does not establish release qualification.
3. Distinguish HDF5 source builds and standalone example projects from consumers
   of a compatible prebuilt library. Do not inject the source-build firewall
   into installed packages to reject arbitrary downstream compilers.
4. Preserve the core C, high-level, opt-in C++, tools, utilities, tests, and
   retained examples, including existing legal optional feature combinations.
5. Preserve public C/C++ names, calling conventions, layouts, exported symbols,
   library names/versions, static/shared products, install/export behavior,
   and cross-platform HDF5 file compatibility.
6. Keep generic Windows/POSIX separation, supported feature fallbacks,
   `H5T_INTEL_*`, `H5T_FORTRAN_S1`, and other API/file-format compatibility names.
   Keep JNI discovery needed by the HDFS VFD; it is not a Java binding.
7. Retain developer tooling, vendored content, generated skeletons, and factual
   history with explicit classifications. Reproduce project-owned generated
   edits from identified canonical inputs when a correction affects them.
8. Retain the accepted Linux plugin filename restriction. Verify real positive
   loading and negative discovery behavior; do not broaden it incidentally.
9. Separate header text, effective declarations, layout, symbols, linkage, and
   runtime evidence. Explain normalization; never suppress configuration or
   public declaration changes merely to obtain equal output.
10. Carry forward existing optional deferrals while the relevant path is
    unaffected. A changed path needs appropriate new evidence or a revised
    scope decision; unavailable prerequisites never authorize feature deletion.

## Findings and Repair Policy

The initial ledger contains the following known items. Their inclusion is a
planned disposition, not a claim that this document repairs the implementation.

| ID | Finding and source | Agreed disposition | Acceptance evidence |
| --- | --- | --- | --- |
| `S4-01` | `HDF5_BUILD_UTILS` is declared in `utils/CMakeLists.txt` after `test/` consumes it; Stage 3 records different first/repeat test registration. | Required focused repair in 4C; preserve the intended default and explicit user values. | First, second, and third configure contracts agree per option set; utility-dependent targets/tests appear only when their prerequisites permit them. |
| `S4-02` | The optional API driver has local include-path defects and `H5API_CLEAN_PROCESSES` spelling inconsistent with `H5_API_CLEAN_PROCESSES`. Stage 3 used validation-only corrections. | Required focused repair in 4D; validate the retained optional target with committed source. | Native MSVC/GCC target builds and process success/failure/cleanup checks, without validation-only source patches. |
| `S4-03` | Some current plan/status prose still describes Linux validation as pending or bundled compression as an open/non-Stage-1 defect. | Align current summaries during plan preparation and audit all remaining claims in 4B. Preserve historical evidence and add explicit superseding references. | Current documents agree with Stage 2/3 results; no previously fixed failure is reported as a current blocker. |
| `S4-04` | Header and contract evidence can be overstated when file counts or incomplete old C++ installs are used as equality claims. | Preserve the accepted correction; capture complete fresh default/C++ baselines in 4A and compare them in 4E/4F. | Manifest coverage, normalization, declaration, symbol, consumer, and any layout checks each have a stated scope. |

For additional findings, record file/symbol, owning module, affected pair and
feature, trigger, root cause, compatibility impact, required validation, and
one disposition:

- `FIX_STAGE4`: a regression, unsupported-only path, inaccurate current claim,
  or defect required to pass an agreed final gate. Keep the correction focused.
- `KEEP_PROTECTED`: API/format, retained variant, tooling, third-party/generated
  content, or factual history, with a concrete semantic rationale.
- `DEFER_MODERNIZATION`: independent structural work, with a named destination,
  continuation action, and evidence that no Stage 4 gate depends on the change.
- `DEFER_FOLLOWUP`: an independent product defect outside Stage 4, recorded in
  the results ledger with root cause, impact, owning module, and next action.
  Use a separate issue or defect record when available; do not classify ordinary
  product defects as CMake modernization. No required Stage 4 gate may depend
  on the deferred repair.
- `DEFER_ENVIRONMENT`: an existing or explicitly agreed missing-prerequisite
  disposition, with the affected feature and evidence limits retained.
- `INVESTIGATE`: unresolved ownership or semantics; blocks the affected batch
  and must be resolved before completion.

Every `FIX_STAGE4` item must close with a correction and passing evidence.
Do not move a failing required row into a deferred category to pass the stage.
Independent issues outside the above repair scope are recorded for later work;
seek a scope decision only when they prevent a required gate or would require
an additional compatibility change. Existing user decisions remain effective.

## Atomic Local Commit Discipline

Every repository modification is an atomic, independently revertible local
commit after its required checks. Keep one behavior's implementation,
reproducer, tests, changelog, and required documentation together. Separate
unrelated repairs and formatting. Use imperative sentence-case subjects of at
most 72 characters and a useful scope; include a body for non-trivial changes.

Before committing, inspect the exact diff and staged paths, run
`git diff --check`, format touched C/C++ files with the repository formatter,
and pass focused checks on both affected pairs. Never stage unrelated user
changes, IDE metadata, validation worktrees, downloads, build/install trees,
packages, or logs. Pure inspection and validation creates no commit; portable
plans and results use focused `docs:` checkpoints. Documentation-only changes
require link, consistency, and diff checks, not a new product test run.

Do not amend historical stage evidence into a different tested commit. Correct
a failed committed implementation checkpoint in a new focused commit; a
revert, if needed, must remain confined to that checkpoint's owned changes.

## Execution Topology and Baseline Capture

- Prefer the current CLion MCP for reading, searching, editing, inspections,
  and terminal/build/test work. Use other tools when the MCP service is
  unavailable, lacks the needed capability, or cannot reliably complete the
  operation. A timed-out IDE command may still be running: check and finish or
  stop it before retrying.
- Qualify Windows x64/MSVC/Visual Studio and native Linux x86_64/GCC/G++/Ninja
  validators, plus GNU Make. Record exact versions and target triples as result
  evidence. Use `CL=/utf-8` on Windows and `HDF_TEST_EXPRESS=3` for test rows.
- Limit build and CTest concurrency to four in total per physical host.
  Windows and WSL on the same host share that budget; independent physical
  hosts each have their own limit of four. Divide the budget among concurrent
  rows, or run them sequentially. Use `cmake --build ... --parallel 4` and
  `ctest ... -j 4` only when that command owns the entire host budget; otherwise
  lower the values. Explicitly cap IDE builds and nested dependency builds,
  including native build-tool/compiler parallelism, so inherited presets or
  environment settings cannot multiply or exceed the limit. Record MPI ranks
  separately and avoid oversubscribing the validators.
- This four-job limit is a temporary resource budget for executing this Stage 4
  plan. It is not a product default or compatibility value and does not require
  changing repository presets or general user commands that use another job
  count.
- Prefer the WSL native filesystem for Linux source/build evidence. Do not
  reuse Windows CMake caches, install prefixes, or dependency outputs on Linux.
- Use clean tracked trees at the same commit for baseline and final gates.
  Before each implementation commit, test the identical candidate diff against
  the same parent on both affected validators; record the resulting commit.
- Probe optional prerequisites read-only. Use the configured local proxy for
  outbound downloads and exclude localhost/LAN traffic. Record dependency
  identity and retrieval mode without credentials or machine-local paths.
- Resolve actual executable locations and environment at execution time.
  Previous machine paths and untracked build trees are not prerequisites.

Work Package 4A fixes its baseline at the reviewed plan checkpoint derived from
`7e50c3c17`. Verify and classify every difference from `74288cbaa`; expected
differences are documentation only. Any intervening implementation change must
be included explicitly in the baseline and validation ownership ledger.

Before the first implementation correction, capture on both platforms:

1. Fresh default and C++ Release builds, focused tests, CTest registration and
   fixture metadata, and complete isolated installs.
2. Normalized File API contracts using
   `config/cmake/scripts/HDF5BuildContract.cmake`. Register `QUERY` before the
   first configure; capture `CAPTURE` results after each planned configure.
3. Separate first/repeat configure records that reproduce `S4-01`. Do not
   silently mix them or require their known baseline discrepancy to pass.
4. Complete default and C++ installed-header manifests and content hashes,
   effective C/C++ declarations, and representative compile/link consumers.
5. Exported C core, C high-level, tools-library, C++ core, and C++ high-level
   symbol sets; names, import libraries, versions, SONAME/RUNPATH, and metadata.
6. Default and C++ binary packages and one clean tracked-source package, with
   manifests covering product files and excluding local artifacts.

Use equivalent toolchains, configurations, and logical install/staging prefixes
for each before/after comparison. Retain raw capture coverage separately from
normalization. If an old artifact is missing, recreate a clean baseline at its
recorded commit or state the limit; do not infer equality from an incomplete
installation. New Stage 4 baselines do not retroactively repair old evidence.

## Execution Order

| Work package | Purpose | Dependencies |
| --- | --- | --- |
| 4A | Qualify validators, capture baseline, establish findings ledger | Reviewed execution plan |
| 4B | Audit repository support claims, entry points, and residuals | 4A |
| 4C | Repair configure-order-dependent utility test registration | 4A and relevant 4B classification |
| 4D | Repair and validate the optional API driver | 4A and relevant 4B classification |
| 4E | Audit artifacts, installed contracts, and consumers | 4B and all relevant implementation corrections |
| 4F | Run final dual-platform gate and close the direction | 4B through 4E complete |

Complete each correction with its focused checks before the final matrix.
Resolve other `FIX_STAGE4` items in separate ownership-based commits before
4F. Independent read-only checks may overlap; shared build/install state may not.

## Work Package 4A: Baseline and Findings Ledger

### Work

Qualify the validators and capture the baseline described above. Read the
Stage 1/2/3 results and map each historical passing or deferred row to its
tested commit, feature, and potential Stage 4 owner. Reproduce the two named
implementation defects in isolated trees before fixing them. Discover the API
driver's actual optional entry path and KWSys prerequisite from current CMake.

Create `CMakePlatformSupportReductionStage4Results.md` with the initial evidence,
baseline identity, defect reproductions, optional capability table, and ledger.
Use results states `PASS`, `FAIL`, `SKIP_MISSING_ENV`, and `NOT_RUN`. Label inherited
passing evidence with its historical commit; never present it as a fresh run.

### Exit criteria and commit boundary

Both validators are qualified, all required baseline captures are complete,
and named defect reproductions and validation owners are recorded before 4A
can close. A missing required baseline blocks its dependent implementation
batch. Partial evidence may be committed and independent read-only audit work
may continue, but neither action marks 4A complete. No unrelated baseline
failure is hidden behind Stage 3 completion. Commit only portable evidence in
a focused `docs:` checkpoint.

## Work Package 4B: Repository Contract Audit

### Work

- Enumerate tracked files with Git; use CLion search and `rg` for candidates.
  Audit all active CMake entry points and language-enabling calls, including
  standalone examples and the optional API driver, for firewall coverage.
- Run the retained synthetic admission suite and inspect cases for both pairs,
  rejected systems/compilers, optional C++, generator/architecture variation,
  and non-bypass by `HDF5_ALLOW_UNSUPPORTED`.
- Inspect presets, CI, dashboards, scripts, toolchain helpers, packaging choices,
  and current usage docs for reachable unsupported build paths or conflicting
  claims. Commands in accurate historical records remain history.
- Repeat Stage 3's original keyword families and exact selector searches;
  extend the repository scan to other rejected systems/compilers such as AIX,
  HP-UX, IntelLLVM, NVHPC, AOCC, and Emscripten. Classify matches semantically.
- Check generic compiler dispatch and fallback branches even when they lack an
  unsupported brand name. Keep CMake feature probes and supported architecture
  handling where their selected behavior remains necessary.
- Verify Java/Fortran product removal without removing format constants, HDFS
  JNI discovery, or Python example code.
- Align root handoff, detailed plans, current user docs, and changelog. Preserve
  previous dates/results and mark superseded diagnoses explicitly.

### Exit criteria and commit boundaries

Every entry surface and residual family has an owner and disposition. No
`INVESTIGATE` remains in a batch released for edits. Implement missed reduction
defects in focused commits with dual-platform tests; use separate documentation
commits for support-claim corrections. The final ledger must show no reachable
project-owned unsupported-only implementation or unsupported current build claim.

## Work Package 4C: Stable Utility Test Registration

### Work

Trace `HDF5_BUILD_UTILS` declaration and all consumers, including mirror VFD
server dependencies and test fixtures. Make the smallest ordering/ownership
correction that preserves the intended default `ON`, explicit `OFF`, and legal
feature combinations. Do not globally reorganize option loading or CTest.

Add a configure-level reproducer that compares target names, registered tests,
fixtures, and normalized relevant contracts after first, second, and third
configuration with identical arguments. Cover default options, explicit utils
`ON` and `OFF`, and enabled/disabled mirror VFD prerequisites where legal.
Also exercise an `ON` to `OFF` to `ON` reconfigure sequence: no stale test or
missing executable may remain. Do not compare only aggregate counts.

### Validation and exit criteria

Run the reproducer on both native pairs. Build and run newly enabled utility or
mirror tests with their actual server dependencies where available, and verify
absence of those tests when disabled. Keep unsupported platform/feature
combinations disabled by their existing contract. Baseline-to-final default
count changes must name the exact tests and explain the corrected registration.
Commit the repair, reproducer, and changelog as one focused behavior change.

## Work Package 4D: Optional API Driver Reliability

### Work

Repair the known include-directory and process-cleanup identifier defects in
`test/API/driver/` at their owning target/source boundary. Preserve the existing
KWSys acquisition contract and public compiler-pair policy. Do not upgrade KWSys
or redesign the driver. Keep generated and dependency files outside the commit.

The repair scope is limited to those known defects and behavior directly
affected by their correction. The process checks below do not authorize a
general driver redesign. Record an independent deeper defect as
`DEFER_FOLLOWUP` if it does not block a required Stage 4 gate. If it prevents a
required gate, keep that gate failed and seek a focused scope decision rather
than expanding the repair automatically or accepting a failing required case.

Use the real configured optional driver target from current repository CMake.
Document any standalone prerequisites; do not assume the driver directory is a
complete independent build product. No validation-only source corrections may
be required to build the final committed target.

### Validation and exit criteria

Build the target with MSVC and GCC/G++ and exercise its Windows/POSIX process
branches. Use controlled child processes to check successful completion,
nonzero child exit propagation, launch failure, timeout, and cleanup without
leaving child processes running. Bound timeout tests and inspect their outcomes;
do not terminate unrelated processes. Run registered API and affected process
tests as additional integration evidence, not as a substitute for the driver.

If the actual option path or KWSys prerequisite is unavailable, record the
specific blocker and continue independent audit work. This newly required repair
has no inherited Stage 2 waiver. Commit the focused repair, meaningful regression
tests, and changelog after the required checks pass.

## Work Package 4E: Products and Consumer Contracts

### Work

- Compare complete fresh default/C++ installations and exported symbol sets
  against 4A. Check effective C headers in C and C++ modes and C++ wrapper
  header consumers separately. No unexplained API, layout, or symbol delta is
  acceptable; a symbol-set comparison alone does not prove layout compatibility.
- If public/header/layout code changes, add targeted size/alignment/offset and
  compile/link checks for affected public types on both pairs. Otherwise retain
  the no-source-change proof and existing ABI evidence with its stated limits.
- Inspect library names, static/shared separation, Windows DLL import libraries
  and Debug PDBs, Linux SONAME/RUNPATH, export sets, dependency metadata, and
  runtime tool execution without accidental ambient library paths.
- Verify build-tree and install-tree `find_package` consumers for C, HL, C++,
  and static/shared forms. Run retained standalone C/C++/HL examples against
  both locations. Exercise minimal `add_subdirectory()` and local-source
  FetchContent consumers and compare parent-visible settings with 4A. Classify
  new global-state leakage without requiring the paused global-state migration.
- Verify Linux `h5cc`, `h5c++`, default high-level linkage, `-nohl`, and installed
  pkg-config metadata. Inspect package configuration for accidental source-build
  admission checks imposed on prebuilt-library consumers.
- Check source and binary package manifests for removed paths, local data,
  missing products, and wrong support metadata. Scan generated outputs
  separately from tracked sources; do not commit captures or package archives.
- Exercise normal plugin loading and the accepted Linux filename exclusion,
  and retain datatype/conversion/reference/file compatibility test coverage.

### Exit criteria and commit boundaries

All product/consumer deltas are classified and supported behavior passes.
Corrections belong in individual implementation commits with regression tests;
portable manifest summaries and evidence belong in a `docs:` checkpoint.

## Per-Commit Gates and Evidence Inheritance

| Gate | Required check |
| --- | --- |
| `S4-DIFF` | Exact diff, staged paths, `git diff --check`, applicable formatting, and documentation links |
| `S4-FOCUSED` | Native MSVC and GCC configure/build/test checks for each affected behavior, including its reproducer and fixtures |
| `S4-ADMISSION` | Admission suite and entry-point review after any firewall/caller change |
| `S4-CONTRACT` | Before/after normalized contracts for option, target, test, generated-product, install, export, or package changes |
| `S4-PUBLIC` | C/C++ header consumers, symbols, and affected layout checks after public/generated header or ABI-sensitive changes |
| `S4-OPTIONAL` | New validation of any previously passing or deferred optional path affected by the correction |

A previously passing optional row may be inherited only with its original
commit/result and a file/target/dependency impact rationale proving that Stage 4
does not affect its behavior. Merely changing no file in that feature directory
is insufficient: shared CMake helpers, exports, runtime code, and dependency
handling may affect it indirectly. Rerun whenever impact cannot be excluded.

The final core gate below is mandatory at one final implementation commit even
when some optional rows inherit evidence. A 4E result may satisfy the matching
4F row directly when it used that final implementation commit, the required
configuration, a fresh build/install tree and clean tracked source, and the
same validation checks and environment requirements. Record the reused row's
evidence identity explicitly; do not repeat it merely because the work-package
label changed. Subsequent changes require the affected rows to be rerun;
all required rows must still identify the final implementation commit, subject
only to the documentation-only exception below. The independent 4A before-change
baseline remains required.

Later documentation-only checkpoints
may retain that implementation evidence if their diff and package-manifest
implications are explicitly accounted for. Do not rerun completed product tests
solely to change a documentation commit hash.

## Final Dual-Platform Gate

Collect passing results after all implementation fixes at the same clean commit
on both validators, including qualifying 4E results under the reuse rule above.
Use fresh build/install directories for each row. Execute all enabled default
tests at `HDF_TEST_EXPRESS=3`, record disabled counts and reasons, and use the
narrowest relevant fixture-aware selections for other configurations.

| Row | Windows/MSVC | Linux/GCC |
| --- | --- | --- |
| Default Release | Full combined static/shared build and full enabled CTest | Full Ninja build and full enabled CTest |
| Debug | Full build, focused C/HL/tool tests, and Debug install/PDB check | Full build and focused C/HL/tool tests |
| Static-only Release | Full build, focused tests, static artifacts and consumer | Same |
| Shared-only Release | Full build, focused tests, DLL/import library and consumer | Same, including versioned shared library |
| C++ Release | Combined C/C++ build and focused C++/HL C++ tests | Same |
| Reconfigure | 4C option matrix and repeated/toggled configuration checks | Same |
| API driver | Target build and 4D success/failure/process-cleanup cases | Same |
| Admission | Existing 12 synthetic cases plus any required new cases; root and optional language entry checks | Same |
| Secondary generator | Preserve non-Visual-Studio admission through policy cases; no new release baseline implied | Unix Makefiles default build and focused tests |
| Install/package | Default and C++ installs and ZIP packages; Debug PDB installation | Default and C++ installs and TGZ packages; SONAME/RUNPATH |
| Standalone examples | All registered C/C++/HL examples against build and install packages | Same |
| Consumers | Build/install C/HL/C++ static/shared, source `add_subdirectory`, and FetchContent | Same plus wrappers and pkg-config |
| Compatibility | Header/declaration/symbol comparisons, affected layout checks, plugin and file compatibility tests | Same |
| Source package | One clean tracked-source package for the final delivery, with manifest and residual audit | Shared repository-level evidence; no duplicate package required |

Record normalized commands with `<src>`, `<build-root>`, `<install-root>`, and
`<row-options>`. Record exact option sets, test regexes, fixtures, counts,
tool versions, dependency sources, and environment requirements. Inspect test
registration with CTest's structured listing before execution. Compare named
tests and fixture relationships; do not force old Stage 3 totals after 4C.

## Optional Rows and Existing Deferrals

Carry forward Stage 2 passing rows for system/bundled compression, parallel,
subfiling, thread-safe/concurrency, external plugins, coverage, STGZ, and DEB
under the impact rules above. Also carry forward Windows optional evidence and
its platform-specific gaps from Stage 1 and later corrections; Linux evidence
does not close a Windows-only packaging or dependency gap.

The six explicit Stage 2 missing-environment deferrals remain:

| Row | Missing prerequisite |
| --- | --- |
| Parallel tools | mpiFileUtils, libcircle, DTCMP |
| ROS3 | aws-c-s3 development and service inputs |
| HDFS | JDK/JNI, Hadoop/libhdfs, runtime configuration |
| Signed plugins | OpenSSL development files and signing inputs |
| RPM package | `rpmbuild` |
| Real unsupported-compiler rejection | An installed unsupported native Linux compiler |

Do not reopen these decisions just because Stage 4 starts. If an affected path
requires new evidence, explain its impact and the missing prerequisite and
obtain the needed validation or an explicit revision of the approved scope.
The associated feature remains retained. An available unsupported compiler can
provide supplemental real rejection evidence; synthetic cases must not be
reported as such a native compiler run.

## Failure Handling and Stop Conditions

Record each failure's commit, row, phase, diagnostic, root cause, relationship
to the stage, corrective commit, and rerun result. Correct a current regression
before committing it. Distinguish code failure from missing environment and
from incomplete evidence. Temporary validation patches never establish that the
tracked final product passes.

Stop only the affected batch when:

- a fix would change the approved pair, generator/architecture admission,
  public API/ABI, library version, file format, or accepted plugin boundary;
- supported-pair truth values or generated-code ownership cannot be established;
- a required native validator or changed optional prerequisite is unavailable;
- a required contract/artifact/test delta remains unexplained; or
- a repair requires broad modernization or an independent compatibility change.

Continue independent work while the affected issue is resolved. Existing
authorization covers focused repairs and reversible inspection within the
reviewed plan; do not request repeated approval for those routine actions.

## Work Package 4F: Final Audit and Handoff

### Work

Run the final matrix and repeat the tracked/generated/package residual scans.
Close every `FIX_STAGE4` finding with evidence, classify every remaining match,
and retain explicit environment gaps, structural modernization follow-ups, and
independent product defects in their separate disposition categories.
Reconcile current docs, changelog, and all stage continuation summaries with
the actual final implementation and tested package inputs.

Record the final state in `CMakePlatformSupportReductionStage4Results.md` and
`REFACTORING_PROGRESS.md`: implementation anchor, atomic commit list, clean
validator state, exact commands/options/results, named test deltas, contract
comparisons, optional inheritance rationales, missing prerequisites, and
remaining work with a concrete destination. Update the modernization progress
document without advancing its paused implementation anchor or stage status.

### Exit criteria

Stage 4 and the overall platform-reduction direction complete only when:

1. All tracked entry surfaces and generated/delivered products have been audited
   against the two-pair contract; no finding remains `INVESTIGATE`.
2. No reachable project-owned unsupported-only implementation or conflicting
   current support claim remains. Protected residuals have explicit rationales.
3. Both named implementation defects and every other `FIX_STAGE4` item are
   repaired in atomic commits and pass their focused native checks.
4. First/repeat configuration is stable for each tested option set; no utility
   test is registered without its required executable and runtime prerequisites.
5. The final required dual-platform matrix passes at the same implementation
   commit, with no unexplained test, API, ABI, format, artifact, or consumer delta.
6. Every affected optional path has passing new evidence; inherited passes and
   accepted environment deferrals remain identifiable and correctly bounded.
7. Complete baseline/final manifests support all claimed comparisons. Header,
   declaration, symbol, layout, and runtime evidence is not conflated.
8. Source/binary packages contain the expected products and current support
   metadata, with no deleted unsupported paths or local artifacts.
9. All independent follow-ups have an owner/destination and continuation action;
   none is an undisclosed failure of a required Stage 4 gate.
10. Portable results, parent plan, README, changelog, and handoff documents agree
    on completion, remaining validation limits, and the next modernization task.
11. Every repository modification is committed independently of unrelated user
    changes; no uncommitted implementation is used to claim final success.

The agreed completion statement is:

> Project supported-platform reduction is complete: active repository and
> delivery contracts implement Windows/MSVC and Linux/GNU, the required final
> release-baseline gates pass, protected API/ABI/file-format behavior and the
> accepted plugin filename boundary are preserved, and remaining optional
> validation limits and independent follow-ups are explicitly recorded.

This statement does not complete the separate CMake modernization or qualify
every architecture, generator, compiler release, or optional configuration.

### Candidate commit sequence

1. `docs: Add Stage 4 final project audit plan`
2. `docs: Record Stage 4 audit baseline and findings`
3. Focused `cmake:`, `ci:`, or `docs:` commits for classified support-audit gaps
4. `cmake: Stabilize utility test registration across configures`
5. `test: Repair optional API driver build and process cleanup`
6. Focused implementation/evidence commits for package or consumer findings
7. `docs: Record final platform reduction validation and handoff`

Reorder only for demonstrated dependencies. A documentation checkpoint that
records intent does not satisfy an implementation or validation gate.
