include_guard (GLOBAL)

set (_HDF5_SUPPORTED_PLATFORM_MESSAGE
  "Supported HDF5 source-build configurations are Windows x64 with MSVC and the Visual Studio 18 2026 generator, or Linux x86_64 with GNU and the Ninja or Unix Makefiles generator."
)

function (_hdf5_reject_platform field value)
  message (FATAL_ERROR
    "Unsupported HDF5 source build: ${field} '${value}'. ${_HDF5_SUPPORTED_PLATFORM_MESSAGE}"
  )
endfunction ()

function (hdf5_validate_platform_support)
  cmake_parse_arguments (PARSE_ARGV 0 HDF5_PLATFORM "" "" "LANGUAGES")
  if (HDF5_PLATFORM_UNPARSED_ARGUMENTS OR NOT HDF5_PLATFORM_LANGUAGES)
    message (FATAL_ERROR "hdf5_validate_platform_support requires LANGUAGES followed by C and/or CXX")
  endif ()

  if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
    if (NOT CMAKE_GENERATOR STREQUAL "Visual Studio 18 2026")
      _hdf5_reject_platform ("generator" "${CMAKE_GENERATOR}")
    endif ()
    if (NOT CMAKE_GENERATOR_PLATFORM STREQUAL "x64")
      _hdf5_reject_platform ("target architecture" "${CMAKE_GENERATOR_PLATFORM}")
    endif ()
    set (expected_compiler_id "MSVC")
  elseif (CMAKE_SYSTEM_NAME STREQUAL "Linux")
    if (NOT CMAKE_GENERATOR STREQUAL "Ninja" AND NOT CMAKE_GENERATOR STREQUAL "Unix Makefiles")
      _hdf5_reject_platform ("generator" "${CMAKE_GENERATOR}")
    endif ()
    if (NOT CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
      _hdf5_reject_platform ("target architecture" "${CMAKE_SYSTEM_PROCESSOR}")
    endif ()
    set (expected_compiler_id "GNU")
  else ()
    _hdf5_reject_platform ("target system" "${CMAKE_SYSTEM_NAME}")
  endif ()

  foreach (language IN LISTS HDF5_PLATFORM_LANGUAGES)
    if (NOT language STREQUAL "C" AND NOT language STREQUAL "CXX")
      message (FATAL_ERROR "Unsupported language '${language}' passed to hdf5_validate_platform_support")
    endif ()
    if (NOT CMAKE_${language}_COMPILER_ID STREQUAL expected_compiler_id)
      _hdf5_reject_platform ("${language} compiler ID" "${CMAKE_${language}_COMPILER_ID}")
    endif ()
  endforeach ()
endfunction ()
