# Native C++ and High-Level Product Removal Results

## Status

- State: In progress
- Plan approval: 2026-09-06
- Execution baseline: `72e36a522bf2f4f2c272f0edae14705139e35deb`
- Implementation anchor: None
- Work Package 4A: In progress
- Work Packages 4B through 4F: Not started
- Plan: [NativeCppHlRemoval.md](NativeCppHlRemoval.md)
- Portable handoff: [../../REFACTORING_PROGRESS.md](../../REFACTORING_PROGRESS.md)
- Required `HDF_TEST_EXPRESS`: `3`
- Maximum combined build and CTest parallelism: 4 per physical host

The user approved removal of the native C++ and complete high-level products
on 2026-09-06. Approval does not include HighFive integration, a compatibility
shim, a core C API or ABI change, a retained-tool removal, or a file-format
change. Work Package 4A must pass before Work Package 4B changes the product.

## Baseline Identity

The selected execution baseline is
`72e36a522bf2f4f2c272f0edae14705139e35deb`. Its tracked tree was clean at
selection time. Untracked `.codex/`, `.idea/`, and `highfive/` entries and the
then-untracked planning documents were excluded from the product baseline.
The planning documents are tracked by the baseline scaffold commit, but that
commit changes no C/C++ source, header, CMake implementation, test, example,
install, or package behavior.

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
| Secondary generator | Not applicable | GNU Make 4.4.1 |
| MPI | Microsoft MPI SDK and runtime 10.1 | Open MPI 5.0.10 |
| zlib | User-supplied 1.3.2 prefix | Isolated user-local 1.3.1 prefix |
| libaec/SZIP | User-supplied 1.1.7 prefix | Isolated user-local 1.1.5 prefix |
| State | Qualified; product baselines pending | Qualified; product baselines pending |

Windows compiler invocations use `CL=/utf-8`. Windows and WSL workloads run
sequentially so their active build and CTest job counts never exceed four in
aggregate. The CLion MCP service is not exposed in the current execution
session, so Work Package 4A uses normal PowerShell and WSL terminals. Build,
install, package, contract, and evidence outputs remain outside the tracked
source tree.

The compression and MPI inputs are external validator dependencies, not HDF5
source or product additions. Each profile will record the CMake discovery
result and exact dependency version. Profile A will retain the explicit
`HDF5_ALLOW_UNSUPPORTED=ON` override for parallel plus thread safety.

## Work Package 4A Inventory

Initial tracked-path regeneration confirms 96 paths below `c++/` and 119 below
`hl/` at the execution baseline. There are 22 tracked `.cpp` files outside
those trees. Exact source, option, target, test, install, export, package,
wrapper, settings, example, documentation, and external `.cpp` classifications
will be recorded here before the 4A gate is closed.

## Baseline Matrix

| Pair and configuration | Configure | Build | Full CTest | Install/package | Contract freeze |
| --- | --- | --- | --- | --- | --- |
| Windows default Release | Pending | Pending | Pending | Pending | Pending |
| Windows C++ inventory Release | Pending | Pending | Focused pending | Pending | Pending |
| Windows Profile A | Pending | Pending | Pending | Pending | Pending |
| Windows Profile B | Pending | Pending | Pending | Pending | Pending |
| Linux default Release | Pending | Pending | Pending | Pending | Pending |
| Linux C++ inventory Release | Pending | Pending | Focused pending | Pending | Pending |
| Linux Profile A | Pending | Pending | Pending | Pending | Pending |
| Linux Profile B | Pending | Pending | Pending | Pending | Pending |

No `Pending` row is completion evidence. Work Package 4A closes only after the
full dual-platform default and acceptance-profile baselines, exact inventories,
core C contract freeze, cross-platform reads, and HighFive-style consumer
contract have passed without an unexplained failure.

## Next Continuation Point

Generate clean source snapshots from the selected execution baseline. Capture
the default and C++-enabled product inventories, then execute the default,
Profile A, and Profile B build and test baselines on Windows/MSVC and
Linux/GNU. Do not begin Work Package 4B until the complete 4A gate passes.
