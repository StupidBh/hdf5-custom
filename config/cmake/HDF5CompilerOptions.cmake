#
# Copyright by The HDF Group.
# All rights reserved.
#
# This file is part of HDF5. The full HDF5 copyright notice, including
# terms governing use, modification, and redistribution, is contained in
# the LICENSE file, which can be found at the root of the source code
# distribution tree, or in https://www.hdfgroup.org/licenses.
#

include_guard (GLOBAL)

# Internal targets used to migrate directory-wide build settings to scoped
# usage requirements. They intentionally remain outside the install exports.
add_library (hdf5_build_options INTERFACE)
add_library (hdf5_warnings INTERFACE)
add_library (hdf5_platform INTERFACE)
add_library (hdf5_dependencies INTERFACE)
add_library (hdf5_sanitizers INTERFACE)
