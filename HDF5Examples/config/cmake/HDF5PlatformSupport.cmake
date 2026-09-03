include_guard (GLOBAL)

set (hdf5_platform_support_module
  "${CMAKE_CURRENT_LIST_DIR}/../../../config/cmake/HDF5PlatformSupport.cmake"
)
if (NOT EXISTS "${hdf5_platform_support_module}")
  set (hdf5_platform_support_module
    "${CMAKE_CURRENT_LIST_DIR}/HDF5PlatformSupportImpl.cmake"
  )
endif ()
if (NOT EXISTS "${hdf5_platform_support_module}")
  message (FATAL_ERROR "The HDF5 platform-support policy module is missing")
endif ()

include ("${hdf5_platform_support_module}")
unset (hdf5_platform_support_module)
