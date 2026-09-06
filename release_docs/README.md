# Release Documentation

This directory contains release-facing records and maintainer guidance. User
installation and build instructions belong in [`docs/`](../docs/).

- `CHANGELOG.md` records changes, tested platforms, and known problems for the
  current in-development release.
- `HISTORY-2.X.md` archives finalized 2.x release notes. Historical references
  to products and platforms later removed from this fork remain part of the
  record and are not current support claims.
- `RELEASE_PROCESS.md` describes the repository's current CMake and GitHub
  Actions release workflow.
- `MAINTAINERS.md` describes dependency-update responsibilities.

When a release is finalized, archive its completed `CHANGELOG.md` section at
the beginning of `HISTORY-2.X.md`, then reset `CHANGELOG.md` for the next
development version. Do not duplicate the common changelog introduction or
table of contents in each historical release entry.

The version macros in `src/H5public.h`, the shared-library interface numbers
in `config/lt_vers.am`, and the current CMake/workflow files are authoritative
for release engineering. A written release note is not evidence that a build,
test, packaging, signing, ABI, or publication step completed.
