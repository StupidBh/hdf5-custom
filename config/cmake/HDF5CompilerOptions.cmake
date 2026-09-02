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
# IMPORTED prevents CMAKE_INCLUDE_CURRENT_DIR_IN_INTERFACE from leaking the
# repository root through these configuration-only targets.
add_library (hdf5_build_options INTERFACE IMPORTED GLOBAL)
add_library (hdf5_warnings INTERFACE IMPORTED GLOBAL)
add_library (hdf5_platform INTERFACE IMPORTED GLOBAL)
add_library (hdf5_dependencies INTERFACE IMPORTED GLOBAL)
add_library (hdf5_sanitizers INTERFACE IMPORTED GLOBAL)

target_compile_options (hdf5_warnings INTERFACE "${HDF5_CMAKE_C_WARNING_FLAGS}")
target_compile_options (hdf5_build_options INTERFACE "${HDF5_CMAKE_C_BUILD_OPTION_FLAGS}")
if (HDF5_PLATFORM_COMPILE_DEFINITIONS)
  list (REMOVE_DUPLICATES HDF5_PLATFORM_COMPILE_DEFINITIONS)
  target_compile_definitions (hdf5_platform INTERFACE ${HDF5_PLATFORM_COMPILE_DEFINITIONS})
endif ()
if (WIN32)
  target_compile_definitions (hdf5_platform INTERFACE _CRT_SECURE_NO_WARNINGS)
  if (MSVC)
    target_compile_definitions (hdf5_platform INTERFACE _BIND_TO_CURRENT_VCLIBS_VERSION=1 _CONSOLE)
  endif ()
endif ()

function (hdf5_configure_cxx_build_options)
  set_property (TARGET hdf5_warnings PROPERTY INTERFACE_COMPILE_OPTIONS
      "$<$<COMPILE_LANGUAGE:C>:${HDF5_CMAKE_C_WARNING_FLAGS}>"
      "$<$<COMPILE_LANGUAGE:CXX>:${HDF5_CMAKE_CXX_WARNING_FLAGS}>"
  )
  set_property (TARGET hdf5_build_options PROPERTY INTERFACE_COMPILE_OPTIONS
      "$<$<COMPILE_LANGUAGE:C>:${HDF5_CMAKE_C_BUILD_OPTION_FLAGS}>"
      "$<$<COMPILE_LANGUAGE:CXX>:${HDF5_CMAKE_CXX_BUILD_OPTION_FLAGS}>"
  )
endfunction ()

function (hdf5_target_use_platform target)
  target_compile_definitions (${target} PRIVATE
      "$<TARGET_PROPERTY:hdf5_platform,INTERFACE_COMPILE_DEFINITIONS>"
  )
endfunction ()

function (hdf5_target_use_build_options target)
  target_compile_options (${target} PRIVATE
      "$<TARGET_PROPERTY:hdf5_warnings,INTERFACE_COMPILE_OPTIONS>"
      "$<TARGET_PROPERTY:hdf5_build_options,INTERFACE_COMPILE_OPTIONS>"
  )
  hdf5_target_use_platform (${target})
endfunction ()
