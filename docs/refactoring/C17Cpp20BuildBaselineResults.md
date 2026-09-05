# Phase 2 C17 and C++20 Build Baseline Results

## Status

- State: In progress
- Plan approval: 2026-09-05
- Execution baseline: `a1adbc32b7604d6a57d6dcab1a965258ff48f148`
- Implementation anchor: none
- Work Package 2A: Complete
- Work Package 2B: Complete
- Work Packages 2C through 2H: Not started
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
| 2C External standard probe | `NOT_STARTED` | Create the diagnostic-only strict C17/C++20 copy from the 2B evidence checkpoint. |
| 2D C17 readiness repairs | `NOT_STARTED` | Wait for classified 2C findings. |
| 2E Establish C17 | `NOT_STARTED` | Wait for the 2D dual-mode gate. |
| 2F C++20 readiness repairs | `NOT_STARTED` | Wait for the C17 switch and classified C++ findings. |
| 2G Establish C++20 | `NOT_STARTED` | Wait for the 2F dual-mode gate. |
| 2H Full product and handoff gate | `NOT_STARTED` | Wait for the tested C17/C++20 implementation anchor. |

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
superseded terminal session remains.

## Findings Ledger

No C17 or C++20 probe has run, so Work Package 2B creates no blocker finding.
It freezes two facts that Work Package 2C must not lose: current GNU C targets
effectively use GNU C11 extensions, and current MSVC C++11-minimum targets use
the compiler's default C++14-level mode. The raw global C11 flag, duplicate C
standard options, and missing global C++ flag in `libhdf5.settings` are known
standard-ownership inputs for 2E/2G, not newly discovered ordinary defects.
No `INVESTIGATE` item exists at the end of Work Package 2B.

## Continuation Point

Work Package 2B is complete at product baseline `a1adbc32b`; its portable
checkpoint is the focused documentation commit containing this record. Start
Work Package 2C by creating a fresh diagnostic source copy from that exact
checkpoint. Change only the copied standard-ownership declarations needed to
request strict C17/C++20, configure and build default/C++ Release on both
validators with the four-job host limit, and classify every result before any
source repair enters the real tree. Do not copy exploratory edits back.
