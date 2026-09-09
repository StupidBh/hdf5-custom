# Stage 5 Core C17 Internal Modernization Plan

## Status and Purpose

- State: Active; Round 2 complete; next continuation is R3-5A scope freeze.
- Planning date: 2026-09-08.
- Planning source anchor: `05582e903`.
- Execution baseline: `dd7204035`, frozen by Work Package R1-5A.
- Execution results: [CoreC17ModernizationResults.md](CoreC17ModernizationResults.md).
- Direction: modernize project-owned core C internals using the established
  C17 baseline while preserving public headers, API/ABI, file format, and
  observable behavior.
- Supersedes the conversational proposal to modernize C++ test infrastructure.
- Portable handoff: [../../REFACTORING_PROGRESS.md](../../REFACTORING_PROGRESS.md).

This is a multi-round Stage 5 direction with a bounded scope for each round.
The user confirmed the compatibility boundaries and validation priorities
below during plan discussion. R1-5A froze the contracts, candidate ledger,
environment, and clean baseline. R1-5B implemented and characterized the pilot;
the actual diff closed R1-5C and R1-5D as `NOT_APPLICABLE`.
R1-5E completed the mandatory dual-platform default and compression matrices
and all compatibility gates; R1-5F closed the round at implementation anchor
`2a966388e`. The next round must repeat 5A before selecting product edits.
R2-5A froze a resource-ownership batch in `H5PLpath.c` against that accepted
endpoint. R2-5B reproduced and corrected the POSIX directory-entry leak at
`6851af92b`; R2-5C closed its ownership audit. R2-5D implemented the two
frozen Windows follow-ons at `fb09d9fc9` and passed the focused cross-platform
validation gate. R2-5E repeated the complete compatibility matrix and R2-5F
closed Round 2. The next round must begin with R3-5A scope and baseline freeze.
It does not reopen completed Stages
1 through 4 or resume the separately paused CMake modernization. Planning is
not implementation or validation evidence. The first execution deliverable is
an exact candidate ledger, not a repository-wide mechanical rewrite.

## Scope and Protected Contracts

| Surface | Rule |
| --- | --- |
| Core implementation | Project-owned `src/*.c` is the primary scope; select exact functions before each batch. |
| Internal headers | Non-installed private/package headers may change within their existing ownership boundaries. Check actual installation and exports rather than trusting filenames. |
| Public headers | Freeze the complete actual installed header inventory and contents per equivalent configuration, including develop/connector headers, generated headers, and transitive installed inputs. No edits to those headers, even incidental documentation or formatting edits, belong to this internal refactoring. |
| Public consumers | Preserve C99 C-header consumption and C++ consumption of the C API. New internal C17 syntax must not leak into consumer requirements. |
| ABI and exports | Preserve public calling conventions, symbol names, visibility, and public layouts throughout Stage 5. In round 1 also freeze all existing exported internal function signatures, symbols, and associated layouts. New helpers preferentially have file-local static linkage. Later rounds inherit this internal freeze unless a separately reviewed plan amendment explicitly changes it. |
| Behavior | Preserve return values, defined failure behavior, callbacks, object lifetime, reference ownership, cleanup ordering, and error categories/propagation order. Apply the diagnostic comparison rules below rather than requiring byte-identical source locations. |
| Dispatch | Preserve VOL object dispatch, native implementation boundaries, VFL/VFD access, and H5Z filter routing. |
| File format | Preserve encoding, decoding, version selection, datatype compatibility constants, and cross-platform reads. |
| Memory | Preserve H5MM/H5FL ownership, zero-size behavior, debug checks, allocator callbacks, and allocation-failure handling. |
| Tests | Add focused tests beside affected packages using the modern harness; do not add new cases to legacy testhdf5. |
| Tools/utilities/examples | Only necessary caller updates for selected internal changes; independent modernization is outside this Stage 5 direction unless explicitly added by a plan amendment. |
| Build system | Only wiring required by selected sources/tests and validation; preserve options, defaults, supported compiler pairs, and language baselines. |
| HighFive | External header-only product. The existing audited HDF5 dependency list is a mandatory, fixed compatibility floor in every round. Protect the listed interfaces/features without modifying, integrating, installing, or requiring a build of HighFive. |
| Other dependencies | No modernization of zlib, libaec, MPI, KWSYS, or other third-party implementation. Preserve dependency ownership and settings. |
| C++ and removed products | No C++ modernization or language-mode change; no restoration of native C++, HL, Java, or Fortran products. |

Public header compatibility is necessary but not sufficient: unchanged headers
do not prove unchanged ABI, resource semantics, or file behavior. Private
headers included by retained C++ infrastructure must remain compilable there.

## Fixed Compatibility Baseline Across Rounds

The HighFive input is the existing
[HighFiveHDF5ApiDependencyAudit.md](HighFiveHDF5ApiDependencyAudit.md) snapshot:
version 3.3.0, input tracked at `c461ae3e8`, content manifest
`25c7d5e69a69c446b8024941465449b51c9a62c2eb3ce2f981babd9fa6137910`.
Freeze its exact 147-identifier table, not merely the count, together with the
listed headers, types, constants, callback signatures, version-selection macros,
and conditional parallel/filter requirements. Some identifiers are API aliases;
5A must map them to effective declarations and implementation symbols under the
supported API mappings rather than expecting every spelling in a dynamic export.

This inventory must not be shortened or regenerated into a weaker requirement
because a later HighFive copy, round, or feature profile differs. It is a fixed
floor in addition to protection of all public HDF5 headers/API, not permission
to break unlisted APIs. Conditional MPI availability remains conditional on a
parallel build; optional execution priority does not weaken interface protection.
Use HDF5-owned declaration/link checks and existing functional coverage, adding
targeted tests for affected listed behavior. Map every inventory entry to its
evidence or explicit conditional execution limitation; do not equate declarations
or a 147-name count with complete runtime coverage.

Freeze headers from the actual CMake installation, including H5*develop.h,
H5VLconnector*.h and generated configuration. Compare equivalent platform,
compiler, dependencies and feature options; platform-specific differences are
not refactoring deltas. Keep the original Stage 5 freeze across all rounds.
R1-5A establishes one master inventory from all actual installation rules for
the retained product, including conditional headers. Per-configuration installs
verify that inventory; a round's selected configurations cannot narrow it.
If a conditional header cannot currently be generated or installed, retain its
entry, source/template ownership and protection, and record the evidence gap.

For diagnostics, preserve return codes, major/minor error categories, causal
propagation order, and error callback behavior. Source line-number changes are
permitted. File/function-name changes, frame-count changes, or diagnostic-text
changes must be individually identified with rationale and reviewed before the
batch closes; they are not automatically accepted as formatting noise. Keep
error construction at its existing layer where possible. Preserve diagnostic
content interpreted by tools/tests; baseline updates alone do not prove safety.

## Selection Policy and Round Boundaries

Stage 5 progresses through successive rounds, each with a frozen function-level
candidate ledger and its own 5A through 5F checkpoints. Use identifiers such as
R1-5A and R2-5A. Round 1 starts with one pilot package; select follow-on work by
actual evidence, not an arbitrary package quota. Concrete files/functions,
callers, transformations, checks and exclusions are recorded before source edits.
No round authorizes all functions in a package merely by naming that package.

For each later round, retain both the original Stage 5 compatibility baseline
and the preceding accepted implementation as comparison anchors. Check cumulative
compatibility against the original, and behavior changes against the preceding
round. Refresh environment evidence without resetting protected interfaces or
normalizing accumulated regressions. Completed rounds permit further planning
within these constraints; new architecture or compatibility scope needs an
explicit plan amendment. Round completion is not overall Stage 5 completion;
the stage remains ongoing until an explicit stage-level closeout records the
delivered rounds and remaining backlog.

When compilers, dependencies, generator settings or other relevant environment
inputs change between rounds, rebuild the original Stage 5 source and preceding
accepted implementation in the new environment alongside the candidate. Compare
like configurations to distinguish environment deltas from implementation deltas.
Retain the original evidence and record this bridge; do not replace the fixed
dependency inventory or bless cumulative header/ABI drift with a new baseline.
If the comparison cannot be established, defer dependent conclusions.

Prefer local, deterministic functions with existing tests, clear ownership,
no disk serialization, no locking, and no critical I/O hot path. Audit local
string/buffer helpers and non-hot package helpers first. H5MM and H5VM are
candidate inspection surfaces, not preapproved rewrite targets: their shared
reach or performance sensitivity may disqualify them from the pilot.

Each candidate record contains:

- file, function/macro, package, callers, header visibility, actual export;
- concrete maintenance problem and expected benefit;
- ownership, allocation/error behavior, debug/release differences;
- affected serial, parallel, thread, filter, driver, and consumer paths,
  including a mapping to the frozen HighFive dependency inventory;
- baseline reproducer/tests, proposed transformation, performance sensitivity;
- disposition: SELECTED, KEEP, DEFER, DEFECT, or INVESTIGATE;
- implementation commit, exact checks, results, and remaining limitations.

No INVESTIGATE item enters an implementation batch. Candidates that need public
contract changes or unavailable required validation remain deferred. Discoveries
do not silently expand the current round or weaken any inherited constraint.

## Allowed Transformations and Exclusions

Allowed after caller review:

1. Narrow local variable scope and improve const correctness without changing
   pointee ownership, qualifier contracts, or externally visible signatures.
2. Use explicit initialization and compile-time invariants where they express
   established facts. Do not assume zeroed bytes equal every semantic zero or
   change padding-sensitive operations.
3. Replace suitable pure macros with typed local functions or static inline
   helpers after checking evaluation count/order, lvalue and constant-expression
   uses, debug side effects, linkage, and every caller.
4. Extract small helpers from functions with mixed responsibilities while
   preserving error-stack behavior and function-entry conventions.
5. Simplify resource bookkeeping using explicit ownership and the established
   done-label cleanup pattern. C has no automatic C++-style destruction.
6. Clarify size/index conversions only after range and signedness analysis.

Use the C17 baseline rather than requiring a quota of new syntax. Preserve HD
portability wrappers and existing error conventions. Verify selected language
features on both retained compilers; a C17 mode alone does not justify removing
feature probes or fallback implementations.

Excluded from the initial rounds; later rounds do not automatically lift these
exclusions:

- wholesale replacement of FUNC_ENTER/FUNC_LEAVE, HGOTO_ERROR, or goto cleanup;
- lock/atomic redesign, memory pool replacement, reference-count redesign;
- datatype conversion algorithms, metadata layouts, disk encoders/decoders;
- chunk cache, collective I/O, filter-pipeline algorithm redesign;
- bulk restrict/alignment/type-punning changes, VLA introduction;
- global formatting, naming migrations, macro deletion by keyword search;
- direct edits to generated sources such as H5overflow.h without their canonical
  generator/input ownership; such generator work is deferred from the pilot.

For a confirmed defect, freeze a reproducer and separate the behavior correction
from refactoring. Record the changed failure contract and changelog entry. An
unrelated defect is a follow-up; a defect blocking the selected transformation
requires an explicit plan disposition before proceeding. Undefined behavior is
not a behavior to preserve, but fixing it is still an identifiable change.
Round 1 defaults to behavior-preserving changes. A proposed prerequisite fix
must name the affected contract and its repro/validation before implementation.
Changes to public error semantics, behavior required by the fixed HighFive
inventory, file format, or excluded synchronization/architecture require an
explicit scope amendment; they are not incidental cleanup. Unrelated fixes
remain outside the round. Later rounds inherit this rule.

## Environment and Resource Rules

- Maximum build parallelism: 6. CTest also uses at most 6 jobs. Windows and WSL
  on the same physical host share an aggregate six-job budget; run their major
  workloads sequentially. Account for MPI ranks/nested builds and reduce CTest
  concurrency for process-heavy tests rather than launching six MPI jobs each
  with six ranks.
  In 5A record scheduling weights/serial groups for MPI ranks, long-lived test
  servers and nested dependency builds. Account for helpers that outlive their
  launching command; do not apply -j 6 independently at every nesting level.
- Windows: x64, MSVC, Visual Studio 18 2026, command-scoped CL=/utf-8. Discover
  and prefer the supplied `3rdparty/zlib`, `3rdparty/libaec`, and
  `3rdparty/msmpi` inputs. Record versions, architecture, library forms, and
  runtime availability; do not assume headers imply a working MPI runtime.
  Compression dependency linkage follows the actual supplied Windows libraries;
  identify import libraries versus static archives rather than inferring their
  form from a .lib suffix. Do not require absent Windows dependency forms or
  replace the supplied inputs merely to create a symmetric matrix.
- Linux: qualify WSL Linux x86_64, GCC/G++, CMake >= 4.0, Ninja, and GNU Make.
  Acquire needed Linux dependencies through WSL using its package manager or
  pinned source builds in an isolated prefix. Windows binaries are not Linux
  prerequisites. Record source/version and actual discovery results.
  Provide both shared and static zlib/libaec libraries through WSL acquisition
  or supplemental builds. Static inputs linked into shared HDF5 must be suitable
  for that linkage, including position-independent code where required.
- Outbound downloads use the local proxy. If WSL cannot reach the Windows
  loopback proxy, establish the reachable host endpoint first. Do not proxy
  localhost or LAN traffic; do not change global proxy configuration.
- Use clean Linux-filesystem source snapshots to avoid mounted-checkout line
  endings affecting fixtures. Keep dependency builds, installs, logs, and
  source snapshots out of the tracked tree. Do not replace user dependency copies.
- C17 remains the exact C release baseline. Default builds remain C-only;
  optional C++ infrastructure and third-party language settings stay isolated.
- HDF_TEST_EXPRESS=3 is the full default-suite level. Use 0 for focused affected
  boundary/state tests where that harness honors the variable; report the
  actual level and limitations rather than calling level 3 exhaustive.

## Work Packages

### Validation Cadence and Evidence Reuse

Each atomic implementation commit requires its meaningful focused checks before
closure. Each round's final implementation requires the complete mandatory
default and system-compression suites plus the applicable matrix below; focused
commit checks do not replace round acceptance.

When the next round starts at the preceding accepted implementation with exactly
the same relevant sources, configuration, dependency inputs, tools and environment,
5A may cite that endpoint's validation as its starting baseline. Record the exact
tested anchor, inputs and result, and verify their identity. Do not repeat an
identical run solely to change its round label. Changes to source, configuration,
dependencies or environment require impact-based revalidation and the environment
bridge described above where applicable. A new final implementation cannot inherit
the preceding endpoint's full-suite pass as its own acceptance result.

Work packages describe responsibilities rather than a quota of changes. 5A records
which implementation packages apply to the selected round. Unneeded 5C/5D work
may close as NOT_APPLICABLE with evidence and rationale; no new refactoring is
invented to satisfy a heading. Required compatibility and full-suite gates remain.

### 5A: Inventory, Environment, and Baseline

1. Freeze a clean tracked implementation baseline and qualify both validators.
2. Probe dependencies; obtain Linux prerequisites through WSL and classify
   Windows local prerequisites. Register unavailable affected features early.
3. Create CoreC17ModernizationResults.md with the candidate ledger and precise
   pilot/follow-on selections for this round, both comparison anchors, and the
   frozen HighFive interface-to-evidence mapping.
4. Capture default and mandatory system-compression full suites, selected
   package tests, complete installed header manifests,
   generated settings, case-sensitive exports, public layout probes, target and
   install inventories, C/C++ C-API consumers, and representative file fixtures.
   For an identical preceding-round endpoint, reuse qualified evidence under the
   validation-cadence rules instead of duplicating baseline runs.
5. Define any performance experiment before implementation: fixed input,
   identical toolchain/configuration, repeated interleaved runs, noise estimate,
   and acceptable tolerance. Non-hot edits need no invented benchmark.
6. Select actual memory-checking tools, failure hooks, test patterns and express
   levels using repository support and environment probes. The current sanitizer
   module accepts MSVC AddressSanitizer on its configured path; do not assume the
   same switch enables GCC instrumentation. Qualify an existing Linux-compatible
   checker or record a narrowly scoped alternative. A new instrumentation
   framework is not implicit scope. Record the behavior/coverage limitations.
7. Specify the exact supported API-version/alias mappings and C++ consumer modes
   to exercise, including mappings needed by the fixed dependency inventory and
   retained C++11 C-header consumption. Identify their effective declarations,
   linked symbols and feature guards. Test appropriate separate configurations
   rather than assuming one default alias mapping covers all protected names.
   Record MSVC's actual mode limitations; these are C-API consumer checks and
   do not restore an HDF5 C++ product or change its internal C++20 baseline.

5A produces three reviewable records before source changes:

| Record | Evidence to establish |
| --- | --- |
| Frozen contracts | Master inventory from all retained installation rules, with conditional entries and per-configuration evidence/gaps; exports/signatures/associated layouts; exact fixed HighFive identifiers, API aliases, types and conditional feature mappings; original and preceding-round anchors. |
| Round implementation scope | Selected package/functions and callers, benefit, direct/indirect feature impact, proposed transformations, exclusions and defect dispositions. |
| Validation specification | Exact configurations and dependency linkage, test registrations/disabled/skipped baselines, functional and failure-path selections, tools/hooks, performance criteria when needed, and process/resource scheduling. |

5A may select functions within the declared boundaries, inspect Windows dependency
forms, acquire missing Linux forms during authorized execution, map aliases,
choose existing tools and tests, assess indirect callers, and define measurable
coverage/performance checks. These choices require evidence, not advance selection
of every function/tool or a broader rewrite. Additional rounds repeat this process
for their selected scope while retaining the fixed contracts.

5A cannot reduce the HighFive inventory, edit the installed header contract,
relax ABI restrictions, waive mandatory compression/full-suite checks, add
HighFive or third-party modernization, accept a new regression, or lift excluded
architectural work. Such changes require an explicit plan amendment; missing
evidence leads to an unresolved entry or deferred candidate, not wider authority.

Gate: exact selection and checks recorded; no unexplained relevant baseline
failure; required prerequisites available or affected candidates deferred.

### 5B: Characterization and Pilot

1. Add only missing behavioral coverage for the selected transformations:
   empty/boundary inputs, meaningful failures, ownership, and repeat operations.
2. Test defined behavior against the frozen implementation. Do not encode a
   known bug as a permanent compatibility expectation.
3. Apply one low-risk transformation family within the pilot package.
4. Format touched C files, inspect formatting-only churn, run focused tests on
   both validators, and compare affected contracts and diagnostics.

Gate: useful maintenance improvement demonstrated, no semantic delta, no new
warnings attributable to the batch, and no unexplained performance regression.

### 5C: Resource and Function Structure

Apply when selected changes affect resource lifetime or cleanup structure. If
5A and the actual diff establish that they do not, record NOT_APPLICABLE (no
resource change needed; applicability checked). Do not introduce cleanup changes
merely to perform this package. Reassess if later edits change that conclusion.

1. Map allocations, borrowed pointers, ownership transfers, identifiers, and
   cleanup requirements for the selected pilot functions.
2. Extract helpers and simplify cleanup without changing H5MM/H5FL behavior,
   error categories, callback order, or resource-release sequence.
3. Cover partial initialization and allocation/error recovery. Use existing
   failure hooks where available; any new hook must be private/test-only and
   must not add public exports or change normal allocation behavior.
4. Exercise debug memory checks and an available supported memory checker.

Gate: all identified reachable cleanup paths tested or explicitly justified;
no leak, double release, use-after-free, or ownership ambiguity introduced.

### 5D: Expansion Within the Current Round

Expansion is optional. If the pilot is the complete frozen round scope, record
NOT_APPLICABLE with that scope reference and continue to final acceptance.

1. Reassess pilot findings before touching the round's selected follow-on functions.
2. Apply only demonstrated transformation families; record exact caller impact.
3. Shared private-header changes require all dependent targets to build, including
   retained C++ users where present. Avoid turning local helpers into global APIs.
4. Validate affected feature configurations before closing each batch.

Gate: all SELECTED entries implemented and checked, or scope revisions recorded
with reasons. Do not hide required failures by reclassifying them as deferred.

### 5E: Final Product and Compatibility Matrix

System compression is a mandatory business gate, independent of whether a
round directly edits filter code. Both retained platforms must run complete
Release builds and full enabled suites at HDF_TEST_EXPRESS=3 in two configurations:

- SC-A: shared-only core, map and tools enabled, system zlib and libaec/SZIP
  enabled, MPI and thread safety disabled.
- SC-B: static-only core with the same map/tools/system-compression settings,
  MPI and thread safety disabled.

Expand these two HDF5 configurations by compression dependency linkage:

| Platform | HDF5 linkage | zlib and libaec/SZIP linkage | Full-suite obligation |
| --- | --- | --- | --- |
| Windows | SC-A shared and SC-B static | Actual forms supplied in 3rdparty, selected and recorded by 5A for each configuration | Complete suite in both HDF5 configurations; no invented requirement for unavailable dependency variants. |
| Linux | SC-A shared | Shared dependencies, then static dependencies | Two complete suites with proven distinct dependency selection. |
| Linux | SC-B static | Shared dependencies, then static dependencies | Two complete suites with proven distinct dependency selection. |

The Linux matrix is four HDF5/dependency combinations. Test both compression
libraries shared together and static together; mixed zlib/libaec linkage is not
an additional required permutation. Static HDF5 with shared compression is a
valid distinct row, not a fully static executable. Record actual resolved library
paths and link/runtime evidence for each row so discovery cannot silently pick
the same form twice. Source builds supplying a Linux prefix remain external
dependency provisioning, not a bundled HDF5 dependency build.

These are Stage 5 serial acceptance configurations, not renamings of historical
Stage 4 Profiles A/B. 5A freezes the exact current CMake options. Both use
HDF5_ENABLE_ZLIB_SUPPORT=ON, HDF5_ENABLE_SZIP_SUPPORT=ON,
HDF5_ENABLE_SZIP_ENCODING=ON, ZLIB_USE_EXTERNAL=OFF, SZIP_USE_EXTERNAL=OFF and
HDF5_ALLOW_EXTERNAL_SUPPORT=NO. Here system means externally provisioned Linux
or Windows libraries, including the Windows 3rdparty prefixes; no bundled
FetchContent compression build may substitute. Prove dependency paths, filter
availability and actual DEFLATE/SZIP write/read capability, with SZIP encoding
enabled for business acceptance. Install, package and static/shared consumers
must resolve the intended dependencies. Missing dependencies or new unexplained
failures leave the mandatory gate incomplete; focused filter tests alone do
not replace the full suites.

For every full-suite row, capture and compare exact registered-test names,
commands/fixture relationships where relevant, disabled tests, runtime skips,
and executed outcomes with the equivalent baseline. Classify every removal,
disablement, skip or registration change. Do not obtain a pass by narrowing a
selection, disabling a failure, dropping a test or misconfiguring a feature.
Confirm the expected compression cases registered and actually exercised filters;
a zero exit code or aggregate count alone is insufficient. Existing disabled
cases may retain their explained baseline disposition. Meaningful new tests or
equivalent test reorganizations must retain documented coverage. Apply this rule
to both baseline capture and final default/compression suites in each round.

The original Profile A (shared map/SZIP/threadsafe/tools/zlib/parallel) and
Profile B (static map/SZIP/tools/zlib/parallel, thread safety off) are secondary
extended validation in Stage 5. Attempt them with available prerequisites;
run focused affected tests first and broaden toward full suites where practical.
Record Profile A's required HDF5_ALLOW_UNSUPPORTED=ON explicitly and do not
change the feature-combination policy. Also attempt separate legal thread-safe
and concurrency checks as applicable. This revised priority does not rewrite
Stage 4's historical full-profile acceptance records.

Incomplete MPI/thread validation can remain an explicit secondary coverage gap
when there is a recorded impact analysis and no evidence of a new regression.
Apply three distinct dispositions:

- Direct or indirect impact: obtain corresponding validation evidence; impact
  alone is not a failure. If adequate evidence cannot be obtained, defer the
  candidate or revert its implementation before closing the round.
- Newly observed failure: investigate against the baseline; a new regression
  requires a scoped fix or rollback, and an unexplained result stays unresolved.
- Missing secondary environment with relevant impact excluded by evidence:
  record a coverage gap without blocking unrelated demonstrated-safe work.

Secondary priority is not permission to break the frozen parallel C interfaces.
Missing system-compression validation is never a secondary gap.
Determine impact from callers, ownership/state changes and feature reachability,
not filenames or the absence of explicit MPI/thread calls. Shared allocation,
buffer and error helpers can affect parallel execution indirectly. If a relevant
impact cannot be excluded, obtain adequate focused validation or defer/revert
that change; an ordinary missing secondary environment alone does not block
unrelated demonstrated-safe work.

The four Linux compression linkage rows and the Windows supplied-dependency
rows require full suites in Release. Debug is a separate both-platform complete
build with focused debug/memory/package checks, not an automatic cross-product
with every compression linkage row. 5A specifies the Debug linkage/configuration
and adds combinations only when the selected implementation makes them relevant.
Release static/shared build, install and consumer evidence from qualifying SC-A
and SC-B runs satisfies the corresponding matrix obligations; an identical row
need not run again under a different label.

| Row | Required evidence |
| --- | --- |
| Windows/MSVC and Linux/GCC default Release | Fresh complete builds and full enabled CTest suites at level 3; baseline exceptions freshly compared. |
| Debug on both pairs | Separate complete build and focused package/debug/memory checks; configuration/linkage chosen in 5A by impact, without automatic compression cross-product. |
| Static-only/shared-only Release on both pairs | Complete builds, focused package checks, installs and requested-linkage consumers; qualifying SC-A/SC-B evidence may satisfy these same obligations. |
| Focused affected-package depth | Boundary/failure tests and level 0 where supported, with exact selections and outcomes. |
| System compression SC-A and SC-B | Mandatory Windows supplied-dependency rows and all four Linux linkage rows, complete builds/full Release suites with inventory reconciliation, plus actual filter write/read, install/package and linkage checks. |
| MPI Profiles A/B | Secondary extended validation: attempt focused tests and full suites where practical, record exact execution/limitations; no unexplained new regression accepted. |
| Thread safety/concurrency | Secondary legal configurations and focused tests on both pairs where applicable; direct or indirect sensitive changes require adequate evidence or deferral of the change. |
| Other optional VFD/VOL/filter paths | Reachability-based impact record; affected supported paths require tests. Missing environment is not a product pass. |
| Linux Unix Makefiles | Focused configure/build/test of core and affected targets. |
| Installed C API consumers | C99 and C17 consumers; specified C++ modes including C++11 consumption of C headers, plus protected API alias/version mappings selected in 5A; no HighFive prerequisite. MSVC mode limitations recorded accurately. |
| Integration and packages | Build/install find_package, add_subdirectory, local FetchContent; Windows ZIP and Linux TGZ artifact comparisons. |
| API/ABI | Entire installed header freeze, round-1 exported signatures/symbols/associated layouts, and public ABI compared to both original and preceding-round anchors; explicit diagnostic-delta classification. |
| Frozen HighFive dependency inventory | Exact fixed 147-identifier table plus types/constants/callbacks/feature mappings protected; per-entry declaration/link evidence and affected functional coverage using HDF5-owned checks. |
| Format | Existing compatibility fixtures, baseline-to-final/final-to-baseline reads, Windows/Linux cross-reads and semantic data checks. |
| Performance | Predeclared experiments for touched hot paths, otherwise a recorded non-hot impact rationale. |

Preserve the fixed public C interfaces/features identified by the existing
HighFive audit throughout every round. Do not build or alter
HighFive to complete this matrix. Binary identity and whole-file byte identity
are not general acceptance claims; use the specific header, ABI, format, and
semantic comparisons above.

Existing Windows/MS-MPI exceptions must reproduce at the frozen Stage 5 baseline
and be compared on the affected path. Historical exceptions cannot waive a new
failure. Mandatory default/system-compression and required affected rows cannot
be omitted for missing prerequisites: obtain the environment or keep the
dependent batch incomplete. Secondary MPI/thread rows use the explicit
coverage-gap rules above, without weakening their compatibility contract.

### 5F: Round Closeout and Next-Round Handoff

Record implementation anchors, exact commands/configurations, express levels,
test totals/disabled cases, artifact comparisons, dependency versions,
performance results where relevant, and every deferred candidate. Update this
plan and REFACTORING_PROGRESS.md after each coherent batch. Close only the
current round's frozen scope and record the next candidate backlog. Restate
the unchanged original header/API freeze, fixed HighFive dependency inventory,
ABI restrictions, diagnostic policy and mandatory compression gates at each
handoff. Stage 5 remains a multi-round direction; an explicit overall closeout
must distinguish delivered work, remaining candidates and validation gaps.

## Change and Review Discipline

Prefer atomic, independently revertible commits for implementation changes.
Each commit should cover one concrete transformation or demonstrated fix,
together with its focused tests and required documentation, and leave the
affected configurations buildable with the required checks passing. Separate
unrelated refactoring, defect fixes, formatting, and dependency changes. Do not
split tightly coupled source/caller/test edits into intermediate broken commits
merely to make commits smaller.

Record dependencies between commits. When later commits rely on an earlier
change, document the reverse-order rollback sequence or the smallest coherent
rollback group; do not claim arbitrary independent rollback for dependent work.
Use normal revert commits for rollback rather than rewriting shared history.
These rules govern future execution; discussing or editing this plan does not
start implementation or authorize an implementation commit.

Preserve user changes. Run clang-format on
touched C files and git diff --check; isolate unrelated formatting rather than
burying behavior in it. User-visible changes and reported fixes require
release_docs/CHANGELOG.md. Pure validation needs no empty commit.

Stop the dependent batch for an unexpected public contract/format delta, new
unexplained failure, unavailable required validation, or a broader architectural
change. Resolve unrelated candidates independently where safe. A plan and a
passing build alone never establish completion.

## Current Continuation

Round 1 is complete from original baseline `dd7204035` through implementation
anchor `2a966388e`. The const-correct file-local reverse path scans used by
`H5_dirname` and `H5_basename` passed focused, Debug, Valgrind, Unix Makefiles,
parallel subfiling, complete default, and mandatory system-compression checks
on both validators. Installed headers, API/ABI, exports, layouts, packages,
consumers, the fixed HighFive inventory, and cross-platform format behavior
match the frozen contracts. Exact evidence is in
[CoreC17ModernizationResults.md](CoreC17ModernizationResults.md).

R2-5A is complete. It retains `dd7204035` as the original Stage 5 contract
anchor and `2a966388e` as the preceding accepted implementation. Relevant
toolchains and dependency inputs match the Round 1 endpoint, and no product or
test source changed between that endpoint and the R2 planning source anchor
`c3f97252e`, so its qualifying endpoint evidence is the R2 starting baseline.

R2-5B and R2-5C are complete at pilot implementation anchor `6851af92b`. The
same focused test that exposed two definitely lost POSIX directory-path buffers
passes without a Valgrind error after the correction, and the complete pilot
ownership map is recorded. R2-5D is complete at implementation anchor
`fb09d9fc9`: the two symmetric Windows directory paths and untransferred
environment-expansion copies are released, with focused Release, Debug, Unix
Makefiles, thread-safe, parallel, and memory gates passing. R2-5E repeated all
eight full Release rows, installs, packages, linkage, consumers, protected
headers/exports/layouts, the fixed HighFive inventory, and cross-platform format
checks without an unexplained delta. R2-5F closes the round with R2-D1, R2-D2,
R2-I1, R2-D3, and the earlier backlog still deferred. The next execution step
is R3-5A: freeze a new bounded candidate ledger and validation specification
before any further product edit. Exact evidence is recorded in
[CoreC17ModernizationResults.md](CoreC17ModernizationResults.md).
