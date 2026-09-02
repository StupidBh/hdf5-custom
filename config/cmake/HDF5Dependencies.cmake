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

function (hdf5_configure_dependencies private_libraries public_libraries)
  set_property (TARGET hdf5_dependencies PROPERTY HDF5_PRIVATE_LINK_LIBRARIES
      "${private_libraries}"
  )
  set_property (TARGET hdf5_dependencies PROPERTY HDF5_PUBLIC_LINK_LIBRARIES
      "${public_libraries}"
  )
endfunction ()

function (hdf5_target_link_dependencies target)
  get_property (private_libraries TARGET hdf5_dependencies
      PROPERTY HDF5_PRIVATE_LINK_LIBRARIES
  )
  get_property (public_libraries TARGET hdf5_dependencies
      PROPERTY HDF5_PUBLIC_LINK_LIBRARIES
  )

  if (private_libraries)
    target_link_libraries (${target} PRIVATE ${private_libraries})
  endif ()
  if (public_libraries)
    target_link_libraries (${target} PUBLIC ${public_libraries})
  endif ()
endfunction ()
