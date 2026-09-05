# Stage 3 Source and Header Platform Reduction Results

## Status

- State: Completed
- Baseline execution date: 2026-09-04
- Completion date: 2026-09-05
- Completion review accepted: 2026-09-05
- Source implementation anchor: `81e96c889`
- Final implementation anchor: `74288cbaa`
- Clean final validation tree: `74288cbaa`
- Stage 3 plan:
  [CMakePlatformSupportReductionStage3.md](CMakePlatformSupportReductionStage3.md)
- Parent plan:
  [CMakePlatformSupportReduction.md](CMakePlatformSupportReduction.md)
- Portable handoff: [../../REFACTORING_PROGRESS.md](../../REFACTORING_PROGRESS.md)
- `HDF_TEST_EXPRESS`: `3`
- Maximum build and CTest parallelism: 4

Stage 3 is Completed. Both retained target/compiler pairs were qualified at the
same clean tracked tree, the pre-implementation product contract was captured,
and every source/header inventory family received a non-investigative
classification before implementation. Fourteen independently revertible source
reduction commits then removed unsupported-only behavior. The complete final
gate passed at `74288cbaa` without an unexplained product-contract delta.

The completion review is closed. The Linux plugin filename restriction is
explicitly accepted, and the corrected header evidence below supersedes the
earlier byte-identical comparison claims. No Stage 3 review item remains open.

## Qualified Validators

| Component | Windows baseline | Linux baseline |
| --- | --- | --- |
| Target system | Windows NT 10.0.26100 | Ubuntu 26.04.1 LTS under WSL2 |
| Architecture | x64 | x86_64 |
| Compiler | MSVC 19.51.36256.0, toolset 14.51.36231 | GCC/G++ 15.2.0 |
| Target triple | MSVC x64 | `x86_64-linux-gnu` |
| CMake | 4.4.3 | 4.2.3 |
| Generator | Visual Studio 18 2026 | Ninja 1.13.2 |
| Source state | clean tracked tree at `c305c9bfc` | clean tracked tree at `c305c9bfc` |

The tracked difference between `81e96c889` and `c305c9bfc` contains only
approved Stage 3 planning and handoff documentation. The source, headers, CMake
implementation, tests, and package inputs are the `81e96c889` implementation
anchor.

## Reproducible Baseline Commands

Commands below use placeholders rather than machine-specific paths. Build,
install, package, contract, and consumer output remains outside the tracked
source tree.

```powershell
$env:CL = "/utf-8"
cmake -S <src> -B <win-build> -G "Visual Studio 18 2026" -A x64
cmake --build <win-build> --config Release --parallel 4
$env:HDF_TEST_EXPRESS = "3"
ctest --test-dir <win-build> -C Release --output-on-failure -j 4
cmake --install <win-build> --config Release --prefix <win-install>
cpack --config <win-build>/CPackConfig.cmake -C Release -G ZIP
```

```sh
cmake -S <src> -B <linux-build> -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build <linux-build> --parallel 4
HDF_TEST_EXPRESS=3 ctest --test-dir <linux-build> \
  --output-on-failure -j 4
cmake --install <linux-build> --prefix <linux-install>
cpack --config <linux-build>/CPackConfig.cmake -G TGZ
```

The C++ rows add `-DHDF5_BUILD_CPP_LIB=ON`. Focused default smoke used
`^(H5TEST-testhdf5-base|HL_test_lite|H5DIFF-h5diff_10)$`; CTest included the
associated setup and cleanup fixtures. Focused C++ coverage used
`^(CPP_testhdf5|HL_CPP_ptableTest)$`.

## Pre-Implementation Contract

### Build and test registration

| Row | Evidence | State |
| --- | --- | --- |
| Windows default Release | Full build, install, and focused smoke 7/7 passed; 2,853 tests registered | `PASS` |
| Linux default Release | Full 3,153-step build, install, and focused smoke 7/7 passed; 2,855 tests registered | `PASS` |
| Windows C++ Release | C and C++ shared/static libraries plus focused C++ tests 2/2 passed; 2,887 tests registered | `PASS` |
| Linux C++ Release | C and C++ shared/static libraries plus focused C++ tests 2/2 passed; 2,889 tests registered | `PASS` |
| Windows package | ZIP generation passed; 120 archive entries | `PASS` |
| Linux package | TGZ generation passed; 122 archive entries | `PASS` |
| Source package | TGZ generation passed; 4,095 archive entries | `PASS` |

The Stage 2 full Linux result recorded 2,856 registrations at its earlier
matrix checkpoint. Stage 3 uses the freshly captured 2,855-registration tree as
its before/after comparison anchor; at capture time no Stage 3 test had been
removed.
Standalone public C/C++/high-level examples and build/install/source-tree
consumers already passed at the inherited Stage 1 and Stage 2 implementation
anchors. The fresh Stage 3 default and C++ rows compile and link representative
public C and C++ test executables on both retained pairs.

One targeted Windows C++ invocation initially selected
`HL_CPP_ptableTest` before its executable target had been built. Building that
target and rerunning the exact selection passed 2/2. This was an invocation
ordering error, not a product failure. A separate targeted C++ install attempt
was incomplete because unrelated install-owned tool targets had not been
built; the successful default install is the installation baseline.

### Normalized contracts and installed headers

The normalized contract was generated with
`config/cmake/scripts/HDF5BuildContract.cmake`.

| Contract | Records |
| --- | ---: |
| Windows default | 17,446 |
| Windows C++ | 19,566 |
| Linux default | 28,323 |
| Linux C++ | 30,771 |

Both default installs contain 65 public/generated headers. Sorted
path-and-content SHA-256 values are:

| Platform | Header-manifest SHA-256 |
| --- | --- |
| Windows/MSVC | `ed0aa9500257c1e5b0c254160cf21ffaa7f1fcf6e5f62c2e754af2fd912a360b` |
| Linux/GCC | `7ebb6ab581e671d4ffcc16747c2255ed133e3e4c1a0532d3a06978302e4586c2` |

The hashes are intentionally platform-specific because generated configuration
headers describe different retained systems. Each platform is compared only
with its own Stage 3 baseline.

These are historical pre-implementation hashes, not a claim that final header
bytes are identical. The corrected comparison and its limits are recorded in
the header evidence correction below.

### Library and symbol contract

All shared libraries use version `1000.0.0`. Linux records `SONAME`
`.so.1000` and installed `RUNPATH`
`$ORIGIN/../lib:$ORIGIN/`. Windows produces DLLs, matching import libraries,
and separate `libhdf5*.lib` static archives.

The table hashes sorted unique exported symbol names, not binary bytes:

| Library | Windows exports / SHA-256 | Linux dynamic symbols / SHA-256 |
| --- | --- | --- |
| C core | 3,964 / `399424dc5c5b51dd9d7a3f0584fe153fccd0ad250083f43820cafd0b37f8e5d0` | 4,060 / `5cc9627d28b615df09e1a4bf879f9fa9b1feec7abbec3cdc1c4f95f3998fb673` |
| C high-level | 124 / `d94474ecb153ccb482e0eb5e1d5a1e206ec50a6764bf58fcefe98b6d5e434787` | 166 / `9ebb2f1f09c20e5de79952acce9cf6699799753cbf0236afb25bfbcd43e4138d` |
| tools library | 159 / `dec22664eaf83746589c0a1f23e1aedef4e2ffd3f26c6ee6d03f1a003cbe3662` | 180 / `999c6591deea826c9558dbde8c7f6a80c8b51fce3b12af57005f4ffb7d418f2c` |
| C++ core | 1,142 / `6c1593d0c955b5d6f6d5df99483ea2b127cc032aaa964546741c045b72c94bb4` | 1,418 / `9e540c2189b998bd038cb9d8dad7fd58172d50f2e988cd3a60070cb99970ccc7` |
| C++ high-level | 35 / `2666e98aa409e4817bbdfdc613a20e12996fb8a3f62d2d7de705ad42963c6e5e` | 46 / `c4eb5d05991269021e1b034ce6625e343910fd501808049d70c774f2de44e320` |

Archive manifests hash sorted entry names:

| Archive | Entry-name SHA-256 |
| --- | --- |
| Windows ZIP | `69c2fa295cdacbd950701ec96ea5c9ba773fe5de13e5ddf2f8703d95939e42e5` |
| Linux TGZ | `c8747575010d64aa7e2dbdef0a48a5928b06f2f6cccc0ab83d79365bb8a4da69` |
| Source TGZ | `cc499b5f2f793598f70656c059e8e4cd181e310ff10ddd2927921fc22175f592` |

## Inventory Method and Counts

The regenerated lexical scan covers 1,358 tracked C/C++ source, header,
lexer/parser, and template files under `src/`, `hl/`, `c++/`, `tools/`,
`test/`, `testpar/`, and `HDF5Examples/`. Exact preprocessor searches and
canonical generator scripts were reviewed separately. Counts are case
insensitive search leads and include comments, formatter directives, public
names, and substring false positives:

| Family | Matches | Files |
| --- | ---: | ---: |
| `APPLE` | 8 | 5 |
| `CLANG` | 255 | 39 |
| `CYGWIN` | 10 | 8 |
| `DARWIN` | 12 | 5 |
| `FREEBSD` | 12 | 3 |
| `INTEL` | 182 | 15 |
| `MACOS` | 12 | 4 |
| `MINGW` | 29 | 13 |
| `NETBSD` | 2 | 2 |
| `PGI` | 28 | 3 |

## Classification Ledger

Repeated declarations, definitions, tests, and comments that implement one
semantic contract are grouped into one ledger row. Every lexical match is
covered by one of the rows below; there are no `INVESTIGATE` items.

| Owner and locations | Accepted-pair behavior | Classification | Boundary and validation |
| --- | --- | --- | --- |
| GCC diagnostics in `src/H5warnings.h` | GCC branches are active on Linux; MSVC warning macros remain separate | `SIMPLIFY_RETAINED` | Remove only Clang selectors; default and developer-warning C/C++ builds on both pairs |
| Attributes in `src/H5private.h` | GCC supports fallthrough/malloc attributes; MSVC uses the non-attribute path | `SIMPLIFY_RETAINED` | Separate Clang and Intel commits; default C/C++ builds and focused core tests |
| `bin/genparser`, `hl/src/H5LTanalyze.c`, and `hl/src/H5LTparse.c` | GCC accepts the guarded diagnostics; MSVC keeps its warning push | `SIMPLIFY_RETAINED` | One generated-source commit; regenerate and run high-level parser/lite tests |
| Bison/Flex HP, IBM, Intel, and compiler boilerplate inside generated parser output | Owned by the external generator skeleton, not HDF5 compiler admission | `KEEP_TOOLING_HISTORY` | Preserve generated boilerplate unless canonical generator output changes |
| PGI 19.10 storage macro in `src/H5Tnative.c` | Both retained compilers use ordinary `static` storage | `REMOVE_UNSUPPORTED` | Dedicated H5T commit; native datatype and conversion tests |
| Historical PGI exception rationale in `c++/src/H5File.cpp` | Documents still-active exception structure; does not select a compiler | `KEEP_TOOLING_HISTORY` | No edit |
| Darwin I/O limit in `src/H5private.h` | Windows keeps `INT_MAX`; Linux keeps `SSIZE_MAX` | `SIMPLIFY_RETAINED` | POSIX platform commit; sec2/stdio/log VFD tests |
| Darwin/FreeBSD qsort wrappers in `src/H5private.h` and `src/H5system.c` | Windows requires `qsort_s`; Linux requires GNU `qsort_r`; the feature-probe fallback remains protected | `SIMPLIFY_RETAINED` | Dedicated qsort commit; callback-context, sorting, C and C++ builds |
| `H5_HAVE_DARWIN` and Apple Universal Binary size/endianness blocks in `src/H5pubconf.h.in` | Both pairs use configured type sizes and byte order | `REMOVE_UNSUPPORTED` | Generated-header commit; header diff, macro probes, consumers |
| Darwin echo choice in `hl/tools/h5watch/testh5watch.sh.in` | Linux uses the existing non-Darwin branch; script is not run on native Windows | `SIMPLIFY_RETAINED` | Tool/test commit; Linux h5watch selection |
| Cygwin plugin traversal in `src/H5PLpath.c` | Windows takes Win32 path handling; Linux takes POSIX path handling | `SIMPLIFY_RETAINED` | H5PL commit; plugin path and dynamic-filter tests |
| Cygwin selectors in `test/API/driver/h5_api_test_driver.cpp` and `tools/test/perform/iopipe.c` | Windows uses Win32 process/pipe code; Linux uses POSIX code | `SIMPLIFY_RETAINED` | Test/tool commit; affected target builds and CTest selections |
| `H5_HAVE_MINGW` template and guards in `src/H5pubconf.h.in`, `src/H5private.h`, `src/H5system.c`, `src/H5win32defs.h`, `src/H5FDstdio.c`, and `test/cache_common.c` | Windows always selects the existing MSVC branch; Linux does not enter Win32 code | `SIMPLIFY_RETAINED` | MSVC portability commits split between public/generated headers and runtime/test code |
| `__MINGW32__` in `src/H5public.h` | Installed Windows headers keep the present MSVC `ssize_t` definition; Linux declaration is unchanged | `SIMPLIFY_RETAINED` | Dedicated installed-header commit; C/C++ consumers, layout and export comparison |
| MinGW exclusions in atomic reader/writer and direct-write performance sources | Windows keeps the current stub path; Linux keeps the POSIX implementation | `SIMPLIFY_RETAINED` | Test and performance-tool commits; build affected targets and run registered tests |
| MinGW/Cygwin provenance and file-identity comments in VFD/system/test sources | Factual rationale for shared structures or imported implementations; no selector | `KEEP_TOOLING_HISTORY` | Preserve unless an edited block makes a comment false |
| macOS rwlock and semaphore fallbacks in `src/H5TSprivate.h`, `src/H5TSrwlock.*`, and `src/H5TSsemaphore.*` | Windows keeps native synchronization and Linux keeps POSIX rwlocks and semaphores | `SIMPLIFY_RETAINED` | Dedicated H5TS commit; full thread-safe and concurrency builds and tests |
| macOS alignment examples in `src/H5Tconv_macros.h`, BSD/Cygwin conversion history in `src/H5Tpkg.h`, and NetBSD overlap/argv history in `src/H5private.h` and `test/accum.c` | The guarded code is generic conversion or valid process behavior on retained pairs | `KEEP_TOOLING_HISTORY` | No edit |
| `H5T_INTEL_*`, C++ `PredType` Intel constants, and matching datatype/conversion/tests | Public little-endian API and on-disk interoperability names on both pairs | `KEEP_API_FORMAT` | Locked; compare headers, symbols, datatype and conversion tests |
| Intel CPU/endianness terminology and h5import/h5dump data-generation paths | Describes byte order or produces deterministic interoperability data | `KEEP_API_FORMAT` | Preserve; datatype, h5import, and h5dump tests |
| `clang-format`/`clang-tidy` directives and scripts across tracked sources and headers | Developer tooling only; does not select the build compiler | `KEEP_TOOLING_HISTORY` | Preserve formatter directives; format every touched C/C++ file |
| Compiler branches in third-party `src/uthash.h` | Vendored third-party implementation | `KEEP_TOOLING_HISTORY` | No edit |
| macOS text in the active `src/H5PLsig.h` support claim | The signature format remains unchanged; current support wording must name retained systems only | `SIMPLIFY_RETAINED` | Documentation-only source comment with the relevant plugin batch |
| Lexical substring false positives such as `printelems`, `topgid`, prose words, and test corpus text | No platform/compiler meaning | `KEEP_TOOLING_HISTORY` | No edit |

No candidate changes a public symbol, structure layout, calling convention,
library version, file-format encoding, or `H5T_INTEL_*` compatibility name.
The protected qsort fallback remains because it is controlled by a feature
probe and may be reachable within Linux/GNU even though the qualified baseline
has GNU `qsort_r`.

## Implemented Atomic Boundaries

The LF checkout policy was fixed separately at `0d854b2df`. Stage 3 source and
header reduction then landed in these 14 implementation commits:

| Commit | Boundary |
| --- | --- |
| `21f41719b` | Remove unsupported Clang diagnostics, attributes, and generated parser prologues |
| `8ed9d19b1` | Remove Intel compiler exclusions from retained GCC attributes |
| `025481c70` | Remove the PGI 19.10 native-type storage workaround |
| `7ce525912` | Retain Windows `qsort_s`, GNU `qsort_r`, and the feature-probe fallback |
| `d4047a525` | Remove Apple generated-header overrides and the Darwin I/O limit |
| `ba5d60ca4` | Restrict plugin filename traversal to Windows PE and Linux ELF conventions |
| `f94c96b01` | Collapse installed and private Windows guards onto MSVC behavior |
| `98be08478` | Remove MinGW atomic reader/writer branches |
| `782656779` | Remove the MinGW cache callback-comparison workaround |
| `d5c9fef2f` | Remove the MinGW direct-write performance branch |
| `8916745d0` | Remove Cygwin process and pipe branches |
| `6ccaa7b0c` | Limit plugin-signature support wording to retained binary formats |
| `2b4bb2e77` | Remove macOS-only rwlock and semaphore implementations |
| `74288cbaa` | Remove the Darwin h5watch shell-test branch |

Each source commit passed its focused Windows/MSVC and Linux/GCC gate before it
was created. Compiler-family batches used developer-warning C and C++ builds.
The generated parser inputs and outputs traveled in the same commit.

## Final Dual-Platform Matrix

All rows below used clean source trees at `74288cbaa`,
`HDF_TEST_EXPRESS=3` where applicable, and no more than four build or CTest
jobs.

### Windows/MSVC

| Row | Final evidence | State |
| --- | --- | --- |
| Default Release | Full build and all 2,816 enabled tests passed; 37 disabled, 2,853 registered | `PASS` |
| Debug | Full build and focused C/high-level/tool smoke 7/7 passed | `PASS` |
| Static-only Release | Full build and focused smoke 7/7 passed | `PASS` |
| Shared-only Release | Full build and focused smoke 7/7 passed | `PASS` |
| C++ Release | Full combined C/C++ build passed; `CPP_testhdf5` and `HL_CPP_ptableTest` passed | `PASS` |
| Install and ZIP | Default and C++ installs passed; the default ZIP retained 120 entries | `PASS` |
| Standalone examples | C, C++, and high-level examples passed 279/279 against both build and install packages | `PASS` |
| Consumers | Build/install `find_package` consumers passed 3/3 each; `add_subdirectory` and FetchContent passed 1/1 each | `PASS` |
| Admission policy | All 12 synthetic accepted/rejected-pair cases passed | `PASS` |
| Thread modes | Thread-safe and concurrency builds passed their focused selections 6/6 each | `PASS` |

The default build produced both `libhdf5.lib` and `hdf5.dll` with its
`hdf5.lib` import library. Static-only omitted the DLL and import library;
shared-only omitted the static archive. High-level artifacts followed the same
shape.

### Linux/GCC

| Row | Final evidence | State |
| --- | --- | --- |
| Default Ninja Release | Full 3,153-step build and all 2,818 enabled tests passed; 37 disabled, 2,855 registered | `PASS` |
| Debug | Full build and focused C/high-level/tool smoke 7/7 passed | `PASS` |
| Static-only Release | Full 2,702-step build and focused smoke 7/7 passed | `PASS` |
| Shared-only Release | Full 2,748-step build and focused smoke 7/7 passed | `PASS` |
| C++ Release | Full 3,277-step combined build passed; two named C++ tests and their fixtures passed 4/4 | `PASS` |
| Unix Makefiles | Fresh default Release build passed; required core/high-level/tool selections passed | `PASS` |
| Install and TGZ | Default and C++ installs passed; the default TGZ retained 122 entries | `PASS` |
| Standalone examples | C, C++, and high-level examples passed 279/279 against both build and install packages | `PASS` |
| Consumers | Build/install `find_package` consumers passed 3/3 each; `add_subdirectory` and FetchContent passed 1/1 each | `PASS` |
| Wrappers | `h5cc` and `h5c++` passed show/configure, compile, link, and run checks; `-nohl` omitted HL; four `.pc` files report 2.3.0 | `PASS` |
| Admission policy | All 12 synthetic accepted/rejected-pair cases passed | `PASS` |
| Thread modes | Thread-safe and concurrency builds passed their focused selections 6/6 each | `PASS` |

Static-only emitted `libhdf5.a` without a shared library. Shared-only emitted
the versioned shared library without the static archive.

The Stage 2 count of 2,856 registrations came from a reused cache containing
`HDF5_BUILD_UTILS=ON` before `test/` was processed, which enabled
`H5TEST-mirror_vfd`. A fresh first configure registers 2,855 tests and exactly
matches the Stage 3 before/after baseline. Stage 3 did not change CMake test
registration.

## Contract and Compatibility Results

The recorded final contracts have the following counts. Counts alone do not
establish content equality: generated-header text changes require the semantic
comparison below, and installation records must use equivalent capture inputs.

| Contract | Baseline | Final |
| --- | ---: | ---: |
| Windows default | 17,446 | 17,446 |
| Windows C++ | 19,566 | 19,566 |
| Linux default | 28,323 | 28,323 |
| Linux C++ | 30,771 | 30,771 |

A second configure sees the pre-existing `HDF5_BUILD_UTILS` ordering issue and
adds `H5TEST-mirror_vfd`; contracts were therefore captured from fresh trees
with the File API query registered before their first configure, matching the
3A method.

The retained build-only first-configure captures have 17,323 Windows default
records and 28,204 Linux default records. The default totals in the table also
include 123 and 119 installation-related records, respectively. Installation
and CPack staging prefixes must be normalized to the same logical prefix before
comparing these records; their different local paths are not product changes.

Default installs retain the 65-header name set, and final C++ installs contain
101 headers. Header bytes do change as detailed below; the former statements
that both sets matched their baselines byte for byte are withdrawn. The
previous execution recorded zero additions or removals in all five exported
symbol sets: C core, C high-level, tools, C++ core, and C++ high-level. Those
symbol counts and hashes remain separate evidence from header-text comparison.

Windows library and import-library names are unchanged. Linux libraries retain
version `1000.0.0`, `SONAME` suffix `.so.1000`, and installed RUNPATH
`$ORIGIN/../lib:$ORIGIN/`. Build-tree and install-tree package consumers prove
both static and shared export sets. The full default suites cover datatype,
conversion, object-copy/reference, and cross-platform compatibility tests; no
public `H5T_INTEL_*` name or file-format path changed.

The final Linux binary-package manifest matches the pre-Stage-3 122-entry
manifest name for name, and the Windows binary package retains its 120-entry
shape. The clean source TGZ has 4,096 entries: the only path added to the 4,095
entry baseline is this Stage 3 results document. No local build tree, IDE data,
or validation log is present.

The high-level parser was regenerated with Flex 2.6.4, Bison 3.8.2, and M4
1.4.21. `H5LTparse.c` and its header reproduced exactly after repository
formatting; the Flex output differed only in six generated `#line` counters,
with executable lexer content unchanged. This is a normalized reproducibility
pass.

### Header evidence correction, 2026-09-05

The review compared the retained Windows default install at `c305c9bfc` with
the final default install at `74288cbaa`. Both contain the same 65 header
names. Raw bytes differ in all 65 files. After converting only CRLF to LF,
63 files match, consistent with the LF checkout change in `0d854b2df`;
exactly `H5public.h` and `H5pubconf.h` still differ in content.

The following SHA-256 values hash UTF-8 text after CRLF-to-LF conversion,
without removing comments, whitespace, or configuration values:

| Windows header | Baseline | Final |
| --- | --- | --- |
| `H5public.h` | `8ba7e54cce13ce88a0ebfd0383d4998fe1dfbe9359c35be386ccb36899ab71d3` | `fb8929706f28b2134e1283f452f87c2f789c558e7aeda3a64803504dc6fd110e` |
| `H5pubconf.h` | `13ee95c49249d416e9369b2cef95ec41074187a17dfea37e1bc9b1e037645638` | `333295e885a358ddb5ca6411b3bdb383a8367091402659b274ce9b4926dea470` |

The content deltas are expected:

- `H5public.h` removes the MinGW exclusion from the Windows `ssize_t` guard.
  MSVC still selects `SSIZE_T`; Linux/GNU still selects the existing POSIX path.
- `H5pubconf.h` removes unused MinGW/Darwin entries and Apple-only size and
  endianness alternatives. The configured values used on both retained pairs
  remain the selected values.

A supplemental Linux comparison used the retained default install from
`6ee2f392e` and the final install from `74288cbaa`. It found the same 65 header
names and only the same two changed files. This is not relabeled as the
original 3A install: Git confirms that `H5public.h` and `H5pubconf.h.in` are
unchanged between `6ee2f392e` and `c305c9bfc`, but the retained installs have
different configured prefixes in `H5_DEFAULT_PLUGINDIR`. That configuration
delta is distinct from the source reduction and is not silently discarded.

Fresh preprocessing checks of a translation unit containing only
`#include "hdf5.h"` passed against both before/after default include trees:

| Compiler and mode | Comparison | Result |
| --- | --- | --- |
| MSVC 19.51, C11 | `/EP /utf-8 /TC /std:c11`; ignore blank lines and trim each remaining line | Identical effective declarations |
| MSVC 19.51, C++14 | `/EP /utf-8 /TP /std:c++14`; same whitespace normalization | Identical effective declarations |
| GCC 15.2, C11 | `-E -P -std=c11 -x c`; exact output comparison | Identical effective declarations |
| G++ 15.2, C++11 | `-E -P -std=c++11 -x c++`; exact output comparison | Identical effective declarations |

To reproduce, run each compiler twice with `-I <before-install>/include` and
`-I <after-install>/include` (`/I` for MSVC), using the same compiler and system
include paths within a pair. Capture standard output and compare it in order
using the normalization specified above. Preprocessing is evidence about
effective declarations, not a replacement for linking, ABI-layout checks,
exported-symbol checks, or the prior consumer tests.

The retained Windows C++ baseline install is incomplete: it has 57 headers,
not 101. A complete 101-to-101 installed-file comparison is therefore not
established by that artifact. Git confirms no changes to C++ wrapper headers
under `c++/src/` or `hl/c++/src/` between `c305c9bfc` and `74288cbaa`;
the C++ preprocessing checks above cover the changed C public headers. The
previously recorded C++ build, consumer, and symbol checks remain the
compatibility evidence. This correction did not rerun the full CTest matrix
or a comprehensive ABI audit and does not claim a new one.

### Linux plugin filename clarification, 2026-09-05

Commit `ba5d60ca4` changed filename filtering in both POSIX plugin-discovery
loops in `src/H5PLpath.c`, from accepting `.so` or `.dylib` to accepting `.so`.
It did not change plugin compilation, output filenames, or binary formats.
A valid ELF filter with ID 257 was accepted under either suffix before Stage
3; after Stage 3 it is accepted as `libprobe.so` and skipped as
`libprobe.dylib`. The earlier implementation's file blob is identical at
`6ee2f392e` and `c305c9bfc`, and the final test used `74288cbaa`.

The user explicitly confirmed keeping this restriction on 2026-09-05.
Preserving Linux plugins under macOS-style filenames is not required by the
agreed product scope. This is an accepted filename-contract narrowing, not
evidence of a failure to produce Linux shared libraries, and it is not an
outstanding Stage 3 blocker.

## Optional-Row Disposition

Thread-safe and concurrency modes required dedicated optional reconfigures;
both were rebuilt and tested on Windows and Linux. Plugin traversal was also
affected, and default full builds plus plugin-focused tests cover the retained
Windows and Linux `H5PLpath` branches. System and bundled compression, parallel,
subfiling, remote external-plugin dependency builds, coverage, STGZ, and DEB
own no changed Stage 3 behavior and retain their passing Stage 2 evidence. The
six user-deferred, unavailable Stage 2 rows remain untouched, so no new
prerequisite decision is required.

`tools/test/perform/direct_write_perf.c` has no CMake target or CTest
registration; forced MSVC and GCC syntax checks covered its retained Windows
stub and Linux implementation. The optional API driver has pre-existing local
include-directory and `H5API_CLEAN_PROCESSES` spelling defects in its standalone
target path. Validation-only corrections allowed both native branches to build;
registered API tests and `PERFORM_iopipe` passed on both platforms. Repairing
those independent build-definition defects is outside Stage 3.

Two validation invocations needed environment corrections rather than source
changes. A CLion terminal timeout left a Make process active, so a concurrent
retry briefly linked an incomplete test object; a new Unix Makefiles tree built
cleanly. Windows build-tree examples initially lacked the multi-config DLL
directory in `PATH`; the documented runtime path was added and all 279 tests
passed. Direct non-login WSL calls also omitted the user-local `pkg-config`, so
wrapper checks used the qualified login-shell environment.

## Final Residual Audit

The repeated case-insensitive scan over the original 1,358-file scope produced:

| Family | Matches | Files |
| --- | ---: | ---: |
| `APPLE` | 3 | 3 |
| `CLANG` | 225 | 37 |
| `CYGWIN` | 6 | 5 |
| `DARWIN` | 0 | 0 |
| `FREEBSD` | 1 | 1 |
| `INTEL` | 179 | 14 |
| `MACOS` | 4 | 1 |
| `MINGW` | 7 | 6 |
| `NETBSD` | 2 | 2 |
| `PGI` | 17 | 2 |

Exact active-selector review found no project-owned unsupported implementation.
The remaining HP-UX, AIX, and `__ICC` tests in `hl/src/H5LTparse.c` are emitted
by the Bison skeleton. Remaining compiler branches in `src/uthash.h` are vendored
third-party code. Other lexical matches are protected formatter directives,
public/file-format `H5T_INTEL_*` names, historical or interoperability comments,
and substring false positives. No item remains `INVESTIGATE`.

## Completion and Handoff

> Source and header compatibility code now implements the Windows/MSVC and
> Linux/GNU support contract; protected API, ABI, file-format, and
> supported-pair variants remain intact; affected Stage 1 and Stage 2 validation
> rows pass on both baselines.

Stage 3 is Completed at implementation anchor `74288cbaa`, with its completion
review accepted on 2026-09-05. The next continuation point is preparation and
review of the Stage 4 plan. Stage 4 remains a separate, unplanned and unexecuted
final project audit that requires its own plan and approval.
