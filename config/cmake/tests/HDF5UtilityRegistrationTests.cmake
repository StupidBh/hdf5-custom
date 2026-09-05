cmake_minimum_required (VERSION 4.0)

foreach (required_variable IN ITEMS
    HDF5_UTILITY_TEST_BINARY_ROOT
    HDF5_UTILITY_TEST_GENERATOR
    HDF5_UTILITY_TEST_EXPECT_MIRROR
)
  if (NOT DEFINED ${required_variable} OR "${${required_variable}}" STREQUAL "")
    message (FATAL_ERROR "Missing required test variable: ${required_variable}")
  endif ()
endforeach ()

cmake_path (GET CMAKE_CURRENT_LIST_DIR PARENT_PATH cmake_dir)
cmake_path (GET cmake_dir PARENT_PATH config_dir)
cmake_path (GET config_dir PARENT_PATH source_dir)
cmake_path (ABSOLUTE_PATH source_dir NORMALIZE OUTPUT_VARIABLE source_dir)
cmake_path (ABSOLUTE_PATH HDF5_UTILITY_TEST_BINARY_ROOT NORMALIZE
  OUTPUT_VARIABLE binary_root
)
cmake_path (IS_PREFIX source_dir "${binary_root}" NORMALIZE binary_in_source)
if (binary_in_source)
  message (FATAL_ERROR "The utility registration test root must be outside the source tree")
endif ()

file (MAKE_DIRECTORY "${binary_root}/contracts")
if (HDF5_UTILITY_TEST_EXPECT_MIRROR)
  set (expected_native_mirror ON)
else ()
  set (expected_native_mirror OFF)
endif ()

function (_hdf5_utility_prepare_case case_name output_variable)
  set (case_dir "${binary_root}/${case_name}")
  file (REMOVE_RECURSE "${case_dir}")
  set (query_dir "${case_dir}/.cmake/api/v1/query/client-hdf5-utility-registration")
  file (MAKE_DIRECTORY "${query_dir}")
  file (WRITE "${query_dir}/codemodel-v2" "")
  set (${output_variable} "${case_dir}" PARENT_SCOPE)
endfunction ()

function (_hdf5_utility_read_codemodel build_dir output_variable)
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
  foreach (object_index RANGE 0 ${object_last})
    string (JSON object_kind GET "${index_json}" objects ${object_index} kind)
    if (object_kind STREQUAL "codemodel")
      string (JSON json_file GET "${index_json}" objects ${object_index} jsonFile)
      file (READ "${reply_dir}/${json_file}" codemodel_json)
      set (${output_variable} "${codemodel_json}" PARENT_SCOPE)
      return ()
    endif ()
  endforeach ()
  message (FATAL_ERROR "The File API reply does not contain a codemodel object")
endfunction ()

function (_hdf5_utility_expect_cache build_dir name type value help)
  set (cache_file "${build_dir}/CMakeCache.txt")
  file (STRINGS "${cache_file}" cache_entry REGEX "^${name}:${type}=")
  if (NOT cache_entry STREQUAL "${name}:${type}=${value}")
    message (FATAL_ERROR "Unexpected ${name} cache entry: ${cache_entry}")
  endif ()
  file (STRINGS "${cache_file}" cache_help REGEX "^//${help}$")
  if (NOT cache_help STREQUAL "//${help}")
    message (FATAL_ERROR "Unexpected ${name} help text: ${cache_help}")
  endif ()
  file (STRINGS "${cache_file}" cache_advanced REGEX "^${name}-ADVANCED:INTERNAL=")
  if (cache_advanced)
    message (FATAL_ERROR "${name} unexpectedly became an advanced cache entry")
  endif ()
endfunction ()

function (_hdf5_utility_require_text text regex description)
  if (NOT text MATCHES "${regex}")
    message (FATAL_ERROR "Missing ${description}")
  endif ()
endfunction ()

function (_hdf5_utility_capture
    case_name build_dir capture_name utils_setting mirror_setting
    expected_utils expected_mirror
    output_variable
)
  set (configure_command
    "${CMAKE_COMMAND}" -S "${source_dir}" -B "${build_dir}"
    -G "${HDF5_UTILITY_TEST_GENERATOR}"
  )
  if (DEFINED HDF5_UTILITY_TEST_GENERATOR_PLATFORM AND
      NOT HDF5_UTILITY_TEST_GENERATOR_PLATFORM STREQUAL "")
    list (APPEND configure_command -A "${HDF5_UTILITY_TEST_GENERATOR_PLATFORM}")
  endif ()
  if (DEFINED HDF5_UTILITY_TEST_GENERATOR_TOOLSET AND
      NOT HDF5_UTILITY_TEST_GENERATOR_TOOLSET STREQUAL "")
    list (APPEND configure_command -T "${HDF5_UTILITY_TEST_GENERATOR_TOOLSET}")
  endif ()
  list (APPEND configure_command -DBUILD_TESTING=ON -DHDF_TEST_EXPRESS=3)
  if (NOT utils_setting STREQUAL "DEFAULT")
    list (APPEND configure_command "-DHDF5_BUILD_UTILS=${utils_setting}")
  endif ()
  if (NOT mirror_setting STREQUAL "DEFAULT")
    list (APPEND configure_command "-DHDF5_ENABLE_MIRROR_VFD=${mirror_setting}")
  endif ()
  if (DEFINED HDF5_UTILITY_TEST_CONFIGURE_ARGS)
    list (APPEND configure_command ${HDF5_UTILITY_TEST_CONFIGURE_ARGS})
  endif ()

  execute_process (
    COMMAND ${configure_command}
    RESULT_VARIABLE configure_result
    OUTPUT_VARIABLE configure_output
    ERROR_VARIABLE configure_error
  )
  if (configure_result)
    message (FATAL_ERROR
      "Configure ${case_name}/${capture_name} failed:\n${configure_output}${configure_error}"
    )
  endif ()

  _hdf5_utility_expect_cache (
    "${build_dir}" HDF5_BUILD_UTILS BOOL "${expected_utils}" "Build HDF5 Utils"
  )
  _hdf5_utility_expect_cache (
    "${build_dir}" HDF5_ENABLE_MIRROR_VFD BOOL "${expected_mirror}"
    "Build the Mirror Virtual File Driver"
  )
  if (expected_utils AND expected_mirror)
    set (expect_registration TRUE)
  else ()
    set (expect_registration FALSE)
  endif ()

  _hdf5_utility_read_codemodel ("${build_dir}" codemodel_json)
  string (CONCAT mirror_cache_record
    "cache|HDF5_ENABLE_MIRROR_VFD|BOOL|${expected_mirror}|advanced=FALSE|"
    "help=Build the Mirror Virtual File Driver"
  )
  set (relevant_records
    "cache|HDF5_BUILD_UTILS|BOOL|${expected_utils}|advanced=FALSE|help=Build HDF5 Utils"
    "${mirror_cache_record}"
  )
  foreach (target IN ITEMS mirror_server mirror_server_stop mirror_vfd use_append_chunk_mirror)
    string (REGEX MATCHALL
      "\"name\"[ \r\n\t]*:[ \r\n\t]*\"${target}\""
      target_matches "${codemodel_json}"
    )
    list (LENGTH target_matches target_count)
    if (expect_registration AND NOT target_count EQUAL 1)
      message (FATAL_ERROR "Expected one target ${target} in ${case_name}/${capture_name}")
    elseif (NOT expect_registration AND target_count)
      message (FATAL_ERROR "Unexpected target ${target} in ${case_name}/${capture_name}")
    endif ()
    list (APPEND relevant_records "target|${target}|count=${target_count}")
  endforeach ()

  set (ctest_file "${build_dir}/test/CTestTestfile.cmake")
  file (STRINGS "${ctest_file}" mirror_test_lines REGEX "H5TEST-mirror_(server|vfd)")
  list (JOIN mirror_test_lines "\n" mirror_test_text)
  foreach (test_name IN ITEMS
      H5TEST-mirror_server-start
      H5TEST-mirror_vfd
      H5TEST-mirror_server-stop
  )
    if (mirror_test_text MATCHES "${test_name}")
      set (test_present TRUE)
    else ()
      set (test_present FALSE)
    endif ()
    if (expect_registration AND NOT test_present)
      message (FATAL_ERROR "Expected test ${test_name} in ${case_name}/${capture_name}")
    elseif (NOT expect_registration AND test_present)
      message (FATAL_ERROR "Unexpected test ${test_name} in ${case_name}/${capture_name}")
    endif ()
    list (APPEND relevant_records "test|${test_name}|present=${test_present}")
  endforeach ()

  if (expect_registration)
    _hdf5_utility_require_text (
      "${mirror_test_text}"
      "H5TEST-mirror_server-start[^\n]*FIXTURES_SETUP \"hdf5_mirror_server\""
      "mirror server setup fixture"
    )
    _hdf5_utility_require_text (
      "${mirror_test_text}"
      "H5TEST-mirror_vfd[^\n]*FIXTURES_REQUIRED \"clear_H5TEST.hdf5_mirror_server\""
      "mirror test fixture requirements"
    )
    _hdf5_utility_require_text (
      "${mirror_test_text}"
      "H5TEST-mirror_server-stop[^\n]*FIXTURES_CLEANUP \"hdf5_mirror_server\""
      "mirror server cleanup fixture"
    )
  endif ()

  foreach (test_line IN LISTS mirror_test_lines)
    string (REGEX REPLACE " _BACKTRACE_TRIPLES \"[^\"]*\"" "" test_line "${test_line}")
    string (REPLACE "\\" "/" test_line "${test_line}")
    string (REPLACE "${source_dir}" "<SOURCE>" test_line "${test_line}")
    string (REPLACE "${build_dir}" "<BUILD>" test_line "${test_line}")
    list (APPEND relevant_records "ctest|${test_line}")
  endforeach ()
  list (SORT relevant_records)
  list (JOIN relevant_records "\n" relevant_content)
  set (relevant_file "${binary_root}/contracts/${case_name}-${capture_name}.txt")
  file (WRITE "${relevant_file}" "${relevant_content}\n")
  set (${output_variable} "${relevant_file}" PARENT_SCOPE)
endfunction ()

function (_hdf5_utility_compare baseline current description)
  execute_process (
    COMMAND "${CMAKE_COMMAND}" -E compare_files "${baseline}" "${current}"
    RESULT_VARIABLE compare_result
  )
  if (compare_result)
    message (FATAL_ERROR
      "Utility registration contract changed across ${description}:\n  ${baseline}\n  ${current}"
    )
  endif ()
endfunction ()

_hdf5_utility_prepare_case (default default_dir)
_hdf5_utility_capture (default "${default_dir}" first DEFAULT DEFAULT ON OFF default_first)
_hdf5_utility_capture (default "${default_dir}" second DEFAULT DEFAULT ON OFF default_second)
_hdf5_utility_capture (default "${default_dir}" third DEFAULT DEFAULT ON OFF default_third)
_hdf5_utility_compare ("${default_first}" "${default_second}" "default first/second configure")
_hdf5_utility_compare ("${default_first}" "${default_third}" "default first/third configure")

_hdf5_utility_prepare_case (utils-off utils_off_dir)
_hdf5_utility_capture (utils-off "${utils_off_dir}" first OFF DEFAULT OFF OFF utils_off_first)
_hdf5_utility_capture (utils-off "${utils_off_dir}" second OFF DEFAULT OFF OFF utils_off_second)
_hdf5_utility_capture (utils-off "${utils_off_dir}" third OFF DEFAULT OFF OFF utils_off_third)
_hdf5_utility_compare ("${utils_off_first}" "${utils_off_second}" "utils OFF first/second configure")
_hdf5_utility_compare ("${utils_off_first}" "${utils_off_third}" "utils OFF first/third configure")

_hdf5_utility_prepare_case (mirror-on mirror_on_dir)
_hdf5_utility_capture (
  mirror-on "${mirror_on_dir}" first ON ON ON "${expected_native_mirror}" mirror_first
)
_hdf5_utility_capture (
  mirror-on "${mirror_on_dir}" second ON ON ON "${expected_native_mirror}" mirror_second
)
_hdf5_utility_capture (
  mirror-on "${mirror_on_dir}" third ON ON ON "${expected_native_mirror}" mirror_third
)
_hdf5_utility_compare ("${mirror_first}" "${mirror_second}" "mirror ON first/second configure")
_hdf5_utility_compare ("${mirror_first}" "${mirror_third}" "mirror ON first/third configure")

_hdf5_utility_capture (
  mirror-on "${mirror_on_dir}" transition-off OFF ON OFF "${expected_native_mirror}" transition_off
)
_hdf5_utility_capture (
  mirror-on "${mirror_on_dir}" transition-on ON ON ON "${expected_native_mirror}" transition_on
)
_hdf5_utility_compare ("${mirror_third}" "${transition_on}" "utils ON/OFF/ON reconfigure")

message (STATUS "All HDF5 utility registration cases passed")
