cmake_minimum_required (VERSION 4.0)

foreach (required_variable IN ITEMS
    HDF5_PLATFORM_TEST_MODULE
    HDF5_PLATFORM_TEST_SYSTEM
    HDF5_PLATFORM_TEST_COMPILER_ID
)
  if (NOT DEFINED ${required_variable})
    message (FATAL_ERROR "Missing required test variable: ${required_variable}")
  endif ()
endforeach ()

# BASIC_SETTINGS is exercised in script mode so rejected compiler IDs do not
# require unsupported compilers to be installed on either validation host.
macro (ENABLE_LANGUAGE language)
  set (CMAKE_${language}_COMPILER_LOADED TRUE)
  set (CMAKE_${language}_COMPILER_ID "${HDF5_PLATFORM_TEST_COMPILER_ID}")
endmacro ()

macro (SET_HDF_OUTPUT_DIRS package_prefix)
endmacro ()

macro (target_compile_options target)
  set (HDF5_PLATFORM_TEST_COMPILE_OPTIONS "${ARGN}")
endmacro ()

macro (target_link_options target)
  set (HDF5_PLATFORM_TEST_LINK_OPTIONS "${ARGN}")
endmacro ()

macro (target_compile_definitions target)
endmacro ()

set (CMAKE_SYSTEM_NAME "${HDF5_PLATFORM_TEST_SYSTEM}")
set (CMAKE_C_COMPILER_LOADED TRUE)
set (CMAKE_C_COMPILER_ID "${HDF5_PLATFORM_TEST_COMPILER_ID}")
set (H5EXAMPLE_BUILD_CXX ON)
set (H5EXAMPLE_DISABLE_COMPILER_WARNINGS ON)
if (HDF5_PLATFORM_TEST_SYSTEM STREQUAL "Windows")
  set (MSVC TRUE)
  set (CMAKE_C_FLAGS "/W3")
  set (CMAKE_CXX_FLAGS "/W3")
  set (expected_suppression "/w")
else ()
  set (expected_suppression "-w")
endif ()

include ("${HDF5_PLATFORM_TEST_MODULE}")
include ("${CMAKE_CURRENT_LIST_DIR}/../../../HDF5Examples/config/cmake/HDFExampleMacros.cmake")
BASIC_SETTINGS (EX)

foreach (language IN ITEMS C CXX)
  set (expected_option "$<$<COMPILE_LANGUAGE:${language}>:${expected_suppression}>")
  if (NOT expected_option IN_LIST HDF5_PLATFORM_TEST_COMPILE_OPTIONS)
    message (FATAL_ERROR
      "Missing ${language} COMPILE warning suppression: ${HDF5_PLATFORM_TEST_COMPILE_OPTIONS}"
    )
  endif ()
endforeach ()

if (MSVC AND (CMAKE_C_FLAGS MATCHES "(^| )/W[0-9]( |$)" OR
              CMAKE_CXX_FLAGS MATCHES "(^| )/W[0-9]( |$)"))
  message (FATAL_ERROR "MSVC warning levels were not removed before applying /w")
endif ()

if (MSVC)
  if (DEFINED HDF5_PLATFORM_TEST_LINK_OPTIONS)
    message (FATAL_ERROR "Compile-only MSVC warning suppression reached the linker")
  endif ()
else ()
  foreach (language IN ITEMS C CXX)
    set (expected_option "$<$<LINK_LANGUAGE:${language}>:${expected_suppression}>")
    if (NOT expected_option IN_LIST HDF5_PLATFORM_TEST_LINK_OPTIONS)
      message (FATAL_ERROR
        "Missing ${language} LINK warning suppression: ${HDF5_PLATFORM_TEST_LINK_OPTIONS}"
      )
    endif ()
  endforeach ()
endif ()
