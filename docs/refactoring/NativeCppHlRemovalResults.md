# Native C++ and High-Level Product Removal Results

## Status

- State: In progress
- Plan approval: 2026-09-06
- Execution baseline: `72e36a522bf2f4f2c272f0edae14705139e35deb`
- Pre-removal stabilization anchor: `3118d8c2c`
- Removal implementation anchor: `81dff5168`
- Work Package 4A: Complete
- Work Package 4B: Complete
- Work Package 4C: Complete
- Work Package 4D: Complete
- Work Packages 4E and 4F: Not started
- Plan: [NativeCppHlRemoval.md](NativeCppHlRemoval.md)
- Portable handoff: [../../REFACTORING_PROGRESS.md](../../REFACTORING_PROGRESS.md)
- Required `HDF_TEST_EXPRESS`: `3`
- Maximum combined build and CTest parallelism: 4 per physical host

The user approved removal of the native C++ and complete high-level products
on 2026-09-06. Approval does not include HighFive integration, a compatibility
shim, a core C API or ABI change, a retained-tool removal, or a file-format
change. Work Packages 4A through 4C are closed. The complete HL product is
removed at `c62d134e5`, and the native C++ product is removed at `3dc988a48`.

## Baseline Identity

The selected execution baseline is
`72e36a522bf2f4f2c272f0edae14705139e35deb`. Its tracked tree was clean at
selection time. The pre-removal stabilization commits through `3118d8c2c`
repair and cover Windows/MS-MPI failures without changing the planned HL or
native C++ product boundary. Untracked `.codex/`, `.idea/`, and `highfive/`
entries are excluded from the product baseline and all implementation commits.

The workspace `highfive/` header tree remains an untracked, content-pinned
audit and consumer input. It is not part of the HDF5 build, installation,
exports, source package, or binary package.

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
sequentially, with no build or CTest job count above four. The CLion MCP
service was unavailable, so validation used normal PowerShell and WSL
terminals. Build, install, package, contract, and evidence outputs remain
outside the tracked source tree.

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

## Next Continuation Point

Resume at Work Package 4E only. Confirm implementation anchor `81dff5168` and a
clean tracked worktree, then execute clean default, Profile A, Profile B, Unix
Makefiles, focused feature, cross-platform read, package, and HighFive consumer
validation on both retained pairs. Preserve `src/H5HL*`, retained tools, core C
API/ABI, file-format behavior, and the untracked HighFive audit input. Do not
redo Work Packages 4B through 4D unless their frozen contracts change.
