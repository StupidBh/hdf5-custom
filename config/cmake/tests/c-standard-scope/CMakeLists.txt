cmake_minimum_required (VERSION 4.0)
project (HDF5_C_STANDARD_SCOPE C)

include (${CMAKE_CURRENT_LIST_DIR}/../../HDF5LanguageStandards.cmake)
hdf5_configure_c_language_standard ()

set (hdf5_expected_standard "${CMAKE_C_STANDARD}")

function (hdf5_require_owned_standard target)
  get_target_property (actual_standard ${target} C_STANDARD)
  get_target_property (actual_required ${target} C_STANDARD_REQUIRED)
  get_target_property (actual_extensions ${target} C_EXTENSIONS)
  if (NOT actual_standard STREQUAL hdf5_expected_standard OR
      NOT actual_required OR actual_extensions)
    message (FATAL_ERROR
      "${target} has C${actual_standard}, required=${actual_required}, extensions=${actual_extensions}; "
      "expected strict C${hdf5_expected_standard}"
    )
  endif ()
endfunction ()

add_library (hdf5_owned_before STATIC owned.c)
hdf5_require_owned_standard (hdf5_owned_before)

hdf5_begin_dependency_c_standard_scope ()
add_subdirectory (dependency)
hdf5_end_dependency_c_standard_scope ()

add_library (hdf5_owned_after STATIC owned.c)
hdf5_require_owned_standard (hdf5_owned_after)

get_target_property (dependency_default_standard dependency_default C_STANDARD)
get_target_property (dependency_default_required dependency_default C_STANDARD_REQUIRED)
get_target_property (dependency_default_extensions dependency_default C_EXTENSIONS)
foreach (dependency_default_property IN ITEMS
    dependency_default_standard
    dependency_default_required
    dependency_default_extensions
)
  if (${dependency_default_property})
    message (FATAL_ERROR
      "Undeclared dependency property inherited HDF5's C standard: "
      "${dependency_default_property}=${${dependency_default_property}}"
    )
  endif ()
endforeach ()

get_target_property (dependency_declared_standard dependency_declared C_STANDARD)
get_target_property (dependency_declared_required dependency_declared C_STANDARD_REQUIRED)
get_target_property (dependency_declared_extensions dependency_declared C_EXTENSIONS)
if (NOT dependency_declared_standard STREQUAL "11" OR
    NOT dependency_declared_required OR dependency_declared_extensions)
  message (FATAL_ERROR
    "Dependency declaration changed: C${dependency_declared_standard}, "
    "required=${dependency_declared_required}, extensions=${dependency_declared_extensions}"
  )
endif ()
