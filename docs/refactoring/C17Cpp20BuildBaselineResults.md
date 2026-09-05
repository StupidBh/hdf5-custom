# Phase 2 C17 and C++20 Build Baseline Results

## Status

- State: In progress
- Plan approval: 2026-09-05
- Execution baseline: `a1adbc32b7604d6a57d6dcab1a965258ff48f148`
- Implementation anchor: none
- Work Package 2A: Complete
- Work Packages 2B through 2H: Not started
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
| 2B Freeze the pre-migration contract | `NOT_STARTED` | Capture fresh default and C++ Release evidence on both pairs. |
| 2C External standard probe | `NOT_STARTED` | Wait for the complete 2B baseline record. |
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
will create fresh Phase 2 product evidence rather than inherit those builds.

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

Work Package 2B will record exact output identifiers and comparison methods for
the following surfaces. Validation artifacts remain outside the tracked tree.

| Evidence family | Windows | Linux | State |
| --- | --- | --- | --- |
| Default and C++ Release builds/full suites | Pending | Pending | `NOT_STARTED` |
| Cache, target, test, and CMake File API contracts | Pending | Pending | `NOT_STARTED` |
| Exact C11/C++11 modes and target ownership | Pending | Pending | `NOT_STARTED` |
| Generated headers and build settings | Pending | Pending | `NOT_STARTED` |
| Artifacts, installs, exports, and packages | Pending | Pending | `NOT_STARTED` |
| C/HL/C++/HL C++ symbols and public layouts | Pending | Pending | `NOT_STARTED` |
| Headers and normalized effective declarations | Pending | Pending | `NOT_STARTED` |
| pkg-config and compiler wrappers where supported | Pending | Pending | `NOT_STARTED` |
| Build/install/source-tree consumers | Pending | Pending | `NOT_STARTED` |
| Legacy C99 and C++11 installed consumers | Pending | Pending | `NOT_STARTED` |
| Representative HDF5 file round trips | Pending | Pending | `NOT_STARTED` |

## Findings Ledger

No C17 or C++20 probe has run. Work Package 2C will add one entry per finding
with its source or target, triggering compiler and mode, root cause, affected
product, compatibility impact, reproducer, required validation, and approved
disposition. No `INVESTIGATE` item exists at the end of Work Package 2A.

## Continuation Point

Start Work Package 2B from the selected execution baseline and this approval
record. Create fresh default and C++ Release builds on Windows/MSVC and
Linux/GCC, use no more than four combined active build or CTest jobs, capture
the complete pre-migration evidence register, run both full suites at
`HDF_TEST_EXPRESS=3`, and establish the C99/C++11 installed consumers. Do not
start the external C17/C++20 probe until the 2B evidence commit passes its gate.
