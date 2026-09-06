# HDF5 API Tests

This directory contains several test applications that exercise HDF5's
public API and serve as regression tests for HDF5 [VOL Connectors](https://support.hdfgroup.org/documentation/hdf5/latest/_h5_v_l__u_g.html).

## Build Process and options

These HDF5 API tests are enabled by default, but can be disabled by passing the
`-DHDF5_TEST_API=OFF` option to CMake. The following build options are available
to influence how the API tests get built:

### CMake

To set an option, it should be prepended with `-D` when passed to the `cmake` command.
For example,

    cmake -DHDF5_TEST_API=OFF ..

`HDF5_TEST_API` (Default: `ON`) - Determines whether the API tests will be built.

`HDF5_TEST_API_INSTALL` (Default: `OFF`) - Determines whether the API tests should be installed
on the system.

`HDF5_TEST_API_ENABLE_ASYNC` (Default: `OFF`) - Determines whether tests for HDF5's asynchronous
I/O capabilities should be enabled. Note that the "native" HDF5 VOL connector doesn't support
this functionality, so these tests are directed towards VOL connectors that do.

`HDF5_TEST_API_ENABLE_DRIVER` (Default: `OFF`) - Determines whether the API test driver program should
be built. This driver program is useful when a VOL connector relies upon a server executable
(as well as possible additional executables) in order to function. The driver program can be
supplied with a server executable and server/client arguments to use when running the API
tests.

`HDF5_TEST_API_SERVER` (Default: empty string) - If `HDF5_TEST_API_ENABLE_DRIVER` is set to `ON`, this
option should be edited to point to the server executable that the driver program should attempt
to launch before running the API tests.

### Usage

These API tests currently only support usage with the native HDF5 VOL connector and HDF5 VOL
connectors that can be loaded dynamically as a plugin. For information on how to build a VOL
connector in this manner, refer to section 2.3 of the [HDF5 VOL Connector Author Guide](https://support.hdfgroup.org/documentation/hdf5/latest/_v_o_l__connector.html).

If an HDF5 VOL connector has been built alongside the library, these API tests can be used
for testing that VOL connector at the same time that HDF5 is test. For more information on
how to build a VOL connector alongside the HDF5 library, refer to
[Building and testing HDF5 VOL connectors with CMake FetchContent](https://support.hdfgroup.org/documentation/hdf5/latest/_c_make_vols.html).

These API tests can also be used to test an HDF5 VOL connector that is external to the library.
For convenience, the `HDF5_TEST_API_INSTALL` option can be used to install these tests on the
system where other HDF5 executables (such as `h5dump`) are installed. To run these tests manually
with your VOL connector, set the following two environment variables:

`HDF5_VOL_CONNECTOR` - This environment variable should be set to the name chosen for the VOL connector
to be used. For example, HDF5's DAOS VOL connector uses the name "[daos](https://github.com/HDFGroup/vol-daos/blob/v1.2.0/src/daos_vol.h#L30)"
and would therefore set:

    HDF5_VOL_CONNECTOR=daos

`HDF5_PLUGIN_PATH` - This environment variable should be set to the directory that contains the built
library for the VOL connector to be used.

Once these are set, the HDF5 API tests will attempt to load and use the specified VOL connector. If the
connector cannot be located or loaded, the test fails instead of silently running against the native
connector. The HDF5 diagnostic identifies the connector initialization failure.

### Help and Support

For help with building or using the HDF5 API tests, please contact the [HDF Help Desk](https://help.hdfgroup.org/).
