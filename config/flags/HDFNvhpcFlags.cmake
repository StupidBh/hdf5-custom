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

###############################################################################
# This file included from HDFCompilerFlags.cmake with
#  if (CMAKE_C_COMPILER_ID MATCHES "NVHPC" )
###############################################################################

#-----------------------------------------------------------------------------
# Compiler specific flags
#-----------------------------------------------------------------------------
HDF5_ADD_COMPILER_OPTIONS (C SUFFIX -Minform=warn)
if (NOT ${HDF_CFG_NAME} MATCHES "Debug" AND NOT ${HDF_CFG_NAME} MATCHES "Developer")
  if (NOT ${HDF_CFG_NAME} MATCHES "RelWithDebInfo")
    HDF5_ADD_COMPILER_OPTIONS (C SUFFIX -s)
  endif ()
else ()
  HDF5_ADD_COMPILER_OPTIONS (C SUFFIX -Mbounds -gopt)
endif ()
