# Release Process

This document describes the release mechanics present in this repository. It
does not set an organizational release cadence or security-support lifetime.

## Release Scope

Release artifacts cover the retained C library, high-level C library, opt-in
C++ wrappers, tools, utilities, and examples. Java and Fortran products are
not part of this fork. Source release validation is limited to Windows/MSVC
and Linux/GNU; the release baselines are Windows x64 with Visual Studio 18
2026 and Linux x86_64 with GCC/G++ and Ninja, plus a focused Unix Makefiles
check.

The sources of truth are:

- `src/H5public.h` for the product version
- `config/lt_vers.am` for shared-library interface versions
- `CMakeBuildOptions.cmake` and the CMake files for products and options
- `CMakePresets.json` for release-oriented local workflows
- `.github/workflows/release.yml` and its reusable workflows for artifacts
- `release_docs/CHANGELOG.md` for user-visible release content

## 1. Prepare the Release

1. Confirm the release milestone and resolve, defer, or document every open
   item.
2. Reconcile user-visible changes and user-reported fixes with
   `CHANGELOG.md`. Remove known problems that are fixed or outside the current
   supported scope, and record remaining limitations precisely.
3. Review dependency revisions, public API changes, file-format impact, and
   compatibility impact. Update the API/ABI baseline when required.
4. Update only `H5_VERS_MAJOR`, `H5_VERS_MINOR`, `H5_VERS_RELEASE`, and
   `H5_VERS_SUBRELEASE` in `src/H5public.h`; the public version strings are
   derived from those macros.
5. Apply the interface-versioning rules documented in `config/lt_vers.am` to
   each retained library family.
6. Confirm that documentation describes the same products, options, platform
   matrix, and version as the source tree.

Use a dedicated release-preparation branch and keep release-only changes
reviewable. Branch and tag naming must match the repository automation being
used; do not infer a naming convention from historical prose.

## 2. Regenerate Maintained Sources

Generated source files are committed only when their inputs changed. Use the
repository's `HDF5_GENERATE_HEADERS` flow or `bin/process_source.sh` as
appropriate, inspect every generated diff, and ensure no build tree, backup,
or machine-specific file is staged.

Run `git diff --check` after regeneration. A clean source archive must be able
to configure without requiring regeneration tools.

## 3. Validate

At minimum, validate:

- static and shared libraries, tests, tools, high-level C, examples, and the
  opt-in C++ wrappers
- the Windows/MSVC and Linux/GNU release baselines
- Debug and Release where behavior differs
- install trees and CMake package consumption for static and shared variants
- standalone installed examples
- enabled release dependencies and optional configurations represented in the
  artifacts, including parallel or ROS3 variants when selected

For the manual Windows baseline:

```powershell
cmake -S . -B build-msvc18 -G "Visual Studio 18 2026" -A x64
$env:CL = "/utf-8"
cmake --build build-msvc18 --config Release --parallel 6
ctest --test-dir build-msvc18 -C Release --output-on-failure -j 6
```

Record `HDF_TEST_EXPRESS` with results. The normal default is `3`; release
presets currently set it to `2`. Test counts vary with options and must not be
used as a fixed acceptance criterion.

Inspect ABI/API compatibility reports against the intended prior release.
Interface changes require explicit review before artifacts are published.

## 4. Build Artifacts

The manually dispatched `.github/workflows/release.yml` workflow accepts a
`use_tag` input (default `snapshot`). It creates source archives, builds and
tests release packages, produces documentation and ABI reports, computes
SHA-256 checksums, and creates a draft GitHub release for a release run.

Before publishing the draft:

1. Verify that the workflow used the intended commit and version.
2. Compare archive contents with the source and installation manifests.
3. Build at least one source archive independently.
4. Install and smoke-test each binary package on its matching baseline.
5. Verify checksums, documentation, ABI reports, package metadata, runtime
   dependencies, and signatures when signing credentials were available.
6. Confirm that the draft body was extracted correctly from the Executive
   Summary in `CHANGELOG.md`.

Do not treat a green packaging workflow as a substitute for artifact
inspection.

## 5. Publish and Archive

Publish the reviewed GitHub draft through the repository hosting the release.
The separate `.github/workflows/publish-release.yml` workflow mirrors assets,
documentation, and compatibility reports to the HDF Group's S3 layout. It
requires `use_tag`, `file_name`, and `target_dir`, validates their formats, and
supports `dry_run`. That workflow is organization-specific: it downloads from
`HDFGroup/hdf5` and requires HDF Group repository variables and AWS secrets,
so a fork must adapt it before use.

The workflow's current `use_tag` description shows a plain semantic version,
but its validation expression requires a value beginning with `hdf5_` or
`hdf5-`. Resolve that mismatch against the tag produced by the release
workflow before a production publication; documentation must not guess which
side is intended.

After publication:

1. Verify the public download, documentation, checksums, and release notes.
2. Add the finalized changelog entry to `HISTORY-2.X.md` without copying the
   common changelog boilerplate.
3. Reset `CHANGELOG.md` to the next development version and update the base
   version macros on the continuing branch.
4. Record the exact validation and any deferred platform or feature checks.
