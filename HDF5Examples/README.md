# HDF5 Examples

This directory contains retained C, filter, parallel, and Python example
programs. Availability depends on the components enabled in the
HDF5 installation. The Python files are example code, not a maintained Python
binding.

The directory is also a standalone CMake 4 project for verifying an installed
package. From this directory, use the matching release preset:

```bash
cmake --workflow --preset ci-StdShar-GNUC --fresh
```

Use `ci-StdShar-MSVC` on Windows. For manual configuration, supported options,
installation discovery, and runtime library setup, see
[Building and Testing the HDF5 Examples](../docs/USING_CMake_Examples.md).

Installed packages include the `h5cc` compiler wrapper. The `test-pc.sh`
script exercises the installed pkg-config metadata where that interface is
available.
