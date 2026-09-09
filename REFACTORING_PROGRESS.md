# Refactoring Progress

Last updated: 2026-09-09

## Purpose

This file is the portable handoff for the active refactoring direction. It
records what is already complete, what remains, where work should resume, and
which validation is still missing so the refactoring can continue on another
machine without reconstructing its state from chat history or local build
artifacts.

The detailed implementation plan for the completed compatibility-changing direction is
[`docs/refactoring/CMakePlatformSupportReduction.md`](docs/refactoring/CMakePlatformSupportReduction.md).
The self-contained execution plan for the completed Linux validation stage is
[`docs/refactoring/CMakePlatformSupportReductionStage2.md`](docs/refactoring/CMakePlatformSupportReductionStage2.md).
Its portable execution record is
[`docs/refactoring/CMakePlatformSupportReductionStage2Results.md`](docs/refactoring/CMakePlatformSupportReductionStage2Results.md).
The completed self-contained Stage 3 source/header reduction plan is
[`docs/refactoring/CMakePlatformSupportReductionStage3.md`](docs/refactoring/CMakePlatformSupportReductionStage3.md).
Its portable execution record is
[`docs/refactoring/CMakePlatformSupportReductionStage3Results.md`](docs/refactoring/CMakePlatformSupportReductionStage3Results.md).
The completed Stage 4 final project-audit plan is
[`docs/refactoring/CMakePlatformSupportReductionStage4.md`](docs/refactoring/CMakePlatformSupportReductionStage4.md).
Its execution record is
[`docs/refactoring/CMakePlatformSupportReductionStage4Results.md`](docs/refactoring/CMakePlatformSupportReductionStage4Results.md).
The approved Phase 2 language-build direction is defined in
[`docs/refactoring/C17Cpp20BuildBaseline.md`](docs/refactoring/C17Cpp20BuildBaseline.md).
It raises project-owned build modes to C17/C++20 while preserving the current
public-header consumer baselines. Its execution evidence is recorded in
[`docs/refactoring/C17Cpp20BuildBaselineResults.md`](docs/refactoring/C17Cpp20BuildBaselineResults.md).
The most recently completed direction is roadmap Stage 4, defined in
[`docs/refactoring/NativeCppHlRemoval.md`](docs/refactoring/NativeCppHlRemoval.md).
It removes the native `c++/` tree, the complete `hl/` tree, and all related
product contracts while preserving the retained core C product and the two
required business profiles. The user approved implementation on 2026-09-06,
and Work Package 4A has frozen the pre-removal contract at `72e36a522`, with
pre-removal stabilization through `3118d8c2c`. Work Package 4B removed the
complete HL product at `c62d134e5`, and Work Package 4C removed the native C++
product at `3dc988a48`. Work Package 4D normalized package and consumer
contracts at `81dff5168`; Work Packages 4E and 4F completed the full product
matrix and residual audit at evidence anchor `f120c1c95`. Its
execution record is
[`docs/refactoring/NativeCppHlRemovalResults.md`](docs/refactoring/NativeCppHlRemovalResults.md).
The HighFive dependency input is recorded in
[`docs/refactoring/HighFiveHDF5ApiDependencyAudit.md`](docs/refactoring/HighFiveHDF5ApiDependencyAudit.md);
the workspace `highfive/` header copy was tracked separately at `c461ae3e8` but
is not wired into the HDF5 build, install, export, or native binary package.
The completed supported-platform direction intentionally changed the
compatibility contract by first reducing the CMake matrix and then removing
source-level support outside Windows/MSVC and Linux/GCC. The underlying target
architecture and the paused behavior-preserving modernization state remain recorded in
[`docs/CMakeModernization.md`](docs/CMakeModernization.md) and
[`docs/CMakeModernizationProgress.md`](docs/CMakeModernizationProgress.md).

## Refactoring Roadmap

The active direction is [Stage 5 core C17 internal modernization](docs/refactoring/CoreC17Modernization.md).
Detailed planning was requested on 2026-09-08 and execution began on
2026-09-09. R1-5A and R1-5B are complete, and R1-5C/R1-5D are not applicable
to the resource-neutral pilot. Its portable evidence is in
[`docs/refactoring/CoreC17ModernizationResults.md`](docs/refactoring/CoreC17ModernizationResults.md).
Build/CTest parallelism is capped at six jobs per physical host.
Windows uses the supplied `3rdparty` dependencies; Linux prerequisites are
obtained through WSL. Stage 5 is planned as successive bounded rounds, each
preserving the original complete installed-header freeze and the fixed HighFive
audit dependency inventory. System zlib/SZIP shared and static configurations
require full suites on both platforms with registered/disabled/skipped-test
reconciliation. Windows compression linkage follows supplied `3rdparty` forms;
Linux tests shared/static HDF5 against both shared and static compression inputs
(four rows), provisioned through WSL. R1-5A selected only the duplicated reverse
path scans in `H5_dirname` and `H5_basename`, and fixed the exact tools, tests,
and scheduling without relaxing the protected contracts. MPI/thread extensions
are secondary
with explicit coverage gaps and no accepted new regression. HighFive remains
external. R1-5E is the current validation continuation.

The repository-level roadmap uses the following stage names. These stages are
separate from the internal Stage 1 through Stage 4 work packages of the
completed supported-platform reduction plan.

| Roadmap stage | Goal | State | Completion |
| --- | --- | --- | --- |
| 1 | Raise project organization and build entry points to CMake 4.0 and mechanically reject target-system/compiler pairs other than Windows/MSVC and Linux/GNU. | Complete | Yes |
| 2 | Remove project-owned source and header implementation support for target systems and compilers outside the retained pairs while preserving protected public and file-format compatibility constants. | Complete | Yes |
| 3 | Raise project-owned build modes to strict C17/C++20 and repair only blockers caused by the language-mode change, without general source modernization. | Complete | Yes |
| 4 | Delete native `c++/`, complete `hl/`, and their build, test, install, export, package, wrapper, tool, example, and documentation contracts while preserving the core C product and required acceptance profiles. | Complete; Work Packages 4A through 4F passed | Yes |
| 5 | Modernize core C internals in successive bounded C17 rounds, preserving all installed headers, API/ABI, the fixed HighFive C dependency inventory, and file/behavior contracts. | Active; R1-5A/R1-5B complete, R1-5C/R1-5D not applicable | No |
| 6 | No current goal. Previous C17 internal C modernization direction is cancelled from the active roadmap. | Future plan TBD | No |
| 7 | No current goal. | Future plan TBD | No |

Roadmap Stage 4 is an intentional compatibility break only for the removed
native C++ and HL products. It did not change the core C API, ABI, installed-
header declarations, retained tools, or file format, and it did not integrate
HighFive into HDF5 products. Stage 5 now has a proposed bounded C17 plan;
Stages 6 and 7 have no approved execution scope. The C++ modernization proposal
is superseded by the core C direction.

## Last Completed Direction

- Direction: Roadmap Stage 4 native C++ and HL product removal
- Status: Complete; Work Packages 4A through 4F passed
- Detailed plan: `docs/refactoring/NativeCppHlRemoval.md`
- Execution results: `docs/refactoring/NativeCppHlRemovalResults.md`
- HighFive audit: `docs/refactoring/HighFiveHDF5ApiDependencyAudit.md`
- HighFive audit snapshot: workspace `highfive/` version 3.3.0 at content
  manifest `25c7d5e69a69c446b8024941465449b51c9a62c2eb3ce2f981babd9fa6137910`;
  compared with upstream commit
  `959ec30c5cee48ff4dbb458b9f233beded708a36`
- HighFive integration state: workspace headers were untracked at audit time
  and tracked separately at `c461ae3e8`; they are not wired into HDF5 CMake,
  installed, exported, or included in native binary packages
- Planning source anchor: `55a930c0d`
- Plan approval: 2026-09-06
- Execution baseline: `72e36a522`
- Pre-removal stabilization anchor: `3118d8c2c`
- Implementation anchor: `81dff5168` for the completed product contract
- Product-matrix source anchor: `55bad410b`
- Post-matrix audit-input anchor: `c461ae3e8`
- Validation and closeout evidence anchor: `f120c1c95`
- Retained contract: freeze core C installed headers, symbols, package paths,
  retained tools, and file-format behavior at the pre-removal execution baseline
- Removed contract: native C++, HL C/C++, `h5c++`, and HL-owned `h5watch`
- Acceptance Profile A: shared-only map, SZIP, thread safety, tools, zlib, and
  parallel; record the currently required `HDF5_ALLOW_UNSUPPORTED=ON`
- Acceptance Profile B: static-only map, SZIP, tools, zlib, and parallel, with
  thread safety disabled
- Stage 4 build and CTest parallelism: maximum four active jobs in total per
  physical host
- Separate target-scoped CMake modernization: paused at its recorded
  continuation point
- Phase 2 planning baseline: `2e6ed711f`
- Phase 2 plan anchor: `ef0ff7390`
- Phase 2 scope clarification anchor: `2e0772f4c`
- Phase 2 execution baseline: `a1adbc32b`
- Phase 2 implementation anchor: `c38e58ed8`
- Phase 2 execution limit: at most four active build and CTest jobs in total per
  physical host
- Original support-contract anchor: `912fb436b`
- Admission-policy correction anchor: `614dd74c0`
- CMake implementation anchor: `b317dedc9`
- Stage 1 source compilation repair anchor: `a68b4cae4e`
- Stage 2 C11 literal repair anchor: `6ee2f392e`
- Coverage documentation correction anchor: `d39cd5fa0`
- Stage 3 plan anchor: `31cf74435`
- Stage 3 implementation anchor: `74288cbaa`
- Current implementation anchor: `c38e58ed8`
- Last preceding documentation anchor: `8adcde9af`
- Stage 1 CMake implementation commits: 19
- Stage 3 source/header implementation commits: 14
- Supported-platform Stage 4 Work Package 4B implementation commits: 6
- Supported-platform Stage 4 Work Package 4C implementation commits: 1
- Supported-platform Stage 4 Work Package 4D implementation commits: 1
- Phase 2 implementation commits: 5
- Stage 1 completion state: complete
- Stage 2 execution scope: complete; core gate, bundled compression, system
  compression, and coverage passed; six non-required optional rows were
  explicitly deferred by the user
- Stage 3 execution state: Completed; all work packages and the final
  dual-platform gate passed
- Stage 3 completion review: accepted on 2026-09-05 with the confirmed Linux
  plugin filename restriction and corrected header evidence
- Supported-platform Stage 4 audit recommendations and inherited boundaries:
  accepted on 2026-09-05
- Supported-platform Stage 4 detailed plan and review clarifications: approved
  on 2026-09-05
- Supported-platform Stage 4 execution used a temporary maximum build/CTest parallelism of 4 per
  physical host, shared by Windows and WSL on that host; this is not a
  repository default, product compatibility value, or permanent reference
- Supported-platform Stage 4 execution state: complete; Work Packages 4A
  through 4F passed on 2026-09-05 at product implementation anchor
  `f6ff66fed`

The approved endpoint accepts two target-system/compiler pairs: Windows with
compiler ID `MSVC`, and Linux with compiler ID `GNU`. Generator, architecture,
and exact compiler release are validation dimensions rather than central
firewall inputs. The release-qualified baselines remain Windows x64 with MSVC
and a Visual Studio generator, plus Linux x86_64 with GCC/G++ and Ninja, with a
focused Unix Makefiles check. The CMake firewall and unsupported CMake-path
reduction have landed, the over-constrained admission policy is corrected, and
the required Windows/MSVC Stage 1 validation gate has passed. The Stage 2
Linux/GCC core gate and the bundled- and system-compression rows pass, and all
optional rows supported by the supplied validator environment have run. Stage
2 is complete after the user explicitly deferred the six unavailable optional
configurations as non-required. Stage 3 source/header reduction is complete at
`74288cbaa`; protected API, ABI, and file-format behavior remain intact. The
user confirmed the Linux plugin filename restriction to `lib*.so` during the
2026-09-05 review. Corrected header evidence records expected text changes and
preserved effective declarations, rather than byte-identical files. The Stage
4 final audit is complete. Work Package 4A qualified both validators, froze
complete fresh default/C++ baselines, and reproduced the two required defects.
Work Package 4B audited all repository support surfaces and residuals, repaired
six focused implementation gaps through `ebdb99969`, and left no unresolved
classification. Work Package 4C stabilized utility-dependent registration and
added a working mirror-server fixture at `8d7aa0432`. Work Package 4D repaired
the optional API driver's generated-header ownership and cleanup identifier at
`f6ff66fed`, then passed its controlled process and API integration checks on
both retained pairs. Work Package 4E passed the full final-implementation
product and consumer audit, and Work Package 4F passed the remaining Debug,
static-only, shared-only, Unix Makefiles, residual, package, and handoff gates.

The approved Phase 2 plan is a separate compatibility-changing direction. It
will establish project build baselines of C17 and C++20 for the project-owned
core, HL, opt-in C++, tools, tests, plugins, and examples, and will repair only
demonstrated blockers. It
explicitly keeps C99/C++11 installed-header consumers in the validation
contract, forbids incidental modern syntax, excludes third-party libraries and
tools from migration, requires atomic local commits, and caps active
build/CTest parallelism at four jobs per physical host. HDF5-owned integration
with third-party prerequisites remains in the regression matrix. Work Package
2A approved the direction, selected `a1adbc32b` as the execution baseline,
qualified both validators, and classified the current optional prerequisites.
Work Package 2B froze fresh default/C++ contracts, full suites, interfaces,
packages, consumers, and cross-platform file reads at that baseline. Work
Package 2C then built strict C17 and C++20 diagnostic copies on both retained
pairs. It found one C readiness defect in the MSVC complex configure guard, one
expected strict-C namespace delta for Linux `timezone`, and one warning-only
GCC C++20 test delta. No exploratory implementation entered the real tree and
no `INVESTIGATE` item remains. Work Package 2D closed the C defect at
`310fb4323`: C11 and strict-C17 affected builds and 16-test complex selections
pass on both validators, and Windows retains its complete generated-header
contract. Work Package 2E established strict C17 at `8c177f31b`: all 317
project C compile groups, both default builds, focused tests, standalone
examples, installs, dependency isolation, and installed C99 consumers pass on
both validators without exporting the new build minimum. Work Package 2F found
and repaired the MSVC C++20/UCRT complex-header boundary at `b84f9e4a7`.
Affected C++11/C++20 targets, focused tests, installed consumers, and exact
symbol classifications pass on both validators; the known GCC warning and weak
standard-library symbol deltas remain explicitly classified.

## Completed

- Approved the Windows/MSVC and Linux/GCC support contract and documented the
  unsupported target-system/compiler combinations.
- Defined the Linux validation baseline as Linux x86_64 with GCC/G++ and Ninja,
  with a separate Unix Makefiles configure/build check; exact validator versions
  are result evidence rather than baseline requirements.
- Retained a Visual Studio generator and Linux Ninja/Unix Makefiles as validation
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
- Completed Work Package 1G on the retained Windows/MSVC baseline: default,
  static-only, shared-only, Debug, C++, full CTest, install, binary package,
  standalone example, and external-consumer rows all passed.
- Approved a self-contained Stage 2 execution plan with a fixed Linux/GCC core
  gate, read-only optional-capability discovery, validation of every available
  optional row, and explicit user decisions for missing prerequisites.
- Required every repository modification during plan execution to land as an
  atomic, independently revertible local commit after its checks pass; pure
  validation produces no commit, while portable evidence uses focused `docs:`
  checkpoints.
- Qualified an Ubuntu 26.04.1 x86_64 WSL2 validator with GCC/G++ 15.2.0,
  CMake/CTest 4.2.3, Ninja 1.13.2, GNU Make 4.4.1, and native GNU target
  triples.
- Repaired pre-Stage-1 C++ integer separators left in C sources, then passed
  every fixed Stage 2 core row: full default Release CTest, Debug, static-only,
  shared-only, C++, Unix Makefiles, examples, consumers, install, TGZ package,
  and normalized contract comparison.
- Passed available parallel, subfiling, thread-safe, concurrency, external
  plugin, STGZ, and DEB optional rows. A fresh Windows/MSVC default Release
  build and the matching seven-test smoke selection also passed after the C11
  repair.
- Corrected the compiler-wrapper contract to the intentionally consolidated
  `h5cc` and `h5c++` interface and marked its fully exercised Stage 2 row as
  passed.
- Repaired the Stage 1 bundled-compression export regression. Fetched zlib and
  libaec targets are now available to build-tree package consumers, bundled
  plugins reuse HDF5's zlib without target or archive collisions, and static
  and shared build/install consumers pass on Linux/GCC. The retained preset,
  focused compression tests, TGZ package, and fresh Windows/MSVC static path
  also pass.
- Corrected the Stage 1 GCC coverage documentation to match the implemented
  contract: target instrumentation, generated GCC counter data, and the
  `ccov-clean` reset target are supported; report generation is external. The
  validated coverage row now passes.
- Passed the system-compression row with Ubuntu zlib 1.3.1 and libaec 1.1.5
  development packages staged in an isolated external prefix. The full build,
  29 focused tests, install metadata, and static/shared consumers against both
  package locations passed without a FetchContent dependency build.
- Recorded the user's decision to defer the six unavailable optional
  configurations because they are not required, satisfying the last Stage 2
  exit gate.
- Recorded the exact Stage 2 evidence, deferred prerequisites, and continuation
  point in the portable results document.
- Drafted the self-contained Stage 3 source/header reduction plan with
  compatibility protections, atomic commit boundaries, dual-platform gates,
  stop conditions, and explicit exit criteria.
- Approved the Stage 3 plan and fixed its maximum build and CTest parallelism
  at four jobs.
- Qualified fresh Windows/MSVC and WSL Linux/GCC validators at the same tracked
  Stage 3 baseline, then captured default and C++ builds, focused tests,
  installs, package manifests, normalized contracts, installed-header hashes,
  and C/C++ exported-symbol baselines.
- Regenerated the tracked source/header inventory and resolved every candidate
  into an implementation or protected-compatibility classification. No
  `INVESTIGATE` item remains, so Work Package 3A is complete.
- Fixed the tracked text checkout contract to LF, then removed unsupported
  Clang, Intel, PGI, Apple/Darwin, BSD, Cygwin, and MinGW source/header branches
  in 14 atomic implementation commits.
- Preserved supported Windows/MSVC and Linux/GNU behavior for qsort,
  Win32/POSIX process handling, generated configuration, public declarations,
  and thread synchronization. Plugin discovery retains Windows DLL and Linux
  `lib*.so` conventions; skipping `.dylib` names is explicitly accepted.
- Completed the Stage 3 Windows/MSVC and Linux/GCC default, Debug, static-only,
  shared-only, C++, install, package, example, consumer, contract, ABI, and
  residual-audit gates at `74288cbaa`.
- Corrected the Stage 3 header evidence after review: default header names are
  unchanged, while LF normalization and the two edited headers explain text
  deltas. Four fresh C/C++ preprocessing comparisons pass on MSVC and GCC/G++.
  Withdrew the unsupported complete C++ installed-header byte comparison;
  retained source, build, consumer, and symbol evidence remains distinct.
- Drafted the Stage 4 final-audit plan after the user accepted the audit
  recommendations and inherited boundaries. It defines repository and product
  audits, two focused defect repairs, evidence inheritance, dual-platform
  acceptance, and the final modernization handoff. This is planning only.
- Aligned current continuation links and superseding status notes with the
  completed Stage 2/3 evidence; historical validation remains versioned.
- Recorded the approved Stage 4 clarifications: bounded API driver repair,
  reuse of qualifying 4E evidence in 4F, complete required baselines before
  closing 4A, and separate ordinary-defect follow-ups. Fixed the execution
  run's temporary resource budget at four parallel build/test jobs per physical
  host. This was not adopted as a lasting project or validation default.
- Completed Stage 4 Work Package 4A at reviewed baseline `cafdc38e9`, whose
  differences from Stage 3 implementation `74288cbaa` are documentation only.
  Fresh Windows/MSVC and Linux/GCC default and C++ Release builds, focused
  tests, CTest/fixture records, File API contracts, complete installs, header
  hashes, effective declarations, symbol sets, binary packages, one clean
  tracked-source package, and installed consumers passed.
- Reproduced S4-01 on both pairs: an identical second default configure adds
  only `H5TEST-mirror_vfd` and changes fixture and File API records because
  `HDF5_BUILD_UTILS` is declared after its test consumers. Reproduced S4-02 on
  both pairs: the real optional API driver target fails to find
  `H5_api_test_config.h`; the cleanup identifier mismatch is also confirmed.
- Recorded the Stage 4 capability probe, historical evidence ownership, and
  findings ledger in the portable Stage 4 results document.
- Completed the Stage 4 repository contract audit across 204 tracked CMake
  paths, 74 `project()` calls, presets, 57 workflows, dashboards, packaging,
  current documentation, language-product removal, and the repeated 1,358-file
  source/header selector inventory. No `INVESTIGATE` item remains.
- Added the missing combined-examples C++ compiler check and extended the
  admission suite to 16 cases. Full combined C/C++/HL examples pass on both
  accepted pairs.
- Removed unreachable SunOS warning guards, stale AIX/Solaris configuration
  notes, the unused AIX generated-header macro, compiler-simulation remnants,
  and an impossible MSVC branch in the GNU C++ flags module. Supported-pair
  shared builds and focused generated-settings, declaration, complex-probe,
  and command-set comparisons pass.
- Clarified the Parallel HDF5 compiler-wrapper support boundary. Corrected
  combined-example warning suppression so MSVC C++ receives `/w` while the
  compile-only switch no longer reaches `link.exe`; GNU retains `-w` for
  compile and compiler-driver link commands. Dual-host script and target
  checks pass.
- Moved `HDF5_BUILD_UTILS` to the centralized option owner without changing its
  public cache contract. Mirror test targets now require both utilities and the
  Mirror VFD, and CTest starts and stops the real mirror server through setup
  and cleanup fixtures.
- Added an 11-step configure-order reproducer covering default, explicit `ON`
  and `OFF`, first/second/third configures, legal and unavailable Mirror VFD
  prerequisites, and an `ON/OFF/ON` transition. It passes on both pairs; the
  four Linux mirror targets build and the fixture-expanded tests pass 5/5.
- Repaired the optional `h5_api_test_driver` target's HDF5 source and generated
  include ownership and corrected the misspelled process-cleanup identifier.
  Five controlled success, child-failure, launch-failure, timeout-cleanup, and
  server-cleanup tests pass on MSVC and G++, and the registered
  `h5_api_test_misc` path passes through the real driver on both pairs.
- Completed Work Package 4E at implementation anchor `f6ff66fed`. Fresh
  Windows/MSVC and Linux/GCC default and C++ Release products, full default
  suites, installs, binary packages, contracts, headers, symbols, examples,
  build/install/source consumers, Linux wrappers and pkg-config, plugin
  behavior, compatibility selections, and a clean tracked-source package all
  pass with every delta from 4A classified.
- Corrected the Windows C++ symbol evidence method by sorting case-sensitively:
  both retained raw captures contain distinct `reOpen` and `reopen` exports and
  compare as the same 1,143-name set. This is an evidence-identifier correction,
  not a product change.
- Completed Work Package 4F at implementation anchor `f6ff66fed`. Fresh
  Windows/MSVC and Linux/GCC Debug, static-only, and shared-only builds and
  fixture-aware smoke tests passed; static/shared consumers and artifact checks
  passed, Windows installed 19 Debug PDBs, and a fresh Linux Unix Makefiles
  build passed its focused tests. The final residual and 3,935-file source-
  package path audits passed with no unresolved finding.
- Completed Phase 2 Work Package 2E at implementation anchor `8c177f31b`.
  Standard ownership now precedes C probes, strict C17 covers every project C
  target, lower requests fail, later requests remain intact, dependencies keep
  their own modes, build reports are truthful, and installed targets retain the
  C99 consumer contract. Fresh default builds, focused tests, 85 standalone
  example targets, installs, export scans, and C99 consumers pass on both
  validators.
- Completed Phase 2 Work Package 2F at implementation anchor `b84f9e4a7`.
  The MSVC C++20/UCRT complex-header blocker is repaired without changing an
  installed declaration. C++11/C++20 affected targets and focused tests pass on
  both validators, C++11/C++20 installed consumers pass, legacy symbols remain
  exact, and the two strict-G++ weak standard-library additions are classified.
- Completed Phase 2 Work Package 2G at implementation anchor `1ce441445`.
  Strict C++20 now covers every project-owned C++ target while C-only builds
  remain C++-independent and KWSYS retains C++11. Fresh C++ builds, focused and
  process tests, standard contracts, settings, exports, public declarations,
  layouts, symbols, and installed C++11/C++20 consumers pass on both validators.
- Completed Phase 2 Work Package 2H at implementation anchor `c38e58ed8`.
  Both full default and C++ Release suites, Debug/static/shared variants,
  installs, examples, consumers, integration styles, thread modes, applicable
  MPI/subfiling, compression/plugin and parallel-tools paths, Linux coverage
  and Unix Makefiles, binary/source packages, exact contracts, inventory
  comparison, and cross-platform file reads passed. The user approved
  `DEFER_ENVIRONMENT` for ROS3, HDFS, signed plugins, and Linux RPM as
  non-critical optional rows. Windows subfiling and parallel tools are not
  applicable; the Windows MPI filter failure is identical on the frozen C11
  baseline and retained as a classified runtime limitation.

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
- Audited the workspace HighFive 3.3.0 header tree without product integration. Its
  content manifest is
  `25c7d5e69a69c446b8024941465449b51c9a62c2eb3ce2f981babd9fa6137910` and
  differs from the upstream comparison in four documented files. It references
  147 distinct HDF5 C functions, conditionally uses the parallel and filter
  surfaces, and has no native HDF5 C++, HL, or H5M API dependency.
- Abandoned and deleted the unimplemented C++20 internal-modernization plan.
  Drafted the replacement roadmap Stage 4 plan for physical removal of native
  `c++/`, complete `hl/`, and every related product contract.
- Completed roadmap Stage 4 Work Package 4A. The exact removal inventory and
  all 22 external `.cpp` classifications are closed; clean Windows/MSVC and
  Linux/GNU default and acceptance-profile baselines, installs, package
  inventories, retained core contracts, and a dual-platform HighFive-style
  consumer are frozen. Windows/MS-MPI exceptions reproduce on the execution
  baseline, and clean Linux filesystem snapshots eliminate the earlier
  Windows-mount CRLF test contamination.
- Completed roadmap Stage 4 Work Package 4B at `c62d134e5`. The complete
  `hl/` tree, HL C/C++ examples and tests, `h5watch`, and all active HL build,
  install, export, package, wrapper, settings, CI, and current product contracts
  are removed. The native `c++/` tree and core local-heap `src/H5HL*` package
  remain intact.
- Passed clean post-removal default and static Profile B builds on Windows/MSVC
  and Linux/GNU. Focused default tests passed 19/19 on Windows and 15/15 on
  Linux; Linux Profile B passed 17/17 core/filter/MPI/tool tests. Windows
  Profile B passed 15/17, with the two failures carrying the already frozen
  MS-MPI "No aggregators match" disposition.
- Passed default install and binary-package generation on both validators.
  Exact Windows install/ZIP and Linux install/TGZ scans contain no HL library,
  header, tool, component, or package metadata. Dual-platform installed
  HighFive-style consumers compile, link, run, and verify data using only the
  retained core C shared target.
- Completed roadmap Stage 4 Work Package 4C at `3dc988a48`. The native `c++/`
  tree, native C++ examples, libraries, headers, tests, `h5c++`, options,
  exports, package metadata, settings, CI assumptions, and current product
  documentation are removed. Separately owned API-driver C++20 infrastructure
  remains.
- Passed clean default Release builds and focused 12-test selections on
  Windows/MSVC and Linux/GNU. Installs, binary and source packages, artifact
  scans, workflow/preset parsing, and the retained C++20/C++23/lower-standard
  contract matrix pass on both validators at `HDF_TEST_EXPRESS=3` and at most
  four parallel jobs.
- Completed roadmap Stage 4 Work Package 4D at `81dff5168`. Removed build
  options and package components now fail deliberately, while build-tree,
  install-tree, `add_subdirectory()`, local FetchContent, retained C, and
  HighFive-style consumers compile, link, and run on both validators. Negative
  target, variable, metadata, wrapper, tool, and artifact checks also pass.
- Completed roadmap Stage 4 Work Package 4E from clean source anchor
  `55bad410b`. Default, shared Profile A, and static Profile B complete builds,
  full suites, installs, and binary packages ran on Windows/MSVC and Linux/GNU
  at `HDF_TEST_EXPRESS=3` and at most four jobs. Linux passed 2,735, 3,153, and
  3,110 enabled tests; Windows default passed 2,733, and the two profiles had
  only their frozen MS-MPI failures and Profile A hang. Unix Makefiles,
  retained feature, Map, cross-read, package, and HighFive consumer gates pass.
- Completed roadmap Stage 4 Work Package 4F at evidence anchor `f120c1c95`.
  Windows and Linux core C symbol sets match the pre-removal freeze, core C and
  cross-platform sources are unchanged, all 147 HighFive dependencies remain,
  and install, target, tool, test, and residual deltas contain only approved
  native C++/HL removals. No unresolved active contract reference remains.

## Remaining

- No supported-platform reduction implementation or validation work remains.
- No Phase 2 C17/C++20 implementation, validation, or decision gate remains.
- No roadmap Stage 4 implementation, validation, audit, or documentation gate
  remains.
- Roadmap Stage 5 R1-5A and R1-5B are complete. R1-5C and R1-5D are
  `NOT_APPLICABLE`; R1-5E and R1-5F remain.
- Roadmap Stages 6 and 7 remain future plan to be determined.
- Preserve the separate target-scoped CMake modernization at its unchanged
  progress anchor until that direction is explicitly resumed.

## Continuation Point

The next roadmap continuation is Work Package R1-5E of
[CoreC17Modernization.md](docs/refactoring/CoreC17Modernization.md): run the
final product and compatibility matrix for the const-correct file-local path
scan helpers now used by `H5_dirname` and `H5_basename`. R1-5A through R1-5D
evidence is recorded in
[CoreC17ModernizationResults.md](docs/refactoring/CoreC17ModernizationResults.md).
The focused Release, Debug, Valgrind, Unix Makefiles, and Linux parallel
subfiling checks pass. Roadmap Stage 4 remains complete at product implementation
anchor `81dff5168` and validation evidence anchor `f120c1c95`.
Roadmap Stages 6 and 7 have no approved execution scope.

The separately paused CMake modernization may resume only after explicit
direction, from progress anchor `0b9e21c34` and the continuation recorded in
[`docs/CMakeModernizationProgress.md`](docs/CMakeModernizationProgress.md). Do
not infer HighFive integration or revive the deleted C++20 internal-
modernization plan from this completed stage.

Supported-platform Stage 3 is complete at implementation anchor `74288cbaa`;
its completion review is closed at `7e50c3c17`. Supported-platform Stage 4 Work
Packages 4A through 4F are complete, and that overall direction closes at
product implementation anchor `f6ff66fed`. Portable evidence is in the
[supported-platform Stage 4 results](docs/refactoring/CMakePlatformSupportReductionStage4Results.md).
Its temporary four-job resource budget expired with that execution and is not
a lasting project or validation reference.

The approved
[Phase 2 C17/C++20 build-baseline plan](docs/refactoring/C17Cpp20BuildBaseline.md)
is complete at implementation anchor `c38e58ed8`. The main product matrix passed
at `1ce441445`; the final implementation commit touches only the opt-in
parallel-tools path and passed its dedicated strict-C17 build, tests, install,
and installed runtime checks. Supplied Windows dependencies also completed the
system-compression and parallel rows. Windows subfiling and parallel tools are
not applicable, the Windows MPI filter failure reproduces on the frozen C11
baseline, and the four non-critical optional environment dispositions are
approved. Do not redo Phase 2 unless its compatibility contract changes.

The separate CMake 4 modernization remains paused at implementation anchor
`0b9e21c34`. Its preserved continuation is classification of the remaining MPI
include expressions followed by dedicated migration of global compiler-flag
state. Do not advance that anchor as a side effect of Phase 2 planning or
execution.

## Validation State

- Roadmap Stage 4 Work Packages 4A and 4B are complete. Work Package 4A used
  execution baseline
  `72e36a522`, with pre-removal stabilization through `3118d8c2c`. Windows
  default passed 2,816 enabled tests with 37 disabled; clean Linux default
  passed 2,818 enabled tests with 37 disabled. Clean Linux Profiles A and B
  passed 3,236 and 3,193 enabled tests respectively, each with 10 disabled.
  Windows profile exceptions all reproduce on the frozen baseline and are
  recorded in `docs/refactoring/NativeCppHlRemovalResults.md`. The exact
  product ledger, external `.cpp` classification, installed/package contract,
  and dual-platform HighFive-style consumer contract are frozen. Work Package
  4B removed the complete HL product at `c62d134e5`. Post-removal default and
  static Profile B builds pass on both validators; focused tests pass 19/19 and
  15/17 on Windows, and 15/15 and 17/17 on Linux. The two Windows Profile B
  failures are frozen MS-MPI file-aggregator exceptions. Default installs and
  ZIP/TGZ packages have zero exact HL artifact matches, and installed
  HighFive-style consumers pass on both validators. Map-enabled builds and
  standalone symbol linkage pass; native `H5Mcreate()` remains unsupported by
  the native VOL exactly as at pre-removal anchor `3118d8c2c`.
- Phase 2 Work Packages 2A through 2H are complete; the execution baseline is
  `a1adbc32b` and the implementation anchor is `c38e58ed8`. The final
  default/C++ Release suites passed
  2,816/2,850 enabled tests on Windows and 2,818/2,852 on Linux, with 37 disabled
  and zero failed in each default/C++ row. Exact CTest inventories have zero
  name/disabled-state delta from the frozen baseline. Debug, static/shared,
  installs, examples, legacy/baseline consumers, integration styles, thread
  modes, available optional features, coverage, Unix Makefiles, packages, and
  cross-platform file reads pass. The final standard contracts cover 317 C and
  23 C++ compile groups on both validators without dependency or consumer
  leakage. `P2-01`, `P2-04`, and `P2-06` are closed; `P2-02`, `P2-03`,
  `P2-05`, and `P2-07` retain their reviewed dispositions. Windows system
  compression passed 50/50 focused filter tests and four consumers. Windows
  parallel passed a 14/14 four-rank selection, Linux parallel tools passed a
  complete strict-C17 C-only build and 2/2 focused tests, and four optional
  environment deferrals are approved. No `INVESTIGATE` product finding
  remains.
- Stage 4 Work Package 4A is complete. Fresh default and C++ Release builds,
  focused tests, CTest registration/fixture JSON, first/repeat and installed
  contracts, complete isolated installs, header hashes, effective declaration
  captures, five exported-symbol sets, installed consumers, four binary
  packages, and one clean tracked-source package are recorded for both pairs.
- Stage 4 Work Package 4B is complete. The 16-case admission suite, applicable
  preset listing, repository support claims, automation/packaging inventory,
  Java/Fortran removal, and exact/lexical residual classifications pass. Six
  focused implementation corrections end at `ebdb99969`.
- Stage 4 Work Package 4C is complete at `8d7aa0432`. The dual-platform
  configure sequence is stable, default test totals remain 2,853/2,855, and the
  legal Linux mirror configuration registers three exact mirror tests. Its four
  targets build and the fixture-expanded selection passes 5/5.
- Stage 4 Work Package 4D is complete at `f6ff66fed`. MSVC and G++ build the
  actual optional driver without validation-only source patches. Its five
  controlled process tests pass 5/5 on each pair, `h5_api_test_misc` passes
  through the driver at `HDF_TEST_EXPRESS=3`, and no controlled process or PID
  file remains.
- Stage 4 Work Package 4E is complete at implementation anchor `f6ff66fed`.
  Windows default CTest passed 2,816/2,816 enabled tests and Linux passed
  2,818/2,818, both with 37 disabled. Default/C++ installs, packages, contracts,
  effective declarations, all ten platform/library symbol sets, examples,
  consumers, Linux wrappers/pkg-config, plugins, compatibility tests, and the
  clean source-package manifest pass with no unexplained delta.
- Stage 4 Work Package 4F is complete at the same product implementation.
  Fresh Debug, static-only, and shared-only builds and fixture-expanded 7/7
  smoke selections passed on both pairs. Static/shared artifacts and consumers,
  the Windows Debug PDB install, and the Linux Unix Makefiles build and tests
  passed. The final 1,359-file residual and 3,935-file package-path audits pass.
- S4-01 and S4-02 are repaired and S4-04's scoped product comparison passes.
  No `FIX_STAGE4`, `FAIL`, or `INVESTIGATE` item remains.
- Current status: Stages 1 through 4 and the overall supported-platform
  reduction direction are complete. Final Stage 4 product evidence came from
  clean Windows/MSVC and WSL Linux/GCC trees at implementation `f6ff66fed`.
- Windows default Release passed all 2,816 enabled tests with 37 disabled out of
  2,853 registered. Debug, static-only, shared-only, C++, install, ZIP,
  standalone examples, and build/install/source-tree consumers passed.
- Linux default Ninja Release passed all 2,818 enabled tests with 37 disabled
  out of 2,855 registered. Debug, static-only, shared-only, C++, Unix Makefiles,
  install, TGZ, wrappers, standalone examples, and all consumer modes passed.
- The final post-install default/C++ contract totals are Windows 17,446/19,735
  and Linux 28,323/30,940. Counts alone do not prove equality. Header text and
  capture-prefix deltas are
  explained in the corrected Stage 3 results; public declarations compare
  equal. Prior symbol, library-name, import-library, SONAME/RUNPATH, package,
  and consumer evidence remains recorded separately from header-byte checks.
- Thread-safe and concurrency configurations passed focused tests on both
  platforms. Default and plugin-focused tests cover the changed `H5PLpath`
  branches. Other Stage 2 optional rows own no changed Stage 3 behavior and
  retain their prior passing or user-deferred disposition.
- Historical Stage 2 status: complete. The core gate, bundled compression,
  system compression, and coverage pass, and all optional rows supported by the
  supplied Linux/GCC environment executed successfully. The six unavailable,
  non-required optional rows are explicitly deferred.
- The qualified validator was Ubuntu 26.04.1 LTS under WSL2 on x86_64 with
  glibc 2.43, GCC/G++ 15.2.0 targeting `x86_64-linux-gnu`, CMake/CTest/CPack
  4.2.3, Ninja 1.13.2, GNU Make 4.4.1, `HDF_TEST_EXPRESS=3`, and at most six
  parallel jobs. The tracked validation checkout was clean at `6ee2f392e`.
- The default Ninja Release build passed its full suite: 2,819 passed, zero
  failed, and 37 disabled out of 2,856 registered tests. Debug, static-only,
  shared-only, C++, and Unix Makefiles builds plus their focused selections all
  passed. Standalone examples passed 279/279 tests against both build-tree and
  installed packages; install, TGZ, and four consumer modes passed.
- The normalized pre-Stage-1/current contracts differed only by approved
  MinGW and Linux-irrelevant MSVC cache removal plus sanitizer help wording;
  retained Linux targets, flags, tests, generated files, and package metadata
  had no unexplained delta.
- Available optional rows passed for OpenMPI parallel HDF5, subfiling,
  thread-safe and concurrency modes, remotely retrieved external plugins,
  STGZ, and DEB. Detailed commands, counts, artifacts, and versions are in the
  Stage 2 results document.
- The supported `h5cc` and `h5c++` wrappers passed, including default high-level
  linkage and `-nohl`; obsolete four-wrapper documentation was corrected. The
  bundled-compression export regression is fixed and its rerun passed. The
  coverage documentation now matches the implemented instrumentation and
  counter-reset behavior; no failed Stage 2 row remains.
- Bundled zlib 1.3.2 and libaec 1.1.6 passed the retained preset build and 49
  focused compression/plugin tests. Static and shared build-tree/install-tree
  consumers found DEFLATE and SZIP, and the TGZ package contained the expected
  libraries and CMake exports.
- Ubuntu zlib 1.3.1 and libaec 1.1.5 packages passed the non-FetchContent
  system-compression path: 3,161 build steps, 29 focused tests, installation,
  dependency metadata, and four static/shared build/install consumers.
- Missing-environment rows are mpiFileUtils/libcircle/DTCMP, ROS3 aws-c-s3,
  JDK/Hadoop/libhdfs, OpenSSL development/signing inputs, `rpmbuild`, and a real
  unsupported native Linux compiler. The user explicitly deferred every row
  because these configurations are not required.
- A fresh post-repair Windows x64 default Release build passed with CMake 4.4.3,
  Visual Studio 18 2026, MSVC 19.51.36256.0/toolset 14.51.36231, and
  `CL=/utf-8`; its focused selection passed 7/7 with fixtures.
- A fresh Windows/MSVC bundled-compression configuration and Release build also
  passed after `81e96c889`. Static consumers configured, linked, and ran against
  both build-tree and installed packages; multi-config dependency imports used
  the expected configuration-specific library paths.
- The completed local baseline was Windows NT `10.0.26100` x64, Visual Studio
  18 2026 Insiders, MSVC `19.51.36256.0` from toolset `14.51.36231`, Windows
  SDK `10.0.26100.0`, and CMake `4.4.3`. Configures used the Visual Studio 18
  2026 generator without an explicit platform, `CL=/utf-8`,
  `HDF_TEST_EXPRESS=3`, and at most six parallel jobs.
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
- A fresh default Release configure and complete build passed with static and
  shared libraries, tests, tools, high-level libraries, and examples enabled
  and C++ disabled. Full CTest passed all 2,816 enabled tests with 37 disabled
  out of 2,853 registered tests.
- Fresh static-only Release, shared-only Release, and default Debug builds
  passed. Each configuration passed the same focused C, high-level, and tool
  smoke selection plus its fixtures: seven tests per configuration.
- Artifact checks confirmed the default Release build emits `hdf5.dll`, its
  `hdf5.lib` import library, and `libhdf5.lib`; static-only omits the DLL and
  import library; shared-only omits the static library. The high-level library
  follows the same pattern. Debug emits and installs HDF5 and tool PDB files in
  `bin`.
- Release installation of the C++-enabled combined build passed and installed
  C, high-level, C++, and C++ high-level static and shared libraries, runtime
  DLLs, tools, headers, package configuration, and static/shared export sets.
  CPack ZIP generation passed; the archive contains 164 entries, including the
  expected C/C++ runtime and library artifacts.
- Standalone retained C, C++, and high-level examples configured, built, and
  passed all 279 registered tests against both the build-tree package and the
  installed package.
- Minimal external `add_subdirectory()` and local-source FetchContent consumers
  each configured, built, linked to `hdf5-static`, and passed their execution
  test.
- A user-provided vcpkg-exported Microsoft MPI SDK was paired with the installed
  Microsoft MPI runtime. Parallel HDF5 configured and completed a full Release
  build with 3,108 registered tests. A focused core-library, MPI, parallel-tool,
  and parallel-example selection passed all nine tests and fixtures.
- Fresh thread-safe and multi-thread concurrency configurations each built the
  shared library and `testhdf5`; the focused base test and its fixtures passed
  three of three tests in each configuration.
- After refreshing the process environment, CMake found Strawberry Perl
  `5.42.3`; Perl is not a remaining environment gap.

## Residual Audit

- The final source/header scan covers 1,359 tracked files and reports
  `APPLE=3/3`, `CLANG=225/37`,
  `CYGWIN=6/5`, `DARWIN=0/0`, `FREEBSD=1/1`, `INTEL=179/14`, `MACOS=4/1`,
  `MINGW=7/6`, `NETBSD=2/2`, and `PGI=17/2`, expressed as matches/files.
- The Stage 4 extension reports `AIX=134/6`, `HPUX=1/1`, `HP-UX=5/2`,
  `SOLARIS=3/3`, `XL=430/29`, `IBM=29/6`, and `CRAY=25/8`; `INTELLLVM`,
  `NVHPC`, `AOCC`, `EMSCRIPTEN`, `SUNOS`, and `SUNPRO` are zero. High-count
  short terms include ordinary substrings and require exact-selector review.
- Exact active unsupported selectors remain only in Bison-generated skeleton
  code in `hl/src/H5LTparse.c` and vendored compiler handling in
  `src/uthash.h`; both are protected third-party/generated content.
- All other matches are public or file-format compatibility names, retained
  feature/architecture behavior, formatter directives, factual history, or
  lexical false positives. No project-owned unsupported-only implementation or
  `INVESTIGATE` item remains.
- The clean Stage 4 source package contains exactly the same 3,935 files as the
  final tracked path manifest. It excludes Git, IDE, agent, build/CPack staging,
  Java, and Fortran directories. Documentation-only completion edits add no
  package-input path.

The qualified Windows/MSVC and Linux/GCC validators completed Stage 4. Preserve
the versioned Stage 1 through Stage 4 records and do not reinterpret
the six non-required Stage 2 environment deferrals as removed functionality.

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
7. Commit every repository modification as an atomic, independently revertible
   local checkpoint after its required checks pass. Never include unrelated
   user changes or generated artifacts.
8. Use the qualified `roadmap Stage 4 native C++ and HL product removal` name so
   it is not confused with the completed Stage 4 audit inside the supported-
   platform reduction plan.
9. Keep roadmap Stage 5 aligned with the proposed core C17 plan and its actual
   execution evidence; do not label planning as implementation. Stages 6 and 7
   remain `Future plan TBD` with no approved execution scope.
