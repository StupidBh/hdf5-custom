# Native C++ and High-Level Product Removal Results

## Status

- State: Complete
- Plan approval: 2026-09-06
- Execution baseline: `72e36a522bf2f4f2c272f0edae14705139e35deb`
- Pre-removal stabilization anchor: `3118d8c2c`
- Removal implementation anchor: `81dff5168`
- Product-matrix source anchor: `55bad410b`
- Post-matrix audit-input anchor: `c461ae3e8`
- Work Package 4A: Complete
- Work Package 4B: Complete
- Work Package 4C: Complete
- Work Package 4D: Complete
- Work Package 4E: Complete
- Work Package 4F: Complete
- Plan: [NativeCppHlRemoval.md](NativeCppHlRemoval.md)
- Portable handoff: [../../REFACTORING_PROGRESS.md](../../REFACTORING_PROGRESS.md)
- Required `HDF_TEST_EXPRESS`: `3`
- Maximum combined build and CTest parallelism: 4 per physical host

The user approved removal of the native C++ and complete high-level products
on 2026-09-06. Approval does not include HighFive integration, a compatibility
shim, a core C API or ABI change, a retained-tool removal, or a file-format
change. Work Packages 4A through 4F are closed. The complete HL product is
removed at `c62d134e5`, and the native C++ product is removed at `3dc988a48`.

## Baseline Identity

The selected execution baseline is
`72e36a522bf2f4f2c272f0edae14705139e35deb`. Its tracked tree was clean at
selection time. The pre-removal stabilization commits through `3118d8c2c`
repair and cover Windows/MS-MPI failures without changing the planned HL or
native C++ product boundary. Untracked `.codex/`, `.idea/`, and `highfive/`
entries are excluded from the product baseline and all implementation commits.

The workspace `highfive/` header tree was an untracked, content-pinned audit
and consumer input through the product-matrix source anchor. It was subsequently
tracked at `c461ae3e8`, after the Stage 4 product changes, without any HDF5
CMake, source, test, install, export, or binary-package wiring. The final
HighFive consumers use that tracked 3.3.0 content.

## Qualified Validators

| Component | Windows baseline | Linux baseline |
| --- | --- | --- |
| Target system | Windows 11 10.0.26100 | Ubuntu 26.04.1 under WSL2 |
| Architecture | x64 | x86_64, glibc 2.43 |
| Compiler | MSVC 19.51.36256, toolset 14.51.36231 | GCC/G++ 15.2.0 |
| CMake and CTest | 4.4.3 | 4.2.3 |
| Primary generator | Visual Studio 18 2026 | Ninja 1.13.2 |
| Secondary generator | Not applicable | GNU Make 4.4.1 focused check |
| MPI | Microsoft MPI SDK and runtime 10.1 | Open MPI 5.0.10 |
| zlib | User-supplied 1.3.2 prefix | Isolated user-local 1.3.1 prefix |
| libaec/SZIP | User-supplied 1.1.7 prefix | Isolated user-local 1.1.5 prefix |
| State | Qualified | Qualified |

Windows compiler invocations use `CL=/utf-8`. Windows and WSL workloads ran
sequentially, with no build or CTest job count above four. Work Packages 4A
through 4D used normal PowerShell and WSL terminals while CLion MCP was
unavailable. Work Packages 4E and 4F used the active CLion MCP service for
repository navigation, short build/test commands, diagnostics, and audits;
long complete builds and full CTest runs used persistent terminal sessions
because the MCP terminal has a bounded execution timeout. All generated output
remains outside the tracked source tree.

## Work Package 4A Inventory

The exact removal-owned path inventory contains 119 tracked paths below `hl/`,
78 below `HDF5Examples/C/HL`, and 4 below `HDF5Examples/CXX/HL`. The native
`c++/` tree contains 96 tracked paths and is reserved for Work Package 4C.

The 22 tracked `.cpp` files outside `c++/` and `hl/` have no unclassified
entries:

- one HL consumer, `HDF5Examples/CXX/HL/packet_table_FL.cpp`, belongs to 4B;
- sixteen native C++ examples under `HDF5Examples/CXX/H5D` and
  `HDF5Examples/CXX/TUTR` belong to 4C;
- five configuration/API-driver implementation files are retained
  infrastructure or retained test implementations.

The 4B contract ledger includes `HDF5_BUILD_HL_LIB`, `H5_INCLUDE_HL`, the
HL-only dimension-scale reference option and generated macro, the HL C and C++
targets, `h5watch`, eight installed HL headers, `hdf5_hl.pc`,
`hdf5_hl_cpp.pc`, CMake package components `HL` and `CXX_HL`, the compiler
wrapper's implicit HL link and `-nohl` switch, HL install/package components,
and all HL example routing. `src/H5HL*` is the retained core local-heap package,
not the removable high-level product. Generic uses of "high-level" that
describe retained core I/O are also not removal evidence.

## Baseline Matrix

| Pair and configuration | Configure/build | CTest | Install/package and contract |
| --- | --- | --- | --- |
| Windows default Release | Pass | 2,816 enabled passed; 37 disabled of 2,853 | Pass; contract frozen |
| Windows C++ inventory Release | Pass | Focused contract tests pass | Pass; inventory frozen |
| Windows Profile A | Pass | Baseline exceptions below | Pass; profile frozen |
| Windows Profile B | Pass | 3 explained failures; 10 disabled of 3,197 | Pass; profile frozen |
| Linux default Release | Pass | 2,818 enabled passed; 37 disabled of 2,855 | Install and inventory pass |
| Linux C++ inventory Release | Pass | Focused contract tests pass | Install/package inventory frozen |
| Linux Profile A | Pass | 3,236 enabled passed; 10 disabled of 3,246 | Profile frozen |
| Linux Profile B | Pass | 3,193 enabled passed; 10 disabled of 3,203 | Profile frozen |

The HighFive-style C++20 consumer compiled, linked, created a dataset, read it
back, and verified its values on both validators using only the retained core C
library. The workspace HighFive headers were not added to the product.

## Explained Baseline Exceptions

Windows Profile B reports `MPI_TEST_t_pmulti_dset`,
`MPI_TEST_t_select_io_dset`, and `MPI_TEST_t_filters_parallel` failures with
the Microsoft MPI "No aggregators match" diagnostic. Each reproduces on the
frozen baseline. Windows Profile A has the same failures, a baseline
`MPI_TEST_t_2Gio` access violation, and a baseline `MPI_TEST_t_pflush1` hang;
the full suite therefore uses focused reproduction rather than claiming a
clean full pass. A minimal probe also reproduces the existing HDF5/MS-MPI FAPL
hint-lifecycle failure while pure MPI probes pass. These findings are not
caused by HL removal.

Early WSL runs from the Windows-mounted source tree exposed CRLF-contaminated
test inputs in import, repack, and image tests. Rebuilding from a clean Git
archive in the Linux filesystem removed all three failures, and the clean
default and acceptance-profile suites passed as recorded above.

## Work Package 4A Gate

The path and contract inventories are complete, every external `.cpp` file is
classified, both validators and both required profiles are reproducible, the
Profile A unsupported-combination override is explicit, the core C and
HighFive-style consumer contracts are frozen, and no unexplained baseline
failure remains. Work Package 4A is complete.

## Work Package 4B Implementation

Commit `c62d134e5` removes all 119 tracked paths below `hl/`, all 78 C HL
example paths, all 4 C++ HL example paths, and the HL-dependent `h5watch` tool.
It also removes the HL build option and root wiring, target and library names,
SOVERSION data, exports, package components, pkg-config metadata, compiler-
wrapper behavior, install/CPack components, generated settings, examples,
tests, CI assumptions, and current product documentation.

The implementation deliberately retains the native `c++/` tree and the core
local-heap `src/H5HL*` package. No native C++ source path was deleted. The core
C library, retained tools, file-format behavior, and HighFive audit input were
not expanded or redesigned.

## Work Package 4B Validation

| Pair and configuration | Build and focused tests | Install/package contract |
| --- | --- | --- |
| Windows default Release | Complete build passed; retained core/filter/tool selection passed 19/19 with fixtures | Install and ZIP passed; no HL library, header, tool, component, or package entry |
| Windows Profile B | Static map/MPI/zlib/SZIP/tools build passed; 15/17 focused tests passed | Two MS-MPI file-aggregator failures reproduce the frozen baseline and are not removal regressions |
| Linux default Release | Complete Ninja build passed; retained core/filter/tool selection passed 15/15 with fixtures | Install and TGZ passed; exact HL artifact scans returned no matches |
| Linux Profile B | Static map/MPI/zlib/SZIP/tools build passed; focused selection passed 17/17 | Build-tree package and dependency routing passed |

All validation used `HDF_TEST_EXPRESS=3` and no build or CTest job count above
four. Windows runtime tests explicitly included the build and dependency DLL
directories in `PATH`; no missing-DLL result was accepted as test evidence.
The Windows Profile B failures were `MPI_TEST_t_pmulti_dset` and
`MPI_TEST_t_filters_parallel`, both with the previously recorded Microsoft MPI
"No aggregators match" diagnostic. `MPI_TEST_t_mpi` passed, and both failing
tests passed on Linux/Open MPI after the same HL removal.

The repository has no Map API test or non-core `H5M*` caller. Both Profile B
builds enabled `HDF5_ENABLE_MAP_API`, compiled the Map implementation, and a
standalone consumer compiled and linked its `H5M*` calls through the generated
core package target. Attempting `H5Mcreate()` with the native VOL reports its
existing unsupported optional-method result on Windows and Linux; the same
result reproduces at pre-removal anchor `3118d8c2c`. This is a frozen product
limitation, not a 4B regression or an unexplained gate failure.

A HighFive-style C++20 consumer configured, compiled, linked, created and read
back a dataset, and verified its values against both post-removal default
install trees using only the retained core C shared target. HighFive remains
untracked and is not wired into this repository.

Exact active product-contract scans found no remaining `hdf5_hl`,
`hdf5_hl_cpp`, `HDF5_BUILD_HL_LIB`, `H5_INCLUDE_HL`, `HL`/`CXX_HL` package
component, HL pkg-config, or `h5watch` contract. Remaining HL terms in release
history and deeper inherited technical prose are not live product contracts;
their final classification belongs to Work Package 4F.

## Work Package 4B Gate

The complete HL product and its active contracts are absent, retained default
and acceptance-profile builds pass, focused retained tests pass subject only
to frozen Windows/MS-MPI exceptions, post-removal installs and packages have
no HL artifact, and dual-platform retained consumers pass. Work Package 4B is
complete at `c62d134e5`.

## Work Package 4C Implementation

Commit `3dc988a48` removes all 96 tracked paths below `c++/`, the 22 native C++
example paths below `HDF5Examples/CXX`, and the native C++ API guide. It also
removes `HDF5_BUILD_CPP_LIB`, root and example wiring, native C++ targets and
exports, `H5Cpp.h` and companion installed headers, `h5c++`, C++ pkg-config and
install components, generated product settings, CI assumptions, and current
product documentation.

The five classified C++ implementation files outside the removed trees remain.
The API test driver continues to own strict C++20 configuration; dependency
scope tests retain their lower-language isolation. The core C library,
`src/H5HL*`, retained tools, file-format behavior, and untracked HighFive audit
input were not changed or integrated.

## Work Package 4C Validation

| Pair | Build and focused tests | Install/package contract | Retained C++ contract |
| --- | --- | --- | --- |
| Windows/MSVC | Default Release complete build passed; focused selection passed 12/12 with fixtures | Install, binary ZIP, and source ZIP passed; no native C++ artifact or active contract | Default C++20, C++23 preservation, dependency scope, and C++98/11/14/17 rejection passed with 2 driver compile groups |
| Linux/GNU | Default Release complete Ninja build passed; focused selection passed 12/12 with fixtures | Install, binary TGZ, and source TGZ passed; no native C++ artifact or active contract | The same retained standard matrix passed with 2 driver compile groups |

All validation used `HDF_TEST_EXPRESS=3`, and no build or CTest job count
exceeded four. The generated CMake caches, install metadata, package manifests,
and source archives contain no native C++ product path, library, header,
wrapper, component, or removed option. All 57 workflow YAML files, affected
preset JSON, and CMake preset expansion also parse successfully.

## Work Package 4C Gate

The native C++ product and its active contracts are absent, retained default
products build on both validators, focused retained tests pass, installed and
packaged trees are clean, and separately owned C++20 infrastructure retains its
dual-platform standard contract. Work Package 4C is complete at `3dc988a48`.

## Work Package 4D Implementation and Validation

Commit `81dff5168` makes both removed top-level options fail with an explicit
migration diagnostic and makes the installed CMake package reject `CXX`, `HL`,
and `CXX_HL` before loading targets or dependencies. The package exports only
the retained `static`, `shared`, `C`, and `Tools` component vocabulary.

A reusable contract harness passed on Windows/MSVC and Linux/GNU. On each
validator it covered:

- explicit rejection of `HDF5_BUILD_CPP_LIB` and `HDF5_BUILD_HL_LIB`;
- rejection of all three removed components through both build-tree and
  install-tree packages;
- compile, link, and execution of retained C consumers through both package
  routes;
- compile, link, and execution through `add_subdirectory()` and local-source
  FetchContent integration;
- compile, link, dataset write/read, and value verification for the workspace
  HighFive headers through both package routes; and
- absence of removed targets, variables, headers, libraries, pkg-config files,
  wrappers, tools, and generated contract text.

The HighFive headers remain untracked audit input and were not added to any
HDF5 build, export, install, or package surface. No contract workload exceeded
four build jobs.

## Work Package 4D Gate

All retained consumer routes pass and every removed option, component, target,
variable, and artifact check has the expected dual-platform result. Work
Package 4D is complete at `81dff5168`.

## Work Package 4E Product Matrix

All six required Release configurations were built from a clean Git archive
at `55bad410b`, with `HDF_TEST_EXPRESS=3` and no build or CTest job count above
four. Configure, complete build, install, and native binary package generation
passed for every row.

| Pair and configuration | Registered | CTest-pass classification | Failed | Disabled | Skipped |
| --- | ---: | ---: | ---: | ---: | ---: |
| Windows default | 2,770 | 2,733 | 0 | 37 | 0 |
| Windows Profile A | 3,157 | 3,143 | 4 | 10 | 0 |
| Windows Profile B | 3,114 | 3,101 | 3 | 10 | 0 |
| Linux default | 2,772 | 2,735 | 0 | 37 | 0 |
| Linux Profile A | 3,163 | 3,153 | 0 | 10 | 0 |
| Linux Profile B | 3,120 | 3,110 | 0 | 10 | 0 |

The four Windows Profile A failures are the frozen
`MPI_TEST_t_pmulti_dset`, `MPI_TEST_t_select_io_dset`,
`MPI_TEST_t_filters_parallel`, and `MPI_TEST_t_2Gio` baseline exceptions. Its
`MPI_TEST_t_pflush1` case also reproduced the frozen hang; targeted termination
produced the expected nonzero result for its `WILL_FAIL` property, so CTest
classified that case as passed even though it did not complete normally. The
three Windows Profile B failures are the frozen `MPI_TEST_t_pmulti_dset`,
`MPI_TEST_t_select_io_dset`, and `MPI_TEST_t_filters_parallel` exceptions. No
new or unexplained failure occurred. Both Linux/Open MPI profiles passed every
enabled test, including the corresponding parallel I/O cases.

| Pair and configuration | Install entries | Binary-package entries | Removed-product matches |
| --- | ---: | ---: | ---: |
| Windows default | 107 | 107 | 0 |
| Windows Profile A | 105 | 105 | 0 |
| Windows Profile B | 103 | 103 | 0 |
| Linux default | 104 | 107 | 0 |
| Linux Profile A | 102 | 105 | 0 |
| Linux Profile B | 100 | 103 | 0 |

The Linux Unix Makefiles row configured successfully and built the selected
static and shared core libraries, API driver, cross-platform reader, `h5dump`,
and retained C example. Its focused API selection passed 8/8, the cross-read
fixture group passed 3/3 after explicitly building its documented
`HDF5_TEST_LIB_files` prerequisite, and the C example group passed 2/2.

Standalone Map consumers compiled, linked, and passed 1/1 against both shared
Profile A and static Profile B installs on both validators. They confirmed the
existing native-VOL unsupported optional-method result. One initial Linux
launch omitted the libaec runtime directory and could not load `libsz.so.2`;
the correctly provisioned gate passed and the setup-only result is not product
evidence.

The complete package/consumer harness passed on both validators. Its final
Linux repetition covered build-tree and install-tree C consumers, removed
option and component rejection, `add_subdirectory()`, local FetchContent, and
two HighFive dataset write/read consumers. The matching Windows harness passed
the same routes. Full suites and focused checks jointly cover retained C
examples, API drivers, tools, filters, MPI/parallel, Profile A thread safety,
and cross-platform file reads.

## Work Package 4E Gate

Every required matrix row is complete. All deviations are identical to frozen
Windows/MS-MPI exceptions, every retained consumer route passes, and no removed
product artifact or contract appears in a build, install, export, binary
package, or consumer surface.

## Work Package 4F Residual Audit

The final active-file search covers deleted directories, options, components,
targets, headers, libraries, wrappers, examples, and `h5watch`. Active matches
remain only in the deliberate top-level rejection and the negative contract
harness. Matches in `hdf5_1_8.dox`, the versioned software-change documents,
release history, and this execution record are historical facts rather than
live product claims. No unclassified active reference remains.

The Work Package 4A retained-contract comparison produced these exact results:

- Windows `dumpbin` export sets are identical at 3,964 core C symbols, and
  Linux `nm -D` export sets are identical at 4,060 core C symbols.
- Core `src/H5*.c` implementation files, cross-platform reader sources, and
  cross-platform fixtures have no diff from `3118d8c2c`.
- The common installed core header set is preserved. The only removed default
  install headers are the eight frozen HL headers; edits in retained public
  headers remove HL documentation references without changing declarations.
- The default install library-name delta contains only the four HL library
  files, the retained-tool delta contains only `h5watch`, and the installed
  export-target delta contains only `hdf5_hl-shared` and `h5watch`.
- The default CTest inventory removes 83 tests and adds none; all 83 are frozen
  HL example, HL library, or `h5watch` tests. Native C++ test deltas were
  separately frozen and closed by Work Package 4C.
- Re-extraction from the final HighFive 3.3.0 headers yields the same 147 HDF5
  C function dependencies as the audited table, with no missing or extra name.

After the full product matrix, `1aa4282c3` added repository-local copies of the
already qualified Windows dependency inputs and `c461ae3e8` tracked the audited
HighFive headers. The diff from `55bad410b` to that audit-input anchor contains
only `3rdparty/**` and `highfive/**`; no CMake, HDF5 source, test, example,
install, export, package-definition, or current product-documentation input
changed. These additions therefore do not alter the validated HDF5 product
graph. HighFive remains absent from HDF5 targets, installs, exports, and native
binary packages.

## Work Package 4F Gate

Every removed contract has positive absence evidence, every frozen retained
contract has passing evidence, and the residual search has no unresolved active
reference. Roadmap Stage 4 is complete.

## Next Continuation Point

No roadmap Stage 4 work remains. Roadmap Stages 5 through 7 have no approved
scope and remain future plan to be determined. Resume the separately paused
CMake modernization only after explicit direction and from its own recorded
anchor; do not infer a HighFive integration project from this completed removal
stage.
