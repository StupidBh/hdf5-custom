# Stage 2 Native Linux/GCC Validation Results

## Status

- State: core gate, bundled compression, system compression, and coverage
  passed; six missing-environment decisions pending
- Core matrix implementation: `6ee2f392e`
- Bundled-compression repair implementation: `81e96c889`
- Coverage-contract correction: `d39cd5fa0`
- Execution date: 2026-09-04
- Parent plan:
  [`CMakePlatformSupportReductionStage2.md`](CMakePlatformSupportReductionStage2.md)
- Portable handoff: [`../../REFACTORING_PROGRESS.md`](../../REFACTORING_PROGRESS.md)
- `HDF_TEST_EXPRESS`: `3`
- Maximum build and test parallelism: 6

Stage 2 is not closed. The fixed core gate, bundled- and system-compression
rows, and corrected coverage contract are green, but six missing-environment
rows remain under the parent plan's exit criteria. Stage 3 source/header
reduction remains unauthorized.

## Qualified Validator

The broad matrix used implementation `6ee2f392e`; the bundled-compression
repair validation used implementation `81e96c889`. Build, install, download,
package, log, and consumer directories were outside the tracked source tree.
The coverage-contract correction and system-compression validation used
`d39cd5fa0`.

| Component | Qualified value |
| --- | --- |
| Distribution | Ubuntu 26.04.1 LTS under WSL2 |
| Kernel | `6.18.33.2-microsoft-standard-WSL2` |
| Architecture and libc | x86_64, glibc 2.43 |
| CMake, CTest, CPack | 4.2.3 |
| GCC and G++ | 15.2.0 |
| C and C++ target triples | `x86_64-linux-gnu` |
| Ninja | 1.13.2 |
| GNU Make | 4.4.1 |
| OpenMPI | 5.0.10; CMake MPI level 3.1 |
| lcov and genhtml | 2.0-1 |
| pkg-config | 2.5.1 |

The validator satisfies the version-independent Linux/GNU contract and the
release-qualified Linux x86_64, GCC/G++, and Ninja baseline. Root and retained
standalone-example preset listing both passed.

## Normalized Commands

Commands below use `<src>`, `<build-root>`, and `<install-root>` placeholders.
Every configuration used a fresh directory.

```sh
cmake -S <src> -B <build-root>/<row> -G Ninja \
  -DCMAKE_BUILD_TYPE=<Release-or-Debug> <row-options>
cmake --build <build-root>/<row> --parallel 6
HDF_TEST_EXPRESS=3 ctest --test-dir <build-root>/<row> \
  --output-on-failure -j 6 <selection>
cmake --install <build-root>/<row> --prefix <install-root>/<row>
cpack --config <build-root>/<row>/CPackConfig.cmake -G <generator>
```

`LNX-MAKE` substituted `-G "Unix Makefiles"`. Focused core smoke tests used
`^(H5TEST-testhdf5-base|HL_test_lite|H5DIFF-h5diff_10)$`; CTest included the
registered setup and cleanup fixtures. Standalone examples were configured
once with the build-tree `HDF5_DIR` and once with the isolated install-tree
`HDF5_DIR`. Contract comparison used
`config/cmake/scripts/HDF5BuildContract.cmake` for both `b22b55872` and the
tested implementation.

The following are the exact non-default configure option sets. Rows omitted
from this table used repository defaults or only the generator/build type
already shown in their result entry.

| Rows | `<row-options>` |
| --- | --- |
| `LNX-STATIC` | `-DBUILD_SHARED_LIBS=OFF` |
| `LNX-SHARED` | `-DBUILD_STATIC_LIBS=OFF` |
| `LNX-CPP` | `-DHDF5_BUILD_CPP_LIB=ON` |
| Installed examples and `find_package` consumers | `-DHDF5_DIR=<build-package>` or `-DHDF5_DIR=<install-package>` |
| Source-tree consumers | `-DBUILD_SHARED_LIBS=OFF -DBUILD_TESTING=OFF -DHDF5_BUILD_HL_LIB=OFF -DHDF5_BUILD_TOOLS=OFF -DHDF5_BUILD_EXAMPLES=OFF` |
| `LNX-SYSTEM-COMPRESSION` | `-DHDF5_ENABLE_ZLIB_SUPPORT=ON -DHDF5_ENABLE_SZIP_SUPPORT=ON -DZLIB_USE_EXTERNAL=OFF -DSZIP_USE_EXTERNAL=OFF -DHDF5_ALLOW_EXTERNAL_SUPPORT=NO -DCMAKE_PREFIX_PATH=<system-compression-prefix>` |
| `LNX-PARALLEL` | `-DHDF5_ENABLE_PARALLEL=ON` |
| `LNX-SUBFILING` | `-DBUILD_STATIC_LIBS=OFF -DHDF5_ENABLE_PARALLEL=ON -DHDF5_ENABLE_SUBFILING_VFD=ON -DHDF5_BUILD_HL_LIB=OFF -DHDF5_BUILD_TOOLS=OFF -DHDF5_BUILD_EXAMPLES=OFF` |
| `LNX-THREADSAFE` | `-DBUILD_STATIC_LIBS=OFF -DHDF5_ENABLE_THREADSAFE=ON -DHDF5_BUILD_HL_LIB=OFF -DHDF5_BUILD_TOOLS=OFF -DHDF5_BUILD_EXAMPLES=OFF` |
| `LNX-CONCURRENCY` | `-DBUILD_STATIC_LIBS=OFF -DHDF5_ENABLE_CONCURRENCY=ON -DHDF5_BUILD_HL_LIB=OFF -DHDF5_BUILD_TOOLS=OFF -DHDF5_BUILD_EXAMPLES=OFF` |
| `LNX-EXTERNAL-PLUGINS` | `-DBUILD_STATIC_LIBS=OFF -DHDF5_BUILD_HL_LIB=OFF -DHDF5_BUILD_EXAMPLES=OFF -DHDF5_ENABLE_PLUGIN_SUPPORT=ON -DPLUGIN_USE_EXTERNAL=ON -DPLUGIN_USE_LOCALCONTENT=OFF -DHDF5_ALLOW_EXTERNAL_SUPPORT=TGZ` |
| `LNX-COVERAGE` | `-DBUILD_SHARED_LIBS=OFF -DHDF5_ENABLE_COVERAGE=ON -DCODE_COVERAGE=ON -DHDF5_BUILD_HL_LIB=OFF -DHDF5_BUILD_TOOLS=OFF -DHDF5_BUILD_EXAMPLES=OFF` |
| `LNX-BUNDLED-COMPRESSION` | `cmake --preset ci-StdShar-GNUC`; the versioned preset is the option record |

## Core Gate Results

Options not listed remained at repository defaults.

| Row | Non-default configuration | Evidence | State |
| --- | --- | --- | --- |
| `LNX-CORE-REL` | Ninja, Release | Full build passed. Full CTest: 2,819 passed, 0 failed, 37 disabled, 2,856 registered. Focused smoke: 7/7 passed. | `PASS` |
| `LNX-CORE-DBG` | Ninja, Debug | Full build and focused smoke 7/7 passed. | `PASS` |
| `LNX-STATIC` | Release, `BUILD_SHARED_LIBS=OFF` | Full build and smoke 7/7 passed. Static core and high-level archives were present; shared forms were absent. | `PASS` |
| `LNX-SHARED` | Release, `BUILD_STATIC_LIBS=OFF` | Full build and smoke 7/7 passed. Shared core and high-level libraries were present; static forms were absent. | `PASS` |
| `LNX-CPP` | Release, `HDF5_BUILD_CPP_LIB=ON` | Full C/C++ build passed. Focused C++ and C++ high-level tests passed 2/2 and all 12 compiler-admission script cases passed. | `PASS` |
| `LNX-MAKE` | Unix Makefiles, Release | Full default build and focused smoke 7/7 passed. | `PASS` |
| `LNX-EXAMPLES` | C++-enabled build and isolated install packages | Standalone C, C++, and high-level examples passed 279/279 tests against each package location. | `PASS` |
| `LNX-CONSUMERS` | Default products plus static source-tree consumers | Build-tree and install-tree C shared, C++ shared, and high-level static `find_package` programs passed 3/3 each. Minimal `add_subdirectory()` and local-source FetchContent programs passed 1/1 each. | `PASS` |
| `LNX-INSTALL` | Default Release isolated prefix | Core and high-level static/shared libraries, headers, tools, `.pc` files, CMake configuration, and export sets were present. `libhdf5.so.1000`, PIC, and installed RUNPATH were verified; installed `h5dump` ran without an injected library path. | `PASS` |
| `LNX-PACKAGE` | TGZ | Package generation passed. The 122-entry archive contained expected headers, tools, libraries, and metadata. | `PASS` |
| `LNX-CONTRACT` | Default Ninja Release at `b22b55872` and `6ee2f392e` | 28,206 baseline and 28,204 current normalized records. All deltas are classified below; no target, flag, test, generated-file, or package-metadata delta remained. | `PASS` |

The installed shared libraries use an `$ORIGIN`-relative RUNPATH. Static and
shared CMake export sets resolve independently, and representative consumers
linked the requested form rather than relying on an ambient build tree.

### Contract Delta Classification

The current contract removed `HDF5_MINGW_STATIC_GCC_LIBS`, removed the
Linux-irrelevant internal `HDF5_MSVC_NAMING_CONVENTION` cache entry, and changed
only the help text of the retained `HDF5_ENABLE_SANITIZERS` option from a
Clang-specific description to a supported-instrumentation description. The two
removals are approved unsupported-surface reductions; the help-only change has
no generated-product effect.

## Optional Results

| Row | Configuration or prerequisite | Evidence | State |
| --- | --- | --- | --- |
| `LNX-WRAPPERS` | C++-enabled isolated install; pkg-config 2.5.1 | All four installed `.pc` files reported 2.3.0. The supported `h5cc` and `h5c++` wrappers passed `-show`, `-showconfig`, compile, link, and run checks with default high-level linkage; `-nohl` correctly omitted the high-level libraries. | `PASS` |
| `LNX-SYSTEM-COMPRESSION` | Ubuntu zlib 1.3.1 and libaec/libsz 1.1.5 development packages, staged in an isolated prefix | CMake found both dependencies with external fetching disabled, and no dependency build tree was created. The full 3,161-step build and 29 focused filter tests passed. Installation passed; its CMake exports contained symbolic dependency targets and no staged-prefix path. Static and shared consumers configured, linked, and ran against both build-tree and install-tree packages, finding DEFLATE and SZIP. | `PASS` |
| `LNX-BUNDLED-COMPRESSION` | Retained `ci-StdShar-GNUC` preset with outbound download | zlib 1.3.2 and libaec 1.1.6 downloaded; configure and the full build passed. Compression and Blosc2 focused tests passed 49/49. Static build-tree and install-tree consumers linked and found DEFLATE/SZIP, and the 798-entry TGZ contained HDF5, zlib, libaec, and their CMake exports. A separate shared-dependency build and both consumers also passed. | `PASS` |
| `LNX-PARALLEL` | `HDF5_ENABLE_PARALLEL=ON`; OpenMPI 5.0.10 | Full 3,532-step build passed. Focused serial, MPI, parallel-tool, and parallel-example selection passed 11/11 with fixtures. | `PASS` |
| `LNX-PARALLEL-TOOLS` | mpiFileUtils, libcircle, and DTCMP | Development packages were not discoverable by pkg-config. | `SKIP_MISSING_ENV` |
| `LNX-SUBFILING` | Parallel and subfiling on; shared only; C++/HL/tools/examples off | The dedicated target and dependencies built; focused subfiling VFD selection passed 3/3 with fixtures. | `PASS` |
| `LNX-THREADSAFE` | Thread-safe on; shared only; C++/HL/tools/examples off | Full build passed; base and `ttsafe` selections passed 6/6 with fixtures. | `PASS` |
| `LNX-CONCURRENCY` | Multi-thread concurrency on; shared only; C++/HL/tools/examples off | Full build passed; base and `ttsafe` selections passed 6/6 with fixtures. | `PASS` |
| `LNX-EXTERNAL-PLUGINS` | External plugin support and remote FetchContent on; shared only | Full build passed and produced 12 filter plugins. Focused ZFP/ZSTD tests passed 10/10. Positive loading succeeded with the plugin path; the negative check failed to print filtered data without it as expected. | `PASS` |
| `LNX-ROS3` | aws-c-s3 | No aws-c-s3 development package was discoverable. | `SKIP_MISSING_ENV` |
| `LNX-HDFS` | JDK/JNI, Hadoop, and libhdfs | `javac` and `hadoop` were absent and no `libhdfs` runtime was registered. | `SKIP_MISSING_ENV` |
| `LNX-SIGNED-PLUGINS` | OpenSSL development files and signing inputs | OpenSSL 3.5.5 runtime was present, but pkg-config metadata and development headers were absent. | `SKIP_MISSING_ENV` |
| `LNX-COVERAGE` | Debug, static only, coverage options on; lcov/genhtml 2.0-1 | Configure, full build, and focused base tests 3/3 passed. Instrumented objects produced `.gcno` and 343 `.gcda` files; `ccov-clean` reduced the counter-file count to zero, and the same tests regenerated all 343. Documentation now states that report generation is external. | `PASS` |
| `LNX-PACKAGE-STGZ` | STGZ | Self-extracting package generation and help inspection passed. | `PASS` |
| `LNX-PACKAGE-DEB` | DEB | The amd64 2.3.0 package generated successfully; 122 content entries and expected artifacts were verified. | `PASS` |
| `LNX-PACKAGE-RPM` | RPM | `rpmbuild` was absent. | `SKIP_MISSING_ENV` |
| `LNX-UNSUPPORTED-COMPILER` | Native Clang, Intel, or NVIDIA compiler | No candidate unsupported native Linux compiler was installed. The synthetic policy suite still passed 12/12. | `SKIP_MISSING_ENV` |

## Failure Classification

The first formal `LNX-CORE-REL` build exposed C++ digit separators left in C
sources by pre-Stage-1 formatting commit `b22b55872`. Commit `6ee2f392e`
mechanically restored C11-compatible integer literals. The complete Linux core
matrix and a fresh Windows/MSVC default Release build then passed; this defect
is closed and was not caused by the Stage 1 platform reduction.

The bundled-compression failure was a Stage 1 regression. Commit `99fbd083b`
enabled normal standalone build-tree package exports, but fetched zlib and
libaec targets were not added to a loadable export. Static HDF5 therefore
referenced missing dependency targets. The retained plugin preset also exposed
a second collision: Blosc2's private zlib-ng used the same target and archive
names as HDF5's fetched zlib.

Commit `81e96c889` added dedicated build-tree dependency exports, loaded them
before HDF5 targets, isolated fetched-zlib outputs, and let bundled subprojects
reuse that zlib. Static and shared GCC consumers passed against build and
install trees; the retained preset, focused filters, TGZ package, and a fresh
Windows/MSVC static-dependency build and consumers also passed.

The coverage discrepancy was a documentation-contract error, not an
instrumentation failure:

| Row | Original failing phase and root cause | Relationship to Stage 1 | Resolution |
| --- | --- | --- | --- |
| `LNX-BUNDLED-COMPRESSION` | CMake generation: downloaded dependency targets were required by HDF5 export sets but were not exported; the plugin build also introduced colliding zlib target and archive names. | Stage 1 regression introduced by build-tree export commit `99fbd083b`. | Fixed by `81e96c889`; rerun `PASS`. |
| `LNX-COVERAGE` | Report generation: the project does not register an executable with the coverage module, so it creates no `ccov` target. | Stage 1 commit `6ad3399ec` incorrectly documented the generic module target as part of the HDF5 top-level contract. | Documentation corrected to promise only target instrumentation, generated GCC counter data, and `ccov-clean`; external tools own report generation. Existing configure, build, test, artifact, and target evidence is `PASS`. |

## Missing-Environment Decisions

No packages or services were added during discovery. Each row below remains
open until the user supplies the prerequisite for another pass or explicitly
defers it.

| Row | Missing prerequisite and evidence | Coverage unlocked and environment change | Recommendation |
| --- | --- | --- | --- |
| `LNX-PARALLEL-TOOLS` | mpiFileUtils, libcircle, and DTCMP development packages; all pkg-config probes failed. | Install a compatible dependency stack, then build and test the optional parallel tools. | Medium value; MPI and subfiling core behavior already pass. |
| `LNX-ROS3` | aws-c-s3 development package and any test service configuration; discovery failed. | Install/configure the SDK and service inputs, then build and run permitted ROS3 tests. | Low value for the platform-reduction boundary. |
| `LNX-HDFS` | JDK/JNI, Hadoop/libhdfs, and runtime configuration; commands and runtime were absent. | Install and configure the complete HDFS stack, then build and run focused VFD tests. | Low value for the platform-reduction boundary. |
| `LNX-SIGNED-PLUGINS` | OpenSSL development metadata/headers and signing inputs; only the runtime executable was present. | Install development files and provide signing inputs, then run positive and failure-path plugin tests. | Low to medium value; ordinary external plugin loading already passes. |
| `LNX-PACKAGE-RPM` | `rpmbuild`; command lookup failed. | Install RPM build tooling and inspect a generated RPM. | Low value; TGZ, STGZ, and DEB already pass. |
| `LNX-UNSUPPORTED-COMPILER` | A native unsupported compiler; Clang, Intel, and NVIDIA compiler lookups failed. | Install one compiler and run real root/C++ rejection checks. | Low value; all 12 synthetic firewall cases pass. |

## Windows Recheck

After the C11 literal repair, a fresh Windows x64 configuration with CMake
4.4.3, Visual Studio 18 2026, MSVC 19.51.36256.0/toolset 14.51.36231,
`CL=/utf-8`, and repository defaults completed a full Release build. The same
focused C, high-level, and tool selection passed 7/7 with fixtures at
`HDF_TEST_EXPRESS=3` and six parallel jobs. Only existing numeric-conversion
warnings were emitted.

After the bundled-compression repair, a fresh minimal Windows x64 configuration
with the same CMake, Visual Studio, and MSVC versions fetched static zlib and
libaec, generated all dependency exports, and completed a full Release build.
Static consumers configured, linked, and ran successfully against both the
build-tree and installed packages. The generated dependency imports used the
expected per-configuration MSVC library paths. This repair-specific build was
launched through WSL without `CL` propagation, so it emitted existing code-page
warnings; no compile or link errors occurred.

## Continuation Point

Obtain explicit user decisions for the six missing-environment rows. Execute
any rows for which prerequisites are supplied and update this record together
with `REFACTORING_PROGRESS.md`. Do not edit source/header compatibility branches
before Stage 2 closes and a separate Stage 3 plan is reviewed.
