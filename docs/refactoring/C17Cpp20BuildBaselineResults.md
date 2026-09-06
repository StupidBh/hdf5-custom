# Phase 2 C17 and C++20 Build Baseline Results

## Status

- State: In progress
- Plan approval: 2026-09-05
- Execution baseline: `a1adbc32b7604d6a57d6dcab1a965258ff48f148`
- Implementation anchor: `1ce441445159e5f7eb689853e27195bb4be84d05`
- Work Package 2A: Complete
- Work Package 2B: Complete
- Work Package 2C: Complete
- Work Package 2D: Complete
- Work Package 2E: Complete
- Work Package 2F: Complete
- Work Package 2G: Complete
- Work Package 2H validation matrix: Complete
- Work Package 2H closure: Awaiting explicit environment dispositions
- Parent plan: [C17Cpp20BuildBaseline.md](C17Cpp20BuildBaseline.md)
- Portable handoff: [../../REFACTORING_PROGRESS.md](../../REFACTORING_PROGRESS.md)
- Required `HDF_TEST_EXPRESS`: `3`
- Maximum combined build and CTest parallelism: 4 per physical host

The user approved the plan and its distinction between the C17/C++20 project
build baseline and the retained C99/C++11 installed-header consumer baseline on
2026-09-05. Work Package 2A selected the execution baseline, qualified both
required validators, confirmed the resource limit, and performed read-only
optional-capability discovery. No package was installed and no external system
was changed.

## Work Package State

| Package | State | Result or next gate |
| --- | --- | --- |
| 2A Approval and validator qualification | `PASS` | Approved at `a1adbc32b`; both required validators and optional capabilities recorded below. |
| 2B Freeze the pre-migration contract | `PASS` | Fresh product, interface, package, consumer, and file-format evidence passed at `a1adbc32b`. |
| 2C External standard probe | `PASS` | Both strict-mode product matrices built; one C readiness defect and two retained deltas are classified below. |
| 2D C17 readiness repairs | `PASS` | `310fb4323` preserves MSVC complex support in both C11 and strict C17. |
| 2E Establish C17 | `PASS` | `8c177f31b` establishes strict C17 for all project-owned C targets without dependency or consumer leakage. |
| 2F C++20 readiness repairs | `PASS` | `b84f9e4a7` preserves the MSVC native-complex implementation in C++20; dual-mode targets, consumers, and symbols are classified below. |
| 2G Establish C++20 | `PASS` | `1ce441445` establishes strict C++20 without dependency or consumer leakage. |
| 2H Full product and handoff gate | `PENDING_DECISION` | Every runnable row passed at `1ce441445`; explicit approval is required for seven proposed environment dispositions. |

## Baseline Identity

The selected execution baseline is `a1adbc32b7604d6a57d6dcab1a965258ff48f148`.
The tracked tree was clean at selection time. Nine unrelated untracked entries
under `.codex/` and `.idea/` were left untouched and are excluded from every
commit and evidence product.

Relative to the approved scope clarification at `2e0772f4c`, the execution
baseline changes only `.clang-format` key/value spacing and the portable
handoff text. It changes no C/C++ source, header, CMake implementation, test,
example, install, or packaging logic. The product implementation inherited from
the completed platform-support direction remains `f6ff66fed`.

## Qualified Validators

Fresh tool discovery used CLion's project and integrated-terminal services. The
active CLion configuration also resolved `src/H5.c` to the recorded MSVC
compiler and the existing strict C11 project mode. The same validator versions
passed the complete Stage 4 product gate earlier on 2026-09-05; Work Package 2B
created fresh Phase 2 product evidence rather than inheriting those builds.

| Component | Windows baseline | Linux baseline |
| --- | --- | --- |
| Target system | Windows 11 NT 10.0.26100 | Ubuntu 26.04.1 LTS under WSL2 |
| Kernel | NT 10.0.26100 | `6.18.33.2-microsoft-standard-WSL2` |
| Architecture | x64 | x86_64, glibc 2.43 |
| Compiler | MSVC 19.51.36256.0, toolset 14.51.36231 | GCC/G++ 15.2.0 |
| Target identity | MSVC x64 | `x86_64-linux-gnu` for C and C++ |
| CMake and CTest | 4.4.3 | 4.2.3 |
| Primary generator | Visual Studio 18 2026 | Ninja 1.13.2 |
| Secondary generator | Not applicable | GNU Make 4.4.1 |
| Additional build metadata | MSBuild 18.10.0.37909, Windows SDK 10.0.26100.0 | pkg-config 2.5.1, Perl 5.40.1 |
| State | `PASS` | `PASS` |

Windows compilation will use `CL=/utf-8`. Build and CTest jobs on Windows and
WSL share one physical-host budget: their combined active job count must never
exceed four. Successive CLion terminal operations reuse an existing terminal;
no superseded build, test, server, or debugger session may remain active.

The Windows source volume had approximately 759 GiB free. The WSL root volume
had approximately 927 GiB free, and its mounted source volume reports the same
Windows free space. This is sufficient for the planned external build, install,
package, contract, and consumer trees under the four-job execution policy.

## Optional Capability Discovery

The classification below records discovery only. `AVAILABLE` means that the
required external input is currently present; it does not replace the build and
runtime gate in Work Package 2H. `MISSING_ENV` means that no Phase 2 build should
claim that row without a fresh capability decision. Existing Stage 2 artifacts
are prerequisites only where explicitly named, not inherited product evidence.

| Capability | Windows | Linux |
| --- | --- | --- |
| Network-backed bundled compression and external plugins | `AVAILABLE`: the command-scoped local proxy returned HTTP 200 from GitHub. | `AVAILABLE`: use the same host proxy without routing localhost or LAN services through it. |
| System zlib/libaec | `MISSING_ENV`: a zlib header is present, but no libaec/SZIP headers or qualified MSVC dependency pair was found. | `AVAILABLE`: the retained isolated Stage 2 prefix contains zlib 1.3.1 and libaec/libsz 1.1.5 headers, static libraries, shared libraries, and CMake/pkg-config metadata. |
| Parallel HDF5 and subfiling | `MISSING_ENV`: Microsoft MPI runtime is present, but standard SDK headers/libraries and `MSMPI_INC`/`MSMPI_LIB64` are absent. | `AVAILABLE`: OpenMPI 5.0.10 wrappers, headers, and launcher are present. |
| Parallel tools | `MISSING_ENV`: mpiFileUtils/libcircle/DTCMP inputs were not found. | `MISSING_ENV`: pkg-config cannot discover mpiFileUtils, libcircle, or DTCMP. |
| Thread-safe and concurrency | `AVAILABLE`: no external prerequisite. | `AVAILABLE`: no external prerequisite. |
| ROS3 | `MISSING_ENV`: no qualified AWS SDK input was found. | `MISSING_ENV`: aws-c-s3 development metadata is absent. |
| HDFS | `MISSING_ENV`: JDK, Hadoop, and libhdfs inputs are absent. | `MISSING_ENV`: `javac`, Hadoop, and libhdfs inputs are absent. |
| Signed plugins | `MISSING_ENV`: Strawberry OpenSSL 3.6.1 files exist, but no qualified MSVC signing tool/input set was found. | `MISSING_ENV`: OpenSSL 3.5.5 runtime exists, but development metadata and signing inputs are absent. |
| Coverage | Not applicable to the MSVC release baseline. | `AVAILABLE`: lcov/genhtml 2.0-1 are present. |
| Package generators | `AVAILABLE`: required ZIP path; NSIS and WiX are absent. | `AVAILABLE`: required TGZ plus STGZ and DEB tooling; `rpmbuild` is absent. |
| Installed pkg-config and wrappers | Windows pkg-config is not currently on `PATH`; wrapper checks remain product outputs. | `AVAILABLE`: pkg-config 2.5.1 is present; wrapper checks remain product outputs. |
| Perl-dependent paths | `AVAILABLE`: Strawberry Perl 5.42.3 is present. | `AVAILABLE`: Perl 5.40.1 is present. |

Missing optional inputs are not functionality removals and do not inherit the
Stage 2 deferral decisions automatically. Work Package 2H requires a fresh user
decision for every row that remains unavailable and is eligible for deferral.

## Pre-Migration Evidence Register

Work Package 2B ran from clean archive copies of `a1adbc32b`. Windows and WSL
workloads ran sequentially, every build and CTest command used at most four
jobs, and all build, install, package, consumer, and evidence files remained
outside the repository. The product implementation is still `f6ff66fed`; the
later commits through the execution baseline change only documentation and
`.clang-format` spelling.

| Evidence family | Windows | Linux | State |
| --- | --- | --- | --- |
| Default and C++ Release builds/full suites | Both complete builds and suites passed. | Both complete builds and suites passed. | `PASS` |
| Cache, target, test, and CMake File API contracts | First/repeat contracts match byte for byte. | First/repeat contracts match byte for byte. | `PASS` |
| Exact C11/C++11 modes and target ownership | All 340 C/C++ compile groups report standard 11; effective compiler modes are recorded below. | The same 340 compile groups report standard 11 and emit GNU C11/C++11 modes. | `PASS` |
| Generated headers and build settings | Complete hashes retained for both configurations. | Complete hashes retained for both configurations. | `PASS` |
| Artifacts, installs, exports, and packages | Complete relative manifests and ZIP path sets retained. | Complete relative manifests, symlink records, and TGZ path sets retained. | `PASS` |
| C/HL/C++/HL C++ symbols and public layouts | Five case-sensitive symbol sets and C/C++ layout probes retained. | The same five symbol families and layouts retained. | `PASS` |
| Headers and normalized effective declarations | 65/101 header manifests and three preprocessor captures retained. | 65/101 header manifests and three preprocessor captures retained. | `PASS` |
| pkg-config and compiler wrappers where supported | No pkg-config executable is available; CMake consumers cover installed targets. | Four `.pc` files and both wrappers passed. | `PASS` |
| Build/install/source-tree consumers | Build/install package, `add_subdirectory()`, and FetchContent passed. | The same four integration styles passed. | `PASS` |
| Legacy C99 and C++11 installed consumers | CMake minimum properties passed; MSVC has no exact C99/C++11 switch. | Exact `-std=c99` and `-std=c++11` compile/link/run passed. | `PASS` |
| Representative HDF5 file round trips | Read the Linux-created dataset and value. | Read the Windows-created dataset and value. | `PASS` |

### Release Builds and Tests

| Pair and configuration | Registered | Enabled passed | Disabled | Skipped | Failed | Time | State |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Windows default | 2,853 | 2,816 | 37 | 0 | 0 | 155.52 s | `PASS` |
| Windows C++ | 2,887 | 2,850 | 37 | 0 | 0 | 154.45 s | `PASS` |
| Linux default | 2,855 | 2,818 | 37 | 0 | 0 | 143.14 s | `PASS` |
| Linux C++ | 2,889 | 2,852 | 37 | 0 | 0 | 144.58 s | `PASS` |

All four runs used `HDF_TEST_EXPRESS=3`. The sorted `name|disabled` inventory
hashes are respectively `86d7ab755940`, `1bd304d34c17`, `90819bf8b56c`, and
`c1ddb98efbeb`; the full SHA-256 values remain in the external evidence index.
No skipped test was reported. The Windows C++ build log is the warning-bearing
superset of the default product targets. It records 311 existing MSVC warnings
across 13 codes, led by C4251, C4101, and C4244. Linux records 28 warnings for
default and 30 for C++, primarily discarded qualifiers and ignored results;
the two C++-only additions are allocation-size diagnostics. These warnings are
comparison baselines, not standard blockers.

### CMake Contracts and Inventories

The repository contract script normalizes source, build, and install roots and
sorts its records. The accepted first and same-argument repeat captures are
identical on every row:

| Pair and configuration | First/repeat records | First/repeat SHA-256 | Post-install records | Post-install SHA-256 |
| --- | ---: | --- | ---: | --- |
| Windows default | 17,323 | `5ed0c91b3f96` | 17,446 | `d6f2da0782fb` |
| Windows C++ | 19,566 | `c84c73b0e27c` | 19,735 | `90ec2f5f20c7` |
| Linux default | 28,204 | `d63d511c593b` | 28,313 | `5ad9af122260` |
| Linux C++ | 30,771 | `40437eef3a43` | 30,927 | `b04778ea4919` |

Complete sorted target inventories contain 352/376 Windows default/C++
targets and 374/398 Linux default/C++ targets. Their SHA-256 prefixes are
`b4598e226027`, `e0caeaa08770`, `97d76d343450`, and `03b8b5d18fe1`.
Normalized cache inventories contain 210/230 Windows and 211/231 Linux
entries. Artifact-record inventories contain 637/683 Windows and 317/340
Linux entries. Later comparisons use exact content hashes, never counts alone.

### Effective Language Modes

The C++ configurations contain 317 C compile groups and 23 C++ compile groups
on each validator. Every group reports `standard=11` in the CMake File API; the
sorted group manifests hash to `9427705b5cd0` on Windows and
`6e3e157b2a6d` on Linux. Compiler evidence refines that minimum-property view:

- MSVC emits `/std:c11` for all 317 C groups. It emits no `/std:c++` option for
  the 23 C++11-minimum groups because MSVC has no C++11 mode. The representative
  target-equivalent probe reports `_MSVC_LANG=201402`, `_MSC_VER=1951`, and the
  legacy `__cplusplus=199711` value because `/Zc:__cplusplus` is not enabled.
- GCC receives the existing raw `-std=c11` setting followed by CMake's
  `-std=gnu11` on all 317 C groups, so the last and effective option is GNU C11.
  All 23 G++ groups receive `-std=c++11`.

This distinction is a frozen baseline fact: `standard=11` is the declared
CMake minimum, while the effective compiler dialect is MSVC C11/default C++14
or GNU C11/C++11. Work Packages 2E and 2G must prove exact strict C17/C++20
rather than compare only the CMake property.

### Generated Configuration and Public Headers

`H5pubconf.h` is identical between default and C++ builds on a validator:
SHA-256 `55b6c7b4c523` on Windows and `86e98b45b234` on Linux. Default/C++
`libhdf5.settings` hashes are `a5e12debd457`/`87f4815de37c` on Windows and
`6feb2f606782`/`2e3bdcfaacd8` on Linux. The settings currently report the raw
C11 global flag; C++ target standard flags are not represented in the global
C++ flags field.

Complete installed-header manifests contain 65 default and 101 C++ names on
each platform. Their platform-local SHA-256 identifiers are:

| Validator | Default headers | C++ headers |
| --- | --- | --- |
| Windows | `8397be36c441` | `78616b272100` |
| Linux | `4440e891705c` | `0f20a343fcaf` |

These raw manifests are compared only on the same validator and with the same
normalized install-prefix policy. Fresh installed-header preprocessing has
the following raw identifiers:

| Validator and input | Effective mode | Bytes | SHA-256 |
| --- | --- | ---: | --- |
| MSVC `hdf5.h` | C `/std:c11` | 416,045 | `1d94c8e9d1d0` |
| MSVC `hdf5.h` | C++ compiler default | 434,365 | `11d9998f0d6c` |
| MSVC `H5Cpp.h` | C++ compiler default | 1,856,935 | `4d89cc27a038` |
| GCC `hdf5.h` | C11 | 183,187 | `034d92791d68` |
| G++ `hdf5.h` | C++11 | 197,766 | `79502eacf498` |
| G++ `H5Cpp.h` | C++11 | 671,991 | `59f59c29e87c` |

The raw compiler outputs are same-validator identifiers. Later declaration
comparisons normalize only line endings, trailing whitespace, configured
absolute prefixes, and compiler line markers; they do not normalize tokens or
declarations.

### Symbols, Layouts, Installs, and Packages

Exported names are sorted case-sensitively, deduplicated, encoded as UTF-8 with
LF separators, and stored without a final newline. The fresh baseline is:

| Validator | Library | Names | SHA-256 |
| --- | --- | ---: | --- |
| Windows | C core | 3,964 | `399424dc5c5b` |
| Windows | C high-level | 124 | `d94474ecb153` |
| Windows | Tools | 159 | `dec22664eaf8` |
| Windows | C++ core | 1,143 | `1dd526d95d73` |
| Windows | C++ high-level | 35 | `2666e98aa409` |
| Linux | C core | 4,060 | `78cbba308db6` |
| Linux | C high-level | 166 | `48e9bc6c183f` |
| Linux | Tools | 180 | `a83f9ceeb99c` |
| Linux | C++ core | 1,418 | `d751026b67d0` |
| Linux | C++ high-level | 46 | `c69d27592480` |

Representative C and C++ layout probes agree across the two x64 validators.
`hid_t`, `hsize_t`, and `haddr_t` are 8-byte/8-aligned;
`H5A_info_t`, `H5F_info2_t`, `H5L_info2_t`, and `H5O_info2_t` are respectively
24, 80, 40, and 72 bytes, all 8-aligned. `H5::H5File`, `H5::DataSet`,
`H5::DataType`, `H5::PropList`, and `H5::Exception` are respectively 32, 24,
32, 16, and 72 bytes, all 8-aligned. Later probes compare the complete output
on the same compiler, architecture, and consumer mode.

Windows default/C++ installs contain 114/158 regular files and 115/159 install
manifest entries; their full relative file/hash manifests are
`084a108a5b9d`/`de79c38e89f5`. The ZIPs contain 120/164 sorted entries and are
8,292,195/9,262,806 bytes with archive hashes `3a0c8939ffcc` and
`29ff23fcd0bc`. Linux default/C++ installs contain 103/146 regular files,
109/156 install entries, and 6/10 symlinks; their relative file/hash manifests
are `c7ab675e1a1d`/`be31db1bc324`. The TGZs contain 122/169 sorted entries and
are 6,565,268/7,055,696 bytes with hashes `204b074a2564` and
`2b006dab5cf5`.

Both installations export the same ten static/shared C, tools, HL, C++, and HL
C++ imported target names. Installed CMake exports contain no `c_std_*`,
`cxx_std_*`, raw standard option, or `INTERFACE_COMPILE_FEATURES` requirement.
Linux preserves SONAME `libhdf5.so.1000`, RUNPATH
`$ORIGIN/../lib:$ORIGIN/`, and isolated installed-tool resolution. Installed
`h5dump` reports 2.3.0 on both validators.

The clean source TGZ is 40,396,033 bytes with SHA-256 `b9f11acc668f`.
After removing its four-component packaging prefix and directory entries, its
3,936 sorted file paths are byte-identical to `git ls-tree` at
`a1adbc32b`; both manifests hash to `8c249848fb55`. No local IDE, agent, build,
or evidence path entered the source package.

### Consumers, Metadata, and File Format

| Consumer | Windows | Linux | State |
| --- | --- | --- | --- |
| Build-tree `find_package` C shared, HL static, C++ shared | 3/3 | 3/3 | `PASS` |
| Install-tree `find_package` C shared, HL static, C++ shared | 3/3 | 3/3 | `PASS` |
| Local-source `add_subdirectory()` | 1/1 | 1/1 | `PASS` |
| Local-source FetchContent | 1/1 | 1/1 | `PASS` |
| Installed C99/C++11 minimum consumer | 3/3 | 3/3 with exact flags | `PASS` |
| Installed wrappers, default HL and `-nohl` | Not applicable | Four compile/link/run cases | `PASS` |
| Installed pkg-config C/C++ consumers | Not applicable | Two compile/link/run cases | `PASS` |

The four Linux `.pc` files validate and report version 2.3.0. `h5cc` resolves
to C core plus HL by default and C core under `-nohl`; `h5c++` resolves the C++,
HL C++, HL C, and core libraries by default and the C++/C cores under `-nohl`.
No wrapper or pkg-config consumer metadata exports a language-standard flag.

The installed-consumer CMake projects explicitly request C99 and C++11 with
extensions disabled. GCC/G++ compile them with exact `-std=c99` and
`-std=c++11`; MSVC accepts the corresponding CMake minimum properties but has
no exact switches for those modes. All consumers compile, link, run, and use
only the selected build or install runtime path.

The high-level consumer creates a one-element integer dataset named `value`.
Windows `h5dump` read the Linux-created file and Linux `h5dump` read the
Windows-created file; both report `(0): 42`. The two HDF5 files intentionally
have distinct byte hashes, so later compatibility compares successful
cross-platform reads and semantic dump content rather than requiring identical
container bytes.

## Strict C17/C++20 External Probe

Work Package 2C used fresh diagnostic source copies made from documentation
checkpoint `5b871fd3c`. The copies were outside the repository and changed only
the standard-ownership declarations required to request C17/C++20, require the
selected standards, disable extensions, remove the raw C11 option injection,
and restore C++20 after the API driver's third-party KWSYS population. No probe
implementation was copied into the tracked tree.

| Product | Effective modes | Build | Focused tests |
| --- | --- | --- | --- |
| Windows default | 317 C groups at `/std:c17` | `PASS` | 7/7 with fixtures |
| Windows C++ | 317 C groups at `/std:c17`; 23 C++ groups at `/std:c++20` | `PASS` | 9/9 with fixtures |
| Linux default | 317 C groups at exact `-std=c17` | `PASS` | 7/7 with fixtures |
| Linux C++ | 317 C groups at exact `-std=c17`; 23 C++ groups at exact `-std=c++20` | `PASS` | 9/9 with fixtures |

The focused selection covered the core `testhdf5` base case, high-level lite,
and `h5diff` paths in every row, plus the C++ core and high-level packet-table
tests in C++ rows. Default and C++ builds completed with four jobs and no
compile or link failure. The normalized contracts contain 17,325 and 19,568
records on Windows and 28,204 and 30,771 records on Linux for default/C++.
Their SHA-256 values begin `0042413edf4c`, `b1325e0200bc`, `31f4df6d58d1`, and
`3ca2a9722619`, respectively.

Every product-owned C compile group moved to standard 17 and every applicable
product-owned C++ group moved to standard 20. No default configuration loaded a
C++ compiler. The API driver retained KWSYS at its own C++11 declaration and
restored C++20 only for HDF5-owned driver targets, so the probe found no
third-party standard leakage.

The Linux default build retained its 28 baseline warning lines. The C++20 build
retained the 30 C++ baseline lines and added five GCC 15 `-Wlarger-than`
diagnostics for the two fixed-size multidimensional `new` expressions in
`c++/test/dsets.cpp`.
Those tests compile and pass, warnings are not promoted to errors, and the plan
forbids source cleanup that is not required by the migration. Finding `P2-03`
therefore records the delta without a source change.

The same-validator generated-header comparison found only two feature groups:

- MSVC `/std:c17` defines `__STDC_NO_COMPLEX__`; the current outer configure
  guard consequently skips HDF5's existing `_Fcomplex`, `_Dcomplex`, and
  `_Lcomplex` fallback. `H5_HAVE_COMPLEX_NUMBERS` and the three native complex
  sizes disappear even though the compiler-specific implementation remains
  available. This is a C17 readiness defect, not an accepted compatibility
  change.
- Strict GNU C17 hides the non-ISO `timezone` global, so `H5_HAVE_TIMEZONE`
  changes from 1 to undefined. `H5_HAVE_TM_GMTOFF` remains 1 and is the earlier
  branch used by `H5_make_time()`, while complex support and all type sizes are
  unchanged. This accurately reflects strict namespace visibility and causes no
  active runtime or ABI change.

## C17 Readiness Repair

Commit `310fb4323` closes `P2-01`. `ConfigureChecks.cmake` now treats
`__STDC_NO_COMPLEX__` as evidence only against the ISO `_Complex` types. MSVC
continues into the existing `_Fcomplex`, `_Dcomplex`, and `_Lcomplex` fallback,
while non-MSVC compilers with that macro retain the prior disabled result. No C
source, public header, declaration, symbol, layout, or file-format logic changed.

Fresh Windows C11 and strict-C17 configures both selected the MSVC fallback and
generated `H5_HAVE_COMPLEX_NUMBERS=1` with float, double, and long-double complex
sizes 8, 16, and 16. Their complete generated `H5pubconf.h` files are identical
to each other, and the C11 file is identical to the frozen Windows baseline.
Both modes built the static/shared core libraries, `dt_arith`, `ntypes`,
`h5dump`, and its standard test-data target. The focused complex selection
passed 16/16 in each mode at `HDF_TEST_EXPRESS=3` with four jobs.

Fresh Linux C11 and strict-C17 Ninja configures continued to select the ISO C99
complex types. Each completed 1,137 affected build steps and passed the same
16/16 focused selection with four jobs. Their generated-header comparison has
only the already classified `H5_HAVE_TIMEZONE` delta; every complex macro and
size is unchanged. The first Windows C11 CTest invocation preceded the explicit
standalone test and test-data targets and was discarded; after those targets
were built, the accepted rerun passed. No build, CTest, CMake, Ninja, or MSBuild
worker remains active.

## C17 CMake Baseline

Commit `8c177f31b` completes Work Package 2E. The root and standalone-example
entry points now establish the C standard immediately after `project()`, before
platform validation or feature probes. An absent request selects C17; explicit
C90, C99, and C11 requests fail with a direct diagnostic; C23 is retained. The
selected standard is required and extensions are disabled.

The prior late C11 assignment and raw compiler-option injection are removed.
`libhdf5.settings` and the embedded build settings report `C Standard: C17`
without representing the standard as a global C flag. FetchContent projects,
external VOL connectors, and KWSYS are configured within a saved/restored
language-variable scope, so they do not inherit the HDF5 minimum. Installed
targets remain free of a C standard usage requirement.

| Work Package 2E gate | Windows/MSVC | Linux/GCC |
| --- | --- | --- |
| CMake standard contract | `PASS`: 317 C compile groups at `/std:c17` | `PASS`: 317 C compile groups at exact `-std=c17` |
| Default Release build | `PASS` with at most four jobs | `PASS`: 3,153 steps with at most four jobs |
| Focused core/HL/tool tests | 7/7 at `HDF_TEST_EXPRESS=3` | 7/7 at `HDF_TEST_EXPRESS=3` |
| Standalone C examples | 85/85 targets built in strict C17 | 85/85 targets built in exact strict C17 |
| Install and export scan | `PASS`: no C standard requirement leaked | `PASS`: no C standard requirement leaked |
| Installed C99 consumer | Configure/build/run `PASS`; output 2.3.0 | Exact `-std=c99` compile/link/run `PASS`; output 2.3.0 |

The focused CMake script performs fresh default and C23 configures, repeats the
default configure, and compares sorted target/header/export contracts exactly.
Both validators pass all cases with 317 C compile groups. It also proves lower
request rejection for the root and standalone examples and exercises a
dependency fixture in both default and C23 parent modes. An undeclared
dependency target receives no C standard, a dependency-declared C11 target
retains strict C11, and HDF5-owned targets before and after that directory retain
the selected strict parent mode. Default configurations do not load a C++
compiler.

Windows `H5pubconf.h` retains SHA-256 `55b6c7b4c523` and is byte-identical to
the frozen baseline. Linux produces SHA-256 `6e674eb529e9`; its only baseline
delta is the already classified undefined `H5_HAVE_TIMEZONE`, and it is
byte-identical to the accepted strict-C17 readiness result. Complex support and
all related sizes remain unchanged on both validators.

During fixture development, setting the dependency-scope variables to empty
was rejected by CMake as an invalid target `C_STANDARD`; the new scope test
caught this before commit, and the implementation now temporarily removes and
then restores both visible values and cache metadata. An initial installed
consumer used a target namespace that this fork does not export; the accepted
fresh consumers use the actual installed `hdf5-shared` target. A direct
non-login WSL invocation that could not find Ninja was discarded and repeated
through the qualified login environment. These are test-method corrections,
not accepted product failures.

## C++20 Readiness Repair

Work Package 2F first refreshed the C17/C++11 product baseline. Fresh C++
Release builds completed on both validators and the fixture-aware focused
selection passed 9/9 at `HDF_TEST_EXPRESS=3`. The Linux commands contain exact
`-std=c++11` modes; MSVC retains its effective default because it has no exact
C++11 switch. Fresh installs then passed separate C99/C++11 and C17/C++20
`find_package()` consumers on both validators, with 3/3 compile/link/run tests
per mode. `H5Cpp.h` and its representative C API use therefore remain valid at
both installed-header consumer baselines.

The first strict-C++20 affected-target build on the landed C17 base exposed a
new MSVC failure in `H5PacketTable.cpp`. The C17 readiness repair correctly
enables the existing native MSVC complex implementation, but the UCRT redirects
`<complex.h>` to `<ccomplex>` in C++17 and later unless its C-compatible branch
is requested. As a result, `_Fcomplex`, `_Dcomplex`, and `_Lcomplex` were absent
when `H5win32defs.h` formed the internal HDF5 complex typedefs.

Commit `b84f9e4a7` closes this blocker. `H5private.h` now requests the UCRT C
complex declarations only around its internal `<complex.h>` include and then
restores the incoming macro state. No installed header, public declaration,
class layout, calling convention, or format behavior changes.

| Work Package 2F gate | Windows/MSVC | Linux/G++ |
| --- | --- | --- |
| Affected C++11 targets | Core C++, HL C++, and both tests build | Same targets build at exact `-std=c++11` |
| Affected strict-C++20 targets | Four inspected projects use `stdcpp20`; all build | All generated C++ commands use exact `-std=c++20`; 501 affected steps build |
| C++11/strict-C++20 tests | 2/2 in each mode | 2/2 in each mode |
| Installed C++11/C++20 consumers | 3/3 in each mode | 3/3 in each mode with exact standard flags |
| C++11 symbols versus frozen baseline | 1,143 core and 35 HL C++ names, zero delta | 1,418 core and 46 HL C++ names, zero delta |
| Strict-C++20 HDF5 symbols versus frozen baseline | Both name sets have zero delta | HL C++ has zero delta; core has no removal and two classified weak library-template additions |

The strict G++ build reproduces exactly the five `P2-03` `-Wlarger-than`
diagnostics in `c++/test/dsets.cpp`; no new warning family appears. Its only
symbol delta is the C1/C2 alias pair for one weak `std::__cxx11::basic_string`
constructor instantiation. Both aliases have the same address and size, belong
to the standard-library namespace, and are emitted by the compiler's C++20
template strategy rather than an HDF5 declaration. They are an allowed
standard-mode artifact: all HDF5 names are unchanged and the legacy C++11
consumer and symbol contracts remain exact.

## C++20 CMake Baseline

Commit `1ce441445` completes Work Package 2G. The root and retained standalone-
example entry points select C++20 when the opt-in C++ path is enabled. Explicit
C++98, C++11, C++14, and C++17 requests fail with a direct diagnostic; C++23 is
retained. The selected standard is required and extensions are disabled. A
default C-only configuration still does not load or record a C++ compiler.

The dependency scope now saves, masks, and restores all C and C++ standard,
required, and extension variables, including cache metadata. KWSYS therefore
retains its declared C++11 mode while both HDF5-owned API driver executables use
C++20. Installed targets remain free of `cxx_std_*` usage requirements, and
the build settings report `C++ Standard: C++20` without presenting a standard
switch as a global consumer flag.

| Work Package 2G gate | Windows/MSVC | Linux/GCC |
| --- | --- | --- |
| CMake standard contract | `PASS`: 23 C++ compile groups use `stdcpp20` | `PASS`: 23 C++ compile groups use exact `-std=c++20` |
| Fresh C++ Release build | `PASS` with at most four jobs | `PASS`: 3,398 steps with at most four jobs |
| Focused core/HL/tool/C++ tests | 9/9 at `HDF_TEST_EXPRESS=3` | 9/9 at `HDF_TEST_EXPRESS=3` |
| Real KWSYS dependency path | KWSYS inherits no HDF5 mode; both drivers build and process tests pass 5/5 | KWSYS uses exact C++11, both drivers use C++20, and process tests pass 5/5 |
| Install and export scan | `PASS`: settings report C++20 and no standard leaks | `PASS`: settings report C++20 and no standard leaks |
| Installed legacy/baseline consumers | C99/C++11 and C17/C++20 each pass 3/3 | Both modes pass 3/3 with exact C++11/C++20 compiler switches |
| Public headers and layouts | Declaration-bearing headers and C++11/C++20 layouts have zero delta | Same result; only the classified strict-C17 `H5_HAVE_TIMEZONE` generated-header delta remains |
| C++ symbols | Core 1,143 and HL C++ 35 names have zero delta | HL C++ 46 names have zero delta; core retains all 1,418 baseline names plus only the classified `P2-05` pair |

The focused CMake script also proves identical first/repeated contracts, lower-
standard rejection in both entry points, retention of C++23, C-only compiler
independence, dependency isolation in default and later-standard parent modes,
and the absence of exported C++ compile features. The five `P2-03` diagnostics
remain unchanged. Two additional H5Location allocation-size diagnostics also
occur twice in the frozen C++11 log and are not a baseline delta.

## Full Product and Optional Validation

Work Package 2H exercised every runnable matrix row from the exact
`1ce441445159e5f7eb689853e27195bb4be84d05` source tree. All accepted build and
CTest commands stayed within four active jobs per physical host, and full suites
used `HDF_TEST_EXPRESS=3`. Validation output and generated trees remain outside
the repository.

### Required product matrix

| Gate | Windows/MSVC | Linux/GCC |
| --- | --- | --- |
| Default Release | Fresh C-only build; 2,816/2,816 enabled tests passed from 2,853 registered, with 37 disabled | Fresh C-only build; 2,818/2,818 enabled tests passed from 2,855 registered, with 37 disabled |
| C++ Release | Fresh C17/C++20 build; 2,850/2,850 enabled tests passed from 2,887 registered, with 37 disabled | Fresh C17/C++20 build; 2,852/2,852 enabled tests passed from 2,889 registered, with 37 disabled |
| Debug | C++ build and 9/9 fixture-aware focused tests passed | C++ build and 9/9 fixture-aware focused tests passed |
| Static-only and shared-only | Both modes built and installed; artifact shapes, focused tests, and build/install consumers passed | Both modes built and installed; artifact shapes, focused tests, and build/install consumers passed |
| Combined build/install | C, HL, C++, and HL C++ static/shared exports and consumers passed | C, HL, C++, and HL C++ static/shared exports and consumers passed |
| Developer warnings | Full C++ build passed; reviewed warnings exposed no migration blocker | Full C++ build passed; reviewed warnings exposed no migration blocker |
| Standalone examples | Installed-package C, C++, and HL examples passed 279/279 tests | Installed-package C, C++, and HL examples passed 279/279 tests |
| Installed consumers | C99/C++11 and C17/C++20 modes each passed 3/3 compile/link/run tests | C99/C++11 and C17/C++20 modes each passed 3/3 compile/link/run tests |
| Integration styles | Build-tree package, installed package, `add_subdirectory()`, and local FetchContent consumers passed | The same consumers passed; pkg-config and wrapper C17/C++20 checks also passed |
| Thread-safe and concurrency | Both shared C-only configurations built; each passed 6/6 focused tests | Both shared C-only configurations built; each passed 6/6 focused tests |

The default rows did not activate C++. Static-only and shared-only installs
contained only their requested library shape. The external shape consumer used
the actual static or shared imported target in all eight platform, tree, and
linkage combinations. Generated thread and atomic macros were coherent: GNU used
the standard atomic path and MSVC retained its supported fallback, while thread
safety and multi-thread concurrency remained mutually exclusive.

The final C and C++ standard-contract scripts passed on both validators. They
cover 317 C compile groups and 23 C++ compile groups, repeat configuration,
lower-standard rejection, later-standard preservation, dependency isolation,
and export leakage. Exact sorted CTest inventory comparisons against Work
Package 2B had zero name/disabled-state delta in all four Release trees.

### Optional and generator matrix

| Gate | Result |
| --- | --- |
| Linux parallel | Open MPI 5.0.10 full build passed; 13/13 focused MPI/VFD tests passed with exact C17 and no C++ activation |
| Linux subfiling | Build and 3/3 fixture-aware focused tests passed with the expected generated macros |
| Linux system compression | Isolated zlib 1.3.1/libaec 1.1.5 build, filter tests, install, and four static/shared build/install consumers passed; no staged path leaked into exports |
| Bundled compression/plugins | Windows and Linux preset builds passed with zlib 1.3.2, libaec 1.1.6, and configured plugins; each passed 89/89 focused filter/plugin tests |
| Plugin failure behavior | ZFP data printed with the plugin path and failed with the expected diagnostic when the path was absent on both validators |
| Linux coverage | Instrumented C++ Debug build and 13/13 focused tests passed; 454 `.gcda` and 1,156 `.gcno` files were observed, then `ccov-clean` removed every `.gcda` file |
| Linux Unix Makefiles | Fresh C++ build and 13/13 focused tests passed; 213 C17 and 6 C++20 flag records confirmed exact modes independently of Ninja |

Bundled installs contained every plugin selected by their configured export
lists: 11 on Windows and 12 on Linux, where JPEG was additionally enabled.
Installed exports contained no C/C++ standard usage requirement and no
dependency-build or transient path. Strict-C17 external consumers linked the
actual static/shared HDF5 target and created DEFLATE/SZIP datasets in all eight
platform, tree, and linkage combinations.

### Package and format evidence

| Package | Contents and validation | SHA-256 prefix |
| --- | --- | --- |
| Windows ZIP | 2,098 entries; independently extracted runtime, plugin, and strict-C17 shared consumer passed | `926f903edbba` |
| Linux TGZ | 799 entries; independently extracted runtime, plugin, and strict-C17 shared consumer passed | `2e8e585b0ee5` |
| Linux DEB | 799 entries; package `hdf5` version 2.3.0 for `amd64`; extracted runtime, plugin, and strict-C17 shared consumer passed | `fcd95e744256` |
| Source TGZ | 4,123 archive entries representing exactly all 3,949 tracked paths at `1ce441445`; no repository or generated residue | `c1e249f42b34` |

Each binary package reported HDF5 2.3.0 and included the expected HDF5,
compression, plugin, and CMake export payload. The bundled DEB correctly had no
external package dependency. Linux read the Windows-created DEFLATE/SZIP file
and Windows read the Linux-created file; normalized `h5dump` output was exactly
equal.

### Pending environment dispositions

Fresh capability discovery did not find the prerequisites below. No dependency
was installed merely to manufacture a passing row, and no product failure was
observed. The proposed dispositions require explicit user approval before Work
Package 2H can close.

| Unavailable row | Fresh discovery | Proposed disposition |
| --- | --- | --- |
| Windows system compression | No qualified MSVC libaec development-library pair | `DEFER_ENVIRONMENT` |
| Windows parallel/subfiling | Microsoft MPI runtime exists, but SDK headers and libraries do not | `DEFER_ENVIRONMENT` |
| Parallel tools on both validators | Required mpiFileUtils/libcircle/DTCMP toolchain is unavailable | `DEFER_ENVIRONMENT` |
| ROS3 on both validators | No qualified AWS SDK C dependency set is available | `DEFER_ENVIRONMENT` |
| HDFS on both validators | The required Java/Hadoop/libhdfs development stack is unavailable | `DEFER_ENVIRONMENT` |
| Signed plugins on both validators | No qualified OpenSSL development library for the active compiler pair is available | `DEFER_ENVIRONMENT` |
| Linux RPM | `rpmbuild` is unavailable | `DEFER_ENVIRONMENT` |

### Comparison and Validation Rules

| Evidence kind | Later comparison rule |
| --- | --- |
| Raw build and CTest logs | Preserve for diagnosis; compare result counts and classified warning sets, not paths or timings. |
| CMake contract | Use the repository normalizer and require exact sorted-record equality except an explicit reviewed allowlist. |
| Cache, target, artifact, and test inventories | Compare exact normalized lines and SHA-256; counts are only a completeness check. |
| Target standards | Compare every compile group, emitted option order, and actual compiler-mode macro probe. |
| Generated headers and settings | Compare same-validator content after only recorded prefix/line-ending normalization and classify every macro delta. |
| Installed headers and declarations | Compare names and hashes, then compiler-preprocessed declarations independently. |
| Symbols | Compare exact case-sensitive name sets per library and validator; do not infer equality from counts. |
| Layouts | Compare complete probe output for the same compiler, architecture, and mode. |
| Install and package manifests | Compare sorted relative path/hash or path sets; classify intentional binary changes separately. |
| Consumers and wrappers | Repeat compile/link/run with no ambient HDF5 path and inspect the effective command. |
| HDF5 round trips | Require cross-validator open/read and equal semantic dataset output; do not compare file bytes. |

Several discarded invocations were method corrections rather than accepted
evidence: one Windows query path was quoted incorrectly and its exact external
trees were removed before a fresh configure; direct non-login WSL initially
missed the user-local Ninja/pkg-config path; the first Linux contract compare
used `CANDIDATE` instead of the required `CURRENT` argument; and CLion's
terminal wait limit
returned before two Windows source-consumer builds exited. The final accepted
runs used fresh or completed trees, correct command-scoped paths, the current
contract argument, and separately rerun passing tests. No build/test worker or
superseded terminal session remains. The first Windows bundled-dependency build
was stopped and replaced with a clean `/utf-8` build. A TGZ extraction command
that attempted a cross-filesystem rename was replaced by extraction into a
pre-created destination. Two consumer-generated HDF5 files that initially used
the source directory as their working directory were removed before the final
repository-status check.

## Findings Ledger

| ID | Owner and reproducer | Impact | Disposition and gate |
| --- | --- | --- | --- |
| `P2-01` | C/configure: fresh MSVC `/std:c17` configure reaches `__STDC_NO_COMPLEX__` and bypasses the MSVC type fallback in `config/ConfigureChecks.cmake`. | Removed native complex configuration and the corresponding datatype/conversion implementation from the diagnostic Windows build. | `CLOSED` by `310fb4323`: MSVC probes its supported fallback even when ISO complex is unavailable; C11/C17 generated macros, affected builds, and 16/16 focused tests pass on both validators. |
| `P2-02` | C/platform: fresh GCC `-std=c17` configure no longer compiles the nonstandard `timezone` global probe. | No active behavior change because `H5_HAVE_TM_GMTOFF=1` remains selected first in `H5_make_time()`; builds and smoke tests pass. | `KEEP_COMPAT`: the truthful undefined result and otherwise stable installed-header contract were rechecked at 2G; preserve the classification at the final gate. |
| `P2-03` | C++/test warning: GCC 15 with `-std=c++20` reports five `-Wlarger-than` warnings for fixed-size multidimensional allocations in `c++/test/dsets.cpp`. | Warning-only diagnostic in test code; compilation and the C++ focused tests pass. | `DEFER_SOURCE_MODERNIZATION`: the exact five-warning set was rechecked at 2G; do not rewrite passing test allocation code and preserve the classification at the final gate. |
| `P2-04` | C++/MSVC: after `P2-01` restores native complex support, strict C++20 redirects UCRT `<complex.h>` to `<ccomplex>` and leaves the internal `_Fcomplex` family undeclared. | HL C++ fails while compiling `H5PacketTable.cpp`; C++11 and the C core remain buildable. | `CLOSED` by `b84f9e4a7`: temporarily request the UCRT C declarations inside `H5private.h`; affected targets and tests pass in C++11/C++20 on both validators. |
| `P2-05` | C++/GNU symbol comparison: strict C++20 emits the C1/C2 aliases of one weak `std::__cxx11::basic_string` constructor that C++11 does not export. | Two compiler-owned weak names are added; no HDF5 or HL C++ name is added, removed, or changed. | `ALLOW_STANDARD_MODE`: the exact pair and complete legacy symbol set were rechecked at 2G; preserve the classification at 2H. |

The raw global C11 flag, duplicate baseline C options, and missing global C++
flag in `libhdf5.settings` were standard-ownership inputs rather than ordinary
source defects. Work Package 2F closed the additional blocker that became
observable only after the C17 repair enabled native MSVC complex support. Work
Package 2G then established the C++20 baseline without another source repair.
Work Package 2H preserved every reviewed finding disposition. No `INVESTIGATE`
product item remains; only the explicit environment decisions above block
closure.

## Continuation Point

Every runnable Work Package 2H row is complete at implementation anchor
`1ce441445`. Full suites, required product variants, available optional paths,
packages, integration styles, installed consumers, standard and inventory
contracts, and cross-platform reads pass. Resume by obtaining an explicit user
decision for each of the seven proposed `DEFER_ENVIRONMENT` rows above. After
approval, close Work Package 2H and Phase 2 in the plan, this results record, and
the portable handoff without rerunning completed validation. Preserve the
C99/C++11 consumer baseline and the `P2-02`, `P2-03`, and `P2-05`
classifications.
