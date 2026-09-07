cmake_minimum_required (VERSION 4.0)

foreach (required_variable IN ITEMS
    HDF5_CXX_STANDARD_TEST_BINARY_ROOT
    HDF5_CXX_STANDARD_TEST_GENERATOR
)
  if (NOT DEFINED ${required_variable} OR "${${required_variable}}" STREQUAL "")
    message (FATAL_ERROR "Missing required test variable: ${required_variable}")
  endif ()
endforeach ()

cmake_path (GET CMAKE_CURRENT_LIST_DIR PARENT_PATH cmake_dir)
cmake_path (GET cmake_dir PARENT_PATH config_dir)
cmake_path (GET config_dir PARENT_PATH source_dir)
cmake_path (ABSOLUTE_PATH source_dir NORMALIZE OUTPUT_VARIABLE source_dir)
cmake_path (ABSOLUTE_PATH HDF5_CXX_STANDARD_TEST_BINARY_ROOT NORMALIZE
  OUTPUT_VARIABLE binary_root
)
cmake_path (IS_PREFIX source_dir "${binary_root}" NORMALIZE binary_in_source)
if (binary_in_source)
  message (FATAL_ERROR "The C++ standard test root must be outside the source tree")
endif ()

if (NOT DEFINED HDF5_CXX_STANDARD_TEST_EXPECTED_GROUPS)
  set (HDF5_CXX_STANDARD_TEST_EXPECTED_GROUPS 2)
endif ()
if (WIN32)
  set (cxx20_flag_regex "[-/]std:c\\+\\+20")
  set (cxx23_flag_regex "[-/]std:c\\+\\+(23|latest)")
else ()
  set (cxx20_flag_regex "-std=c\\+\\+20")
  set (cxx23_flag_regex "-std=c\\+\\+23")
endif ()

file (MAKE_DIRECTORY "${binary_root}/contracts")

function (_hdf5_cxx_standard_prepare_case case_name output_variable)
  set (case_dir "${binary_root}/${case_name}")
  file (REMOVE_RECURSE "${case_dir}")
  set (query_dir "${case_dir}/.cmake/api/v1/query/client-hdf5-cxx-standard")
  file (MAKE_DIRECTORY "${query_dir}")
  file (WRITE "${query_dir}/codemodel-v2" "")
  set (${output_variable} "${case_dir}" PARENT_SCOPE)
endfunction ()

function (_hdf5_cxx_standard_configure source build standard option_name expect_success expected_message)
  set (configure_command
    "${CMAKE_COMMAND}" -S "${source}" -B "${build}"
    -G "${HDF5_CXX_STANDARD_TEST_GENERATOR}"
  )
  if (DEFINED HDF5_CXX_STANDARD_TEST_GENERATOR_PLATFORM AND
      NOT HDF5_CXX_STANDARD_TEST_GENERATOR_PLATFORM STREQUAL "")
    list (APPEND configure_command -A "${HDF5_CXX_STANDARD_TEST_GENERATOR_PLATFORM}")
  endif ()
  if (DEFINED HDF5_CXX_STANDARD_TEST_GENERATOR_TOOLSET AND
      NOT HDF5_CXX_STANDARD_TEST_GENERATOR_TOOLSET STREQUAL "")
    list (APPEND configure_command -T "${HDF5_CXX_STANDARD_TEST_GENERATOR_TOOLSET}")
  endif ()
  list (APPEND configure_command -DCMAKE_BUILD_TYPE=Release -DHDF_TEST_EXPRESS=3)
  if (NOT option_name STREQUAL "NONE")
    list (APPEND configure_command "-D${option_name}=ON")
  endif ()
  if (option_name STREQUAL "HDF5_TEST_API_ENABLE_DRIVER")
    list (APPEND configure_command "-DHDF5_TEST_API_SERVER=${CMAKE_COMMAND}")
  endif ()
  if (NOT standard STREQUAL "DEFAULT")
    list (APPEND configure_command "-DCMAKE_CXX_STANDARD=${standard}")
  endif ()
  if (DEFINED HDF5_CXX_STANDARD_TEST_CONFIGURE_ARGS)
    list (APPEND configure_command ${HDF5_CXX_STANDARD_TEST_CONFIGURE_ARGS})
  endif ()

  execute_process (
    COMMAND ${configure_command}
    RESULT_VARIABLE configure_result
    OUTPUT_VARIABLE configure_output
    ERROR_VARIABLE configure_error
  )
  set (diagnostic "${configure_output}${configure_error}")
  string (REGEX REPLACE "[ \r\n\t]+" " " normalized_diagnostic "${diagnostic}")

  if (expect_success)
    if (configure_result)
      message (FATAL_ERROR "Configure failed for ${build}:\n${diagnostic}")
    endif ()
  elseif (NOT configure_result)
    message (FATAL_ERROR "Configure unexpectedly accepted C++${standard} for ${source}")
  elseif (NOT normalized_diagnostic MATCHES "${expected_message}")
    message (FATAL_ERROR
      "Configure rejection for C++${standard} omitted '${expected_message}':\n${diagnostic}"
    )
  endif ()
endfunction ()

function (_hdf5_cxx_standard_read_codemodel build_dir output_json output_configuration)
  set (reply_dir "${build_dir}/.cmake/api/v1/reply")
  file (GLOB index_files "${reply_dir}/index-*.json")
  list (SORT index_files)
  list (POP_BACK index_files index_file)
  if (NOT index_file)
    message (FATAL_ERROR "No CMake File API reply found in ${reply_dir}")
  endif ()

  file (READ "${index_file}" index_json)
  string (JSON object_count LENGTH "${index_json}" objects)
  math (EXPR object_last "${object_count} - 1")
  unset (codemodel_file)
  foreach (object_index RANGE 0 ${object_last})
    string (JSON object_kind GET "${index_json}" objects ${object_index} kind)
    if (object_kind STREQUAL "codemodel")
      string (JSON codemodel_file GET "${index_json}" objects ${object_index} jsonFile)
      break ()
    endif ()
  endforeach ()
  if (NOT codemodel_file)
    message (FATAL_ERROR "The File API reply does not contain a codemodel object")
  endif ()

  file (READ "${reply_dir}/${codemodel_file}" codemodel_json)
  string (JSON configuration_count LENGTH "${codemodel_json}" configurations)
  math (EXPR configuration_last "${configuration_count} - 1")
  unset (release_configuration)
  foreach (configuration_index RANGE 0 ${configuration_last})
    string (JSON configuration_name GET
      "${codemodel_json}" configurations ${configuration_index} name
    )
    if (configuration_name STREQUAL "Release")
      set (release_configuration ${configuration_index})
      break ()
    endif ()
  endforeach ()
  if (NOT DEFINED release_configuration)
    message (FATAL_ERROR "The File API codemodel has no Release configuration")
  endif ()

  set (${output_json} "${codemodel_json}" PARENT_SCOPE)
  set (${output_configuration} ${release_configuration} PARENT_SCOPE)
endfunction ()

function (_hdf5_cxx_standard_capture build_dir capture_name expected_standard flag_regex output_variable)
  _hdf5_cxx_standard_read_codemodel ("${build_dir}" codemodel_json configuration_index)
  set (reply_dir "${build_dir}/.cmake/api/v1/reply")
  string (JSON target_count LENGTH
    "${codemodel_json}" configurations ${configuration_index} targets
  )
  math (EXPR target_last "${target_count} - 1")

  set (cxx_group_count 0)
  set (contract_records)
  foreach (target_index RANGE 0 ${target_last})
    string (JSON target_file GET
      "${codemodel_json}" configurations ${configuration_index} targets ${target_index} jsonFile
    )
    file (READ "${reply_dir}/${target_file}" target_json)
    if (NOT target_json MATCHES "\"compileGroups\"")
      continue ()
    endif ()

    string (JSON target_name GET "${target_json}" name)
    if (NOT target_name MATCHES "^h5_api_test_driver(_process)?$")
      continue ()
    endif ()
    string (JSON compile_group_count LENGTH "${target_json}" compileGroups)
    if (NOT compile_group_count)
      continue ()
    endif ()
    math (EXPR compile_group_last "${compile_group_count} - 1")
    foreach (compile_group_index RANGE 0 ${compile_group_last})
      string (JSON language GET
        "${target_json}" compileGroups ${compile_group_index} language
      )
      if (NOT language STREQUAL "CXX")
        continue ()
      endif ()

      math (EXPR cxx_group_count "${cxx_group_count} + 1")
      string (JSON actual_standard ERROR_VARIABLE standard_error GET
        "${target_json}" compileGroups ${compile_group_index} languageStandard standard
      )
      if (NOT standard_error STREQUAL "NOTFOUND" OR
          NOT actual_standard STREQUAL "${expected_standard}")
        message (FATAL_ERROR
          "Target ${target_name} has C++ standard '${actual_standard}', expected '${expected_standard}'"
        )
      endif ()

      string (JSON fragment_count LENGTH
        "${target_json}" compileGroups ${compile_group_index} compileCommandFragments
      )
      math (EXPR fragment_last "${fragment_count} - 1")
      set (compile_fragments "")
      foreach (fragment_index RANGE 0 ${fragment_last})
        string (JSON fragment GET
          "${target_json}" compileGroups ${compile_group_index}
          compileCommandFragments ${fragment_index} fragment
        )
        string (APPEND compile_fragments " ${fragment}")
      endforeach ()
      if (NOT compile_fragments MATCHES "${flag_regex}")
        message (FATAL_ERROR
          "Target ${target_name} does not use strict C++${expected_standard}: ${compile_fragments}"
        )
      endif ()
      list (APPEND contract_records
        "target|${target_name}|group=${compile_group_index}|standard=${actual_standard}|strict=TRUE"
      )
    endforeach ()
  endforeach ()

  if (NOT cxx_group_count EQUAL HDF5_CXX_STANDARD_TEST_EXPECTED_GROUPS)
    message (FATAL_ERROR
      "Found ${cxx_group_count} C++ compile groups; expected ${HDF5_CXX_STANDARD_TEST_EXPECTED_GROUPS}"
    )
  endif ()

  file (GLOB_RECURSE export_files LIST_DIRECTORIES FALSE
    "${build_dir}/CMakeFiles/Export/*.cmake"
  )
  file (GLOB build_tree_exports LIST_DIRECTORIES FALSE
    "${build_dir}/*-targets.cmake"
    "${build_dir}/*_static-targets.cmake"
  )
  list (APPEND export_files ${build_tree_exports})
  list (REMOVE_DUPLICATES export_files)
  list (SORT export_files)
  if (NOT export_files)
    message (FATAL_ERROR "No generated HDF5 target exports found in ${build_dir}")
  endif ()
  foreach (export_file IN LISTS export_files)
    file (READ "${export_file}" export_content)
    if (export_content MATCHES "cxx_std_[0-9]+")
      message (FATAL_ERROR "C++ standard requirement leaked into ${export_file}")
    endif ()
    file (RELATIVE_PATH relative_export "${build_dir}" "${export_file}")
    file (SHA256 "${export_file}" export_hash)
    list (APPEND contract_records "export|${relative_export}|sha256=${export_hash}")
  endforeach ()

  file (SHA256 "${build_dir}/src/H5pubconf.h" generated_header_hash)
  list (APPEND contract_records "header|H5pubconf.h|sha256=${generated_header_hash}")

  list (SORT contract_records)
  list (JOIN contract_records "\n" contract_content)
  set (contract_file "${binary_root}/contracts/${capture_name}.txt")
  file (WRITE "${contract_file}" "${contract_content}\n")
  set (${output_variable} "${contract_file}" PARENT_SCOPE)
endfunction ()

function (_hdf5_cxx_standard_compare baseline current description)
  execute_process (
    COMMAND "${CMAKE_COMMAND}" -E compare_files "${baseline}" "${current}"
    RESULT_VARIABLE compare_result
  )
  if (compare_result)
    message (FATAL_ERROR
      "C++ standard contract changed across ${description}:\n  ${baseline}\n  ${current}"
    )
  endif ()
endfunction ()

_hdf5_cxx_standard_prepare_case (default default_dir)
_hdf5_cxx_standard_configure (
  "${source_dir}" "${default_dir}" DEFAULT HDF5_TEST_API_ENABLE_DRIVER TRUE ""
)
_hdf5_cxx_standard_capture (
  "${default_dir}" default-first 20 "${cxx20_flag_regex}" default_first
)
_hdf5_cxx_standard_configure (
  "${source_dir}" "${default_dir}" DEFAULT HDF5_TEST_API_ENABLE_DRIVER TRUE ""
)
_hdf5_cxx_standard_capture (
  "${default_dir}" default-second 20 "${cxx20_flag_regex}" default_second
)
_hdf5_cxx_standard_compare ("${default_first}" "${default_second}" "first/repeat configure")

_hdf5_cxx_standard_prepare_case (later later_dir)
_hdf5_cxx_standard_configure (
  "${source_dir}" "${later_dir}" 23 HDF5_TEST_API_ENABLE_DRIVER TRUE ""
)
_hdf5_cxx_standard_capture ("${later_dir}" later 23 "${cxx23_flag_regex}" later_contract)

foreach (scope_standard IN ITEMS DEFAULT 23)
  string (TOLOWER "${scope_standard}" scope_case_suffix)
  _hdf5_cxx_standard_prepare_case ("dependency-scope-${scope_case_suffix}" scope_dir)
  _hdf5_cxx_standard_configure (
    "${CMAKE_CURRENT_LIST_DIR}/c-standard-scope" "${scope_dir}" "${scope_standard}" NONE TRUE ""
  )
endforeach ()

foreach (lower_standard IN ITEMS 98 11 14 17)
  _hdf5_cxx_standard_prepare_case ("lower-${lower_standard}" lower_dir)
  _hdf5_cxx_standard_configure (
    "${source_dir}" "${lower_dir}" "${lower_standard}" HDF5_TEST_API_ENABLE_DRIVER FALSE
    "requires C\\+\\+20 or later.*CMAKE_CXX_STANDARD=${lower_standard}"
  )
endforeach ()

message (STATUS
  "All retained HDF5 C++ standard cases passed (${HDF5_CXX_STANDARD_TEST_EXPECTED_GROUPS} C++ compile groups)"
)
