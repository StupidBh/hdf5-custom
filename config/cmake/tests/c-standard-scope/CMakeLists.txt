cmake_minimum_required (VERSION 4.0)
project (HDF5_LANGUAGE_STANDARD_SCOPE C CXX)

include (${CMAKE_CURRENT_LIST_DIR}/../../HDF5LanguageStandards.cmake)
hdf5_configure_c_language_standard ()
hdf5_configure_cxx_language_standard ()

function (hdf5_require_owned_standard target language expected_standard)
  get_target_property (actual_standard ${target} ${language}_STANDARD)
  get_target_property (actual_required ${target} ${language}_STANDARD_REQUIRED)
  get_target_property (actual_extensions ${target} ${language}_EXTENSIONS)
  if (NOT "${actual_standard}" STREQUAL "${expected_standard}" OR
      NOT actual_required OR actual_extensions)
    message (FATAL_ERROR
      "${target} has ${language}${actual_standard}, required=${actual_required}, "
      "extensions=${actual_extensions}; expected strict ${language}${expected_standard}"
    )
  endif ()
endfunction ()

add_library (hdf5_owned_before STATIC owned.c)
add_library (hdf5_cxx_owned_before STATIC owned.cpp)
hdf5_require_owned_standard (hdf5_owned_before C "${CMAKE_C_STANDARD}")
hdf5_require_owned_standard (hdf5_cxx_owned_before CXX "${CMAKE_CXX_STANDARD}")

hdf5_begin_dependency_language_standard_scope ()
add_subdirectory (dependency)
hdf5_end_dependency_language_standard_scope ()

add_library (hdf5_owned_after STATIC owned.c)
add_library (hdf5_cxx_owned_after STATIC owned.cpp)
hdf5_require_owned_standard (hdf5_owned_after C "${CMAKE_C_STANDARD}")
hdf5_require_owned_standard (hdf5_cxx_owned_after CXX "${CMAKE_CXX_STANDARD}")

function (hdf5_require_dependency_default target language)
  foreach (property_suffix IN ITEMS STANDARD STANDARD_REQUIRED EXTENSIONS)
    get_target_property (actual_property ${target} ${language}_${property_suffix})
    if (NOT actual_property MATCHES "-NOTFOUND$")
      message (FATAL_ERROR
        "${target} inherited ${language}_${property_suffix}=${actual_property} from HDF5"
      )
    endif ()
  endforeach ()
endfunction ()

function (hdf5_require_dependency_declared target language expected_standard)
  get_target_property (actual_standard ${target} ${language}_STANDARD)
  get_target_property (actual_required ${target} ${language}_STANDARD_REQUIRED)
  get_target_property (actual_extensions ${target} ${language}_EXTENSIONS)
  if (NOT "${actual_standard}" STREQUAL "${expected_standard}" OR
      NOT actual_required OR actual_extensions)
    message (FATAL_ERROR
      "Dependency declaration changed: ${language}${actual_standard}, "
      "required=${actual_required}, extensions=${actual_extensions}"
    )
  endif ()
endfunction ()

hdf5_require_dependency_default (dependency_default C)
hdf5_require_dependency_default (dependency_cxx_default CXX)
hdf5_require_dependency_declared (dependency_declared C 11)
hdf5_require_dependency_declared (dependency_cxx_declared CXX 11)
