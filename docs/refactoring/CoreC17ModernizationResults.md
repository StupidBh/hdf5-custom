# Stage 5 Core C17 Internal Modernization Results

## Status

- State: Active; Rounds 1 through 4 and R5-5A are complete; later Stage 5 rounds remain unselected.
- Execution date: 2026-09-09.
- Original Stage 5 source anchor: `dd7204035`.
- Preceding accepted product anchor: `81dff5168`.
- R1-5A evidence anchor: `bd6de77dd`.
- Round 1 implementation anchor: `2a966388e`.
- R2-5A planning source anchor: `c3f97252e`.
- R2-5B pilot implementation anchor: `6851af92b`.
- R2-5D implementation anchor: `fb09d9fc9`.
- R3-5A planning source anchor: `a13ae7c8a`.
- R3-5B implementation anchor: `a206f0a6e`.
- Detailed plan: [CoreC17Modernization.md](CoreC17Modernization.md).
- Fixed external interface audit:
  [HighFiveHDF5ApiDependencyAudit.md](HighFiveHDF5ApiDependencyAudit.md).
- R4-5A evidence anchor: `c6421eac6`.
- R4-5B implementation anchor: `720d882ee`.
- R5-5A planning/implementation date: 2026-09-19.
- R5-5A implementation anchor: `74a8f0b79`.
- Current continuation: preserve the completed R5-5A evidence and select a future bounded candidate only after a new 5A freeze.

The tracked product sources, tests, examples, and CMake definitions at
`dd7204035` are byte-identical to `81dff5168`. The intervening tracked changes
are documentation and the separately owned `3rdparty/` and `highfive/` inputs.
Round 1 therefore uses `dd7204035` as both its original Stage 5 implementation
baseline and its comparison anchor. There is no preceding Stage 5 round.

## R1-5A Frozen Contracts

### Installed Headers

The default install on each validator contains this same case-sensitive master
inventory of 57 retained public headers:

`H5ACpublic.h`, `H5api_adpt.h`, `H5Apublic.h`, `H5Cpublic.h`, `H5Dpublic.h`,
`H5Epubgen.h`, `H5Epublic.h`, `H5ESdevelop.h`, `H5ESpublic.h`, `H5FDcore.h`,
`H5FDdevelop.h`, `H5FDdirect.h`, `H5FDfamily.h`, `H5FDhdfs.h`, `H5FDioc.h`,
`H5FDlog.h`, `H5FDmirror.h`, `H5FDmpi.h`, `H5FDmpio.h`, `H5FDmulti.h`,
`H5FDonion.h`, `H5FDpublic.h`, `H5FDros3.h`, `H5FDsec2.h`,
`H5FDsplitter.h`, `H5FDstdio.h`, `H5FDsubfiling.h`, `H5FDwindows.h`,
`H5Fpublic.h`, `H5Gpublic.h`, `H5Idevelop.h`, `H5Ipublic.h`, `H5Ldevelop.h`,
`H5Lpublic.h`, `H5MMpublic.h`, `H5Mpublic.h`, `H5Opublic.h`, `H5overflow.h`,
`H5PLextern.h`, `H5PLpublic.h`, `H5Ppublic.h`, `H5pubconf.h`, `H5public.h`,
`H5Rpublic.h`, `H5Spublic.h`, `H5Tdevelop.h`, `H5Tpublic.h`, `H5TSdevelop.h`,
`H5version.h`, `H5VLconnector_passthru.h`, `H5VLconnector.h`, `H5VLnative.h`,
`H5VLpassthru.h`, `H5VLpublic.h`, `H5Zdevelop.h`, `H5Zpublic.h`, and `hdf5.h`.

The inventory comes from the actual default CMake install, including headers
whose declarations are feature-conditional. Round configurations do not remove
entries from this master list. Full content manifests were recorded separately
per platform because generated configuration is platform-specific:

| Validator | Header count | Content-manifest SHA-256 |
| --- | ---: | --- |
| Windows x64/MSVC | 57 | `ae6a2e1f102dff78fcb00f371fa85a5c9e5f4aa580f2eafe3ef35eff7b0987f7` |
| Linux x86_64/GNU | 57 | `bd55edfe1652c27d6eb5a4b54b442fe37b6a382f93d9245064851ac8f6c4b2f5` |

The four generated-header hashes are:

| Header | Windows SHA-256 | Linux SHA-256 |
| --- | --- | --- |
| `H5pubconf.h` | `7b29c3c37944d66b712b526052f68fd05e2113e6b478e06cae696e86d421527f` | `395e71f6e39fdfff4f358a0a3d72e417105c29679bf2e895836cf6ee0ef3b6b1` |
| `H5version.h` | `64eda5b44a9d34fb62cfaa86306c59c87ed2a8e7e0b6a32f0bb02fb9d409dfc3` | same |
| `H5Epubgen.h` | `b22e449c2ee989aa3ea32148ff82723843aab3aa1fbd6288c8a07527d7248239` | same |
| `H5overflow.h` | `c8551089e317d801e83375b7ad222a8e5bbbe60547a2f691e7bd0356d25142be` | same |

No installed header is in the Round 1 edit set.

### ABI, Exports, and Layouts

The case-sensitive default shared-library export baselines are:

| Validator | Export count | Sorted-name manifest SHA-256 |
| --- | ---: | --- |
| Windows x64/MSVC `dumpbin /exports` | 3,964 | `399424dc5c5b51dd9d7a3f0584fe153fccd0ad250083f43820cafd0b37f8e5d0` |
| Linux x86_64/GNU `nm -D --defined-only` | 4,060 | `5cc9627d28b615df09e1a4bf879f9fa9b1feec7abbec3cdc1c4f95f3998fb673` |

Both validators export `H5_dirname` and `H5_basename`. Their frozen declarations
are `herr_t H5_dirname(const char *path, char **dirname)` and
`herr_t H5_basename(const char *path, char **basename)`, with `H5_DLL` on the
declarations in `H5private.h`. Round 1 does not change either declaration,
calling convention, visibility, return type, or ownership contract. Proposed
helpers have file-local `static` linkage and must not enter either export set.

The selected functions pass strings and output pointers and expose no associated
structure layout. Their associated-layout disposition is `NOT_APPLICABLE`.
The inherited x64 public layout anchors remain 8-byte size/alignment for `hid_t`,
`hsize_t`, and `haddr_t`, and 24/80/40/72-byte size with 8-byte alignment for
`H5A_info_t`, `H5F_info2_t`, `H5L_info2_t`, and `H5O_info2_t`. The R1-5E
installed C17 probes rechecked these anchors on both validators.

### HighFive Compatibility Floor

The exact 147-function table and its types, constants, callbacks, headers, and
feature guards remain frozen at audit manifest
`25c7d5e69a69c446b8024941465449b51c9a62c2eb3ce2f981babd9fa6137910`.
The package counts remain General 1, H5A 13, H5D 14, H5E 7, H5F 9, H5G 4,
H5I 6, H5L 9, H5O 6, H5P 36, H5R 2, H5S 13, H5T 26, and H5Z 1.

None of the 147 names maps to `H5_dirname`, `H5_basename`, or the proposed
file-local helpers. The fixed table nevertheless remains in the final declaration
and link consumer gate. The default API is v200. Separate existing API-version
tests cover `H5_USE_16_API`, `H5_USE_18_API`, `H5_USE_110_API`,
`H5_USE_112_API`, `H5_USE_114_API`, and `H5_USE_200_API`. In the mappings
relevant to the audit, H5L information/iteration aliases select version 1 through
v110 and version 2 from v112 onward; `H5Oget_info` selects version 1 through
v110 and version 3 from v112 onward; `H5Rdereference` selects version 1 through
v18 and version 2 from v110 onward. Conditional MPI and compression entries are
checked only in configurations that provide those features, without weakening
their declaration or export protection.

### Product and Test Inventories

The default Windows install has 101 regular files and 20 exported CMake targets;
its content-manifest hash is
`ba114c313782db511619d5920a0677fa832b62f9d179e414e052f1a716c3d4a6`.
The default Linux install has 90 regular files, four symlinks, and the same 20
target names; its content-manifest hash is
`5cb311405734b1d5b4286466fba1e28d153dd8b5a1174a304c4275d03933d8da`.
The targets are the shared and static core/tool libraries plus the 16 retained
tools from `h5clear` through `h5unjam` recorded by the installed CMake exports.

The Windows default CTest inventory has 2,770 registrations and sorted-name hash
`b3da0b8c04fc94caa8c736120f3e03c4139c567a7b093d157d67cb10bf84a99d`.
The Linux default has 2,772 registrations and hash
`40c6b5b3a5216c9586edc02ec2c588a3b939f1ffc3abf616fa38cf94dc092ee8`.
R1-5E compares like-platform inventories; platform differences are not deltas.

## R1 Candidate Ledger

| ID | Package/functions | Decision | Evidence and scope |
| --- | --- | --- | --- |
| `R1-P1` | `H5system.c`: `H5_dirname`, `H5_basename` | `SELECTED` | Extract the duplicated reverse separator scans into typed, const-correct, file-local helpers and make the local `H5_dirname` scan pointer const. Preserve all allocations, errors, branches, results, and signatures. Existing `th5_system.c` cases cover null outputs, empty paths, roots, repeated leading/trailing separators, normal paths, and contrived paths. |
| `R1-D1` | `H5MM.c`, `H5VM.c` | `DEFER` | Shared reach, allocator/ownership contracts, and hot-path sensitivity exceed a pilot round. |
| `R1-D2` | checksum/encoding helpers | `DEFER` | File-format and performance risk require a separately selected round. |
| `R1-D3` | `H5PLpath.c` | `DEFER` | Global plugin path state, resource ownership, and Windows environment behavior need dedicated characterization. |
| `R1-D4` | `H5RS.c`, `H5SL.c` | `DEFER` | Shared ownership and container invariants are unsuitable for the pilot. |
| `R1-D5` | `H5_get_option` const diagnostic | `DEFER` | The GNU baseline reports a separate discarded-qualifier warning, but it is unrelated to the selected path-component transformation. |

The only production callers of the selected functions are in the subfiling/IOC
VFD implementation. The Linux parallel subfiling tests are therefore an indirect
feature gate. No public API, VOL dispatch, filter routing, on-disk encoding,
allocator, lock, callback, or error construction layer is changed. The reverse
loops execute the same comparisons, so no performance experiment is warranted.

R1-5C is `NOT_APPLICABLE`: the selected transformation neither acquires nor
releases resources and does not alter function cleanup structure. R1-5D is
`NOT_APPLICABLE`: no follow-on function is admitted to this pilot round.

## R1-5A Environment and Baseline

| Validator | Toolchain | Default Release result |
| --- | --- | --- |
| Windows x64 | Visual Studio 18 2026, MSVC 19.51.36256.0/toolset 14.51.36231, CMake/CTest 4.4.3 | 2,733/2,733 enabled passed; 37 disabled; 2,770 registered |
| Linux x86_64 | Ubuntu 26.04.1 under WSL, GCC/G++ 15.2.0, CMake 4.2.3, Ninja 1.13.2 | 2,735/2,735 enabled passed; 37 disabled; 2,772 registered |

All baseline suites used Release, `HDF_TEST_EXPRESS=3`, and at most six jobs.
The Windows default also used `HDF5_ENABLE_DEV_WARNINGS=ON` and `/utf-8`.
The Linux default used developer warnings and recorded the selected
`H5_dirname` discarded-qualifier diagnostic before implementation.

### System Compression Matrix

External dependency fetching was off and `HDF5_ALLOW_UNSUPPORTED` was off in
every row. Tools, zlib, SZIP, and SZIP encoding were on. The Windows rows had
Map API enabled. R3-5E later established from the retained caches that the four
Linux rows had Map API disabled despite the original record saying otherwise;
their results therefore were not Linux Map-enabled acceptance evidence. R3-5E
repeats all four rows with `HDF5_ENABLE_MAP_API=ON` and closes that gap.

| Validator/configuration | Actual dependency form | Release result |
| --- | --- | --- |
| Windows SC-A: shared HDF5 only | Repository `3rdparty/zlib` 1.3.2 and `3rdparty/libaec` 1.1.7 shared DLL/import-library form | 2,896/2,896 enabled passed; 10 disabled; 2,906 registered |
| Windows SC-B: static HDF5 only | The same supplied shared dependency form | 2,853/2,853 enabled passed; 10 disabled; 2,863 registered |
| Linux shared HDF5/shared dependencies | Distribution zlib 1.3.1 and libaec 1.1.5 shared objects | 2,898/2,898 enabled passed; 10 disabled; 2,908 registered |
| Linux shared HDF5/static dependencies | Supplied zlib 1.3.2 and libaec 1.1.7 PIC static archives | 2,898/2,898 enabled passed; 10 disabled; 2,908 registered |
| Linux static HDF5/shared dependencies | Distribution zlib 1.3.1 and libaec 1.1.5 shared objects | 2,855/2,855 enabled passed; 10 disabled; 2,865 registered |
| Linux static HDF5/static dependencies | Supplied zlib 1.3.2 and libaec 1.1.7 static archives | 2,855/2,855 enabled passed; 10 disabled; 2,865 registered |

Link inspection confirms `libz.so`/`libsz.so` dynamic dependencies in the Linux
shared-dependency rows and the selected `libz.a`, `libsz.a`, and `libaec.a`
inputs with no compression dynamic dependency in the static-dependency rows.
The distribution libaec 1.1.5 static CMake export incorrectly names shared
targets, so the static rows deliberately use the independently built supplied
archives rather than accepting a silent shared fallback.

Before every Windows compression execution, use the repository dependency bins
explicitly and verify all three runtime DLLs resolve there:

```powershell
$env:PATH = "$PWD\3rdparty\zlib\bin;$PWD\3rdparty\libaec\bin;$env:PATH"
Get-Command z.dll, aec.dll, szip.dll
```

The clean SC-A and SC-B results above were produced only after this preflight.
Earlier executions without the dependency path are environment errors and are
not product test results.

## R1 Validation Specification

- R1-5B runs `H5TEST-testhdf5-base` on Windows and Linux with the default
  configurations, then the complete existing `th5_system.c` path cases at the
  lowest practical express setting. No new legacy `testhdf5` case is added
  because the selected input and failure partitions are already covered.
- Linux Valgrind checks the focused executable. Windows and Linux Debug builds
  repeat the focused test. No sanitizer cross-product is selected because the
  transformation creates no new memory or ownership operation.
- A focused Linux GNU/Unix Makefiles build and test verifies the secondary
  supported generator. Linux parallel/subfiling tests validate the only indirect
  production caller. Extra thread-safe coverage is not selected because no
  thread, global-state, or allocator path changes.
- R1-5E reruns both complete default Release suites, both Windows compression
  suites, and all four Linux compression suites at `HDF_TEST_EXPRESS=3`, with
  the same dependency-form preflights and six-job limit.
- Equivalent installs compare the complete header, install, target, generated
  header, export, and CTest inventories frozen above. C99, C17, and C++11
  installed C-header consumers compile, link, and run; MSVC uses its supported
  language switches and does not claim a distinct strict C99 mode.
- Existing API-version tests cover v16, v18, v110, v112, v114, and v200 aliases.
  A declaration/link probe maps all exact 147 HighFive identifiers, with MPI
  entries checked in the parallel configuration and filter entries in the
  compression configurations.
- Existing cross-platform reader cases, tool golden-output cases, and generated
  example files are the representative fixture gate. No format fixture is added
  because the selected functions do not reach encoding or decoding.
- Test processes use CTest scheduling and at most six workers. MPI tests use the
  registered rank counts and are not run concurrently with another full matrix
  suite. Long-lived SWMR tests retain their registered serial/resource behavior.

R1-5A has no unexplained relevant baseline failure, all required dependencies
are available, and the selected scope and acceptance checks are frozen. Its gate
is complete.

## R1-5B Characterization and Pilot

The pilot adds `H5__path_trim_trailing_separators` and
`H5__path_component_start` as typed `static` helpers in `H5system.c`. The
existing scans in `H5_dirname` and `H5_basename` call them without changing
branch conditions, allocations, result lengths, errors, or cleanup. The local
separator pointer in `H5_dirname` is now `const char *`; the frozen declarations
in `H5private.h` are unchanged. `clang-format` 22.1.0 formatted the one modified
C file.

No new test was added to the legacy `testhdf5` aggregate. Its existing
`th5_system.c` partition already covers both null-argument failures, empty paths,
roots, paths without separators, repeated leading and trailing separators,
ordinary paths, and contrived combinations. The focused results are:

| Check | Result |
| --- | --- |
| Windows Release | Incremental MSVC build passed; `H5TEST-testhdf5-base` plus fixtures passed 3/3; direct `h5system` at express level 0 passed |
| Linux Release/Ninja | Complete build passed; `H5TEST-testhdf5-base` plus fixtures passed 3/3; direct `h5system` at express level 0 passed |
| Windows Debug | Complete default build passed; direct `h5system` at express level 0 passed after repository DLL preflight |
| Linux Debug/Ninja | Complete default build passed; direct `h5system` at express level 0 passed |
| Linux Valgrind 3.26.0 | Focused Release `h5system` passed with error exit enabled for definite/indirect leaks |
| Linux Unix Makefiles | Focused Release build and `h5system` at express level 0 passed |
| Linux Open MPI 5.0.10 | Six-rank `MPI_TEST_t_subfiling_vfd` plus fixtures passed 3/3 |

The GNU warning build no longer reports the selected discarded-qualifier
diagnostic in `H5_dirname`; the unrelated `H5_get_option` diagnostic remains as
frozen in `R1-D5`. The MSVC build reports only its pre-existing warning classes
plus informational optimizer decisions to inline the new file-local helpers.

The first Linux CTest attempt followed a target-only build and failed unrelated
array/misc cases because that target does not stage `tarrold.h5`, `tmtimeo.h5`,
and other aggregate fixtures. The directly selected `h5system` partition passed,
then a complete build staged the fixtures and the identical CTest selection
passed 3/3. This was validation-tree assembly, not a product failure.

The actual diff confirms the R1-5C `NOT_APPLICABLE` disposition: no resource is
acquired, released, or transferred and no cleanup structure changes. R1-5D is
also `NOT_APPLICABLE` because the frozen round admits no second implementation
candidate. R1-5B, R1-5C, and R1-5D are complete; R1-5E evidence follows.

## R1-5E Final Product and Compatibility Matrix

All final Release suites used `HDF_TEST_EXPRESS=3` and no more than six jobs.
Each Windows executable run first resolved `z.dll`, `aec.dll`, and `szip.dll`
from the repository `3rdparty` dependency bins. No run with an unresolved or
different DLL source is included below.

| Validator/configuration | Passed enabled | Disabled | Registered | Time |
| --- | ---: | ---: | ---: | ---: |
| Windows default | 2,733 | 37 | 2,770 | 121.18 s |
| Windows SC-A, shared HDF5/supplied shared compression | 2,896 | 10 | 2,906 | 123.93 s |
| Windows SC-B, static HDF5/supplied shared compression | 2,853 | 10 | 2,863 | 124.65 s |
| Linux default | 2,735 | 37 | 2,772 | 127.13 s |
| Linux shared HDF5/shared system compression | 2,898 | 10 | 2,908 | 135.93 s |
| Linux shared HDF5/static supplied compression | 2,898 | 10 | 2,908 | 136.89 s |
| Linux static HDF5/shared system compression | 2,855 | 10 | 2,865 | 135.56 s |
| Linux static HDF5/static supplied compression | 2,855 | 10 | 2,865 | 135.40 s |

Every row completed configure, complete Release build, full enabled CTest suite,
and install. Exact Linux registered-name and disabled-state comparisons report
zero delta for the default and all four compression rows. A separately rebuilt
Windows original-anchor default reports the same exact 2,770-name inventory and
37 disabled markers as the final build. The Windows compression totals and
disabled counts equal their frozen clean baselines; no CMake or test definition
is in the implementation diff. Expected gzip, SZIP, filter, example, and tool
tests were registered and executed in the compression suites.

The accepted Linux default uses the same configure inputs as the frozen
baseline. An earlier extra run with a custom install prefix also passed 2,735
enabled tests, but changed generated plug-in/wrapper settings and is not used
for contract equality.

### Compression, Installs, and Packages

Installed standalone C examples linked to each of the six compression package
rows, then wrote and read datasets through both `H5Z_FILTER_DEFLATE` and
`H5Z_FILTER_SZIP`. Discovery and binary inspection established these forms:

| Row | Consumer/package linkage evidence |
| --- | --- |
| Windows SC-A | `hdf5-shared`; zlib 1.3.2 and libaec 1.1.7 import libraries/DLLs |
| Windows SC-B | `hdf5-static`; the same supplied dependency import libraries/DLLs |
| Linux shared/shared | consumer needs `libhdf5.so`; it needs system `libz.so.1` and `libsz.so.2` |
| Linux shared/static | consumer needs `libhdf5.so`; it has no compression `NEEDED` entry |
| Linux static/shared | consumer directly needs system `libz.so.1` and `libsz.so.2` |
| Linux static/static | link uses `libhdf5.a`, `libz.a`, `libsz.a`, and `libaec.a`; no compression `NEEDED` entry |

The supplied libaec package selects static targets only when
`libaec_USE_STATIC_LIBS=ON`; CMake's zlib module likewise needs
`ZLIB_USE_STATIC_LIBS=ON` to select the supplied archive. The fully static
installed consumer passed with both explicit selections. Omitting them fails
the same way against the original-anchor install because the dependency config
otherwise defines shared libaec targets; this is a pre-existing downstream
selection requirement, not a Round 1 delta or an accepted silent fallback.

CPack produced ZIP packages for both Windows compression rows and TGZ packages
for all four Linux rows. Their regular-file counts are 97/95 for Windows SC-A/
SC-B and 91/91/87/87 for the four Linux rows in table order. Every package
contains the HDF5 CMake target files and zlib/libaec dependency discovery.

Default binary-package comparison also passed. The Windows baseline/final ZIPs
have the same 101 paths and byte-identical installed headers. Three source-text
entries differ only because the two Windows checkouts materialized the same Git
blobs with LF versus CRLF; their normalized text is identical. Remaining
content differences are rebuilt binaries, for which byte identity is not an
acceptance claim. The Linux baseline/final TGZs have the same 90 regular files,
four symlinks, paths, link targets, and byte-identical installed headers; only
rebuilt libraries and tools differ in content.

### Headers, ABI, Exports, and Consumers

Equivalent default installs preserve all 57 header names and contents, all 20
exported CMake target names, and the 101-file Windows and 90-file/four-symlink
Linux path inventories. The four generated-header hashes exactly equal the
R1-5A values. `H5private.h` is unchanged from the original anchor.

The final default export sets exactly match the frozen manifests: Windows has
3,964 names with hash
`399424dc5c5b51dd9d7a3f0584fe153fccd0ad250083f43820cafd0b37f8e5d0`,
and Linux has 4,060 names with hash
`5cc9627d28b615df09e1a4bf879f9fa9b1feec7abbec3cdc1c4f95f3998fb673`.
`H5_dirname` and `H5_basename` remain exported; the two new helpers do not.

Installed C99 `find_package` consumers and direct strict-C17 consumers compile,
link, run, and report HDF5 2.3.0 on both validators. C++11 consumption of the C
headers also passes with G++ `-std=c++11`; MSVC uses its lowest explicit
`/std:c++14` mode because it has no distinct C++11 switch. Separate C17 static
assertion consumers on both x64 validators rechecked the seven frozen public
size/alignment anchors and linked and ran against the final shared installs.
The existing API-version tests cover the v16, v18, v110, v112, v114, and v200
alias configurations.

The repository's retained-product integration contract script passes on both
validators. It builds and runs build-tree and install-tree `find_package`
consumers plus isolated `add_subdirectory()` and local-source `FetchContent`
consumers. HighFive is neither built nor added to the product.

### HighFive, Format, and Secondary Checks

Re-extraction of the fixed audit gives exactly 147 identifiers, all present in
the installed header closure. The default Windows library exports 135 spellings
directly. Under the default v200 mapping, `H5Lget_info`, `H5Literate`,
`H5Oget_info`, and `H5Rdereference` resolve to exported `H5Lget_info2`,
`H5Literate2`, `H5Oget_info3`, and `H5Rdereference2`. A parallel Linux library
exports each of the remaining eight collective/MPIO functions. Compression
consumers exercise `H5Pset_deflate`, `H5Pset_szip`, and filter availability.
The tracked `highfive/` tree has no change from its audit-input anchor, while
the complete header identity protects the associated types, constants,
callbacks, and feature guards.

Explicit format fixtures were created by the original and final libraries on
both platforms. Original and final `h5diff` tools on Windows and Linux read the
opposite-platform files and report semantic equality. The full suites also pass
the existing compatibility readers and tool golden-output cases. The selected
helpers do not reach encoding or decoding.

The only indirect production users are the subfiling/IOC VFD sources. The
six-rank Linux subfiling test and its fixtures passed 3/3 with Open MPI 5.0.10.
No thread/global-state/allocator path is reachable from the change, so separate
thread-safe and concurrency rows remain not applicable. Both complete Debug
builds and focused level-0 runs passed; the Windows Debug library emitted its
PDB. Valgrind 3.26.0 reported no definite/indirect leak in the focused Linux
run, and the GNU/Unix Makefiles focused build and run passed. The scans are not
a newly introduced hot path, so no performance experiment was required.

Two validation setup results were rejected rather than treated as product
evidence: a Windows run without the dependency DLL path, and concurrent Linux
examples started in one working directory that contended for the same output
files. The former was rerun after exact DLL preflight; the latter was rerun in
isolated directories without an HDF5 diagnostic. A mis-cased package hint and
the target-only Linux fixture-staging issue described above were likewise
corrected before their passing reruns.

## R1-5F Round Closeout

Round 1 is complete at implementation commit `2a966388e`, one atomic product
commit after evidence anchor `bd6de77dd`. Reverting that implementation commit
is the complete product rollback; the two helpers are file-local and no later
product commit depends on them. The original Stage 5 installed-header/API/ABI
freeze, diagnostic policy, fixed 147-entry HighFive floor, file-format contract,
and mandatory compression matrix remain unchanged for later rounds.

All selected work is implemented and every mandatory Round 1 gate passes. The
deferred candidates `R1-D1` through `R1-D5` retain their recorded dispositions;
no deferred item was silently admitted and no Stage 5 compatibility gap remains
from this pilot. Round completion does not close the multi-round Stage 5
direction.

At Round 1 closeout, R2-5A was the recorded continuation: retain original anchor
`dd7204035` and accepted Round 1 anchor `2a966388e`, then requalify the relevant
environment and characterize `H5PLpath.c` before selecting source edits. The
resulting frozen ledger and validation specification follow.

## R2-5A Frozen Scope and Baseline

### Environment Bridge and Reused Baseline

The Round 2 planning source is `c3f97252e`; its only tracked changes after
`2a966388e` are Round 1 documentation. `src/`, `test/`, `testpar/`, `tools/`,
`config/`, `HDF5Examples/`, and the top-level CMake definitions have no delta.
The `H5PLpath.c` Git blob remains
`a1eb49808cd5232fdf5a20670439535ae2763ef4`. The original anchor remains
`dd7204035`, and cumulative product comparison therefore contains only the
accepted Round 1 `H5system.c` implementation.

Relevant environment inputs are unchanged from the qualified Round 1 endpoint:

| Validator | Requalified inputs |
| --- | --- |
| Windows x64 | Visual Studio 18 2026 Insiders 18.10.12120.281, MSVC 19.51.36256/toolset 14.51.36231, CMake/CTest 4.4.3, and clang-format 22.1.0 |
| Linux x86_64 | Ubuntu 26.04.1 under WSL, GCC/G++ 15.2.0, CMake 4.2.3, Ninja 1.13.2, GNU Make 4.4.1, and Valgrind 3.26.0 |

Windows dependency preflight again resolves the repository copies of `z.dll`,
`aec.dll`, and `szip.dll` before executable validation. The supplied x64 zlib
1.3.2 and libaec 1.1.7 `.lib` files contain import descriptors and `__imp_`
members, so the mandatory Windows rows continue to use shared compression DLLs.
Their binaries and package-version inputs have the same SHA-256 values recorded
for Round 1. Linux system packages remain zlib 1.3.1 and libaec 1.1.5 with both
shared objects and archives; the pinned PIC-capable zlib 1.3.2/libaec 1.1.7
source-build inputs remain the required static-dependency form for the two
supplied-static rows. Open MPI 5.0.10 remains available for secondary Linux
parallel validation. No new prerequisite was acquired and no proxy or persistent
environment change was needed.

Under the plan's evidence-reuse rule, all eight passing Round 1 endpoint suites
are the Round 2 starting baseline: Windows default/SC-A/SC-B passed
2,733/2,896/2,853 enabled tests, and Linux default plus four compression rows
passed 2,735/2,898/2,898/2,855/2,855. Their exact registered/disabled inventories,
installs, packages, consumers, ABI/export/header checks, HighFive mapping, and
format evidence remain applicable. A new final implementation cannot reuse
those results and must run the complete mandatory matrix again.

### Frozen Contracts and Call Graph

Round 2 inherits the complete 57-header content freeze, 3,964-name Windows and
4,060-name Linux export manifests, public layouts, generated settings, install
and target inventories, C99/C17/C++ C-header consumers, API aliases, file-format
fixtures, and fixed 147-entry HighFive inventory. The protected HighFive table
does not call `H5PL` directly; its `H5Zfilter_avail` entry reaches dynamic plugin
lookup indirectly and remains in focused and compression coverage.

The relevant Windows library exports the seven public path APIs
`H5PLappend`, `H5PLprepend`, `H5PLreplace`, `H5PLinsert`, `H5PLremove`,
`H5PLget`, and `H5PLsize`; library-private `H5PL_iterate`; and all eleven
`H5PL__*` path-table functions declared in `H5PLpkg.h`. Their names and
signatures are frozen. Selected edits add no header declaration, type, public
layout, or exported helper.

The exact caller paths are:

- public path APIs -> the matching `H5PL__*` path-table wrapper -> file-local
  insertion/replacement helpers;
- package initialization/termination -> `H5PL__create_path_table` /
  `H5PL__close_path_table`;
- filter, VOL, and VFD lookup -> `H5PL_load` ->
  `H5PL__find_plugin_in_path_table` -> platform-specific directory search;
- native VOL file-open fallback -> `H5PL_iterate` ->
  `H5PL__path_table_iterate` -> platform-specific directory iteration.

The static `H5PL_paths_g` owns both its allocated pointer array and every
non-null path string. `H5PL_num_paths_g` identifies the compact owned prefix;
`H5PL_path_capacity_g` bounds the allocation. `H5PL__insert_at` and
`H5PL__replace_at` own `path_copy` until assignment transfers it to the table.
On Windows, `H5_expand_windows_env_vars` replaces that pointer only on success
and deliberately leaves the caller's original allocation unchanged on failure.
The two platform directory helpers own each temporary candidate path and their
directory enumeration handles. All state and helper types are file-local; no
associated public layout exists. Calls occur under existing HDF5 API/package
initialization serialization. Locking and global-state architecture are not
selected.

### R2 Candidate Ledger

| ID | Exact functions | Decision | Evidence, transformation, and boundary |
| --- | --- | --- | --- |
| `R2-P1` | POSIX `H5PL__path_table_iterate_process_path` | `IMPLEMENTED; 6851af92b` | A matching directory entry allocated `path` and continued without releasing it; a later matching entry overwrote the owner. Two plugin-shaped directories and the package iterator kept the preceding implementation functionally successful while Valgrind exposed two definitely lost buffers. The temporary path is now released before the existing `continue`; enumeration, callbacks, diagnostics, and handle cleanup are preserved. |
| `R2-F1` | Windows `H5PL__path_table_iterate_process_path`; Windows `H5PL__find_plugin_in_path` | `IMPLEMENTED; fb09d9fc9` | The same directory branch retained `path` across `continue`. Both Windows helpers now mirror the demonstrated pilot ownership correction. Two `.dll`-shaped directories cover iteration and a missing-filter lookup while preserving Win32 enumeration and error behavior. |
| `R2-F2` | `H5PL__insert_at`; `H5PL__replace_at` | `IMPLEMENTED; fb09d9fc9` | After `H5MM_strdup`, failed Windows environment expansion left the local copy owned by the caller but the `done` path did not release it. Both functions now release only an untransferred copy. Normal `%VAR%` expansion and over-capacity append/replace failures preserve table size and content; success results and error categories are unchanged. |
| `R2-D1` | `H5PL__expand_path_table` | `DEFECT; DEFER` | Direct assignment of `H5MM_realloc` can lose the table on allocation failure. The existing 42-path test covers successful growth, but no deterministic allocator-failure hook exists. Defer until a separately frozen test-only hook or other reliable reproducer is justified. |
| `R2-D2` | `H5PL__create_path_table` | `DEFECT; DEFER` | A failure after one or more appended tokens frees the pointer array without releasing owned entries. It shares the missing deterministic allocation-failure coverage problem with R2-D1 and is not needed for the selected pilot. |
| `R2-I1` | `H5PL__find_plugin_in_path_table` | `INVESTIGATE` | The found-path guard tests the output-parameter address rather than `*plugin_info`. Do not change it without a reproducer and plugin-return contract analysis. |
| `R2-D3` | Windows `service[2048]` construction in both directory helpers | `DEFER` | Truncation/long-path behavior is a separate user-visible path contract, not incidental ownership cleanup. |
| `R2-K1` | path-table globals; `H5PL__make_space_at`; public/package wrappers and headers | `KEEP` | Struct consolidation, lock redesign, signature changes, and unrelated index/error cleanup provide no necessary benefit to this batch and would enlarge the state or ABI risk. |

R2-P1 is the only R2-5B product edit. R2-F1 and R2-F2 may enter R2-5D only
after the pilot's R2-5C ownership evidence passes. R2-D1, R2-D2, R2-I1,
R2-D3, all remaining `H5PLpath.c` functions, and the Round 1 deferred backlog
are outside this round's implementation scope.

The selected defects change only resource retention on already-defined branches:
the public success/failure result, search order, callback order, table contents,
and major/minor errors stay unchanged. Record the correction in
`release_docs/CHANGELOG.md` with the implementation, separate from any later
behavior-preserving refactor. There is no disk serialization or format reach.
The affected code is non-hot administration/filesystem scanning; releasing one
skipped-entry allocation adds no experiment-worthy work, so no performance
benchmark is defined.

### R2 Validation Specification

- Before the pilot source edit, add the focused nested-directory coverage to
  the existing `h5test`-based `filter_plugin` target. Stage two directory names
  that pass each platform's plugin filename filter. Run it against
  `2a966388e`; require functional success and a Linux Valgrind leak. After the
  pilot require the same functional result with no definite/indirect leak.
- Run `H5PLUGIN-filter_plugin` at `HDF_TEST_EXPRESS=0` on Windows Release and
  Linux Release after every applicable implementation commit. Windows execution
  must first assert exact resolution of the repository zlib/libaec DLLs.
- R2-F1 requires Windows iterator and missing-filter directory coverage. R2-F2
  additionally requires Windows `%VAR%` append/replace success and over-capacity
  failure with unchanged table state. Linux compiles and runs the shared test
  source but does not pretend to exercise Win32 expansion.
- R2-5C maps every selected local allocation, transfer, `continue`, `done`
  cleanup, and directory handle. Allocation-failure branches without a reliable
  hook retain the explicit R2-D1/R2-D2 deferral rather than an untested edit.
- Complete Debug builds and focused plugin runs are required on both validators.
  Run the focused Linux target and test with Unix Makefiles. Run focused legal
  thread-safe builds on both validators because the table is global, plus Linux
  parallel filter/VOL/VFD plugin coverage. No lock behavior is changed.
- Final R2-5E repeats Windows default/SC-A/SC-B and Linux default plus all four
  compression-linkage full Release suites at express level 3 and at most six
  jobs. It also repeats installs/packages, filter write/read, linkage proof,
  installed consumers, integration styles, headers/exports/signatures/layouts,
  exact test inventories, HighFive evidence, and cross-platform format reads
  against both `dd7204035` and `2a966388e` where applicable.
- Major builds run serially across Windows and WSL. Focused ordinary CTest uses
  at most six workers; MPI work accounts for registered ranks and runs apart
  from full suites. No helper process is allowed to outlive its validation row.

The current endpoint has no unexplained relevant baseline failure, all mandatory
dependencies are available, exact selection and checks are frozen, and no
product source has been edited. R2-5A is complete.

## R2-5B Characterization and POSIX Pilot

The focused `filter_plugin` fixture now creates two plugin-shaped directory
entries in its first search directory and invokes the package path iterator
before the existing path API test empties the table. Against the preceding
implementation, `H5PLUGIN-filter_plugin` passed functionally on both retained
validators at `HDF_TEST_EXPRESS=0`. Linux CTest Memcheck nevertheless reported
one defect: 162 bytes in two blocks were definitely lost from
`H5PL__path_table_iterate`, exactly matching the two staged directories.

Implementation anchor `6851af92b` releases the per-entry `path` allocation
before the POSIX directory branch continues. The qualifying Windows build used
command-scoped `CL=/utf-8`; its focused Release test passed 1/1 after exact
preflight resolution of the repository `z.dll`, `aec.dll`, and `szip.dll`.
The Linux Ninja Release test also passed 1/1. Both used
`HDF_TEST_EXPRESS=0`. The repeated Linux CTest Memcheck run reported zero bytes
in zero blocks at exit, all 152,654 allocations freed, and zero errors. No new
compiler warning is attributable to the one-line ownership correction.

The implementation changes no public or package signature, export, table
content, callback order, plugin search order, diagnostic frame, or handle
cleanup. The test adds only build-tree directories and a package-friend callback;
no installed artifact or file-format path changes. R2-5B is complete.

## R2-5C Resource and Function Structure

The pilot ownership audit covers every exit after the POSIX iterator acquires
resources:

- `H5MM_calloc` gives the current loop iteration sole ownership of `path`.
  A regular file releases it at the loop tail; stat/open/callback failure and
  callback stop reach `done`, which releases the current value.
- A directory neither transfers nor exposes `path`. The new release occurs
  before `continue`; `H5MM_xfree` returns null, so later cleanup cannot double
  release it.
- `HDopendir` gives the function ownership of `dirp`; every post-open exit still
  reaches the unchanged `HDclosedir` cleanup. The edit does not alter handle
  lifetime or error ordering.
- Plugin metadata remains owned by the plugin cache/opening layer. The iterator
  callback receives borrowed values, and the pilot does not change that
  ownership.

The Windows iterator and lookup directory branches retain the demonstrated
symmetrical defect and are admitted as R2-F1. The untransferred Windows
environment-expansion copies in insertion and replacement remain admitted as
R2-F2. Allocation-failure-only R2-D1/R2-D2 remain deferred because the repository
still has no deterministic allocator-failure hook; the pilot supplies no reason
to edit them without coverage. The R2-5C gate is complete: all pilot cleanup
paths are mapped, the functional and memory checks pass, and no ownership
ambiguity remains. R2-5D may now begin with only R2-F1 and R2-F2.

## R2-5D Windows Follow-ons and Focused Validation

Implementation anchor `fb09d9fc9` closes R2-F1 by releasing the current
per-entry path before the existing Windows directory `continue` in both plugin
iteration and lookup. Each `FindFirstFileA` result remains owned by its helper
until the unchanged `FindClose` cleanup, while regular-file, open, callback,
found, and error exits retain their preceding order and result.

The same anchor closes R2-F2 by keeping each duplicated insertion/replacement
path in the local `path_copy` owner until successful table assignment. A
successful transfer clears the local pointer; the common `done` path releases
only a non-null, untransferred copy. Windows environment expansion failure
therefore releases the original copy that `H5_expand_windows_env_vars` leaves
untouched. Insert failure does not grow the logical table, and replacement
failure leaves the old table entry owned and unchanged. No table path is freed
by the new cleanup after a successful transfer.

The extended Windows test passed against the preceding product source before
the R2-5D edit, establishing that its iterator, missing-filter lookup,
environment-expansion success, and unchanged-state failure expectations do not
depend on the correction. After the edit, qualifying Windows and Linux Ninja
Release runs of `H5PLUGIN-filter_plugin` passed 1/1 at
`HDF_TEST_EXPRESS=0`. The Windows run used command-scoped `/utf-8` and exact
preflight resolution of the build-tree HDF5 DLLs plus the repository
`z.dll`, `aec.dll`, and `szip.dll`. Linux Memcheck again reported all 152,654
allocations freed, zero live bytes, and zero errors.

Complete Debug builds succeeded on both validators, followed by focused Debug
runs passing 1/1 at express level 0. The focused Linux Unix Makefiles build
also passed after explicitly building the four filter plugin libraries required
by the test. Building only the `filter_plugin` executable did not stage those
fixtures and produced the expected missing-filter failure; that incomplete
build precondition is excluded from product evidence.

Legal thread-safe configurations passed the same focused test on Windows and
Linux. The Windows configuration used shared libraries only, as required by
the supported thread-safe combination, and repeated exact dependency-DLL
preflight. The Linux parallel configuration enabled MPI, subfiling, and VFD
testing; its registered filter, VFD, and VOL plugin tests passed 3/3 at express
level 0. No lock, serialization, public signature, export, installed artifact,
or file-format behavior changed. R2-5D is complete; R2-5E evidence follows.

## R2-5E Final Product and Compatibility Matrix

All final Release suites used `HDF_TEST_EXPRESS=3` and no more than six jobs.
Before every Windows CTest or installed executable run, the build or install
HDF5 DLL directory where applicable and the repository zlib/libaec dependency
directories were placed first in `PATH`; each resolved DLL path was asserted
before execution. No missing-DLL or differently resolved run is acceptance
evidence.

| Validator/configuration | Passed enabled | Disabled | Registered | Time |
| --- | ---: | ---: | ---: | ---: |
| Windows default | 2,733 | 37 | 2,770 | 135.23 s |
| Windows SC-A, shared HDF5/supplied shared compression | 2,896 | 10 | 2,906 | 126.39 s |
| Windows SC-B, static HDF5/supplied shared compression | 2,853 | 10 | 2,863 | 126.14 s |
| Linux default | 2,735 | 37 | 2,772 | 128.47 s |
| Linux shared HDF5/shared system compression | 2,898 | 10 | 2,908 | 137.37 s |
| Linux shared HDF5/static supplied compression | 2,898 | 10 | 2,908 | 136.91 s |
| Linux static HDF5/shared system compression | 2,855 | 10 | 2,865 | 136.10 s |
| Linux static HDF5/static supplied compression | 2,855 | 10 | 2,865 | 134.83 s |

Every row completed a full Release build, enabled CTest suite, and install.
Exact registered-name and disabled-state comparisons against the corresponding
Round 1 row have zero delta. The accepted Linux configuration explicitly
stabilized package discovery: default disabled optional PkgConfig discovery,
while compression rows pinned the already qualified PkgConfig executable. This
removed inherited-shell metadata variability without changing dependency
selection or product behavior.

### Compression, Installs, and Packages

Installed gzip and SZIP C examples built and ran against both Windows and all
four Linux compression rows. Each reported the requested filter and read back
the expected maximum value 1,890. Binary inspection reconfirmed the frozen
linkage forms:

| Row | Final linkage evidence |
| --- | --- |
| Windows SC-A | consumer needs `hdf5.dll`; `hdf5.dll` needs repository `z.dll` and `szip.dll` |
| Windows SC-B | consumer directly needs repository `z.dll` and `szip.dll` |
| Linux shared/shared | consumer needs `libhdf5.so`; it needs system `libz.so.1` and `libsz.so.2` |
| Linux shared/static | consumer needs `libhdf5.so`; it has no compression `NEEDED` entry |
| Linux static/shared | consumer directly needs system `libz.so.1` and `libsz.so.2` |
| Linux static/static | link uses `libhdf5.a`, `libz.a`, `libsz.a`, and `libaec.a`; no compression `NEEDED` entry |

CPack produced the two Windows ZIPs and all five Linux TGZs. The original R2
record reported zero package-path delta from Round 1. R3-5E reinspection of the
retained archives found that the R2 Linux shared/shared, shared/static, and
static/shared TGZs each omitted `bin/h5cc`, although their corresponding install
trees and all Round 1 archives contained it. That zero-delta package claim is
withdrawn; the product install trees were intact, and fresh R3 packages restore
the exact Round 1 path inventory. All 20 default installed CMake target names
remain unchanged.

The Windows compression installs contain the same 57 header contents as their
Round 1 counterparts, including byte-identical `H5pubconf.h`. The accepted
Linux default header closure is also byte-identical. In each independently
prefixed Linux compression row, the sole header-content delta is the expected
configured install directory inside `H5_DEFAULT_PLUGINDIR`; all other lines and
all other installed headers are identical.

### Headers, ABI, Consumers, HighFive, and Format

The default installs preserve all 57 public header names and contents against
both `dd7204035` and `2a966388e`. Generated configuration, version, error, and
overflow headers retain their frozen hashes. The public-header source diff is
empty. The final default export manifests remain exactly 3,964 Windows names
and 4,060 Linux names with the Round 1 hashes; the existing `H5PL` symbols stay
exported and the new ownership logic adds no symbol or signature.

Installed C99 `find_package` consumers and direct strict-C17 consumers compile,
link, run, and report HDF5 2.3.0 on both validators. C++ consumption of the C
headers passes under G++ C++11 and MSVC's lowest explicit C++14 mode. The seven
frozen x64 size/alignment assertions pass. The retained-product integration
contract passes build-tree and install-tree `find_package`, isolated
`add_subdirectory`, local `FetchContent`, and negative removed-product checks on
both platforms.

Re-extraction of the fixed HighFive audit still produces exactly 147 identifiers
and the tracked HighFive header tree is unchanged from its audit anchor. All 147
map to installed declarations. Windows resolves 139 direct or version-aliased
exports, and the parallel Linux library supplies the remaining eight MPI
symbols, leaving no missing entry.

Final Windows and Linux compression writers produced equivalent gzip datasets.
Round 1 and Round 2 `h5diff` tools on both platforms read the cross-platform
outputs and report semantic equality. Final default tools also read and compare
the frozen Round 1 cross-platform fixtures. No encoding, datatype, layout, or
file-format contract changed.

Two setup corrections are excluded from acceptance evidence. Linux Unix
Makefiles focused validation initially built only the executable and therefore
did not stage its four required plugin fixtures; the complete fixture build and
identical test then passed. Final Linux package metadata was regenerated with
stable PkgConfig selection. Windows SC-A/SC-B were reconfigured to the frozen
install-prefix input and their complete builds, full suites, installs, packages,
examples, headers, linkage, and format checks were rerun; only those final runs
are recorded above.

## R2-5F Round Closeout

Round 2 is complete at product implementation anchor `fb09d9fc9`. The POSIX
pilot is `6851af92b`; the later Windows follow-ons depend on its expanded shared
test fixture, so a complete rollback reverts `fb09d9fc9` before `6851af92b`.
Documentation-only commits do not alter that product rollback group.

All selected ownership defects are corrected and every mandatory focused,
memory, full-suite, package, ABI, consumer, HighFive, and format gate passes.
R2-D1, R2-D2, R2-I1, and R2-D3 retain their recorded dispositions, and the
Round 1 deferred ledger remains unchanged. No deferred candidate was admitted
silently. The selected code is non-hot plugin-path administration, so the
predeclared non-hot rationale remains sufficient and no performance experiment
was required.

The original Stage 5 installed-header/API/ABI freeze at `dd7204035`, preceding
accepted Round 1 anchor `2a966388e`, diagnostic policy, fixed 147-entry HighFive
floor, file-format contract, and mandatory compression matrix remain in force.
The next continuation is R3-5A: requalify the relevant environment and freeze a
new bounded candidate ledger, ownership/behavior model, and validation
specification before selecting or editing any product source.

## R3-5A Frozen Scope and Baseline

### Environment Bridge and Reused Baseline

The Round 3 planning source is `a13ae7c8a`. Its only tracked changes after the
accepted Round 2 product anchor `fb09d9fc9` are Round 2 documentation.
`src/`, `test/`, `testpar/`, `tools/`, `utils/`, `config/`, `HDF5Examples/`,
and the top-level CMake definitions have no delta. The `H5system.c` Git blob is
still `851255b7854b70c4440e2bfdd2ecf9cd5facb328`, so the original anchor
remains `dd7204035`, the preceding accepted implementation is `fb09d9fc9`, and
the cumulative product delta consists only of the accepted Round 1 and Round 2
changes.

Relevant environment inputs were requalified without a material change:

| Validator | Requalified inputs |
| --- | --- |
| Windows x64 | Visual Studio 18 2026 Insiders 18.10.12120.281, MSVC 19.51.36256/toolset 14.51.36231, CMake/CTest 4.4.3, and clang-format 22.1.0 |
| Linux x86_64 | Ubuntu 26.04.1 under WSL, GCC/G++ 15.2.0, CMake 4.2.3, Ninja 1.13.2, GNU Make 4.4.1, Valgrind 3.26.0, and Open MPI 5.0.10 |

The Windows x64 zlib 1.3.2 and libaec 1.1.7 DLLs and import libraries retain
the Round 2 SHA-256 values. Linux retains system zlib 1.3.1 and libaec 1.1.5 in
shared and static forms plus the pinned PIC-capable zlib 1.3.2/libaec 1.1.7
static prefix used by the supplied-static rows. No prerequisite acquisition,
proxy change, or persistent environment change was required.

Because product, test, CMake, toolchain, and dependency inputs are identical,
the complete Round 2 endpoint was initially reused as the Round 3 behavioral
starting baseline under the evidence-reuse rule. Windows default/SC-A/SC-B
passed 2,733/2,896/2,853 enabled
tests, and Linux default plus four compression rows passed 2,735/2,898/2,898/
2,855/2,855. Their exact test inventories, installs, packages, consumers,
headers, ABI/exports/layouts, HighFive mapping, linkage, and format evidence
remain applicable subject to the historical corrections above. In particular,
the retained R1/R2 Linux compression caches have Map API disabled, and three
retained R2 Linux archives omit `h5cc`; neither claim is reused as conforming
Map/package evidence. The Round 3 implementation must repeat the complete final
matrix and cannot inherit the preceding passes as final evidence.

### Frozen Contracts, Callers, and Ownership

Round 3 inherits the complete 57-header freeze, 3,964-name Windows and
4,060-name Linux export manifests, public layouts, generated settings, install
and target inventories, C99/C17/C++ C-header consumers, API aliases, file-format
fixtures, and fixed 147-entry HighFive inventory. `H5_get_option`, `H5_opterr`,
`H5_optind`, and `H5_optarg` are library exports declared in non-installed
`H5private.h`; their names, signatures, types, and linkage remain frozen.

There are 19 actual `H5_get_option` invocation sites: 14 in retained command-line
tools, four in tool test/performance programs, and one in `h5dwalk`. They cover
`h5copy`, `h5diff`, `h5dump`, `h5format_convert`, `h5jam`, `h5unjam`,
`pio_perf`, `sio_perf`, `h5repack`, `h5sign`, `h5stat`, `h5clear`, `h5mkgrp`,
`h5gentest`, `getub`, `tellub`, `zip_perf`, and `h5dwalk`; `h5dump` calls the
parser twice. The fixed HighFive inventory does not use this private parser.

In the selected short-option branch, `opts` is a borrowed `const char *`, and
the local `cp` only points into that string, advances, and reads the following
option marker. It never writes through the pointer and owns no storage. The
long-option branch owns its `strdup` result until the existing `free`; all
`H5_optarg` values remain borrowed pointers into `argv`. The static scan index,
three exported global variables, argument advancement, wildcard handling,
return values, and diagnostic text are untouched. No allocation, cleanup,
identifier, callback, VOL/VFD/filter dispatch, file format, or public layout is
reachable from the proposed qualifier-only change.

### R3 Candidate Ledger

| ID | Exact functions | Decision | Evidence, transformation, and boundary |
| --- | --- | --- | --- |
| `R3-P1` | `H5system.c`: short-option branch of `H5_get_option` | `SELECTED PILOT` | A clean Linux C17 developer-warning build at the preceding implementation reports `-Wdiscarded-qualifiers` when `strchr(opts, optchar)` is assigned to `char *cp`. Change only this borrowed local to `const char *`. Preserve the exported declaration/definition signature, evaluation order, pointer advancement, globals, results, and diagnostics. |
| `R3-K1` | `H5_get_option` long-option branch, global parser state, declaration, and all callers | `KEEP` | Resource handling, parser reentrancy, signature/caller casts, option semantics, and diagnostic cleanup are independent work with wider compatibility risk and no need for this pilot. |
| `R3-D1` | R2-D1, R2-D2, R2-I1, R2-D3 and R1-D1 through R1-D4 | `DEFER` | Their frozen allocation-failure, behavior, file-format, shared-container, or performance constraints remain unchanged; none is admitted to Round 3. |

R3-P1 is the complete Round 3 implementation scope. The proposed edit is one
local pointer qualifier and is not a user-visible behavior change, so it needs
no changelog entry. The branch performs the same `strchr`, increment, and byte
tests, and the command-line parser is not a measured hot path; no performance
experiment is warranted. R3-5C and R3-5D are provisionally `NOT_APPLICABLE`,
subject to confirmation against the actual diff.

### R3 Validation Specification

- R3-5B changes only `cp` to `const char *` and formats `H5system.c`. A clean
  Linux C17 `HDF5_ENABLE_DEV_WARNINGS=ON` build must remove the exact
  `H5_get_option` discarded-qualifier warning without introducing a new warning.
  MSVC uses the same developer-warning configuration and command-scoped
  `/utf-8`; both validators complete the default Release build.
- On Windows and Linux, run the exact five-test focused selection
  `H5DIFF-h5diff_10`, `H5DIFF-h5diff_15`, `H5CLEAR_CMP-h5clr_usage_h`,
  `H5STAT-h5stat_help1`, and `H5STAT-h5stat_help2` at
  `HDF_TEST_EXPRESS=0`. It exercises short help, long help, and an attached
  long-option value through three retained callers; compare outputs and
  diagnostics to the preceding implementation. Existing complete tool suites
  provide the broader caller coverage; no new legacy aggregate test is added
  for a qualifier-only change.
- Complete Debug builds and the same focused selection run on both validators.
  Linux Valgrind runs the short and long `h5stat` help cases with an error exit
  for definite/indirect leaks. Linux Unix Makefiles builds the library and the
  three selected tools and runs the focused cases.
- The direct parallel caller requires Linux/Open MPI and Windows/MS-MPI parallel
  builds of `pio_perf` plus its help/argument-parser smoke invocation. Other
  thread-safe, VOL, VFD, and filter paths do not call the parser and have no
  state, ownership, or signature impact from this local qualifier.
- R3-5E repeats Windows default/SC-A/SC-B and Linux default plus all four
  compression-linkage full Release suites at `HDF_TEST_EXPRESS=3` and at most
  six jobs. It repeats installs/packages, linkage, consumers, integration
  styles, complete headers/exports/signatures/layouts, exact test inventories,
  the fixed HighFive evidence, and cross-platform format reads against both
  `dd7204035` and `fb09d9fc9` where applicable.
- C99, C17, C++11, and the v16/v18/v110/v112/v114/v200 API-alias consumers
  retain the R1 specification. `H5_get_option` is absent from all installed
  headers and the HighFive table, but the entire inherited contract is still
  checked at final acceptance. Major Windows and WSL builds run serially;
  focused ordinary CTest uses no more than six workers, and MPI ranks run apart
  from full suites with no surviving helper process.

The preceding warning is reproduced, all mandatory dependencies remain
available, exact selection and checks are frozen, and no Round 3 product source
has been edited. R3-5A is complete.

## R3-5B Characterization and Pilot

Implementation anchor `a206f0a6e` changes only the short-option branch's local
`cp` declaration from `char *` to `const char *`. `clang-format` 22.1.0 leaves
the rest of `H5system.c` unchanged. The `H5_get_option` declaration and
definition signature, library exports, 19 invocation sites, option string,
global/static state, evaluation order, returns, diagnostics, and long-option
allocation path are byte-identical to the preceding implementation.

A fresh Linux-filesystem source snapshot configured for C17 Release with GNU
developer warnings and completed all 3,011 build steps. The build log contains
zero `H5_get_option` warnings, removing the exact preceding
`-Wdiscarded-qualifiers` diagnostic without adding another diagnostic in that
function. A fresh Windows/MSVC Release configuration used command-scoped
`/utf-8`, enabled developer warnings, and completed the full default build.

The focused results at `HDF_TEST_EXPRESS=0` are:

| Check | Result |
| --- | --- |
| Windows Release | Complete default build passed; exact repository zlib/libaec DLL preflight passed; selected tool tests passed 5/5 |
| Linux Release/Ninja | Complete default build passed; selected tool tests passed 5/5; target warning absent |
| Windows Debug | Complete default build passed; selected tool tests passed 5/5 |
| Linux Debug/Ninja | Complete default build passed; selected tool tests passed 5/5 |
| Linux Valgrind 3.26.0 | `h5stat -h` freed 2,875/2,875 allocations and `h5stat --help` freed 2,876/2,876; both have zero live blocks and zero errors |
| Linux Unix Makefiles | Library and selected tools built; after the required `h5diff_files` fixture target, the selected tests passed 5/5 |
| Linux Open MPI 5.0.10 | `h5perf` built; two-rank `-h` printed the expected usage and returned its designed status 1 |
| Windows MS-MPI 10.1 | `h5perf` built; two-rank `-h` printed the expected usage and returned its designed status 1 |

The exact selected tests are `H5DIFF-h5diff_10`, `H5DIFF-h5diff_15`,
`H5CLEAR_CMP-h5clr_usage_h`, `H5STAT-h5stat_help1`, and
`H5STAT-h5stat_help2`. The first Unix Makefiles execution followed a target-only
build and passed four cases, while `H5DIFF-h5diff_15` could not open the absent
generated `h5diff_basic*.h5` inputs. Building the repository's
`h5diff_files`/`h5diffgentest` fixture targets staged those inputs and the
identical five-test selection then passed. This is test-tree assembly, not a
product failure.

R3-5C is `NOT_APPLICABLE`: the one-line qualifier edit acquires, transfers, and
releases no resource and changes no cleanup structure. The borrowed pointer
still refers to the same immutable option string for the same lexical extent.
R3-5D is also `NOT_APPLICABLE`: R3-P1 is the complete frozen round scope and no
follow-on was admitted. R3-5B through R3-5D are complete; the mandatory R3-5E
matrix was still open at this checkpoint; final evidence follows.

## R3-5E Final Product and Compatibility Matrix

All final Release suites used `HDF_TEST_EXPRESS=3` and no more than six jobs.
Windows compilation used command-scoped `/utf-8`; every Windows compression
execution put the exact repository zlib/libaec DLL directories first in
`PATH`. The accepted results are:

| Validator/configuration | Passed enabled | Disabled | Registered | Time |
| --- | ---: | ---: | ---: | ---: |
| Windows default | 2,733 | 37 | 2,770 | 130.65 s |
| Windows SC-A, shared HDF5/supplied shared compression | 2,896 | 10 | 2,906 | 137.21 s |
| Windows SC-B, static HDF5/supplied shared compression | 2,853 | 10 | 2,863 | 136.85 s |
| Linux default | 2,735 | 37 | 2,772 | 128.46 s |
| Linux shared HDF5/shared system compression | 2,898 | 10 | 2,908 | 135.93 s |
| Linux shared HDF5/static supplied compression | 2,898 | 10 | 2,908 | 136.49 s |
| Linux static HDF5/shared system compression | 2,855 | 10 | 2,865 | 135.08 s |
| Linux static HDF5/static supplied compression | 2,855 | 10 | 2,865 | 143.86 s |

All 22,723 enabled tests passed. Structured CTest comparison against the
corresponding R2 builds gives zero delta in registered names, disabled names,
normalized commands, and fixture relationships for every row. The only tests
not run are the same 37 or 10 explicitly disabled baseline cases; there is no
additional runtime skip. The six API-default executables for v16, v18, v110,
v112, v114, and v200 also passed 6/6 on each validator at express level 0.

The Windows compression caches select the repository import libraries and both
generated configurations define `H5_HAVE_MAP_API 1`. All four Linux compression
rows explicitly set `HDF5_ENABLE_MAP_API=ON` and define the same macro. The
shared-dependency rows resolve distribution zlib 1.3.1 and libaec 1.1.5; the
static-dependency rows resolve the pinned PIC zlib 1.3.2 `libz.a` and libaec
1.1.7 `libsz.a`/`libaec.a`. Dynamic inspection shows `libz.so.1` and
`libsz.so.2` only in the shared-dependency rows. The first shared/static probe
that selected `libz.so`/`libsz.so` was discarded and rebuilt with explicit
static-selection options and paths before acceptance.

### Installs, Packages, and Consumers

All eight rows installed successfully. CPack produced three Windows ZIPs and
five Linux TGZs. Windows default/SC-A/SC-B packages contain 101/97/95 files.
The Linux default package has 91 regular files and four symlinks; the two
shared-HDF5 compression packages each have 87 regular files and four symlinks,
and the two static-HDF5 packages each have 87 regular files. The three Windows
and four Linux compression package paths match the corresponding Round 1
archives exactly. Reinspection during Round 4 found that the retained Round 1
Linux default TGZ lacks `bin/h5cc`; the fresh Round 3 default package contains
that accepted installed compiler wrapper, so the earlier all-five Linux claim
is withdrawn. The Round 3 packages match the retained R2 archives except for
the three corrected `bin/h5cc` omissions documented above. The install path
inventories match R2 exactly.

Default installs retain all 57 installed header names and byte-identical
contents against both `dd7204035` and `fb09d9fc9`. The compression installs also
retain 57 names. Their only Windows header-content delta from R2 is the expected
configured `H5_DEFAULT_PLUGINDIR`; the four Linux rows additionally change the
previously missing `H5_HAVE_MAP_API` definition to 1. No source public header
changed. Default `libhdf5.settings` is byte-identical to R2, and generated
version, error, overflow, and configuration headers retain the frozen content.
The default/compression CMake target sets remain 20/18 names with zero delta.

Installed C99, strict-C17, G++ C++11, and MSVC `/std:c++14` C-header consumers
compile, link, run, and report HDF5 2.3.0. The seven frozen x64 layout assertions
pass. The full retained-product contract passes build-tree and install-tree
`find_package`, isolated `add_subdirectory`, local `FetchContent`, HighFive
consumer, and removed-product negative checks on both platforms. Installed
gzip and SZIP examples build and run against both Windows and all four Linux
compression packages; all 12 executions report the requested filter and read
back the expected maximum value 1,890.

### ABI, HighFive, and Format

The default case-sensitive export sets remain exactly 3,964 Windows names and
4,060 Linux names with zero delta from both comparison anchors. The exported
`H5_get_option` spelling remains present and its non-installed `H5private.h`
declaration is unchanged. Default public headers and the seven layout probes
therefore preserve the frozen signatures and associated layouts.

Re-extraction of the fixed HighFive table produces exactly 147 identifiers,
all present in both the tracked HighFive tree and installed header closure. The
default Windows library exports 135 directly; the four default v200 aliases
resolve to `H5Lget_info2`, `H5Literate2`, `H5Oget_info3`, and
`H5Rdereference2`, and the Round 3 parallel Linux build exports the remaining
eight MPIO/collective functions. The 77-file tracked HighFive tree has zero
diff from audit anchor `c461ae3e8`; dual-platform consumers create and read the
expected dataset.

Current Windows and Linux compression writers produced semantically equivalent
gzip datasets. The original `dd7204035`, preceding `fb09d9fc9`, and current
`a206f0a6e` Windows and Linux `h5diff` tools all read and compare those files
successfully. Current default tools on both platforms also read and compare the
four frozen Round 1 cross-platform fixtures. No encoding, datatype, layout, or
file-format contract changed.

## R3-5F Round Closeout

Round 3 is complete at product implementation anchor `a206f0a6e`. It contains
one independently revertible product commit after R3-5A; reverting that commit
restores the preceding implementation. Documentation-only commits do not alter
the rollback unit. R3-5C and R3-5D remain `NOT_APPLICABLE`, and no deferred
candidate was admitted.

The complete warning, focused, memory, generator, MPI caller, full-suite,
package, ABI, consumer, HighFive, and format gates pass. The selected parser
branch is non-hot, so the predeclared no-benchmark rationale remains sufficient.
The historical Linux Map and R2 TGZ inventory discrepancies are explicitly
corrected above; the final R3 matrix satisfies the frozen contract without an
unresolved validation gap.

The original Stage 5 contract at `dd7204035`, accepted R1 implementation
`2a966388e`, accepted R2 implementation `fb09d9fc9`, diagnostic policy, fixed
147-entry HighFive floor, API/ABI and file-format restrictions, and mandatory
compression matrix remain in force. The next continuation is R4-5A: requalify
the relevant environment and freeze a new bounded candidate ledger, ownership
and behavior model, and validation specification before any product edit.

## R4-5A Frozen Scope and Baseline

### Environment Bridge and Reused Baseline

The Round 4 planning source is `82913bddb`. Its only tracked changes after the
accepted Round 3 product anchor `a206f0a6e` are Round 3 documentation. `src/`,
`test/`, `testpar/`, `tools/`, `utils/`, `config/`, `HDF5Examples/`, and the
top-level CMake definitions have zero delta. `src/H5FDfamily.c` retains Git
blob `9af4fb7815f0178d14194196a172e65e7ddc5da9`, and `test/vfd.c` retains blob
`0bfe524207e22998b156115bb1a3f0bce52aa8a2`. The original contract anchor
remains `dd7204035`, and the preceding accepted implementation remains
`a206f0a6e`.

The supported validators were requalified without a material change. Windows
x64 retains Visual Studio 18 2026 Insiders 18.10.12120.281, MSVC
19.51.36256/toolset 14.51.36231, CMake/CTest 4.4.3, clang-format 22.1.0, and
command-scoped `/utf-8`. Linux x86_64 retains Ubuntu 26.04.1 under WSL,
GCC/G++ 15.2.0, CMake 4.2.3, Ninja 1.13.2, GNU Make 4.4.1, Valgrind 3.26.0,
and Open MPI 5.0.10. The repository Windows zlib 1.3.2/libaec 1.1.7 inputs,
Linux system zlib 1.3.1/libaec 1.1.5 inputs, and the pinned PIC-capable static
zlib 1.3.2/libaec 1.1.7 prefix remain available. No proxy, dependency, or
persistent environment change was required.

Because product, test, CMake, toolchain, and dependency inputs are unchanged,
the complete accepted Round 3 endpoint is reused as the Round 4 behavioral
starting baseline under the evidence-reuse rule. Its eight Release rows passed
all 22,723 enabled tests, including corrected Map-enabled Linux compression
and complete package evidence. The exact test inventories, installs, packages,
linkage, consumers, headers, exports, layouts, fixed HighFive inventory, and
format results remain the comparison baseline. Round 4 must nevertheless
repeat the complete final matrix before acceptance.

The preceding clean Linux C17 developer-warning build reports exactly two
`-Wdiscarded-qualifiers` instances in
`H5FD__family_get_default_printf_filename`, where `strstr` and `strrchr`
results from a `const char *` input are assigned to `char *file_extension`.
The retained Windows and Linux Release `H5TEST-vfd` baseline passes 3/3 with
its setup and cleanup fixtures at `HDF_TEST_EXPRESS=0`. Direct retained
`h5mkgrp` executions through the family default-driver configuration produce
`alpha-000000.h5`, `beta-000000.data`, and `gamma-000000` on both validators,
establishing the three naming branches before any product edit.

### Frozen Contracts, Callers, and Ownership

`H5FD__family_get_default_printf_filename` is file-local and has exactly two
call sites, both in `H5FDfamily.c`: the default-configuration branches of
`H5FD__family_open` and `H5FD__family_delete`. Its declaration, definition
signature, return type, callers, VFD class callbacks, and all installed family
VFD APIs remain frozen.

`old_filename` is a borrowed immutable string. `file_extension` only points
inside that string and is used for a null test, pointer subtraction, and a
read-only `%s` conversion; it is never written through, freed, returned, or
stored. `tmp_buffer` is the only allocation owned by the helper. On success its
ownership transfers through `ret_value` to the existing caller; on failure the
existing `done` path releases it. The suffix, length arithmetic, allocation,
branch order, formatting calls, results, errors, and cleanup are unchanged.
No identifier, callback, lock, VOL/filter dispatch, member I/O, file-format
encoding, public layout, or installed declaration is reachable from changing
the borrowed local's qualifier.

### R4 Candidate Ledger

| ID | Exact functions | Decision | Evidence, transformation, and boundary |
| --- | --- | --- | --- |
| `R4-P1` | `H5FDfamily.c`: `H5FD__family_get_default_printf_filename` | `SELECTED PILOT` | Change only local `file_extension` from `char *` to `const char *`. This removes the two reproduced qualifier-loss diagnostics while preserving both call sites, all three filename branches, allocation ownership, output bytes, and errors. |
| `R4-T1` | `test/vfd.c`: new family default-configuration characterization | `SELECTED TEST` | Through public `H5Pset_driver(..., H5FD_FAMILY, NULL)`, create and delete names ending in `.h5`, another extension, and no extension. Check the exact member names before deletion and their absence afterward, exercising both helper callers without exposing the helper. |
| `R4-K1` | Remaining family VFD implementation and public/package declarations | `KEEP` | Signatures, VFD registration, configuration, allocation/cleanup, member enumeration, errors, and file behavior require no change for the local qualifier correction. |
| `R4-D1` | `H5FDsplitter.c`: analogous default W/O filename diagnostic | `DEFER` | It belongs to a separate user-visible VFD and requires its own default-configuration characterization; symmetry does not admit it to this round. |
| `R4-D2` | Other retained const diagnostics in `H5Fint.c`, `H5trace.c`, and tools | `DEFER` | Their macros, trace parsing, or intentionally mutable command-line inputs have different contracts and callers; they are outside this single-helper pilot. |
| `R4-D3` | R2-D1, R2-D2, R2-I1, R2-D3 and R1-D1 through R1-D4 | `DEFER` | Their allocation-failure, behavior, file-format, shared-container, or performance constraints remain unchanged and none is admitted to Round 4. |

R4-P1 and R4-T1 are the complete Round 4 implementation scope. The product
edit is one local qualifier and is not user-visible, so no changelog entry is
required. The helper runs only during default family open/delete filename
normalization and the transformation does not change its work, so no benchmark
is warranted. R4-5C and R4-5D are provisionally `NOT_APPLICABLE`, subject to
confirmation against the actual diff.

### R4 Validation Specification

- R4-5B changes only the selected local qualifier and adds the frozen modern
  `h5test.h` characterization. Format both touched C files. Fresh default
  Release builds use developer warnings on Linux and Windows; the exact two
  GNU diagnostics must disappear without a new diagnostic in the helper or
  test.
- On both validators, run `H5TEST-vfd` with its setup/cleanup fixtures at
  `HDF_TEST_EXPRESS=0` in Release and Debug. Confirm its output includes the
  new family default-filename case and compare the exact three created names
  to the retained baseline. Linux repeats the focused build/test with Unix
  Makefiles and runs the focused executable under Valgrind with definite and
  indirect leaks treated as errors.
- Direct retained `h5mkgrp` family-driver probes repeat the `.h5`, other
  extension, and no-extension cases on both validators. No MPI, thread-safety,
  splitter, VOL, filter, or compression-specific focused row owns changed
  state or control flow from this qualifier-only helper edit.
- R4-5E repeats Windows default/SC-A/SC-B and Linux default plus all four
  compression-linkage full Release suites at `HDF_TEST_EXPRESS=3`, with major
  Windows and WSL builds serial and no more than six jobs. Repeat installs,
  packages, dependency linkage, consumers, integration styles, complete
  headers/exports/signatures/layouts, exact test inventories, fixed HighFive
  evidence, and cross-platform format reads against the inherited anchors.
- Retain the inherited C99, strict-C17, C++11/MSVC C++14 C-header consumers,
  v16/v18/v110/v112/v114/v200 API-alias checks, Map requirement, system
  compression business gate, 57-header freeze, 3,964/4,060 export sets, and
  147-entry HighFive floor. Missing or changed evidence is a stop condition,
  not grounds to expand the candidate scope.

The environment bridge, warning reproduction, direct behavior baseline,
ownership model, exact selection, deferrals, and checks are frozen. No Round 4
product or test source has been edited. R4-5A is complete.

## R4-5B Characterization and Pilot

Implementation anchor `720d882ee` changes only the borrowed local
`file_extension` declaration from `char *` to `const char *` in
`H5FD__family_get_default_printf_filename`. The added modern `h5test.h` case
uses public `H5Pset_driver(..., H5FD_FAMILY, NULL)`, creates and closes each
base file, verifies the exact first member name, deletes through `H5Fdelete`,
and verifies that member's removal for `.h5`, another extension, and no
extension. The helper signature, its two call sites, allocation and error
paths, VFD callbacks, public declarations, and on-disk data are unchanged.
`clang-format` 22.1.0 formatted both touched C files.

A fresh Linux-filesystem Release source snapshot with GNU developer warnings
completed all 3,011 build steps. The two frozen discarded-qualifier diagnostics
at the `strstr` and `strrchr` assignments are absent, and the changed helper and
new test report no GNU diagnostic. A fresh Windows/MSVC Release build completed
with command-scoped `/utf-8`. Its normalized 13 pre-existing
`H5FDfamily.c` diagnostic locations/classes match the Round 3 build; the new
test adds only MSVC high-warning informational optimizer/Spectre advisories,
not a qualifier or correctness diagnostic.

The focused results at `HDF_TEST_EXPRESS=0` are:

| Check | Result |
| --- | --- |
| Windows Release | Complete default build passed; `H5TEST-vfd` plus setup/cleanup passed 3/3; direct output includes `default FAMILY member filenames` and reports all VFD tests passed |
| Linux Release/Ninja | Complete default build passed; the same focused selection passed 3/3 and direct output includes the new case |
| Windows Debug | Complete default build passed; the same focused selection passed 3/3 |
| Linux Debug/Ninja | Complete default build passed; the same focused selection passed 3/3 |
| Linux Valgrind 3.26.0 | Full focused `vfd` execution made and freed 12,217 allocations, left zero live blocks, and reported zero errors |
| Linux Unix Makefiles | The selected target and repository fixture target built; the same focused selection passed 3/3 |
| Direct Windows/Linux tool probes | `h5mkgrp` through the default family driver produced `alpha-000000.h5`, `beta-000000.data`, and `gamma-000000` on both validators, exactly matching the pre-edit baseline |

The first Unix Makefiles execution followed the focused target-only build. The
new default-filename case passed, while the existing
family/multi compatibility cases could not open `family_v16-*` and
`multi_file_v16-*` inputs because target `vfd` does not stage them. Building
the repository's `HDF5_TEST_LIB_files` target copied the required fixtures and
the identical three-test selection then passed. This is test-tree assembly,
not a product failure.

R4-5C is `NOT_APPLICABLE`: the actual product edit acquires, transfers, and
releases no resource and changes no cleanup edge. The borrowed pointer retains
the same immutable input and lexical lifetime. R4-5D is also
`NOT_APPLICABLE`: R4-P1 and R4-T1 are the complete frozen round scope, and no
follow-on or deferred candidate was admitted. R4-5B through R4-5D are
complete.

## R4-5E Final Product and Compatibility Matrix

All eight fresh Release rows ran at `HDF_TEST_EXPRESS=3`, with no more than six
jobs and the major Windows and WSL builds serialized:

| Configuration | Passed | Disabled | Registered | Time |
| --- | ---: | ---: | ---: | ---: |
| Windows default | 2,733 | 37 | 2,770 | 137.45 s |
| Windows shared HDF5/shared supplied compression | 2,896 | 10 | 2,906 | 139.35 s |
| Windows static HDF5/shared supplied compression | 2,853 | 10 | 2,863 | 138.83 s |
| Linux default | 2,735 | 37 | 2,772 | 129.54 s |
| Linux shared HDF5/shared system compression | 2,898 | 10 | 2,908 | 135.92 s |
| Linux shared HDF5/static supplied compression | 2,898 | 10 | 2,908 | 135.20 s |
| Linux static HDF5/shared system compression | 2,855 | 10 | 2,865 | 134.94 s |
| Linux static HDF5/static supplied compression | 2,855 | 10 | 2,865 | 134.30 s |

All 22,723 enabled tests passed. The only tests not run are the same 37 or 10
explicitly disabled cases. Structured comparison with the corresponding Round
3 rows gives zero delta in registered test names, disabled names, normalized
commands, and fixture properties. The six API-default executables for v16,
v18, v110, v112, v114, and v200 passed both validators directly at express
level 0.

### Installs, Packages, Dependencies, and Consumers

All eight rows installed outside the repository and packaged successfully as
three Windows ZIPs and five Linux TGZs. Windows default/SC-A/SC-B packages
contain 101/97/95 paths. The Linux default package contains 91 regular files
and four symlinks; the two shared-HDF5 packages each contain 87 regular files
and four symlinks, and the two static-HDF5 packages each contain 87 regular
files. Every Round 4 package path manifest exactly matches its Round 3 row.
The three Windows and four Linux compression manifests also match Round 1.
The Linux default row retains the accepted `bin/h5cc` addition relative to the
retained Round 1 default archive. All install path inventories match Round 3.

Every install retains 57 public headers. Default Windows and Linux header
contents and `libhdf5.settings` are byte-identical to Round 3. Each compression
row differs in only `H5pubconf.h`, where the configured
`H5_DEFAULT_PLUGINDIR` contains that row's new install prefix. No source public
header changed. The default generated configuration, version, error, and
overflow headers retain the frozen contents; compression version, error, and
overflow headers do likewise. Default installs expose 20 CMake target names
and compression installs expose 18, with zero Round 3 delta.

Windows compression caches select the repository zlib and libaec inputs and
define `H5_HAVE_MAP_API 1`. The shared-HDF5 Windows library in SC-A loads
`z.dll` and `szip.dll`; the statically linked HDF5 tools in SC-B load those
same supplied compression DLLs. All four Linux compression rows define
`H5_HAVE_MAP_API 1`. The shared-dependency rows load `libz.so.1` and
`libsz.so.2`; the static-dependency rows use the frozen PIC archives and add no
compression `NEEDED` entry to the inspected HDF5 library or tool.

Fresh installed C99, strict-C17, G++ C++11, and MSVC C++14 C-header consumers
compile, link, run, and report HDF5 2.3.0. The seven frozen x64 type and
structure layout assertions pass. Build-tree and install-tree `find_package`
consumers, build-tree and install-tree HighFive consumers, isolated
`add_subdirectory`, and local `FetchContent` consumers pass on both platforms.
Build-tree and install-tree requests for CXX, HL, and CXX_HL are rejected, as
are the removed `HDF5_BUILD_CPP_LIB` and `HDF5_BUILD_HL_LIB` options.

Installed gzip and SZIP examples build and run against both Windows and all
four Linux compression packages. All 12 executions report the requested
filter and read back the expected maximum value 1,890. Shared and static HDF5
selection and all dependency locations were supplied explicitly.

Three preliminary Windows probe setups were discarded before acceptance: one
PowerShell helper parameter consumed `HDF5_DIR`, one build-tree CTest run did
not put the Visual Studio configuration directory on `PATH`, and the first
example probes did not fully select the frozen dependency and shared/static
parameters. Each was corrected and rerun from a fresh probe tree; none reached
an accepted product-runtime failure.

### ABI, HighFive, and Format

The default case-sensitive export sets remain exactly 3,964 Windows names and
4,060 Linux names with zero Round 3 delta. `H5_get_option` remains exported.
The unchanged public headers and passing layout probes preserve the frozen
signature and layout contract.

The fixed HighFive audit still contains exactly 147 C identifiers across the
unchanged 77-file tracked HighFive tree. All 147 appear in the current tree and
both installed header closures. The Windows default library exports 135
directly; the four v200 aliases resolve through `H5version.h` to
`H5Lget_info2`, `H5Literate2`, `H5Oget_info3`, and `H5Rdereference2`. A fresh
minimal parallel Linux shared build exports the remaining eight frozen
MPIO/collective functions. The HighFive input has zero tree delta from its
fixed audit anchor.

Current Windows and Linux gzip example files differ at the byte level but are
semantically interchangeable. Original Stage 5, Round 3, and Round 4 Windows
and Linux `h5diff` binaries all compare both current files successfully.
Current default Windows and Linux `h5diff` binaries also compare all four
frozen Round 1 cross-platform fixtures with their canonical counterpart. No
file-format delta was found.

## R4-5F Round Closeout

Round 4 is complete at implementation anchor `720d882ee`. The selected local
qualifier and direct family-filename characterization pass the focused gate,
the complete eight-row matrix, and every inherited compatibility contract.
R4-5C and R4-5D remain `NOT_APPLICABLE`; R4-D1 through R4-D3 and the earlier
backlog remain deferred. No public header, API/ABI, target, package contract,
HighFive dependency, observable filename, or file-format change was accepted.

The next continuation is R5-5A. It requalified the source and environment
against accepted Round 4 anchor `720d882ee`, then froze the exact candidate
ledger and validation specification below. No other Round 5 candidate is
admitted.

## R5-5A Scope and Baseline Freeze

R5-5A explicitly admits one new candidate after requalifying the accepted Round
4 endpoint `720d882ee`; it does not silently reopen Round 4. The analogous
Splitter item was recorded as `R4-D1` because it needed its own default-
configuration characterization. That characterization is now the sole R5
pilot scope:

| ID | Exact scope | Decision | Frozen boundary |
| --- | --- | --- | --- |
| `R5-P1` | `src/H5FDsplitter.c`: `H5FD__splitter_get_default_wo_path` | `SELECTED PILOT` | Change only the borrowed `file_extension` local from `char *` to `const char *`; preserve the helper signature, all three filename branches, output bytes, errors, and the three existing callers. |
| `R5-T1` | `test/vfd.c`: `test_splitter_default_filename` | `SELECTED TEST` | Through public `H5Pset_driver(..., H5FD_SPLITTER, NULL)`, create and delete `.h5`, other-extension, and extensionless names; check the exact default W/O names before deletion and absence afterward. This exercises the open and delete default-path branches without exposing the helper. |
| `R5-K1` | Remaining Splitter VFD implementation, public headers, package wiring, and unrelated diagnostics | `KEEP` | No signature, ABI/layout, registration, dispatch, resource, file-format, target, or dependency change is admitted. |
| `R5-D1` | Other const diagnostics and all prior deferred items | `DEFER` | No additional warning cleanup, macro change, tool edit, ownership work, or performance work enters this batch. |

The product edit is local and non-user-visible. It changes no public header,
export, ABI/layout, HighFive dependency, resource edge, observable filename,
or file-format rule. The direct callers remain the Splitter open path and the
two default Splitter delete paths; the characterization covers the public
driver setup and deletion API.

R5-5A validation is intentionally narrower than a round closeout until this
pilot is proven: run the focused VFD build and test at `HDF_TEST_EXPRESS=0`,
then the required Debug/Release and retained contract gates. Every new build,
CTest, and validation command uses no more than two parallel jobs. Historical
R1-R4 records retain their original six-job execution settings and are not
rewritten. A failed or unavailable required validator leaves R5 incomplete.

### R5-5A Pilot Validation Status

The fresh MSVC 19.51/Ninja Release configuration completed with development
warnings disabled. Its complete build was started with `--parallel 2` but
stopped in the unrelated `test/dt_arith.c` compilation because this MSVC/Ninja
configuration did not define `H5_SIZEOF_FLOAT` after the CMake float-size
probe failed. This is an environment/configuration validation gap, not a
diagnostic from the selected Splitter edit.

The focused `vfd` target rebuilt successfully with `--parallel 2`; the strict
MSVC `/Wall` tree also compiled `H5FDsplitter.c` as a single object with
`-j 2`, with no qualifier-loss diagnostic at the edited helper. After building
the registered reference-file fixture target, `H5TEST-vfd` passed at
`HDF_TEST_EXPRESS=0` with CTest `--parallel 2`. Direct execution of the same
binary also passed, including the new default Splitter W/O filename test.

Additional R5-5A validation now recorded:

- A fresh Windows x64 Visual Studio 18 2026 Release build with
  `HDF5_ENABLE_DEV_WARNINGS=ON`, command-scoped `CL=/utf-8`, and build/CTest
  parallelism capped at two completed successfully. The default suite passed
  2,733/2,733 enabled tests, with 37 disabled out of 2,770 registered tests;
  `H5TEST-vfd` and its clear/cleanup fixtures passed 3/3 at
  `HDF_TEST_EXPRESS=0`.
- A fresh Linux WSL x86_64 GCC 15.2/Ninja Release build completed the selected
  VFD target and reference fixtures with two jobs. `H5TEST-vfd` and its
  clear/cleanup fixtures passed 3/3 at `HDF_TEST_EXPRESS=0`; the output
  includes the default Splitter W/O filename case and all expected VFD checks.
  Valgrind 3.26.0 reported 12,856 allocations and frees, zero live blocks, and
  zero errors for the focused executable.
- The Linux validator has system zlib 1.3.1 and libaec 1.1.5 in both shared
  and archive forms. The pinned PIC-capable zlib 1.3.2/libaec 1.1.7 static
  inputs also remain available under the qualified WSL dependency prefix.
  Open MPI 5.0.10, CMake 4.2.3, Ninja 1.13.2, Valgrind 3.26.0, Perl 5.40.1,
  and pkg-config 2.5.1 are available.

- The mandatory R5-5A Release compression matrix passed with `HDF_TEST_EXPRESS=3`
  and no more than two build/CTest jobs per command:

  | Configuration | Passed | Disabled | Registered | Time |
  | --- | ---: | ---: | ---: | ---: |
  | Windows shared HDF5/shared supplied compression | 2,896 | 10 | 2,906 | 228.93 s |
  | Windows static HDF5/shared supplied compression | 2,853 | 10 | 2,863 | 227.28 s |
  | Linux shared HDF5/shared system compression | 2,898 | 10 | 2,908 | 229.02 s |
  | Linux shared HDF5/static supplied compression | 2,898 | 10 | 2,908 | 220.28 s |
  | Linux static HDF5/shared system compression | 2,855 | 10 | 2,865 | 220.09 s |
  | Linux static HDF5/static supplied compression | 2,855 | 10 | 2,865 | 219.17 s for final row |

  Each row completed a full Release build and enabled CTest suite with zero
  failures. The Windows rows resolved zlib 1.3.2 and libaec 1.1.7 from the
  repository `3rdparty` prefix; Linux shared rows used zlib 1.3.1/libaec 1.1.5,
  while Linux static rows used the qualified PIC zlib 1.3.2/libaec 1.1.7
  archives. The four Linux rows were installed and produced CPack packages;
  both Windows rows were likewise installed and packaged successfully.

The following optional environment rows are explicitly deferred and do not
block the R5-5A mandatory default/compression acceptance: ROS3 requires the
`aws-c-s3` CMake package (and Docker/AWS CLI only for its proxy tests); HDFS
requires JDK/JNI, Hadoop, and `libhdfs`; parallel tools require mpiFileUtils,
libcircle, and DTCMP; signed-plugin validation requires OpenSSL development
files; and RPM packaging requires `rpmbuild`. These are reachability and
packaging coverage gaps, not failures of the selected Splitter change.

The mandatory full-suite matrix and initial install/package checks are complete.

### R5-5A Contract Gates and Closeout

The installed-contract gates were rerun against the current R5 build outputs.
Windows SC-A and SC-B installs each contain the frozen 57 public headers; all
non-generated installed content is byte-identical to its Round 4 counterpart.
The Linux default, HS-DA, and HS-DS installs likewise contain 57 headers and
zero normalized content delta. Generated configuration headers and settings
retain only their expected platform, dependency, or install-prefix values.

Windows C99, strict C17, C++11 C-header, and HighFive consumers pass against
the shared SC-A install. The same C17, C++11, layout, and HighFive probes pass
against the static SC-B install. Linux default and both shared compression
install rows pass the C17, C++11, and layout probes; the default static archive
passes direct C17, C++11, layout, and HighFive consumers. The Windows and
Linux static/shared package target routes therefore remain usable without
adding a consumer prerequisite.

The default Linux shared export set remains 4,060 names with zero delta from
Round 4; the Windows shared SC-A set remains 3,988 names with zero same-row
delta. The default Windows frozen set remains 3,964 names in the accepted
default build. The fixed HighFive extraction still yields 147 identifiers.
Current non-parallel installs provide 135 direct identifiers plus the four
v200 aliases (`H5Lget_info2`, `H5Literate2`, `H5Oget_info3`, and
`H5Rdereference2`); the eight MPIO identifiers remain conditional and absent
only from non-parallel headers/exports. All seven x64 layout assertions pass.

All six API-version tests (`v16`, `v18`, `v110`, `v112`, `v114`, and `v200`)
pass from the current Linux build. The focused Splitter VFD partition and its
clear/cleanup fixtures pass 3/3 again. Current compression-enabled `h5diff`
reads the retained gzip and SZIP fixtures from both prior platform/profile
rows with zero differences, and the prior R4 tool reads a current R5
`h5repack` output with zero differences. Current Windows ZIP path inventories
remain 103 entries (SC-A) and 101 entries (SC-B), matching R4; the Linux
HS-DA TGZ inventory remains 104 entries. HighFive shared consumers pass on
both validators, and the static consumers pass on both validators.

The first default Linux install attempt exposed only an incomplete local build
tree: CMake's install script referenced optional static/tool artifacts that had
not yet been materialized. Building those existing targets and rerunning the
same install completed successfully; no source or product failure resulted.
The first compressed `h5diff` attempt used a no-filter default install and
reported unavailable filters; rerunning with the matching compression install
passed. These setup corrections are excluded from acceptance failures.

R5-5A is complete at product implementation anchor `74a8f0b79`. R5-5C and
R5-5D are `NOT_APPLICABLE`: the one-line local qualifier change adds no
resource edge, cleanup branch, or second admitted candidate. R5-5F closes the
round without a public header, ABI/layout, export, package, HighFive,
observable filename, or file-format delta. R2-D1, R2-D2, R2-I1, R2-D3, the
R1-R4 deferred backlog, and later Stage 5 rounds remain explicitly deferred.
