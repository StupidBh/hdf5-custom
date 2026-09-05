#
# Copyright by The HDF Group.
# All rights reserved.
#
# This file is part of HDF5.  The full HDF5 copyright notice, including
# terms governing use, modification, and redistribution, is contained in
# the LICENSE file, which can be found at the root of the source code
# distribution tree, or in https://www.hdfgroup.org/licenses.
# If you do not have access to either file, you may request a copy from
# help@hdfgroup.org.
#

include_guard (GLOBAL)

macro (hdf5_configure_c_language_standard)
  if (NOT DEFINED CMAKE_C_STANDARD OR "${CMAKE_C_STANDARD}" STREQUAL "")
    set (CMAKE_C_STANDARD 17)
  elseif (CMAKE_C_STANDARD MATCHES "^(90|99|11)$")
    message (FATAL_ERROR
      "HDF5 examples require C17 or later, but CMAKE_C_STANDARD=${CMAKE_C_STANDARD} requests an older standard."
    )
  endif ()

  set (CMAKE_C_STANDARD_REQUIRED TRUE)
  set (CMAKE_C_EXTENSIONS OFF)
endmacro ()
