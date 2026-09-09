# Stage 5 Core C17 Internal Modernization Results

## Status

- State: Active; R2-5B through R2-5D complete; next continuation is R2-5E.
- Execution date: 2026-09-09.
- Original Stage 5 source anchor: `dd7204035`.
- Preceding accepted product anchor: `81dff5168`.
- R1-5A evidence anchor: `bd6de77dd`.
- Round 1 implementation anchor: `2a966388e`.
- R2-5A planning source anchor: `c3f97252e`.
- R2-5B pilot implementation anchor: `6851af92b`.
- R2-5D implementation anchor: `fb09d9fc9`.
- Detailed plan: [CoreC17Modernization.md](CoreC17Modernization.md).
- Fixed external interface audit:
  [HighFiveHDF5ApiDependencyAudit.md](HighFiveHDF5ApiDependencyAudit.md).
- Current continuation: R2-5E final Round 2 compatibility matrix.

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
every row. Map API, tools, zlib, SZIP, and SZIP encoding were on.

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
or file-format behavior changed. R2-5D is complete; R2-5E is the next and final
Round 2 gate.
