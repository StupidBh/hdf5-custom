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
      "HDF5 requires C17 or later, but CMAKE_C_STANDARD=${CMAKE_C_STANDARD} requests an older standard."
    )
  endif ()

  set (CMAKE_C_STANDARD_REQUIRED TRUE)
  set (CMAKE_C_EXTENSIONS OFF)
endmacro ()

# Directory-level language settings initialize every target created below the
# current directory. Mask them while configuring third-party source trees so
# each dependency retains its own declared language mode.
macro (hdf5_begin_dependency_c_standard_scope)
  if (_HDF5_DEPENDENCY_C_STANDARD_SCOPE_ACTIVE)
    message (FATAL_ERROR "Nested HDF5 dependency C standard scopes are not supported")
  endif ()

  set (_HDF5_DEPENDENCY_C_STANDARD_SCOPE_ACTIVE TRUE)
  foreach (_hdf5_c_standard_variable IN ITEMS
      CMAKE_C_STANDARD
      CMAKE_C_STANDARD_REQUIRED
      CMAKE_C_EXTENSIONS
  )
    if (DEFINED ${_hdf5_c_standard_variable})
      set (_HDF5_SAVED_${_hdf5_c_standard_variable}_VISIBLE TRUE)
      set (_HDF5_SAVED_${_hdf5_c_standard_variable}_VALUE "${${_hdf5_c_standard_variable}}")
    else ()
      set (_HDF5_SAVED_${_hdf5_c_standard_variable}_VISIBLE FALSE)
    endif ()

    if (DEFINED CACHE{${_hdf5_c_standard_variable}})
      set (_HDF5_SAVED_${_hdf5_c_standard_variable}_CACHED TRUE)
      get_property (_HDF5_SAVED_${_hdf5_c_standard_variable}_CACHE_VALUE
        CACHE ${_hdf5_c_standard_variable} PROPERTY VALUE
      )
      get_property (_HDF5_SAVED_${_hdf5_c_standard_variable}_CACHE_TYPE
        CACHE ${_hdf5_c_standard_variable} PROPERTY TYPE
      )
      get_property (_HDF5_SAVED_${_hdf5_c_standard_variable}_CACHE_HELP
        CACHE ${_hdf5_c_standard_variable} PROPERTY HELPSTRING
      )
      get_property (_HDF5_SAVED_${_hdf5_c_standard_variable}_CACHE_ADVANCED
        CACHE ${_hdf5_c_standard_variable} PROPERTY ADVANCED
      )
      unset (${_hdf5_c_standard_variable} CACHE)
    else ()
      set (_HDF5_SAVED_${_hdf5_c_standard_variable}_CACHED FALSE)
    endif ()
    unset (${_hdf5_c_standard_variable})
  endforeach ()
  unset (_hdf5_c_standard_variable)
endmacro ()

macro (hdf5_end_dependency_c_standard_scope)
  if (NOT _HDF5_DEPENDENCY_C_STANDARD_SCOPE_ACTIVE)
    message (FATAL_ERROR "No HDF5 dependency C standard scope is active")
  endif ()

  foreach (_hdf5_c_standard_variable IN ITEMS
      CMAKE_C_STANDARD
      CMAKE_C_STANDARD_REQUIRED
      CMAKE_C_EXTENSIONS
  )
    if (_HDF5_SAVED_${_hdf5_c_standard_variable}_CACHED)
      set (${_hdf5_c_standard_variable}
        "${_HDF5_SAVED_${_hdf5_c_standard_variable}_CACHE_VALUE}"
        CACHE "${_HDF5_SAVED_${_hdf5_c_standard_variable}_CACHE_TYPE}"
        "${_HDF5_SAVED_${_hdf5_c_standard_variable}_CACHE_HELP}" FORCE
      )
      if (_HDF5_SAVED_${_hdf5_c_standard_variable}_CACHE_ADVANCED)
        mark_as_advanced (FORCE ${_hdf5_c_standard_variable})
      endif ()
    endif ()

    if (_HDF5_SAVED_${_hdf5_c_standard_variable}_VISIBLE)
      set (${_hdf5_c_standard_variable}
        "${_HDF5_SAVED_${_hdf5_c_standard_variable}_VALUE}"
      )
    else ()
      unset (${_hdf5_c_standard_variable})
    endif ()

    unset (_HDF5_SAVED_${_hdf5_c_standard_variable}_VISIBLE)
    unset (_HDF5_SAVED_${_hdf5_c_standard_variable}_VALUE)
    unset (_HDF5_SAVED_${_hdf5_c_standard_variable}_CACHED)
    unset (_HDF5_SAVED_${_hdf5_c_standard_variable}_CACHE_VALUE)
    unset (_HDF5_SAVED_${_hdf5_c_standard_variable}_CACHE_TYPE)
    unset (_HDF5_SAVED_${_hdf5_c_standard_variable}_CACHE_HELP)
    unset (_HDF5_SAVED_${_hdf5_c_standard_variable}_CACHE_ADVANCED)
  endforeach ()
  unset (_hdf5_c_standard_variable)
  unset (_HDF5_DEPENDENCY_C_STANDARD_SCOPE_ACTIVE)
endmacro ()
