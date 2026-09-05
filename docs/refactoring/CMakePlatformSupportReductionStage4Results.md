# Stage 4 Final Project Support Audit Results

## Status

- State: Complete
- Work Package 4A: complete
- Work Package 4B: complete
- Work Package 4C: complete
- Work Package 4D: complete
- Work Package 4E: complete
- Work Package 4F: complete
- Completion date: 2026-09-05
- Baseline execution date: 2026-09-05
- Baseline checkpoint: `cafdc38e9`
- Current implementation anchor: `f6ff66fed`
- Stage 4 plan:
  [CMakePlatformSupportReductionStage4.md](CMakePlatformSupportReductionStage4.md)
- Parent plan:
  [CMakePlatformSupportReduction.md](CMakePlatformSupportReduction.md)
- Portable handoff: [../../REFACTORING_PROGRESS.md](../../REFACTORING_PROGRESS.md)
- `HDF_TEST_EXPRESS`: `3`
- Temporary Stage 4 build and CTest execution cap used: 4 per physical host

Work Package 4A is complete. Fresh default and C++ Release baselines were
captured on both retained target/compiler pairs before an implementation
correction. The two required defects were reproduced on both pairs, complete
default and C++ installs and packages are recorded, and the findings have
validation owners. Work Package 4B completed the repository audit; its six
focused implementation corrections end at `ebdb99969`, and its current-support
documentation correction is recorded at `c6e2c2cb9`. Work Package 4C repaired
utility-dependent registration at `8d7aa0432`, and Work Package 4D repaired and
validated the optional API driver at `f6ff66fed`. Work Package 4E validated the
delivered products and consumer contracts at that final implementation anchor.
Work Package 4F completed the remaining fresh matrix rows, repeated the
residual and package audits, and closed the final handoff. Stage 4 and the
overall supported-platform reduction direction are complete.

The four-job cap was a temporary resource constraint for this Stage 4
execution, not a repository default, product compatibility value, or permanent
validation reference. Existing presets and general user documentation retain
their independently chosen job counts.

## Baseline Identity

Both validators used clean tracked source trees at
`cafdc38e902db2e5ffcd0bdd981544f01e0bd6f0`. The difference from the Stage 3
implementation anchor `74288cbaa` is limited to ten planning, results,
handoff, and changelog paths. It contains no C/C++ source, header, CMake
implementation, test, example, install, or package-input change. The current
product implementation therefore remains `74288cbaa`; the Stage 4 baseline
does not reinterpret or amend the Stage 3 result.

Build, install, package, contract, and consumer outputs were kept outside the
tracked source trees. The working repository's unrelated untracked IDE and
agent directories were not read into a package, modified, staged, or committed.

## Qualified Validators

| Component | Windows baseline | Linux baseline |
| --- | --- | --- |
| Target system | Windows 11 NT 10.0.26100 | Ubuntu 26.04 under WSL2 |
| Kernel | NT 10.0.26100 | `6.18.33.2-microsoft-standard-WSL2` |
| Architecture | x64 | x86_64 |
| Compiler | MSVC 19.51.36256.0, toolset 14.51.36231 | GCC/G++ 15.2.0 |
| Target identity | MSVC x64 | `x86_64-linux-gnu` for C and C++ |
| CMake and CTest | 4.4.3 | 4.2.3 |
| Primary generator | Visual Studio 18 2026, platform x64 | Ninja 1.13.2 |
| Secondary generator | Not applicable | GNU Make 4.4.1 qualified |
| Additional build metadata | MSBuild 18.10.0.37909, toolset v145, Windows SDK 10.0.26100.0 | pkg-config 2.5.1, Perl 5.40.1 |
| Source state | clean tracked tree at `cafdc38e9` | clean tracked tree at `cafdc38e9` on the WSL native filesystem |
| State | `PASS` | `PASS` |

Windows compiler invocations used `CL=/utf-8`. Build and CTest commands ran
sequentially between Windows and WSL and used no more than four jobs. GNU Make
was resolved and version-qualified for the secondary final check; the fresh
Stage 4 product baselines below intentionally use Ninja, and Work Package 4F
adds a fresh full Unix Makefiles product build at final implementation
`f6ff66fed`.

## Reproducible Baseline Commands

Commands below use logical placeholders. The File API `QUERY` action was run
before each first product configure.

```powershell
$env:CL = "/utf-8"
cmake -DHDF5_CONTRACT_ACTION=QUERY `
  -DHDF5_CONTRACT_BUILD_DIR=<build> `
  -P <src>/config/cmake/scripts/HDF5BuildContract.cmake
cmake -S <src> -B <build> -G "Visual Studio 18 2026" -A x64 <options>
cmake --build <build> --config Release --parallel 4
$env:HDF_TEST_EXPRESS = "3"
ctest --test-dir <build> -C Release --output-on-failure -j 4 -R <selection>
cmake --install <build> --config Release --prefix <install>
cpack --config <build>/CPackConfig.cmake -C Release -G ZIP
```

```sh
cmake -DHDF5_CONTRACT_ACTION=QUERY \
  -DHDF5_CONTRACT_BUILD_DIR=<build> \
  -P <src>/config/cmake/scripts/HDF5BuildContract.cmake
cmake -S <src> -B <build> -G Ninja -DCMAKE_BUILD_TYPE=Release <options>
cmake --build <build> --parallel 4
HDF_TEST_EXPRESS=3 ctest --test-dir <build> \
  --output-on-failure -j 4 -R '<selection>'
cmake --install <build> --prefix <install>
cpack --config <build>/CPackConfig.cmake -C Release -G TGZ
```

Each contract capture used `HDF5BuildContract.cmake` with `CAPTURE`, the
matching build directory and configuration, and an install directory only for
the explicitly labeled post-install capture. CTest registration evidence used
`ctest --show-only=json-v1` and retained the raw test/property data outside the
repository.

## Fresh Product Baseline

| Row | Evidence | State |
| --- | --- | --- |
| Windows default Release | Complete build passed; focused C, HL, tool, and mirror selection passed 10/10 with fixtures | `PASS` |
| Windows C++ Release | Complete combined C/C++ build passed; `CPP_testhdf5` and `HL_CPP_ptableTest` passed 2/2 | `PASS` |
| Linux default Release | Complete 3,159-step build passed; the matching focused selection passed 10/10 with fixtures | `PASS` |
| Linux C++ Release | Complete 3,277-step combined build passed; both named C++ tests passed 2/2 | `PASS` |
| Windows installs | Default and C++ isolated Release installs completed with 65 and 101 headers | `PASS` |
| Linux installs | Default and C++ isolated Release installs completed with 65 and 101 headers | `PASS` |
| Installed consumers | C, C HL, C++, and C++ HL standalone examples configured through installed CMake packages, built, linked, and ran on both pairs | `PASS` |

The focused default expression selected `H5TEST-testhdf5-base`,
`HL_test_lite`, `H5DIFF-h5diff_10`, and `H5TEST-mirror_vfd`. CTest expanded
the required setup and cleanup fixtures. The C++ expression selected
`CPP_testhdf5` and `HL_CPP_ptableTest`.

## Configure and Contract Evidence

The following rows deliberately separate fresh first-configure, unchanged
repeat-configure, and post-install captures. Aggregate counts are evidence
identifiers, not equality claims.

| Pair and configuration | Capture point | Contract records | Registered | Enabled | Disabled | Mirror test | Fixture properties | State |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Windows default | First configure | 17,323 | 2,853 | 2,816 | 37 | 0 | 497 | `PASS` |
| Windows default | Same-argument repeat | 17,397 | 2,854 | 2,817 | 37 | 1 | 498 | `FAIL` |
| Windows default | Post-install, after repeat | 17,520 | 2,854 | 2,817 | 37 | 1 | 498 | `PASS` |
| Windows C++ | First configure | 19,566 | 2,887 | 2,850 | 37 | 0 | 509 | `PASS` |
| Windows C++ | Post-install | 19,735 | 2,887 | 2,850 | 37 | 0 | 509 | `PASS` |
| Linux default | First configure | 28,204 | 2,855 | 2,818 | 37 | 0 | 497 | `PASS` |
| Linux default | Same-argument repeat | 28,356 | 2,856 | 2,819 | 37 | 1 | 498 | `FAIL` |
| Linux default | Post-install, after repeat | 28,475 | 2,856 | 2,819 | 37 | 1 | 498 | `PASS` |
| Linux C++ | First configure | 30,771 | 2,889 | 2,852 | 37 | 0 | 509 | `PASS` |
| Linux C++ | Post-install | 30,940 | 2,889 | 2,852 | 37 | 0 | 509 | `PASS` |

The `FAIL` state is the required S4-01 reproduction, not a failed build or
test. The only registered-test addition is `H5TEST-mirror_vfd`. It requires
fixture `clear_H5TEST` and depends on `H5TEST-clear-objects`; the repeat adds
exactly one fixture property. Windows adds 74 normalized pre-install contract
records and Linux adds 152 because their generated build models represent the
new target and configuration metadata differently.

## Installed Headers and Effective Declarations

Complete per-file SHA-256 manifests were retained for all four installs.
Default manifests contain 65 names and C++ manifests contain 101 names.

| Capture | Header count | Raw manifest SHA-256 | Comparison with retained Stage 3 install | State |
| --- | ---: | --- | --- | --- |
| Windows default | 65 | `2950f52812a50a9f8355440c8f605b7979db486cfc161b2ef0def2e7d65b7813` | 65/65 names and bytes equal | `PASS` |
| Windows C++ | 101 | `b03e37f832d5fe091239dddd840da18b135212930565ad9e8aff7e58316617cb` | 101/101 names and bytes equal | `PASS` |
| Linux default | 65 | `e512e855119cd1b6850809653fe73c586ce11cdb348cbf939a48ac91b9d24629` | 65/65 names and bytes equal | `PASS` |
| Linux C++ | 101 | `53edb6dd312283fb663f2f684e9c170894460329e8c476d2f68e4e9e3071a554` | 101/101 names and bytes equal | `PASS` |

The raw manifest formats are validator-specific and are not compared across
operating systems. Equality claims above compare each Stage 4 install with the
complete retained install from `74288cbaa` on the same validator.

Fresh preprocessing of installed umbrella headers produced these raw output
identifiers:

| Validator and input | Mode | Bytes | SHA-256 | State |
| --- | --- | ---: | --- | --- |
| MSVC, `hdf5.h` | C, `/EP /utf-8 /TC` | 413,018 | `958377771879cac6ea0342a01c436e2fae54e46d3651d6440b6f4d3a5921fb42` | `PASS` |
| MSVC, `hdf5.h` | C++, `/EP /utf-8 /TP` | 434,371 | `9da7252d69ae015da76db089252c90502295e4ec8cb88bb737e4326409edce8f` | `PASS` |
| MSVC, `H5Cpp.h` | C++, `/EP /utf-8 /TP` | 1,856,941 | `3bcf719f9b6d5c06b8eeaed3872cdef4600aa0361c013fc0324f5013d6e0fbce` | `PASS` |
| GCC, `hdf5.h` | C11, `-E -P` | 183,187 | `034d92791d68557c0c9674ec65e29b7b5203f2436473031a86aa131c70ce9d55` | `PASS` |
| G++, `hdf5.h` | C++11, `-E -P` | 197,766 | `79502eacf498b6e561251d95662df4d04cbdcac9bcbb91c520a7963ae29c4677` | `PASS` |
| G++, `H5Cpp.h` | C++11, `-E -P` | 671,991 | `59f59c29e87c128fe844b68077474211c33b77974ab94f7222444cf45866b5f8` | `PASS` |

These hashes identify current effective declarations within a compiler pair;
they are not cross-compiler ABI comparisons. Exact same-pair header equality,
the representative compile/link/run consumers, and the symbol evidence below
provide separate scopes of compatibility evidence.

## Symbols and Binary Metadata

Exported-name lists were sorted and hashed without a final newline. All five
Stage 4 sets compare name for name with the retained same-platform Stage 3
installation.

| Validator | Library | Export count | SHA-256 | Stage 3 comparison | State |
| --- | --- | ---: | --- | --- | --- |
| Windows | C core | 3,964 | `399424dc5c5b51dd9d7a3f0584fe153fccd0ad250083f43820cafd0b37f8e5d0` | Equal | `PASS` |
| Windows | C high-level | 124 | `d94474ecb153ccb482e0eb5e1d5a1e206ec50a6764bf58fcefe98b6d5e434787` | Equal | `PASS` |
| Windows | Tools | 159 | `dec22664eaf83746589c0a1f23e1aedef4e2ffd3f26c6ee6d03f1a003cbe3662` | Equal | `PASS` |
| Windows | C++ core | 1,143 | `9cf928d3a7be4c005c6c8f2d434f6017c8c238049553729106f4345eac42d771` | Equal | `PASS` |
| Windows | C++ high-level | 35 | `2666e98aa409e4817bbdfdc613a20e12996fb8a3f62d2d7de705ad42963c6e5e` | Equal | `PASS` |
| Linux | C core | 4,060 | `78cbba308db66f835f7fafa4335e67528714203a47e57ff8335ca5106489ae44` | Equal | `PASS` |
| Linux | C high-level | 166 | `48e9bc6c183f45087bbea2b9c42b0a01177384ca4b6439153049d232cb790e48` | Equal | `PASS` |
| Linux | Tools | 180 | `a83f9ceeb99c4918213b30e9f2ccab8334f39049b08a446cfad1cd3504ec1da5` | Equal | `PASS` |
| Linux | C++ core | 1,418 | `d751026b67d0d5816fb0ba8931383f1aa926c76080b2418813da4eea17cd4d14` | Equal | `PASS` |
| Linux | C++ high-level | 46 | `c69d275924807c79b6d7bf12113500028f146f185a129de819dd30bfbf3ad5cb` | Equal | `PASS` |

Windows default output and installation retain `hdf5.dll`, `hdf5.lib`, and
`libhdf5.lib`, with corresponding high-level and tools forms. The C++ install
adds the same DLL/import/static triplets for `hdf5_cpp` and `hdf5_hl_cpp`.
Release CMake packages contain separate static and shared target exports.

The original Windows C++ baseline normalization used PowerShell's default
case-insensitive unique sort. It collapsed the distinct exported C++ names
containing `reOpen` and `reopen` and reported 1,142 names. Re-normalizing both
retained raw `dumpbin` captures with a case-sensitive unique sort yields the
1,143-name set above; the corrected baseline and final manifests are byte
identical. This supersedes only that evidence identifier and does not describe
a product change.

Linux retains `libhdf5`, `libhdf5_hl`, `libhdf5_tools`, `libhdf5_cpp`, and
`libhdf5_hl_cpp` as applicable. Shared objects have version `1000.0.0`, SONAME
suffix `.so.1000`, and installed RUNPATH `$ORIGIN/../lib:$ORIGIN/`. Installed
`h5dump` runs without an injected library path and reports HDF5 2.3.0. All four
C++-install pkg-config files report version 2.3.0, and `h5c++ -showconfig`
reports the matching configuration.

## Package Manifests

| Package | Entries | Required content and exclusions | State |
| --- | ---: | --- | --- |
| Windows default ZIP | 120 | C/HL libraries, tools, headers, CMake metadata; no local or removed-language paths | `PASS` |
| Windows C++ ZIP | 164 | Adds C++/HL C++ libraries, headers, wrapper, and metadata | `PASS` |
| Linux default TGZ | 122 | C/HL libraries, tools, headers, CMake and pkg-config metadata | `PASS` |
| Linux C++ TGZ | 169 | Adds C++/HL C++ libraries, headers, wrapper, and pkg-config metadata | `PASS` |
| Clean tracked-source TGZ | 4,097 | Contains all 3,929 tracked files; no Git, IDE, agent, build, cache, log, Java, or Fortran path | `PASS` |

The accepted source package was generated from a normal clean clone. An
earlier validation-only package made from a Git worktree contained the
worktree's root `.git` pointer file and was discarded; it is not baseline
evidence and does not indicate a tracked packaging input change.

## Required Defect Reproductions

### S4-01: configure-order-dependent utility registration

On both validators, a fresh default first configure omits
`H5TEST-mirror_vfd`. Repeating the identical configure after
`HDF5_BUILD_UTILS=ON` has entered the cache adds exactly that test and its
fixture property. Baseline CMake declared the option in `utils/CMakeLists.txt`
after root test processing had already consumed it. This was a product-owned,
cross-platform configure-order defect. Work Package 4C repaired it at
`8d7aa0432` and added its first/second/third and ON/OFF/ON configure reproducer.

### S4-02: optional API driver does not compile

The real optional entry path was configured with
`HDF5_TEST_API_ENABLE_DRIVER=ON` and a nonempty `HDF5_TEST_API_SERVER`.
Command-scoped proxy settings allowed the existing pinned acquisition path to
download and configure KWSys. The target then failed on both MSVC and G++ at:

```text
h5_api_test_driver.cpp:15: fatal error: H5_api_test_config.h: No such file or directory
```

The compile line contains the KWSys source and binary include directories but
not the HDF5 API generated-header directory. Independent source inspection also
confirms the later cleanup identifier `H5API_CLEAN_PROCESSES` disagrees with
the defined `H5_API_CLEAN_PROCESSES`. Work Package 4D later repaired both
focused defects at `f6ff66fed` and passed the required process checks on both
retained pairs.

## Work Package 4C: Stable Utility Test Registration

Implementation commit `8d7aa0432` moves the sole `HDF5_BUILD_UTILS` declaration
from `utils/CMakeLists.txt` to `CMakeBuildOptions.cmake`, before the test tree is
processed. Its public contract remains `BOOL`, help text `Build HDF5 Utils`,
default `ON`, and non-advanced. Explicit values are preserved. The sibling
product options consumed by test-dependent options are already declared at the
same central owner; the audit found no second ordering defect.

Mirror test and example targets now require both `HDF5_BUILD_UTILS` and the
effective `HDF5_ENABLE_MIRROR_VFD`. The legal Linux configuration registers the
`mirror_server`, `mirror_server_stop`, `mirror_vfd`, and
`use_append_chunk_mirror` targets exactly once. CTest uses a build-tree-derived
port and these exact tests and fixtures:

| Test | Fixture contract |
| --- | --- |
| `H5TEST-mirror_server-start` | `FIXTURES_SETUP=hdf5_mirror_server` |
| `H5TEST-mirror_vfd` | `FIXTURES_REQUIRED=clear_H5TEST;hdf5_mirror_server` |
| `H5TEST-mirror_server-stop` | `FIXTURES_CLEANUP=hdf5_mirror_server` |

The setup runs the server from the same working directory as the client so
relative mirror paths resolve consistently. All three tests are serial, and
the cleanup fixture stops the server even when the functional test fails.

`config/cmake/tests/HDF5UtilityRegistrationTests.cmake` performs 11 real root
configures per pair. It compares first, second, and third relevant contracts for
default options, explicit utilities `OFF`, and utilities plus Mirror VFD `ON`,
then checks an `ON/OFF/ON` transition. The contract records the two cache
entries, four target names, three test names, normalized commands, and fixture
properties rather than relying on aggregate counts.

| Pair and option state | Registered tests | Mirror tests | Stable contract SHA-256 | State |
| --- | ---: | ---: | --- | --- |
| Windows default or requested Mirror VFD | 2,853 | 0 | `f454c054e9753aeb63f72655b8fb0d3eb1d5289abeeb5a2d92b3d1e1a8bcff5d` | `PASS` |
| Windows utilities `OFF` | 2,853 | 0 | `987741f1e2967e04d848b72c98250a0b034a34be80e1792c0b17e93e272621ae` | `PASS` |
| Linux default | 2,855 | 0 | `76f8344b96b7fa464e712193e0a79c178218e9c20bfd75729b27a8e91fb1141f` | `PASS` |
| Linux utilities `OFF` | 2,855 | 0 | `44747ac2ffc68bdc5857f7234289c6f16092266e23878f668f4ad2b8cbbbda6f` | `PASS` |
| Linux utilities and Mirror VFD `ON` | 2,858 | 3 | `b21726d13ba4107a49f4c7c6de2a285d015267cf23c9fa5063d99e78b53e2956` | `PASS` |
| Linux transition `OFF` with Mirror VFD retained | 2,855 | 0 | `852062bab1f93dd7b8e73c3a86b5956fb6200fd16448062129534e48840d3713` | `PASS` |

On Windows, requesting the Mirror VFD is still forced `OFF` because the existing
`fork` prerequisite is unavailable, so no unsupported target or test is
introduced. On Linux, all four named targets and their dependencies built with
four jobs. CTest expanded the clear fixture plus the three mirror tests and
cleanup to five executions; all 5 passed at `HDF_TEST_EXPRESS=3`, and no server
process remained. The 16-case platform-support policy suite also passed on both
pairs.

Fresh default totals remain the 4A values: 2,853 on Windows and 2,855 on Linux.
The broken repeat configure previously added only `H5TEST-mirror_vfd`; it now
remains at the fresh count. A legal Linux mirror-enabled configuration instead
adds the three exact server/functional/cleanup tests above.

## Work Package 4D: Optional API Driver Reliability

Implementation commit `f6ff66fed` gives the real `h5_api_test_driver` target
the HDF5 source, generated-header, and generated API-test include directories
required by `H5_api_test_config.h` and its `hdf5.h` dependency. It also changes
the misspelled `H5API_CLEAN_PROCESSES` allocation-failure path to the defined
`H5_API_CLEAN_PROCESSES` identifier. No validation-only patch is needed.

The existing KWSys acquisition contract is unchanged. Both configurations used
the repository-defined `KWSYS_TGZ_ORIGPATH` value
`https://gitlab.kitware.com/utils/kwsys/-/archive/master` and archive name
`kwsys-master.tar.gz`; no URL, archive name, namespace, FetchContent logic, or
KWSys source was changed by 4D. Downloads used the command-scoped local proxy.
Generated dependency content stayed outside the repository.

Five tests use the actual driver with a small controlled child process. CTest's
structured listing confirmed their generated commands, `HDF5_API` and
`HDF5_API_DRIVER` labels, and 20-second outer bounds:

| Test | Checked behavior |
| --- | --- |
| `H5API-driver-success` | A child exit of 0 is reported and returned as 0. |
| `H5API-driver-child-failure` | Child exit 7 is reported and propagated exactly. |
| `H5API-driver-launch-failure` | A nonexistent executable produces a nonzero driver result and launch diagnostic. |
| `H5API-driver-timeout-cleanup` | A 30-second child is expired by the one-second driver timeout and its recorded PID is gone. |
| `H5API-driver-server-cleanup` | A controlled server reaches `Waiting`, the client succeeds, and the server PID is gone after driver cleanup. |

The wrapper applies its own 12-second bound and verifies controlled PIDs after
the driver exits. If driver cleanup regresses, the verifier terminates only the
process whose PID the helper wrote, then fails the test. It never selects or
terminates unrelated processes. The five regressions are reachable only when
`HDF5_TEST_API_ENABLE_DRIVER=ON`; the default option remains `OFF` and no
default test is added.

| Pair | Target build | Driver process tests | Registered API integration | Residual check | State |
| --- | --- | ---: | --- | --- | --- |
| Windows/MSVC 19.51 | `h5_api_test_driver`, helper, and `h5_api_test` passed in Release | 5/5 | `h5_api_test_misc` passed through the driver | No driver/helper process or PID file | `PASS` |
| Linux/GCC/G++ 15.2 | The same three Ninja targets passed in Release | 5/5 | `h5_api_test_misc` passed through the driver | No driver/helper process or PID file | `PASS` |

Both integrations ran at `HDF_TEST_EXPRESS=3`. The Windows validator used a
Visual Studio generator and the Linux validator used Ninja. Builds and CTest
used at most four jobs under the temporary Stage 4 execution constraint.

## Work Package 4E: Products and Consumer Contracts

Work Package 4E used fresh build, install, package, example, and consumer trees
from a clean tracked source at documentation checkpoint `eb118c43d`. Its
product implementation is exactly `f6ff66fed`; changes after that implementation
anchor and before the validation checkpoint are documentation only. Windows
used Visual Studio 18 2026 x64 with `CL=/utf-8`, and Linux used Ninja with
GCC/G++ 15.2.0. All CTest runs used `HDF_TEST_EXPRESS=3`, and build and test
commands stayed within the temporary four-job Stage 4 execution budget.

### Fresh Products and Contracts

| Pair and configuration | Build and tests | Install/package | State |
| --- | --- | --- | --- |
| Windows default Release | Complete static/shared build; all 2,816 enabled tests passed, with 37 disabled out of 2,853 registered | 65 headers; 120-entry ZIP | `PASS` |
| Windows C++ Release | Complete C/C++ static/shared build; `CPP_testhdf5` and `HL_CPP_ptableTest` passed | 101 headers; 164-entry ZIP | `PASS` |
| Linux default Release | Complete 3,153-step static/shared build; all 2,818 enabled tests passed, with 37 disabled out of 2,855 registered | 65 headers; 122-entry TGZ | `PASS` |
| Linux C++ Release | Complete 3,277-step C/C++ static/shared build; `CPP_testhdf5` and fixture-expanded `HL_CPP_ptableTest` passed | 101 headers; 169-entry TGZ | `PASS` |

The final default first and identical repeat configurations are byte-identical
after normalization: 17,323 records on Windows and 28,204 on Linux. This closes
S4-01 in the complete product configuration rather than only in its focused
reproducer. Current default post-install captures contain 17,446 records on
Windows and 28,323 on Linux. Current C++ first/post-install captures contain
19,566/19,735 records on Windows and 30,771/30,940 on Linux.

The 4A first-configure and final contracts differ only in generated
`H5pubconf.h` and `libhdf5.settings` hashes. The settings difference is the
explicit isolated install prefix. The configuration header difference is that
prefix plus the approved removal of the inactive AIX-only `H5__LARGE_FILES`
template entry. The final C++ post-install contract has no structural delta
from 4A. The 4A default post-install capture followed the intentionally broken
repeat configure; its only structural delta from the final capture is removal
of the erroneous `mirror_vfd`, `use_append_chunk_mirror`, and
`H5TEST-mirror_vfd` records and their generated CTest metadata. Those removals
are the expected Work Package 4C correction. CPack staging paths were excluded
by refreshing the real install manifest before the final installed captures.

Installed CMake package files contain no source-build target-system/compiler
admission call or compiler-ID check. Build-tree and installed consumers using
the accepted compilers therefore remain governed by normal prebuilt-library
compatibility rather than the HDF5 source-build firewall.

### Headers, Libraries, and Metadata

All installed header names match 4A. Apart from `H5pubconf.h`, 64 of 64 default
and 100 of 100 C++ header files are byte-identical on each validator. The only
raw `H5pubconf.h` changes are the two generated differences described above.
Fresh installed-header preprocessing produced these comparisons:

| Validator and input | Comparison with 4A | State |
| --- | --- | --- |
| MSVC C and C++ `hdf5.h`; C++ `H5Cpp.h` | Equal after removing blank lines introduced solely by the deleted inactive template entry and right-trimming lines | `PASS` |
| GCC C11 `hdf5.h`; G++ C++11 `hdf5.h` and `H5Cpp.h` | Raw preprocessor output byte-identical | `PASS` |

No public declaration, public type, layout-sensitive C/C++ source, or active
configuration macro changed after 4A. A new layout probe was therefore not
triggered; the exact effective-declaration, compile/link/run, and symbol checks
retain their separate scopes.

Fresh case-sensitive symbol manifests match the 4A raw captures for all five
libraries on both validators. Counts and hashes are recorded in
`Symbols and Binary Metadata` above, including the corrected 1,143-name Windows
C++ baseline. Windows retains DLL/import/static triplets for C, HL, tools, C++,
and HL C++ as applicable. Linux retains static archives plus `.so`, `.so.1000`,
and `.so.1000.0.0`; SONAMEs remain `.so.1000` and installed RUNPATH remains
`$ORIGIN/../lib:$ORIGIN/`. Installed `h5dump` reports version 2.3.0 without an
ambient HDF5 path on both validators, and Linux `ldd` resolves its HDF5
dependencies from the isolated install.

The sorted binary-package path sets are exactly equal to 4A at 120/164 Windows
ZIP entries and 122/169 Linux TGZ entries. All expected static/shared products,
headers, tools, exports, and metadata are present; removed-language and local
validation paths are absent.

### Consumers, Wrappers, and Examples

| Consumer surface | Windows | Linux | State |
| --- | --- | --- | --- |
| Build-tree `find_package` | C shared, HL static, and C++ shared configured, built, and passed 3/3 | Same, passed 3/3 without ambient HDF5 variables | `PASS` |
| Install-tree `find_package` | Same three consumers passed 3/3 using only the tested install runtime path | Same, passed 3/3 without ambient HDF5 variables | `PASS` |
| Standalone combined examples | Build-tree and install-tree C/C++/HL/HL C++ sets each passed 279/279 | Both shared sets passed 279/279; additional all-static build/install sets each passed 279/279 | `PASS` |
| Source consumers | `add_subdirectory` and local-source FetchContent consumers each passed 1/1 | Both consumers passed 1/1 | `PASS` |

The six compared parent-visible source-consumer cache settings are unchanged
from the retained baseline: `BUILD_SHARED_LIBS`, `BUILD_TESTING`,
`HDF5_BUILD_CPP_LIB`, `HDF5_BUILD_EXAMPLES`, `HDF5_BUILD_HL_LIB`, and
`HDF5_BUILD_TOOLS`. An initial Windows build-tree consumer execution without
the just-built DLL directory failed loader startup; rerunning with only that
explicit runtime path passed 3/3. This was an invocation-environment correction,
not a package or product failure.

Linux installed `h5cc` and `h5c++` compile and run C and C++ consumers in both
default-HL and `-nohl` modes. Their displayed link sets are respectively
`hdf5_hl` plus `hdf5`, `hdf5` alone, `hdf5_hl_cpp` plus `hdf5_cpp`, `hdf5_hl`,
and `hdf5`, and `hdf5_cpp` plus `hdf5`. All four installed pkg-config files
validate, report version 2.3.0, and expose the expected libraries. A direct WSL
invocation initially omitted the user-local `pkg-config` directory; the final
checks used an explicit command-scoped tool path and no ambient HDF5 library
path.

### Plugins, Compatibility, and Source Package

Normal plugin loading passed on both validators. On Linux, valid filter-plugin
binaries copied under `.dylib`-only names were not registered and the controlled
negative invocation failed as expected; the same `.so` test passed before and
after it. This confirms the accepted Linux filename exclusion without changing
the plugin contract. Focused error, HL compatibility, datatype API, reference,
and conversion tests passed 11/11 with fixtures on Windows and 10/10 with
fixtures on Linux; the separate Linux positive plugin test also passed 1/1.

The final clean tracked-source TGZ has 4,103 internal package entries (4,106
archive listing lines including three outer packaging directories) and matches
all 3,935 tracked files exactly. Relative to 4A it adds only six tracked Stage 4
test/documentation paths: `config/cmake/runMirrorServer.cmake`,
`config/cmake/tests/HDF5ExamplePlatformSupportCase.cmake`,
`config/cmake/tests/HDF5UtilityRegistrationTests.cmake`,
`docs/refactoring/CMakePlatformSupportReductionStage4Results.md`,
`test/API/driver/HDF5APIDriverProcessTests.cmake`, and
`test/API/driver/h5_api_test_driver_process.cpp`. It contains no Git, IDE,
agent, build, CPack staging, Java, or Fortran path. This later documentation
checkpoint changes tracked document content but not the verified source-package
path manifest; product evidence remains attached to `f6ff66fed` under the
plan's documentation-only inheritance rule.

Work Package 4E required no product correction. All product and consumer deltas
are classified, S4-04 is closed, and its fresh default/C++ Release, install,
package, example, consumer, wrapper, plugin, and compatibility evidence may be
reused by Work Package 4F at implementation anchor `f6ff66fed`.

## Work Package 4F: Final Gate and Handoff

Work Package 4F used clean tracked Windows and Linux source trees whose product
implementation is exactly `f6ff66fed`. The Windows tree was at documentation
checkpoint `8adcde9af`; the Linux tree was at `eb118c43d`. Differences after
`f6ff66fed` are limited to plans, results, the handoff, and other current
documentation. No CMake implementation, C/C++ source, header, test, example,
install, export, or package-input path differs between the validators.

The atomic Stage 4 implementation sequence is `137ebb73c`, `901ef3d20`,
`20bd1a464`, `1559e52be`, `49237b0af`, and `ebdb99969` for Work Package 4B;
`8d7aa0432` for Work Package 4C; and `f6ff66fed` for Work Package 4D. Work
Packages 4E and 4F required no product correction.

Windows used Visual Studio 18 2026 x64 and MSVC 19.51 with `CL=/utf-8`.
Linux used GCC/G++ 15.2.0 with Ninja 1.13.2 and GNU Make 4.4.1. All test runs
used `HDF_TEST_EXPRESS=3`. Windows and WSL commands ran sequentially, and each
build or CTest invocation used at most four jobs. This was the temporary Stage
4 execution budget, not a repository default or a durable product parameter.

### Final Matrix

| Row | Windows/MSVC result | Linux/GCC result | Evidence identity |
| --- | --- | --- | --- |
| Default Release | Full static/shared build and 2,816/2,816 enabled tests passed; 37 disabled out of 2,853 registered | Full 3,153-step Ninja build and 2,818/2,818 enabled tests passed; 37 disabled out of 2,855 registered | Fresh 4E row at `f6ff66fed` |
| Debug | Fresh full build, fixture-expanded smoke 7/7, Debug install, and 19 installed library/tool PDBs passed | Fresh full 3,153-step build and fixture-expanded smoke 7/7 passed | Fresh 4F row at `f6ff66fed` |
| Static-only Release | Fresh full build, smoke 7/7, static-only C/HL artifacts, and isolated consumer 1/1 passed | Fresh full 2,702-step build, smoke 7/7, archives without shared objects, and isolated consumer 1/1 passed | Fresh 4F row at `f6ff66fed` |
| Shared-only Release | Fresh full build, smoke 7/7, DLL/import libraries without static C/HL archives, and isolated consumer 1/1 passed | Fresh full 2,748-step build, smoke 7/7, versioned shared objects without archives, SONAME `libhdf5.so.1000`, and isolated consumer 1/1 passed | Fresh 4F row at `f6ff66fed` |
| C++ Release | Full C/C++ static/shared build and named core/HL C++ tests 2/2 passed | Same | Fresh 4E row at `f6ff66fed` |
| Reconfigure | Default and explicit `ON`/`OFF`, repeated configures, unavailable prerequisites, and `ON/OFF/ON` passed | Same; legal mirror targets and fixture-expanded tests also passed 5/5 | 4C at `8d7aa0432`; later changes do not touch the option or mirror registration |
| API driver | Driver/helper/API targets, process cases 5/5, registered API integration 1/1, and residual-process check passed | Same | 4D at final implementation `f6ff66fed` |
| Admission | Twelve central cases plus four combined-example cases passed | Same | 4B at `ebdb99969`; 4C/4D do not change the firewall or its callers |
| Secondary generator | Synthetic policy cases preserve generator-independent admission | Fresh full Unix Makefiles product build and smoke 7/7 passed | 4B policy evidence plus fresh 4F Linux build |
| Install/package | Default/C++ installs and 120/164-entry ZIPs passed; fresh Debug PDB install passed | Default/C++ installs and 122/169-entry TGZ packages passed; SONAME/RUNPATH checks passed | Fresh 4E products plus the 4F Debug check |
| Standalone examples | Build/install package sets each passed 279/279 | Shared and static build/install package sets each passed 279/279 | Fresh 4E row at `f6ff66fed` |
| Consumers | Build/install C, HL, and C++ consumers passed 3/3 each; source consumers passed 1/1 each; fresh static/shared linkage consumers passed 1/1 each | Same, plus wrappers/pkg-config and fresh static/shared linkage consumers passed 1/1 each | Fresh 4E and 4F rows at `f6ff66fed` |
| Compatibility | Effective headers, all five symbol families, libraries, metadata, plugins, and file/API compatibility selection 11/11 passed | Same with compatibility selection 10/10, plugin 1/1, and the accepted negative `.dylib` discovery check | Fresh 4E row at `f6ff66fed` |
| Source package | The shared clean-source result covers both validators | 3,935 packaged files match all 3,935 tracked paths; no local or removed-language path is present | Fresh 4E archive, path manifest repeated in 4F |

Before the final smoke rerun, `ctest --show-only=json-v1` confirmed the exact
seven-test expansion in every fresh Debug, static-only, shared-only, and Unix
Makefiles tree: the three requested tests, the C and HL setup/cleanup fixtures,
and their `FIXTURES_REQUIRED` relationships. The subsequent fixture-aware run
passed 7/7 in each tree. The common selection was:

```text
^(H5TEST-testhdf5-base|HL_test_lite|H5DIFF-h5diff_10)$
```

The additional configurations used these normalized commands and option sets:

```powershell
$env:CL = "/utf-8"
cmake -S <src> -B <build-root>/debug -G "Visual Studio 18 2026" -A x64
cmake --build <build-root>/debug --config Debug --parallel 4
cmake --install <build-root>/debug --config Debug --prefix <install-root>/debug
cmake -S <src> -B <build-root>/static -G "Visual Studio 18 2026" -A x64 `
  -DBUILD_SHARED_LIBS=OFF
cmake -S <src> -B <build-root>/shared -G "Visual Studio 18 2026" -A x64 `
  -DBUILD_STATIC_LIBS=OFF
cmake --build <build> --config Release --parallel 4
$env:HDF_TEST_EXPRESS = "3"
ctest --test-dir <build> -C <config> --output-on-failure -j 4 -R <selection>
```

```sh
cmake -S <src> -B <build-root>/debug -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake -S <src> -B <build-root>/static -G Ninja -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF
cmake -S <src> -B <build-root>/shared -G Ninja -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_STATIC_LIBS=OFF
cmake -S <src> -B <build-root>/makefiles -G "Unix Makefiles" \
  -DCMAKE_BUILD_TYPE=Release
cmake --build <build> --parallel 4
HDF_TEST_EXPRESS=3 ctest --test-dir <build> \
  --output-on-failure -j 4 -R '<selection>'
```

Fresh static/shared consumers used `find_package(HDF5 CONFIG REQUIRED
COMPONENTS C HL)`, linked the explicit `hdf5[-hl]-static` or
`hdf5[-hl]-shared` build-tree targets, created a file and HL dataset, and ran
without ambient `HDF5_DIR`, `HDF5_ROOT`, or Linux library-path variables. The
Windows shared consumer used only the just-built DLL directory at runtime.

### Final Residual and Package Audit

The repeated tracked scan now covers 1,359 files because 4D added
`test/API/driver/h5_api_test_driver_process.cpp`. That file adds no selector
match, so every lexical family count remains exactly the 4B value recorded
under `Residual Selectors`. Exact active unsupported CMake conditions remain
absent outside the synthetic rejection tests; the only condition-shaped scan
hits are retained `clang-format` and `clang-tidy` developer-tool checks.

The generated-header, settings, installed CMake metadata, and pkg-config scan
of the fresh default build/install products found no removed platform macro,
unsupported compiler selector, or rejected target-system admission check. The
source archive was compared again after removing its documented packaging
prefix: all 3,935 file paths equal the current tracked path set, and no Git,
IDE, agent, build-staging, Java, or Fortran directory is present. Later 4F
documentation edits change file contents but add no package-input path, so the
path-manifest result remains applicable under the documentation-only rule.
The current breaking-change entry in `release_docs/CHANGELOG.md` names the
two-pair contract and the delivered compatibility changes consistently; no
additional user-visible 4F behavior was introduced.

### Optional Evidence Inheritance

Stage 4 does not change dependency discovery or exports for compression, MPI,
subfiling, ROS3, HDFS, signed plugins, or external filters; coverage or package
generator implementation; or thread/concurrency runtime code. The shared
configuration and GNU flag edits remove only rejected-system/compiler
alternatives. MSVC/GNU generated settings, effective declarations, compile
commands, and final products retain the accepted-pair results. The utility and
API-driver corrections affect test registration or opt-in test-driver code,
not those product paths. These file, target, dependency, and generated-contract
facts support the inherited results listed below. In-tree plugin behavior was
also rerun in 4E.

The retained Stage 2 passes for bundled/system compression, parallel HDF5,
subfiling, thread-safe/concurrency, external plugins, coverage, STGZ, and DEB
therefore remain valid at their named commits. The six accepted missing-
environment deferrals remain unchanged. No Stage 4 correction affects a
deferred feature, and no required Stage 4 gate is hidden by a deferral.

### Invocation Corrections

An initial Windows Debug configure lost the multiword generator quoting before
CMake parsed it; the corrected invocation configured and completed the full
build. A direct WSL structured-listing query likewise lost shell quoting around
the combined regular expression; exact-name queries produced the intended
seven-test fixture set, followed by the passing formal rerun. A first source-
archive comparison removed only one of its documented outer path components;
using the complete package prefix produced the exact 3,935-to-3,935 result.
These were invocation or normalization errors, not product failures, and none
caused a repository change.

All `FIX_STAGE4` findings are closed, every required matrix row passes or cites
qualifying final-implementation evidence, no `INVESTIGATE` item remains, and
the completion statement is established:

> Project supported-platform reduction is complete: active repository and
> delivery contracts implement Windows/MSVC and Linux/GNU, the required final
> release-baseline gates pass, protected API/ABI/file-format behavior and the
> accepted plugin filename boundary are preserved, and remaining optional
> validation limits and independent follow-ups are explicitly recorded.

## Historical Evidence Map and Current Capability Probe

Historical passing evidence remains attached to its tested implementation. It
is not relabeled as a Stage 4 run.

| Evidence family | Tested implementation | Recorded result | Potential Stage 4 owner |
| --- | --- | --- | --- |
| Stage 1 Windows CMake matrix and firewall | `614dd74c0`, source repair `a68b4cae4e` | `PASS` | 4B admission/current-claim audit; 4F final gate |
| Stage 2 Linux core matrix and optional rows | `6ee2f392e` | `PASS` except six explicit environment deferrals | 4B evidence classification; 4F affected rows |
| Bundled compression repair | `81e96c889` | `PASS` | Inherit unless audit or repair changes dependency/export behavior |
| Coverage contract and system compression | `d39cd5fa0`, record `4fb87c374` | `PASS` | Inherit unless affected |
| Stage 3 source/header reduction | `74288cbaa` | `PASS` | 4E product comparison and 4F final gate |
| Stage 4 fresh baseline | `cafdc38e9`, implementation still `74288cbaa` | `PASS` except reproduced S4-01/S4-02 | 4B through 4F |

The current read-only probe found OpenMPI 5.0.10, lcov/genhtml 2.0-1,
pkg-config 2.5.1, and an OpenSSL 3.5.5 runtime on Linux. Microsoft MPI runtime,
Strawberry pkg-config, Perl, and OpenSSL executables are present on Windows;
signing tools, JDK/Hadoop, and their development inputs are not. No dependency
was installed or modified.

| Optional row | Current capability or limit | Historical evidence | Stage 4 state |
| --- | --- | --- | --- |
| Installed wrappers/pkg-config | Available; final installed execution and metadata checks passed in 4E | `PASS` at final implementation `f6ff66fed` | `PASS` |
| System zlib/libaec | Not discoverable in the current Linux pkg-config environment | `PASS` from isolated packages at `d39cd5fa0`; dependency/export paths are unaffected | `INHERITED_PASS` |
| Bundled compression | Outbound proxy works; row not rerun | `PASS` at `81e96c889`; dependency/export paths are unaffected | `INHERITED_PASS` |
| Parallel HDF5 | OpenMPI 5.0.10 available; row not rerun | `PASS` at `6ee2f392e`; MPI discovery, targets, wrappers, and runtime paths are unaffected | `INHERITED_PASS` |
| Parallel tools | mpiFileUtils/libcircle/DTCMP not discoverable | Explicit Stage 2 deferral | `SKIP_MISSING_ENV` |
| Subfiling | OpenMPI prerequisite available; row not rerun | `PASS` at `6ee2f392e`; subfiling and MPI implementation paths are unaffected | `INHERITED_PASS` |
| Thread-safe and concurrency | No external prerequisite; rows not rerun | `PASS` at `6ee2f392e` and `74288cbaa`; runtime and option paths are unaffected | `INHERITED_PASS` |
| External plugins | In-tree loading and filename behavior rerun; external row not rerun | `PASS` at `6ee2f392e`, with final in-tree plugin `PASS` in 4E; loader and external dependency paths are unaffected | `INHERITED_PASS` |
| ROS3 | aws-c-s3 development package absent | Explicit Stage 2 deferral | `SKIP_MISSING_ENV` |
| HDFS | JDK, Hadoop, and libhdfs absent | Explicit Stage 2 deferral | `SKIP_MISSING_ENV` |
| Signed plugins | OpenSSL runtime exists; pkg-config metadata, development, and signing inputs absent | Explicit Stage 2 deferral | `SKIP_MISSING_ENV` |
| Coverage | lcov/genhtml 2.0-1 available; row not rerun | `PASS` at `d39cd5fa0`; the GNU-only coverage truth value and coverage targets are unchanged | `INHERITED_PASS` |
| STGZ and DEB | Rows not rerun | `PASS` at `6ee2f392e`; Linux package-generator implementation is unaffected and final TGZ passes | `INHERITED_PASS` |
| RPM | `rpmbuild` absent | Explicit Stage 2 deferral | `SKIP_MISSING_ENV` |
| Native unsupported compiler | Clang, Intel, and NVIDIA compilers absent | Explicit Stage 2 deferral; synthetic policy `PASS` | `SKIP_MISSING_ENV` |

## Repository Contract Audit

### Entry Points and Admission

The audit enumerated all 204 tracked `CMakeLists.txt` and CMake module or
template paths and reviewed 74 `project()` calls. Most project calls are nested
package coordinators and inherit the root admission decision. The active
configure surfaces have these owners:

| Configure surface | Languages and admission owner | State |
| --- | --- | --- |
| Root HDF5 project | C is checked immediately after `project()`; optional C++ is checked immediately after `ENABLE_LANGUAGE(CXX)` | `PASS` |
| Combined standalone examples | C is checked at entry; optional C++ is now checked immediately after it is enabled | `PASS` |
| Standalone C++ examples | C++ is checked at entry | `PASS` |
| Optional API test driver | C++ is checked at entry | `PASS` |

The C-only example subdirectories are entered through the combined examples
coordinator; their nested `project()` calls are not documented independent
configure surfaces. Installed packages intentionally do not apply the
source-build firewall to downstream consumers using their own compatible
compiler. The optional API driver cannot bypass admission. Its separate S4-02
build defects were repaired and validated by Work Package 4D at `f6ff66fed`.

The admission suite now contains 12 central policy cases and four combined
example cases. It passed on both Windows and Linux. The cases cover both
accepted pairs, rejected target systems and compiler IDs, optional C++,
generator and architecture variation, non-bypass by
`HDF5_ALLOW_UNSUPPORTED`, and the combined examples' late C++ enablement.

### Presets, Automation, Packaging, and Claims

- Root preset listing exposes one applicable MSVC configure preset on Windows
  and two applicable GNU configure presets on Linux. The examples expose one
  applicable configure preset per host. Cross-host build/test names shown by
  `--list-presets=all` require a corresponding configured tree and cannot
  bypass the root firewall.
- All 57 workflow files were enumerated; 35 invoke CMake or CTest. HDF5 source
  build jobs use Windows/MSVC, Ubuntu/GCC, or MPI wrappers resolving to GNU.
  Clang occurrences are formatter/analyzer tooling rather than source builds.
- Dashboard selection is limited to the Visual Studio baseline on Windows and
  Ninja or Unix Makefiles on Linux. HPC scripts still configure the root
  project and therefore remain subject to its compiler firewall.
- Packaging selects Windows ZIP with optional WiX metadata and Linux TGZ/STGZ
  with environment-dependent DEB/RPM. Retained NSIS settings support explicit
  Windows packaging. No macOS or other rejected-system package generator is
  reachable. The release-index script's `.dmg` label can describe historical
  or externally supplied artifacts and is not a source-package path.
- Current installation and option guides state the two accepted compiler
  pairs and the HDFS/JNI exception. The Parallel HDF5 guide now requires Linux
  MPI wrappers to resolve to GNU and labels Cray-specific advice historical.
  Historical release documents remain unchanged.
- No Java or Fortran product directory, build option, language enablement,
  target, example product, packaging component, or workflow remains. Python
  under `HDF5Examples/` remains example code. `H5T_FORTRAN_S1` is public
  API/file-format compatibility, and JNI discovery remains required only by
  the retained libhdfs VFD.

### Residual Selectors

The repeated case-insensitive scan covered the same 1,358 tracked C/C++ source,
header, lexer/parser, and template files as the Stage 3 final inventory. Counts
are lexical leads expressed as matches/files:

| Family | Matches/files | Family | Matches/files |
| --- | ---: | --- | ---: |
| `APPLE` | 3/3 | `AIX` | 134/6 |
| `CLANG` | 225/37 | `HPUX` | 1/1 |
| `CYGWIN` | 6/5 | `HP-UX` | 5/2 |
| `DARWIN` | 0/0 | `INTELLLVM` | 0/0 |
| `FREEBSD` | 1/1 | `NVHPC` | 0/0 |
| `INTEL` | 179/14 | `AOCC` | 0/0 |
| `MACOS` | 4/1 | `EMSCRIPTEN` | 0/0 |
| `MINGW` | 7/6 | `SUNOS` | 0/0 |
| `NETBSD` | 2/2 | `SOLARIS` | 3/3 |
| `PGI` | 17/2 | `SUNPRO` | 0/0 |
| `XL` | 430/29 | `IBM` | 29/6 |
| `CRAY` | 25/8 |  |  |

Exact preprocessor review found only `__hpux`, `_AIX`, and two `__ICC`
occurrences in Bison-skeleton code within `hl/src/H5LTparse.c`, plus compiler
dispatch in vendored `src/uthash.h`. Both are `KEEP_PROTECTED`; their canonical
generated or third-party ownership is unchanged. Exact unsupported CMake
selectors are absent outside the synthetic rejection tests.

Other lexical matches are protected public/file-format names, architecture or
interoperability data, generic supported feature probes, formatter/analyzer
tooling, test-output normalization, and factual history. In particular,
`bin/output_filter.sh`, `bin/warnhist`, `test/test_flush_refresh.sh.in`,
`src/H5Tpkg.h`, and `.github/scripts/generate-index-html.sh` do not select an
unsupported source build. There is no remaining `INVESTIGATE` item.

### Corrections and Validation

| Finding | Correction and evidence | State |
| --- | --- | --- |
| Combined examples late C++ admission | `137ebb73c` added immediate C++ validation and four script cases; full standalone C/C++/HL builds passed on MSVC and GCC | `PASS` |
| SunOS/AIX configuration remnants | `901ef3d20` removed unreachable SunOS guards and stale AIX/Solaris notes; `20bd1a464` removed the unused AIX header template; C/C++ shared builds and generated settings/declaration comparisons passed on both pairs | `PASS` |
| Compiler simulation remnants | `1559e52be` reduced coverage and complex probing to actual MSVC/GNU paths; fresh shared builds and expected complex configuration values passed on both pairs | `PASS` |
| GNU C++ module's nested MSVC path | `49237b0af` removed the unreachable branch while retaining the effective GNU operation; 408 normalized all-warning commands and `libhdf5.settings` remained hash-identical, and MSVC/GCC C++ shared builds passed | `PASS` |
| Parallel-HDF5 support prose | `c6e2c2cb9` scoped MPI wrappers to the accepted compiler IDs and marked Cray advice historical | `PASS` |
| Combined-example warning suppression | `ebdb99969` applies `/w` to enabled MSVC C++ examples and keeps it out of `link.exe`; dual-host script cases and representative C/C++ example builds passed, while GNU retained `-w` on compile and compiler-driver link commands | `PASS` |
| Utility-dependent test registration | `8d7aa0432` centralizes the option, gates mirror targets on both prerequisites, and adds real server fixtures; 11-step contracts passed on both pairs and Linux mirror tests passed 5/5 | `PASS` |
| Optional API driver build and cleanup | `f6ff66fed` owns the generated include paths and fixes the cleanup identifier; both targets build and five process plus one registered API integration test pass on each pair without residual processes | `PASS` |

## Findings Ledger

| ID | Classification | Baseline evidence | Validation owner | State |
| --- | --- | --- | --- | --- |
| `S4-01` | `FIX_STAGE4` | Fixed at `8d7aa0432`: first/second/third and `ON/OFF/ON` contracts match; legal Linux mirror targets build and fixture-expanded tests pass 5/5 | 4C | `PASS` |
| `S4-02` | `FIX_STAGE4` | Fixed at `f6ff66fed`: the real optional driver builds on MSVC and G++, five controlled process tests pass on each, and registered API integration passes | 4D | `PASS` |
| `S4-03` | `FIX_STAGE4` | Current summaries and support guides agree with completed Stage 2/3 evidence; the HPC compiler-wrapper ambiguity was corrected | 4B | `PASS` |
| `S4-04` | `KEEP_PROTECTED` | Final 65/101 header sets, effective declarations, contracts, symbols, artifacts, and consumers are compared with separate scopes and no unexplained delta | 4E and 4F | `PASS` |
| `S4-05` | `FIX_STAGE4` | Combined examples allowed late C++ enablement without a C++ compiler-pair check; fixed at `137ebb73c` | 4B | `PASS` |
| `S4-06` | `FIX_STAGE4` | Unreachable SunOS branches, stale AIX/Solaris notes, and the unused AIX header macro were removed at `901ef3d20` and `20bd1a464` | 4B | `PASS` |
| `S4-07` | `FIX_STAGE4` | Unsupported compiler-simulation paths were removed at `1559e52be` without changing pair-specific complex results | 4B | `PASS` |
| `S4-08` | `FIX_STAGE4` | The GNU C++ flags module's impossible nested MSVC branch was removed at `49237b0af` with exact GNU command/settings equality | 4B | `PASS` |
| `S4-09` | `FIX_STAGE4` | Combined examples now suppress MSVC C++ warnings and no longer pass `/w` to the linker; fixed at `ebdb99969` | 4B | `PASS` |

The discarded 4A worktree source archive is a corrected validation-method
artifact, not a product finding. Work Package 4B has no remaining
`INVESTIGATE` or failed row. Work Packages 4C and 4D close S4-01 and S4-02;
the findings ledger has no remaining required `FAIL` row. Work Package 4E
closes the product and consumer comparisons without a product correction.
Work Package 4F closes the complete matrix and handoff; no finding remains open.

## Continuation Point

Stage 4 and the overall platform-reduction direction are complete at product
implementation anchor `f6ff66fed`. Preserve the versioned Stage 1 through 4
results, the six accepted environment deferrals, and the documented evidence
limits. No platform-reduction implementation or validation action remains.

Resume the separate CMake 4 modernization from its unchanged implementation
anchor `0b9e21c34`. The concrete next batch is to classify the remaining
repeated MPI include expressions owned by standalone examples, package
configuration, dependency-specific targets, and C++ targets, then continue the
dedicated compatible migration of remaining global compiler-flag state. That
work must use the modernization plan's own per-change validation requirements;
the temporary Stage 4 four-job budget is not a permanent reference value.
