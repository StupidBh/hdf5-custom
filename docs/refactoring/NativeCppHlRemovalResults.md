# Native C++ and High-Level Product Removal Results

## Status

- State: In progress
- Plan approval: 2026-09-06
- Execution baseline: `72e36a522bf2f4f2c272f0edae14705139e35deb`
- Pre-removal stabilization anchor: `3118d8c2c`
- Removal implementation anchor: None
- Work Package 4A: Complete
- Work Package 4B: Ready to implement
- Work Packages 4C through 4F: Not started
- Plan: [NativeCppHlRemoval.md](NativeCppHlRemoval.md)
- Portable handoff: [../../REFACTORING_PROGRESS.md](../../REFACTORING_PROGRESS.md)
- Required `HDF_TEST_EXPRESS`: `3`
- Maximum combined build and CTest parallelism: 4 per physical host

The user approved removal of the native C++ and complete high-level products
on 2026-09-06. Approval does not include HighFive integration, a compatibility
shim, a core C API or ABI change, a retained-tool removal, or a file-format
change. Work Package 4A is closed; Work Package 4B may remove only the complete
HL product and its contracts.

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

## Next Continuation Point

Execute Work Package 4B only: remove the complete `hl/` product, its examples,
and all active build, install, export, package, wrapper, settings, tool, test,
and current-documentation contracts. Preserve `src/H5HL*`, the native `c++/`
tree, retained tools, core C API/ABI, and file-format behavior. Stop before
Work Package 4C.
