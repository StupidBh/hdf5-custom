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
add_library (hdf5_assertions INTERFACE IMPORTED GLOBAL)
add_library (hdf5_platform INTERFACE IMPORTED GLOBAL)
add_library (hdf5_dependencies INTERFACE IMPORTED GLOBAL)
add_library (hdf5_sanitizers INTERFACE IMPORTED GLOBAL)

set_property (TARGET hdf5_platform PROPERTY HDF5_COMPILER_COMPILE_OPTIONS
    ${HDF5_C_COMPILER_COMPILE_OPTIONS}
)
set_property (TARGET hdf5_platform PROPERTY HDF5_COMPILER_LINK_OPTIONS
    ${HDF5_C_COMPILER_LINK_OPTIONS}
)
set_property (TARGET hdf5_platform PROPERTY HDF5_COMPILER_EXECUTABLE_LINK_OPTIONS
    ${HDF5_C_COMPILER_EXECUTABLE_LINK_OPTIONS}
)
target_compile_options (hdf5_warnings INTERFACE "${HDF5_CMAKE_C_WARNING_FLAGS}")
target_compile_options (hdf5_build_options INTERFACE "${HDF5_CMAKE_C_BUILD_OPTION_FLAGS}")
target_compile_options (hdf5_assertions INTERFACE "${HDF5_ASSERT_COMPILE_OPTION}")
target_compile_options (hdf5_sanitizers INTERFACE ${HDF5_SANITIZER_COMPILE_OPTIONS})
target_link_options (hdf5_sanitizers INTERFACE ${HDF5_SANITIZER_LINK_OPTIONS})
target_link_libraries (hdf5_sanitizers INTERFACE ${HDF5_SANITIZER_LINK_LIBRARIES})
if (HDF5_PLATFORM_COMPILE_OPTIONS)
  target_compile_options (hdf5_platform INTERFACE ${HDF5_PLATFORM_COMPILE_OPTIONS})
endif ()
if (HDF5_PLATFORM_COMPILE_DEFINITIONS)
  list (REMOVE_DUPLICATES HDF5_PLATFORM_COMPILE_DEFINITIONS)
  target_compile_definitions (hdf5_platform INTERFACE ${HDF5_PLATFORM_COMPILE_DEFINITIONS})
endif ()
if (HDF5_PLATFORM_EXECUTABLE_LINK_OPTIONS)
  target_link_options (hdf5_platform INTERFACE ${HDF5_PLATFORM_EXECUTABLE_LINK_OPTIONS})
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
  if (HDF5_PLATFORM_CXX_COMPILE_OPTIONS)
    target_compile_options (hdf5_platform INTERFACE ${HDF5_PLATFORM_CXX_COMPILE_OPTIONS})
  endif ()
  set_property (TARGET hdf5_platform APPEND PROPERTY HDF5_COMPILER_COMPILE_OPTIONS
      ${HDF5_CXX_COMPILER_COMPILE_OPTIONS}
  )
  set_property (TARGET hdf5_platform APPEND PROPERTY HDF5_COMPILER_LINK_OPTIONS
      ${HDF5_CXX_COMPILER_LINK_OPTIONS}
  )
  set_property (TARGET hdf5_platform APPEND PROPERTY HDF5_COMPILER_EXECUTABLE_LINK_OPTIONS
      ${HDF5_CXX_COMPILER_EXECUTABLE_LINK_OPTIONS}
  )
endfunction ()

function (hdf5_target_use_instrumentation target)
  get_target_property (instrumentation_applied ${target} HDF5_INSTRUMENTATION_APPLIED)
  if (instrumentation_applied)
    return ()
  endif ()

  get_target_property (compile_options hdf5_sanitizers INTERFACE_COMPILE_OPTIONS)
  get_target_property (link_options hdf5_sanitizers INTERFACE_LINK_OPTIONS)
  get_target_property (link_libraries hdf5_sanitizers INTERFACE_LINK_LIBRARIES)
  foreach (requirement IN ITEMS compile_options link_options link_libraries)
    if ("${${requirement}}" MATCHES "-NOTFOUND$")
      set (${requirement})
    endif ()
  endforeach ()
  if (compile_options OR link_options OR link_libraries)
    target_compile_options (${target} PRIVATE ${compile_options})
    get_target_property (target_type ${target} TYPE)
    if (target_type MATCHES "^(EXECUTABLE|SHARED_LIBRARY|MODULE_LIBRARY)$")
      target_link_options (${target} PRIVATE ${link_options})
    endif ()
    target_link_libraries (${target} PRIVATE ${link_libraries})
    set_property (TARGET ${target} PROPERTY HDF5_INSTRUMENTATION_APPLIED TRUE)
  endif ()
endfunction ()

function (hdf5_target_use_compiler_options target)
  get_target_property (compiler_options_applied ${target} HDF5_COMPILER_OPTIONS_APPLIED)
  if (compiler_options_applied)
    return ()
  endif ()

  target_compile_options (${target} PRIVATE
      "$<GENEX_EVAL:$<TARGET_PROPERTY:hdf5_platform,HDF5_COMPILER_COMPILE_OPTIONS>>"
  )
  get_target_property (target_type ${target} TYPE)
  if (target_type MATCHES "^(EXECUTABLE|SHARED_LIBRARY|MODULE_LIBRARY)$")
    target_link_options (${target} PRIVATE
        "$<GENEX_EVAL:$<TARGET_PROPERTY:hdf5_platform,HDF5_COMPILER_LINK_OPTIONS>>"
    )
  endif ()
  if (target_type STREQUAL "EXECUTABLE")
    target_link_options (${target} PRIVATE
        "$<GENEX_EVAL:$<TARGET_PROPERTY:hdf5_platform,HDF5_COMPILER_EXECUTABLE_LINK_OPTIONS>>"
    )
  endif ()
  set_property (TARGET ${target} PROPERTY HDF5_COMPILER_OPTIONS_APPLIED TRUE)
endfunction ()

function (hdf5_target_use_platform target)
  hdf5_target_use_instrumentation (${target})
  hdf5_target_use_compiler_options (${target})
  get_target_property (target_type ${target} TYPE)
  if (target_type STREQUAL "EXECUTABLE")
    get_target_property (link_flags_applied ${target} HDF5_PLATFORM_LINK_FLAGS_APPLIED)
    if (NOT link_flags_applied)
      get_target_property (executable_link_flags hdf5_platform HDF5_PLATFORM_EXECUTABLE_LINK_FLAGS)
      if (executable_link_flags AND NOT executable_link_flags MATCHES "-NOTFOUND$")
        set_property (TARGET ${target} APPEND_STRING PROPERTY LINK_FLAGS " ${executable_link_flags}")
      endif ()
      set_property (TARGET ${target} PROPERTY HDF5_PLATFORM_LINK_FLAGS_APPLIED TRUE)
    endif ()
    target_link_options (${target} PRIVATE
        "$<GENEX_EVAL:$<TARGET_PROPERTY:hdf5_platform,INTERFACE_LINK_OPTIONS>>"
    )
  endif ()
  target_compile_options (${target} PRIVATE
      "$<TARGET_PROPERTY:hdf5_platform,INTERFACE_COMPILE_OPTIONS>"
      "$<TARGET_PROPERTY:hdf5_assertions,INTERFACE_COMPILE_OPTIONS>"
  )
  target_compile_definitions (${target} PRIVATE
      "$<TARGET_PROPERTY:hdf5_platform,INTERFACE_COMPILE_DEFINITIONS>"
  )
endfunction ()

function (hdf5_target_use_build_options target)
  hdf5_target_use_instrumentation (${target})
  hdf5_target_use_compiler_options (${target})
  target_compile_options (${target} PRIVATE
      "$<TARGET_PROPERTY:hdf5_warnings,INTERFACE_COMPILE_OPTIONS>"
      "$<TARGET_PROPERTY:hdf5_build_options,INTERFACE_COMPILE_OPTIONS>"
  )
  hdf5_target_use_platform (${target})
endfunction ()
