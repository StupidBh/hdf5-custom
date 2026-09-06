# Security Policy

## Scope

Security reports are accepted for the products retained in this repository:
the HDF5 C library, high-level C library, opt-in C++ wrappers, tools,
utilities, and retained examples. Java and Fortran bindings are not present or
supported here.

The supported source-build environments are Windows/MSVC and Linux/GNU.
`HDF5_ALLOW_UNSUPPORTED` relaxes only documented HDF5 feature-combination
checks; it does not bypass the target-system/compiler policy. Problems that
occur only on unsupported platforms, compilers, or feature combinations may
not be reproducible or actionable in this fork.

The source tree currently identifies itself as HDF5 2.3.0 development code.
This repository does not declare a security-support lifetime or backport
matrix for released branches. Consult the
[HDF Group support information](https://www.hdfgroup.org/solutions/hdf5) and
published advisories for supported upstream release lines.

## Reporting a Vulnerability

Do not disclose a suspected vulnerability in a public issue. Report upstream
HDF5 vulnerabilities through the
[HDF5 private security advisory form](https://github.com/HDFGroup/hdf5/security/advisories/new).
If that form is unavailable, contact `security@hdfgroup.org`.

Include the affected version or commit, build configuration, operating system,
compiler, reproduction steps, and a minimal proof of concept when possible.
For malformed-file issues, include the smallest reproducing file and explain
whether merely opening the file triggers the behavior.

The HDF Group's
[Vulnerability Management and Disclosure Policy](https://ssp.hdfgroup.org/policy/Vulnerability%20Management%20%26%20Disclosure%20(PSIRT)%20Policy)
describes its triage, coordinated disclosure, and safe-harbor process.

## Operational Guidance

HDF5 parses a complex binary format. Isolate applications that process
untrusted files and apply normal resource limits. The library is not
thread-safe by default; `HDF5_ENABLE_THREADSAFE` must be selected explicitly
and still has documented compatibility limits. Dynamically loaded filter, VFD,
and VOL plugins execute with the application's privileges, so load only
trusted plugin binaries. Signed-plugin support can add an authenticity check
when it is built and configured; see
[PLUGIN_SIGNATURE_README.md](docs/PLUGIN_SIGNATURE_README.md).

Verify release artifacts against the checksums published with the release.
General source-build instructions are in [docs/INSTALL.md](docs/INSTALL.md).
