# Stage 5 Core C17 Internal Modernization Results

## Status

- State: Active; Round 1 Work Package 5A complete, product source unchanged.
- Execution date: 2026-09-09.
- Original Stage 5 source anchor: `dd7204035`.
- Preceding accepted product anchor: `81dff5168`.
- Detailed plan: [CoreC17Modernization.md](CoreC17Modernization.md).
- Fixed external interface audit:
  [HighFiveHDF5ApiDependencyAudit.md](HighFiveHDF5ApiDependencyAudit.md).
- Current continuation: R1-5B characterization and pilot implementation.

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
`H5A_info_t`, `H5F_info2_t`, `H5L_info2_t`, and `H5O_info2_t`. The default
C/C++ C-header consumer checks will recheck these anchors at R1-5E.

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
