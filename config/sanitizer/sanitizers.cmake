#
# Copyright (C) 2018-2022 by George Cave - gcave@stablecoder.ca
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

set(HDF5_USE_SANITIZER
    ""
    CACHE STRING "Compile with a sanitizer. Supported value: Address (MSVC).")

function(hdf5_append_sanitizer_compile_options)
  set(compile_options ${HDF5_SANITIZER_COMPILE_OPTIONS})
  set(link_options ${HDF5_SANITIZER_LINK_OPTIONS})
  set(reported_c_flags_suffix "${HDF5_REPORTED_C_FLAGS_SUFFIX}")
  set(reported_cxx_flags_base "${HDF5_REPORTED_CXX_FLAGS_BASE}")

  foreach(option IN LISTS ARGN)
    list(APPEND compile_options "${option}")
    if(UNIX)
      # CMAKE_<LANG>_FLAGS were also passed to compiler-driver link steps.
      list(APPEND link_options "${option}")
    endif()
    string(APPEND reported_c_flags_suffix " ${option}")
    string(APPEND reported_cxx_flags_base " ${option}")
  endforeach()

  set(HDF5_SANITIZER_COMPILE_OPTIONS "${compile_options}")
  set(HDF5_SANITIZER_LINK_OPTIONS "${link_options}")
  set(HDF5_REPORTED_C_FLAGS_SUFFIX "${reported_c_flags_suffix}")
  set(HDF5_REPORTED_CXX_FLAGS_BASE "${reported_cxx_flags_base}")
  return(PROPAGATE HDF5_SANITIZER_COMPILE_OPTIONS HDF5_SANITIZER_LINK_OPTIONS
                   HDF5_REPORTED_C_FLAGS_SUFFIX HDF5_REPORTED_CXX_FLAGS_BASE)
endfunction()

message(STATUS "HDF5_USE_SANITIZER=${HDF5_USE_SANITIZER}, CMAKE_C_COMPILER_ID=${CMAKE_C_COMPILER_ID}")
if(HDF5_USE_SANITIZER)
  # C++ may not be enabled yet. Capture the value that the previous global
  # mutation reported before enable_language(CXX) initializes its flags.
  set(HDF5_CXX_FLAGS_BEFORE_INSTRUMENTATION "${CMAKE_CXX_FLAGS}")
  set(HDF5_REPORTED_CXX_FLAGS_BASE "${CMAKE_CXX_FLAGS}")

  if(CMAKE_C_COMPILER_ID STREQUAL "MSVC")
    if(HDF5_USE_SANITIZER MATCHES "([Aa]ddress)")
      message(STATUS "Building with Address sanitizer")
      hdf5_append_sanitizer_compile_options("/fsanitize=address")
    else()
      message(FATAL_ERROR "This sanitizer not yet supported in the MSVC environment: ${HDF5_USE_SANITIZER}")
    endif()
  else()
    message(FATAL_ERROR "HDF5_USE_SANITIZER is not supported on this platform.")
  endif()
endif()
