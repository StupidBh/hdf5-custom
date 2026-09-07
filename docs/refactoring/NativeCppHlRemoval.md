# Native C++ and High-Level Product Removal Plan

State: In progress

Last updated: 2026-09-07

Planning source anchor: `55a930c0d`

Plan approval: 2026-09-06

Execution baseline: `72e36a522bf2f4f2c272f0edae14705139e35deb`

Implementation anchor: `81dff5168`

## Decision

Roadmap Stage 4 will physically remove the repository's native `c++/` tree,
the complete `hl/` tree, and every current product contract whose only purpose
is to build, test, install, export, package, document, or consume those
products.

The replacement C++ direction is HighFive. The workspace `highfive/` header
copy is an audit input, but it is not wired into the build, install, export, or
package in this stage. The content-pinned dependency audit is
[`HighFiveHDF5ApiDependencyAudit.md`](HighFiveHDF5ApiDependencyAudit.md).

The user approved this plan on 2026-09-06 without broadening it into HighFive
integration. Work Package 4A selected the clean tracked execution baseline
above and is freezing the exact pre-removal contracts before product changes
begin.

## Intended Endpoint

The product surface after Stage 4 consists of the HDF5 core C library and the
retained tools, utilities, tests, plugins, examples, and optional core features
needed by the two acceptance profiles. It does not contain:

- native HDF5 C++ libraries, headers, tests, examples, package components,
  pkg-config files, or the `h5c++` wrapper;
- HDF5 high-level C or C++ libraries, headers, tests, examples, package
  components, pkg-config files, or the `h5watch` tool;
- `HDF5_BUILD_CPP_LIB` or `HDF5_BUILD_HL_LIB` compatibility options;
- CMake targets, aliases, variables, generated settings, exported metadata,
  install components, or documentation that promise those removed products.

This is an intentional source, binary, and package compatibility break for the
removed products. The core C API, ABI, installed headers, file format, and
retained tool behavior are not authorized to change.

## Fixed Acceptance Profiles

| Profile | Linkage | Required features | Required platforms |
| --- | --- | --- | --- |
| A | Shared only | `map`, `szip`, `threadsafe`, `tools`, `zlib`, `parallel` | Windows/MSVC and Linux/GNU |
| B | Static only | `map`, `szip`, `tools`, `zlib`, `parallel`; `threadsafe=OFF` | Windows/MSVC and Linux/GNU |

Profile A currently needs `HDF5_ALLOW_UNSUPPORTED=ON` for the parallel and
thread-safe combination. The override is part of the validation command, not a
Stage 4 policy change. Profile B confirms static parallel support with thread
safety disabled. Both rows must use available platform-appropriate MPI and
compression dependencies and must record their exact versions and ownership.

## Scope Boundaries

### In Scope

- Delete all tracked paths below `c++/` and `hl/`.
- Remove their root and nested CMake entry points and option handling.
- Remove native C++, HL C, and HL C++ library targets in static and shared
  forms, including aliases, exports, install rules, PDB rules, and pkg-config
  metadata.
- Remove native C++ and HL headers from build-tree and install-tree manifests.
- Remove native C++ and HL examples and their standalone/example-selection
  logic.
- Remove `h5c++`, HL-aware wrapper switches, and the HL-dependent `h5watch`
  tool and tests.
- Remove `CXX`, `HL`, and `CXX_HL` package components and the matching
  `*_PROVIDES_*`, library, include, and feature variables.
- Remove obsolete generated settings fields such as native C++ and high-level
  build-state reporting.
- Update active documentation, presets, validation scripts, source-package
  manifests, release notes, and consumer tests to describe only retained
  products.
- Preserve and validate all C API dependencies in the pinned HighFive audit.

### Out of Scope

- Wiring HighFive into CMake or packaging, exporting, or installing it.
- Modifying the workspace HighFive headers or deciding whether and how they
  become tracked product source.
- Designing the future HighFive public contract or choosing its permanent
  version/update policy.
- Replacing removed native C++/HL APIs with compatibility shims.
- General C17 or C++20 source modernization.
- Redesigning any retained C API or changing the on-disk format.
- Changing the support status of parallel plus thread safety.
- Removing retained tools merely because HighFive does not use them.
- Removing retained internal C++ utilities solely because public native C++ is
  gone.

## Current Removal Inventory

The planning tree contains 96 tracked paths under `c++/` and 119 under `hl/`.
The directory totals are inventory aids, not completion evidence; Work Package
4A must regenerate them at the selected execution baseline.

| Surface | Current contents | Required disposition |
| --- | --- | --- |
| `c++/src` | Native C++ implementation and installed headers including `H5Cpp.h` | Delete directory and all library/header product rules |
| `c++/test` | Native C++ unit and VFD tests | Delete with target and CTest registration cleanup |
| `hl/src` | HL C APIs including H5DO, H5DS, H5IM, H5LT, H5PT, H5TB, and H5LD | Delete directory and all HL C product rules |
| `hl/c++` | Packet-table C++ wrapper, tests, and product metadata | Delete as part of complete HL removal |
| `hl/test` | HL C tests, generators, and fixtures | Delete with registrations and copied fixtures |
| `hl/tools/h5watch` | HL-dependent command-line product and tests | Delete; other tools remain in scope |
| `HDF5Examples/CXX` | Native C++ and C++ HL examples | Delete or remove from retained example distribution |
| `HDF5Examples/HL` and other HL-selected examples | HL C examples and selection logic | Delete or remove from retained example distribution |
| Root/build options | `HDF5_BUILD_CPP_LIB`, `HDF5_BUILD_HL_LIB`, language setup, subdirectories, unsupported-combination checks | Remove options and all consumers; retain C++ language only where separately owned sources require it |
| Installed package | CXX/HL/CXX_HL components, targets, variables, headers, libraries, pkg-config files | Remove contracts and add explicit negative checks |
| Wrappers/settings | `h5c++`, `-nohl` behavior, build-settings fields | Remove obsolete product behavior while retaining `h5cc` |
| Documentation/packaging | option references, API manuals, examples, component lists, source/package manifests | Update current claims; preserve historical result documents as historical evidence |

Project-owned `.cpp` files exist outside the removal trees, including CMake
feature probes and API test-driver processes. They need ownership
classification before editing. The absence of native C++ products does not by
itself authorize deleting those retained build/test implementation files or
lowering their C++20 build mode.

## Product Contract Ledger

Work Package 4A must expand this ledger to exact target and path names at the
execution baseline. Every row must have a positive retained check or a negative
removed check; disappearance from one build configuration is insufficient.

| Contract | Remove | Preserve/replace |
| --- | --- | --- |
| Source trees | `c++/**`, `hl/**` | `src/**`, retained tools/tests/examples/plugins |
| Cache options | `HDF5_BUILD_CPP_LIB`, `HDF5_BUILD_HL_LIB` | Existing retained core-feature options |
| Libraries | native C++, HL C, and HL C++ static/shared libraries | Core HDF5 static/shared library selected by profile |
| Installed headers | `H5Cpp.h` and native C++ headers; `hdf5_hl.h` and HL headers | Core public C headers, including HighFive-audited families |
| Package components | `CXX`, `HL`, `CXX_HL` and static/shared variants or variables | Core C plus linkage and retained Tools contracts |
| CMake exports | removed-product imported targets and `PROVIDES_CPP/HL` claims | Core targets and dependency propagation |
| pkg-config | C++, HL, and HL C++ `.pc` files | Core static/shared metadata |
| Compiler wrappers | `h5c++` and HL-specific link selection | `h5cc` for the retained C product |
| Tools | `h5watch` | All core tools required by `tools=ON` |
| Tests/examples | native C++ and all HL suites/examples | Core C, map, filter, parallel, thread-safe, and retained tool coverage |
| Generated reports | C++/HL availability fields | Accurate retained product and feature report |

## Known External Touch Points

The following files and families already contain active native C++ or HL
contracts and must be reconciled with the exact Work Package 4A inventory.

| Area | Known touch points |
| --- | --- |
| Root configuration | `CMakeLists.txt`, `CMakeBuildOptions.cmake` |
| Installed CMake package | `config/install/hdf5-config.cmake.in` and export/install generation in the root and library CMake files |
| Build presets and contract tests | `config/cmake/cacheinit.cmake`, `config/cmake/MemcheckCacheinit.cmake`, `config/cmake/scripts/HDF5BuildContract.cmake`, `config/cmake/tests/HDF5CXXStandardTests.cmake` |
| Compiler wrappers | `config/libh5cc.in` plus its configure/install/test call sites |
| Examples | `HDF5Examples/CXX/**`, HL examples, `HDF5Examples/config/cmake/HDFExampleMacros.cmake`, `config/cmake/HDF5ExampleCache.cmake` |
| Generated configuration/settings | `src/H5pubconf.h.in`, `src/H5build_settings.cmake.c.in`, `src/libhdf5.settings.in` |
| Library metadata | C++/HL target variables, pkg-config templates and calls, PDB/install components, source-package lists |
| Documentation | Doxygen inputs, install/options/tool/example pages, current package/consumer guidance, `release_docs/CHANGELOG.md` |

This table is deliberately not treated as exhaustive. The implementation gate
is a zero-unclassified-result search across all tracked active CMake, source,
test, example, packaging, and current-documentation files.

## Execution Rules

These rules apply to every implementation and validation work package and
override broader repository defaults for the duration of roadmap Stage 4.

### Local Atomic History

- Every coherent repository modification must end in an atomic local Git
  commit after its required checks pass. Do not leave completed implementation
  batches only in the working tree or postpone all commits until the end.
- Each commit must represent one reviewable purpose, remain independently
  revertible, and leave the repository in a buildable state for the affected
  configuration. A revert must not require unrelated follow-up commits to
  restore the preceding contract.
- Keep implementation, its focused tests, and required current-documentation
  updates together when they describe one behavior. Keep unrelated deletion,
  formatting, modernization, dependency, and evidence-only changes separate.
- Pure read-only investigation or validation does not require an empty commit.
  Portable results produced from it must be committed as a focused `docs:`
  checkpoint when the work package requires repository evidence.
- Before committing, inspect the exact staged paths and exclude unrelated user
  changes, generated outputs, IDE state, logs, temporary checkouts, build
  trees, install trees, and packages.

### Build and Test Parallelism

- The maximum build and CTest parallelism is 4. Use no value greater than 4
  for `cmake --build --parallel`, `ctest -j`, native build-tool job counts, or
  equivalent controls.
- When multiple build or test processes run concurrently on one physical host,
  their active job limits must share the same total budget of 4 rather than
  each process receiving four jobs.
- A workload may use fewer than four jobs for stability or resource pressure.
  Record any lower limit that materially affects validation evidence.

### CLion MCP and Terminal Reuse

- Prefer the CLion MCP service for repository navigation, reference searches,
  inspections, build/test execution, and diagnostics when the service exposes
  a suitable operation and is available.
- Reuse an existing CLion MCP terminal session for commands that share the
  same platform and environment. Do not create a new terminal for every MCP
  call and do not abandon one-shot terminals after use.
- Keep the number of live terminals minimal, identify their platform and
  purpose in execution notes, and close a terminal when its work package is
  complete, when the session is no longer reusable, or before final handoff.
- A normal terminal is an allowed fallback when CLion MCP is unavailable,
  unsuitable for the operation, or cannot preserve the required environment.
  Record the fallback reason when it affects reproducibility or validation.

## Ordered Work Packages

### Work Package 4A: Approval, Baseline, and Exact Contract Freeze

1. Approve this plan without broadening it into HighFive integration.
2. Select one clean tracked execution baseline and record toolchain,
   dependency, MPI, compression, and `HDF_TEST_EXPRESS` values.
3. Regenerate the complete path, option, target, test, installed-file,
   export, package-component, pkg-config, wrapper, settings, example, and
   documentation inventories for native C++ and HL.
4. Classify every `.cpp` outside `c++/` and `hl/` as retained infrastructure,
   retained test implementation, or a removed-product consumer. No
   `INVESTIGATE` item may enter implementation.
5. Capture fresh pre-removal builds and full CTest results for the default
   build and both acceptance profiles on both retained compiler pairs.
6. Freeze the core C installed headers, exported symbols, library names,
   package metadata, retained tool list, CTest inventory, and representative
   cross-platform file reads.
7. Freeze a reproducible HighFive-style consumer contract using the workspace
   `highfive/` header set without wiring it into the HDF5 build or install
   package.

Gate: all inventories are complete, both required profiles are reproducible,
the shared override is explicit, and no unexplained baseline failure remains.

### Work Package 4B: Remove the Complete HL Product

1. Remove `hl/`, including HL C, HL C++, tests, fixtures, and `h5watch`.
2. Remove `HDF5_BUILD_HL_LIB`, `H5_INCLUDE_HL`, HL root wiring, HL Doxygen
   aggregation, and HL-related unsupported-combination checks.
3. Remove HL library/target-name variables, exports, install components,
   pkg-config files, generated settings, and package `HL`/`CXX_HL` contracts.
4. Remove HL C and C++ examples and their build-tree/installed-package routing.
5. Update retained tool and test expectations so only the intentional
   `h5watch`/HL losses occur.

Gate: the default build and the narrowest core, map, filter, parallel, and
retained-tool tests pass; installed and packaged trees have no HL artifact or
active HL contract.

### Work Package 4C: Remove the Native C++ Product

1. Remove `c++/`, including implementation headers, tests, and fixtures.
2. Remove `HDF5_BUILD_CPP_LIB`, root C++ library wiring, C++-specific
   unsupported-combination checks, target variables, exports, install
   components, pkg-config files, and generated settings.
3. Remove `h5c++` generation/install behavior and native C++ wrapper tests.
4. Remove native C++ examples and component-selection logic.
5. Retain C++20 configuration only for separately classified project-owned
   C++ infrastructure or test sources that remain after the product deletion.

Gate: the default build and focused retained-product tests pass; installed and
packaged trees have no native C++ artifact or active C++ product contract.

### Work Package 4D: Normalize Package and Consumer Contracts

1. Reduce valid installed CMake components to the retained product surface and
   remove stale variables rather than leaving permanent false-valued aliases.
2. Ensure build-tree, install-tree, `add_subdirectory()`, and FetchContent-style
   C consumers still resolve only retained targets and dependencies.
3. Verify a HighFive-style header consumer through the existing retained core
   package target. Record upstream HighFive's `HDF5::HDF5` expectation as a
   future integration question; do not add an alias or change package routing
   solely for HighFive in this stage.
4. Add negative consumer/configure checks proving removed options, components,
   targets, headers, libraries, `.pc` files, wrappers, and tools are absent or
   rejected with deliberate diagnostics.
5. Remove all active source-package references to deleted paths.

Gate: all retained consumers pass and every negative product-contract check
has the expected result on both retained platform/compiler pairs.

### Work Package 4E: Execute the Required Product Matrix

For Windows/MSVC and Linux/GNU, run each row from a clean out-of-source tree:

1. Default Release configure, complete build, full CTest, install, and native
   binary package.
2. Profile A shared-only configure/build/full CTest/install/package with map,
   SZIP, zlib, tools, parallel, thread safety, and the explicit unsupported
   override.
3. Profile B static-only configure/build/full CTest/install/package with map,
   SZIP, zlib, tools, parallel, static tools as required, and thread safety off.
4. Focused Unix Makefiles configure/build check on Linux for a retained profile.
5. Retained examples, core C consumers, wrappers, filters, map, MPI/parallel,
   thread-safe Profile A tests, and cross-platform file reads.
6. HighFive-style compile/link/run probes against both build-tree and installed
   HDF5 package routes, using the content-pinned workspace `highfive/` headers
   without adding them to HDF5's CMake, install, export, or package products.

Apply the Stage 4 aggregate maximum of four parallel build and CTest jobs;
use fewer when a recorded workload requires it.
Report exact registered, passed, failed, disabled, and skipped CTest totals and
the configured `HDF_TEST_EXPRESS` value for each full suite.

Gate: all rows pass with zero unexplained contract delta and no removed product
appears in any build, install, export, package, or consumer surface.

### Work Package 4F: Residual Audit and Closeout

1. Search tracked active files for deleted directories, options, component
   names, target names, installed headers, library names, wrappers, and tools.
2. Classify historical documentation references separately from active claims;
   do not rewrite versioned execution evidence as though the old products
   never existed.
3. Compare final core headers, C symbols, retained targets/tools/tests, package
   metadata, and cross-platform files with the Work Package 4A freeze.
4. Update `release_docs/CHANGELOG.md`, this plan, a new results document,
   `docs/refactoring/README.md`, and `REFACTORING_PROGRESS.md`.
5. Record all implementation commits, validation gaps, exact exceptions, and
   the next continuation point.

Gate: every removal contract has positive absence evidence, every preserved
contract has passing evidence, and no unresolved residual remains.

## Required Validation Summary

| Gate | Windows/MSVC | Linux/GNU |
| --- | --- | --- |
| Clean default Release build/full CTest/install/package | Required | Required |
| Profile A shared map+SZIP+threadsafe+tools+zlib+parallel | Required | Required |
| Profile B static map+SZIP+tools+zlib+parallel, no thread safety | Required | Required |
| Core C build/install consumers | Required | Required |
| HighFive-style external consumer | Required | Required |
| Removed-product negative contract checks | Required | Required |
| Retained tool, map, filter, MPI, and file-read checks | Required | Required |
| Unix Makefiles focused check | Not applicable | Required |

Validation must distinguish an unavailable external prerequisite from a
product defect. Because Profiles A and B define Stage 4 acceptance, a missing
required MPI or compression prerequisite is a blocker until supplied or the
user explicitly revises the acceptance contract; it is not an automatic
deferral.

## Stop Conditions

Stop the affected batch and record the finding if any of the following occurs:

- a core C installed declaration, exported symbol, file-format behavior, or
  retained tool changes without explicit approval;
- any of the 147 audited HighFive C function dependencies disappears or its
  required installed header/package path breaks;
- a tool other than the HL-owned `h5watch` is removed as collateral damage;
- implementation requires integrating HighFive into the HDF5 product or
  retaining a native C++/HL compatibility shim;
- Profile A or B requires silently weakening its requested feature set;
- parallel plus thread safety must be promoted from unsupported to supported
  to proceed;
- a retained out-of-tree consumer or package route loses its core target;
- an unclassified reference or generated artifact remains.

## Commit Boundaries

Every repository modification must follow the Local Atomic History rules
above. Use separate local commits for the baseline/results scaffold, HL
removal, native C++ removal, package/consumer normalization,
documentation/release changes, and portable validation evidence. Each commit
must be independently revertible and buildable for its affected configuration.
Do not combine mass deletion with unrelated formatting or modernization.

Before each commit, run `git diff --check`, the narrowest relevant configure,
build, and test gates, and verify that no generated build, install, package,
log, IDE, or temporary HighFive checkout enters the commit.

## Completion Criteria

Roadmap Stage 4 is complete only when:

1. `c++/` and `hl/` and all active product contracts listed in this plan are
   gone from the tracked source and generated product surfaces.
2. Both acceptance profiles and the default product pass their required
   dual-platform gates.
3. Core C headers, API/ABI, file-format behavior, retained tools, and all 147
   audited HighFive dependencies remain available.
4. HighFive-style consumers compile, link, and run using the workspace headers
   without HighFive being integrated into the HDF5 build or package.
5. Positive retained-contract evidence and negative removed-contract evidence
   are recorded in a portable results document.
6. The residual audit has no unresolved active reference.
7. `REFACTORING_PROGRESS.md` names the implementation anchor and an accurate
   next continuation point.

All roadmap work after Stage 4 remains cancelled from the active roadmap and
is recorded only as future plan to be determined.
