# Repository Guidelines

## Project Structure & Module Organization

Core C code is in `src/`; the high-level API is in `hl/`, C++ wrappers in `c++/`, and command-line programs in `tools/`. Tests live in `test/` and `testpar/`, examples in `HDF5Examples/`, CMake support in `config/`, and documentation in `docs/` and `release_docs/`.

## Build, Test, and Development Commands

Use an out-of-source MSVC 18 build:

```powershell
cmake -S . -B build-msvc18 -G "Visual Studio 18 2026" -A x64
$env:CL = "/utf-8"
cmake --build build-msvc18 --config Release
ctest --test-dir build-msvc18 -C Release --output-on-failure -j 4
```

`/utf-8` prevents Unicode test failures on non-UTF-8 Windows locales. Use `-DHDF5_ENABLE_DEVELOPER_MODE=ON` for stricter warnings. Never commit generated build or install trees.

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
