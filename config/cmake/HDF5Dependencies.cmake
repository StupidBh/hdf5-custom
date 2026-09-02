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

function (hdf5_configure_dependencies system_libraries compression_libraries public_libraries)
  set_property (TARGET hdf5_dependencies PROPERTY HDF5_SYSTEM_LINK_LIBRARIES
      "${system_libraries}"
  )
  set_property (TARGET hdf5_dependencies PROPERTY HDF5_COMPRESSION_LINK_LIBRARIES
      "${compression_libraries}"
  )
  set_property (TARGET hdf5_dependencies PROPERTY HDF5_PUBLIC_LINK_LIBRARIES
      "${public_libraries}"
  )
endfunction ()

function (hdf5_target_link_dependencies target)
  get_property (system_libraries TARGET hdf5_dependencies
      PROPERTY HDF5_SYSTEM_LINK_LIBRARIES
  )
  get_property (compression_libraries TARGET hdf5_dependencies
      PROPERTY HDF5_COMPRESSION_LINK_LIBRARIES
  )
  get_property (public_libraries TARGET hdf5_dependencies
      PROPERTY HDF5_PUBLIC_LINK_LIBRARIES
  )

  if (system_libraries OR compression_libraries)
    target_link_libraries (${target} PRIVATE ${system_libraries} ${compression_libraries})
  endif ()
  if (public_libraries)
    target_link_libraries (${target} PUBLIC ${public_libraries})
  endif ()
endfunction ()

function (hdf5_target_link_system_dependencies target visibility)
  if (NOT visibility MATCHES "^(PRIVATE|PUBLIC|INTERFACE)$")
    message (FATAL_ERROR "Invalid dependency visibility for ${target}: ${visibility}")
  endif ()

  get_property (system_libraries TARGET hdf5_dependencies
      PROPERTY HDF5_SYSTEM_LINK_LIBRARIES
  )
  if (system_libraries)
    target_link_libraries (${target} ${visibility} ${system_libraries})
  endif ()
endfunction ()

function (hdf5_target_link_compression_dependencies target visibility)
  if (NOT visibility MATCHES "^(PRIVATE|PUBLIC|INTERFACE)$")
    message (FATAL_ERROR "Invalid dependency visibility for ${target}: ${visibility}")
  endif ()

  get_property (compression_libraries TARGET hdf5_dependencies
      PROPERTY HDF5_COMPRESSION_LINK_LIBRARIES
  )
  if (compression_libraries)
    target_link_libraries (${target} ${visibility} ${compression_libraries})
  endif ()
endfunction ()

#-----------------------------------------------------------------------------
# Option to Enable HDFS
#-----------------------------------------------------------------------------
if (HDF5_ENABLE_HDFS)
  find_package (JNI REQUIRED)
  if (JNI_FOUND)
    set (H5_HAVE_LIBJVM 1)
  endif ()
  find_package (HDFS REQUIRED)
  if (HDFS_FOUND)
    set (H5_HAVE_LIBHDFS 1)
    set (H5_HAVE_HDFS_H 1)
    if (NOT MSVC)
      list (APPEND LINK_LIBS -pthread)
    endif ()
  else ()
    set (HDF5_ENABLE_HDFS OFF CACHE BOOL "Enable HDFS" FORCE)
    message (FATAL_ERROR "Set to use libhdfs library, but could not find or use libhdfs. Please verify that the path to HADOOP_HOME is valid, and/or reconfigure without HDF5_ENABLE_HDFS")
  endif ()
endif ()
