# Stage 3 Source and Header Platform Reduction Results

## Status

- State: in progress; Work Package 3A complete
- Baseline execution date: 2026-09-04
- Source implementation anchor: `81e96c889`
- Clean validation tree: `c305c9bfc`
- Stage 3 plan:
  [CMakePlatformSupportReductionStage3.md](CMakePlatformSupportReductionStage3.md)
- Parent plan:
  [CMakePlatformSupportReduction.md](CMakePlatformSupportReduction.md)
- Portable handoff: [../../REFACTORING_PROGRESS.md](../../REFACTORING_PROGRESS.md)
- `HDF_TEST_EXPRESS`: `3`
- Maximum build and CTest parallelism: 4

Work Package 3A is complete. Both retained target/compiler pairs were qualified
at the same clean tracked tree, the pre-implementation product contract was
captured, and every source/header inventory family has a non-investigative
classification. No source or header compatibility edit had started when this
baseline was recorded.

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
its before/after comparison anchor; no Stage 3 test has yet been removed.
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
| `H5TSprivate.h` pthread-rwlock and semaphore fallbacks | Feature-probe fallbacks remain part of accepted Linux/GNU variants | `KEEP_RETAINED_VARIANT` | No platform-keyword removal |
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

## Planned Atomic Boundaries

The resolved ledger fixes the implementation order:

1. Remove Clang-only diagnostics and attributes, including regenerated
   high-level parser prologues.
2. Remove Intel-compiler exclusions from retained GCC attributes.
3. Remove the PGI native-type storage workaround.
4. Reduce qsort and POSIX runtime selection to the retained systems.
5. Remove Apple generated-header overrides.
6. Remove Cygwin plugin-path behavior.
7. Simplify installed and private Windows guards to MSVC behavior.
8. Remove remaining unsupported-only test, performance-tool, and h5watch
   branches.
9. Run the residual audit, full dual-platform matrix, contract comparison, and
   final Stage 3 documentation checkpoint.

Each boundary inherits the exact validation and commit rules in the Stage 3
plan. Work Package 3B is the next continuation point.
