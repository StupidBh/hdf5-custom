# Repository Guidelines

## Project Structure & Module Organization

Core C code is in `src/`; the high-level API is in `hl/`, C++ wrappers in `c++/`, and command-line programs in `tools/`. Tests live in `test/` and `testpar/`, examples in `HDF5Examples/`, CMake support in `config/`, and documentation in `docs/` and `release_docs/`.

## Repository Profile & Sources of Truth

This is a CMake-only fork of upstream `develop` with a minimum CMake version of 4.0. The supported product
surface is the core C library, the high-level library, the opt-in C++ wrappers, tools, utilities, and retained
examples. Java and Fortran sources, build options, examples, packaging, and CI were deliberately removed.
Python content under `HDF5Examples/` is example code, not a Python library binding maintained here.

For repository behavior, prefer the current source tree and CMake definitions over inherited prose. In
particular, use `CMakeBuildOptions.cmake`, the top-level `CMakeLists.txt`, and the relevant subdirectory
`CMakeLists.txt` as the source of truth for available options and targets. Some upstream documentation and
history still mention Java or Fortran; those references do not expand this fork's supported scope. JNI discovery
under `HDF5_ENABLE_HDFS` is intentionally retained because libhdfs requires it, not because Java bindings are
supported.

The default build enables static and shared libraries, tests, tools, the high-level library, and examples. C++,
parallel HDF5, thread safety, multi-thread concurrency, and external compression filters are off by default.

`REFACTORING_PROGRESS.md` is the portable handoff for the active refactoring direction. It records completed
work, remaining work, the implementation anchor, the next continuation point, and validation gaps so work can
resume on another machine without relying on chat history or local build artifacts. Read it before continuing a
refactoring and update it after each coherent batch. Keep it aligned with the direction's detailed implementation
document, currently `docs/CMakeModernizationProgress.md`, and never add absolute local paths, transient build
directories, or machine-specific logs.

## Build, Test, and Development Commands

Use an out-of-source MSVC 18 build:

```powershell
cmake -S . -B build-msvc18 -G "Visual Studio 18 2026" -A x64
$env:CL = "/utf-8"
cmake --build build-msvc18 --config Release
ctest --test-dir build-msvc18 -C Release --output-on-failure -j 4
```

`/utf-8` prevents Unicode test failures on non-UTF-8 Windows locales. For stricter diagnostics in this MSVC
workflow, configure with `-DHDF5_ENABLE_DEV_WARNINGS=ON`; there is no `HDF5_ENABLE_DEVELOPER_MODE` CMake
option, and the default Visual Studio configuration list does not contain `Developer`. Never commit generated
build or install trees.

## Architecture & Code Navigation

The core library is divided into prefix-based packages. The main data-model packages are `H5A` (attributes),
`H5D` (datasets), `H5F` (files), `H5G`/`H5L` (groups and links), `H5O` (object headers), `H5P` (property
lists), `H5S` (dataspaces and selections), `H5T` (datatypes), and `H5R` (references). Important infrastructure
includes `H5I` (IDs), `H5E` (errors), `H5C`/`H5AC` (metadata cache), `H5Z` (filters), `H5VL` (VOL), `H5FD`
(VFD), and `H5MM`/`H5FL` (memory management).

Within a package, `H5Xpublic.h` is the installed API, `H5Xprivate.h` is the cross-package internal interface,
`H5Xpkg.h` is restricted to that package, and `H5Xmodule.h` establishes package and error macros. Respect
these boundaries instead of exposing package-only declarations to unrelated modules.

Public object operations normally pass through VOL before reaching the native implementation. For example,
dataset creation follows `H5Dcreate2()` -> `H5D__create_api_common()` -> `H5VL_dataset_create()` ->
`H5VL__native_dataset_create()` -> `H5D__create_named()`. Preserve the VOL dispatch point when changing
user-visible object behavior. Raw file access ultimately passes through the VFL/VFD, while dataset filters are
handled by `H5Z`.

The high-level and C++ libraries wrap the C library; C++ is opt-in (`HDF5_BUILD_CPP_LIB=OFF` by default).
Release version macros live in `src/H5public.h` and feed the top-level CMake package version.

## Focused Development Workflow

Use `rg` to start at a public symbol and follow it through VOL/native and package-private implementations.
Prefer the modern `h5test.h` harness for new tests; `testhdf5` is a legacy aggregate and should not receive new
cases. Inspect registered tests with `ctest --test-dir build-msvc18 -C Release -N -R <pattern>`, then run the
narrowest matching set with the same `-R` pattern and `--output-on-failure`. `HDF_TEST_EXPRESS` ranges from `0`
(exhaustive) to `3` (quickest, the default), so report the configured level with test results.

Useful design references are `CONTRIBUTING.md` for code and test conventions, `docs/INSTALL_CMake_options.md`
for explanations of build options and unsupported combinations, `docs/doxygen/dox/TechnicalNotes.dox` for the
architecture/VOL/VFL/I/O notes index, and `docs/doxygen/dox/FileFormatSpec.dox` for on-disk format behavior.
Verify those explanations against the current CMake source before acting. User-visible changes and user-reported
fixes also require an entry in `release_docs/CHANGELOG.md`.

## Coding Style & Naming Conventions

Use `.clang-format`: four-space indentation, 110 columns, and Stroustrup braces. Format touched C/C++ files with `clang-format -i`. Preserve visibility naming: public `H5Xfoo()`, private `H5X_foo()`, and package-only `H5X__foo()`. Use `HD*` portability wrappers and established HDF5 error macros.

## Testing Guidelines

CTest drives the custom C harnesses. Add focused tests beside the affected module and follow nearby naming. Fixes need a reproducer; new behavior needs positive and failure-path coverage. The full MSVC 18 Release suite must pass before review.

## Commit Guidelines

Make commits atomic, reviewable, and buildable. Keep one behavior's implementation, tests, and required documentation together; split unrelated refactoring, formatting, and dependency updates.

Commit subjects follow project history; Conventional Commits are not mandatory:

- Use an imperative, sentence-case summary no longer than 72 characters, without a period.
- Add a useful scope when appropriate: `H5D:`, `hl:`, `tools:`, `cmake:`, `ci:`, or `docs:`.
- Avoid vague subjects such as `Fix issue`, `Misc changes`, `Updates`, or `WIP`.
- Do not manually append `(#PR)`; GitHub adds the PR number when changes are squash-merged.

For non-trivial changes, add a body after a blank line describing the problem, root cause, resulting behavior, compatibility or file-format impact, and tests. Wrap near 72 characters. Use `Fixes #NNNN` only to close an issue; otherwise use `Refs #NNNN`. Preserve valid `Co-authored-by:` trailers.

```text
H5D: reject mismatched chunk rank on open

Validate the stored layout rank while decoding the message so malformed
datasets fail before I/O selection setup.

Fixes #6491
```

Before committing, run `git diff --check`, formatting, and focused CTest cases. Run the full suite before review. Do not commit builds, install trees, logs, or editor metadata.

## Pull Request Guidelines

Target `develop` and open an issue except for minor edits. Complete the PR template: describe behavior and compatibility impact, link the GitHub or JIRA ticket, report exact test results, and add tests. Update `release_docs/CHANGELOG.md` for user-visible changes and user-reported fixes.

## Supported Scope

Java and Fortran modules are unsupported. Do not restore their sources, options, examples, CI, install components, or targets. Preserve format-level C compatibility constants and required HDFS VFD JNI discovery.
