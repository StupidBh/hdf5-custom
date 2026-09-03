cmake_minimum_required (VERSION 4.0)

# CMake 4.4 diagnoses legacy macro argument escaping. Keep Windows command
# fragments intact while retaining CMake 4.0 as the actual minimum.
if (POLICY CMP0219)
  cmake_policy (SET CMP0219 NEW)
endif ()

if (NOT DEFINED HDF5_CONTRACT_ACTION)
  message (FATAL_ERROR "Set HDF5_CONTRACT_ACTION to QUERY, CAPTURE, or COMPARE")
endif ()

string (TOUPPER "${HDF5_CONTRACT_ACTION}" HDF5_CONTRACT_ACTION)

function (_hdf5_contract_absolute_path input_path output_variable)
  cmake_path (ABSOLUTE_PATH input_path NORMALIZE OUTPUT_VARIABLE absolute_path)
  file (TO_CMAKE_PATH "${absolute_path}" absolute_path)
  set (${output_variable} "${absolute_path}" PARENT_SCOPE)
endfunction ()

if (HDF5_CONTRACT_ACTION STREQUAL "QUERY")
  if (NOT DEFINED HDF5_CONTRACT_BUILD_DIR)
    message (FATAL_ERROR "QUERY requires HDF5_CONTRACT_BUILD_DIR")
  endif ()

  _hdf5_contract_absolute_path ("${HDF5_CONTRACT_BUILD_DIR}" build_dir)
  set (query_dir "${build_dir}/.cmake/api/v1/query/client-hdf5-contract")
  file (MAKE_DIRECTORY "${query_dir}")
  file (WRITE "${query_dir}/cache-v2" "")
  file (WRITE "${query_dir}/codemodel-v2" "")
  message (STATUS "Registered HDF5 build contract query in ${query_dir}")
  return ()
endif ()

if (HDF5_CONTRACT_ACTION STREQUAL "COMPARE")
  if (NOT DEFINED HDF5_CONTRACT_BASELINE OR NOT DEFINED HDF5_CONTRACT_CURRENT)
    message (FATAL_ERROR "COMPARE requires HDF5_CONTRACT_BASELINE and HDF5_CONTRACT_CURRENT")
  endif ()

  _hdf5_contract_absolute_path ("${HDF5_CONTRACT_BASELINE}" baseline_file)
  _hdf5_contract_absolute_path ("${HDF5_CONTRACT_CURRENT}" current_file)
  if (NOT EXISTS "${baseline_file}")
    message (FATAL_ERROR "Baseline contract does not exist: ${baseline_file}")
  endif ()
  if (NOT EXISTS "${current_file}")
    message (FATAL_ERROR "Current contract does not exist: ${current_file}")
  endif ()

  execute_process (
    COMMAND "${CMAKE_COMMAND}" -E compare_files "${baseline_file}" "${current_file}"
    RESULT_VARIABLE compare_result
  )
  if (compare_result)
    message (FATAL_ERROR
      "Build contracts differ. Compare these normalized manifests:\n"
      "  baseline: ${baseline_file}\n"
      "  current:  ${current_file}"
    )
  endif ()

  message (STATUS "Build contracts match: ${baseline_file}")
  return ()
endif ()

if (NOT HDF5_CONTRACT_ACTION STREQUAL "CAPTURE")
  message (FATAL_ERROR "Unknown HDF5_CONTRACT_ACTION: ${HDF5_CONTRACT_ACTION}")
endif ()

if (NOT DEFINED HDF5_CONTRACT_BUILD_DIR OR NOT DEFINED HDF5_CONTRACT_OUTPUT)
  message (FATAL_ERROR "CAPTURE requires HDF5_CONTRACT_BUILD_DIR and HDF5_CONTRACT_OUTPUT")
endif ()

_hdf5_contract_absolute_path ("${HDF5_CONTRACT_BUILD_DIR}" build_dir)
_hdf5_contract_absolute_path ("${HDF5_CONTRACT_OUTPUT}" output_file)
if (DEFINED HDF5_CONTRACT_INSTALL_DIR)
  _hdf5_contract_absolute_path ("${HDF5_CONTRACT_INSTALL_DIR}" install_dir)
else ()
  set (install_dir "")
endif ()
if (NOT DEFINED HDF5_CONTRACT_CONFIG)
  set (HDF5_CONTRACT_CONFIG "Release")
endif ()
if (NOT DEFINED HDF5_CONTRACT_IGNORE_TARGET_REGEX)
  set (HDF5_CONTRACT_IGNORE_TARGET_REGEX
    "^hdf5_((build_options|warnings|platform|dependencies|sanitizers)|.+_usage_requirements)$"
  )
endif ()

set (reply_dir "${build_dir}/.cmake/api/v1/reply")
file (GLOB index_files "${reply_dir}/index-*.json")
list (SORT index_files)
list (POP_BACK index_files index_file)
if (NOT index_file)
  message (FATAL_ERROR
    "No CMake File API reply found in ${reply_dir}. Run QUERY, then reconfigure the build tree."
  )
endif ()

function (_hdf5_contract_json_get output_variable json)
  string (JSON value ERROR_VARIABLE error GET "${json}" ${ARGN})
  if (error STREQUAL "NOTFOUND")
    set (${output_variable} "${value}" PARENT_SCOPE)
    set (${output_variable}_FOUND TRUE PARENT_SCOPE)
  else ()
    set (${output_variable} "" PARENT_SCOPE)
    set (${output_variable}_FOUND FALSE PARENT_SCOPE)
  endif ()
endfunction ()

function (_hdf5_contract_json_length output_variable json)
  string (JSON value ERROR_VARIABLE error LENGTH "${json}" ${ARGN})
  if (error STREQUAL "NOTFOUND")
    set (${output_variable} "${value}" PARENT_SCOPE)
  else ()
    set (${output_variable} 0 PARENT_SCOPE)
  endif ()
endfunction ()

function (_hdf5_contract_normalize input_value output_variable)
  set (value "${input_value}")
  string (REPLACE "\\" "/" value "${value}")
  if (install_dir)
    string (REPLACE "${install_dir}" "<INSTALL>" value "${value}")
  endif ()
  if (build_dir)
    string (REPLACE "${build_dir}" "<BUILD>" value "${value}")
  endif ()
  if (source_dir)
    string (REPLACE "${source_dir}" "<SOURCE>" value "${value}")
  endif ()
  string (REGEX REPLACE "CMakeFiles/[0-9A-Fa-f]+/" "CMakeFiles/<RULE_HASH>/" value "${value}")
  string (REGEX REPLACE "[\r\n\t]+" " " value "${value}")
  set (${output_variable} "${value}" PARENT_SCOPE)
endfunction ()

macro (_hdf5_contract_append input_record)
  _hdf5_contract_normalize ("${input_record}" normalized_record)
  string (REPLACE ";" "%3B" normalized_record "${normalized_record}")
  list (APPEND contract_records "${normalized_record}")
endmacro ()

function (_hdf5_contract_read_reply_file kind index_json output_variable)
  _hdf5_contract_json_length (object_count "${index_json}" objects)
  if (object_count GREATER 0)
    math (EXPR object_last "${object_count} - 1")
    foreach (object_index RANGE 0 ${object_last})
      _hdf5_contract_json_get (object_kind "${index_json}" objects ${object_index} kind)
      if (object_kind STREQUAL kind)
        _hdf5_contract_json_get (json_file "${index_json}" objects ${object_index} jsonFile)
        file (READ "${reply_dir}/${json_file}" reply_json)
        set (${output_variable} "${reply_json}" PARENT_SCOPE)
        return ()
      endif ()
    endforeach ()
  endif ()
  message (FATAL_ERROR "The CMake File API reply does not contain a ${kind} object")
endfunction ()

file (READ "${index_file}" index_json)
_hdf5_contract_read_reply_file ("codemodel" "${index_json}" codemodel_json)
_hdf5_contract_read_reply_file ("cache" "${index_json}" cache_json)
_hdf5_contract_json_get (source_dir "${codemodel_json}" paths source)
_hdf5_contract_json_get (codemodel_build_dir "${codemodel_json}" paths build)
file (TO_CMAKE_PATH "${source_dir}" source_dir)
file (TO_CMAKE_PATH "${codemodel_build_dir}" codemodel_build_dir)

if (NOT codemodel_build_dir STREQUAL build_dir)
  message (FATAL_ERROR
    "File API reply belongs to a different build tree: ${codemodel_build_dir}"
  )
endif ()

set (contract_records "")
_hdf5_contract_json_get (generator_name "${index_json}" cmake generator name)
_hdf5_contract_json_get (generator_platform "${index_json}" cmake generator platform)
_hdf5_contract_json_get (generator_multi_config "${index_json}" cmake generator multiConfig)
_hdf5_contract_json_get (cmake_version "${index_json}" cmake version string)
_hdf5_contract_append ("meta|cmake|${cmake_version}")
_hdf5_contract_append ("meta|generator|${generator_name}")
_hdf5_contract_append ("meta|generator-platform|${generator_platform}")
_hdf5_contract_append ("meta|multi-config|${generator_multi_config}")
_hdf5_contract_append ("meta|configuration|${HDF5_CONTRACT_CONFIG}")

# Capture the HDF5-owned cache surface, including option metadata.
_hdf5_contract_json_length (cache_entry_count "${cache_json}" entries)
if (cache_entry_count GREATER 0)
  math (EXPR cache_entry_last "${cache_entry_count} - 1")
  foreach (entry_index RANGE 0 ${cache_entry_last})
    _hdf5_contract_json_get (cache_name "${cache_json}" entries ${entry_index} name)
    if (NOT cache_name MATCHES "^(BUILD_SHARED_LIBS|BUILD_TESTING|HDF5_.+|HDF_.+)$")
      continue ()
    endif ()

    _hdf5_contract_json_get (cache_type "${cache_json}" entries ${entry_index} type)
    _hdf5_contract_json_get (cache_value "${cache_json}" entries ${entry_index} value)
    set (cache_advanced "FALSE")
    set (cache_strings "")
    set (cache_help "")
    _hdf5_contract_json_length (property_count "${cache_json}" entries ${entry_index} properties)
    if (property_count GREATER 0)
      math (EXPR property_last "${property_count} - 1")
      foreach (property_index RANGE 0 ${property_last})
        _hdf5_contract_json_get (property_name "${cache_json}"
          entries ${entry_index} properties ${property_index} name
        )
        _hdf5_contract_json_get (property_value "${cache_json}"
          entries ${entry_index} properties ${property_index} value
        )
        if (property_name STREQUAL "ADVANCED")
          set (cache_advanced "${property_value}")
        elseif (property_name STREQUAL "STRINGS")
          set (cache_strings "${property_value}")
        elseif (property_name STREQUAL "HELPSTRING")
          set (cache_help "${property_value}")
        endif ()
      endforeach ()
    endif ()
    _hdf5_contract_append (
      "cache|${cache_name}|${cache_type}|${cache_value}|advanced=${cache_advanced}|strings=${cache_strings}|help=${cache_help}"
    )
  endforeach ()
endif ()

# Select one codemodel configuration. Single-config generators normally expose an empty name.
set (selected_config_index -1)
_hdf5_contract_json_length (config_count "${codemodel_json}" configurations)
if (config_count GREATER 0)
  math (EXPR config_last "${config_count} - 1")
  foreach (config_index RANGE 0 ${config_last})
    _hdf5_contract_json_get (config_name "${codemodel_json}" configurations ${config_index} name)
    if (config_name STREQUAL HDF5_CONTRACT_CONFIG
        OR (config_name STREQUAL "" AND config_count EQUAL 1))
      set (selected_config_index ${config_index})
      break ()
    endif ()
  endforeach ()
endif ()
if (selected_config_index LESS 0)
  message (FATAL_ERROR "Configuration '${HDF5_CONTRACT_CONFIG}' is not present in the codemodel")
endif ()

_hdf5_contract_json_length (target_count "${codemodel_json}"
  configurations ${selected_config_index} targets
)
if (target_count GREATER 0)
  math (EXPR target_last "${target_count} - 1")
  foreach (target_index RANGE 0 ${target_last})
    _hdf5_contract_json_get (target_name "${codemodel_json}"
      configurations ${selected_config_index} targets ${target_index} name
    )
    if (target_name MATCHES "${HDF5_CONTRACT_IGNORE_TARGET_REGEX}")
      continue ()
    endif ()
    _hdf5_contract_json_get (target_json_file "${codemodel_json}"
      configurations ${selected_config_index} targets ${target_index} jsonFile
    )
    file (READ "${reply_dir}/${target_json_file}" target_json)
    _hdf5_contract_json_get (target_type "${target_json}" type)
    _hdf5_contract_json_get (target_name_on_disk "${target_json}" nameOnDisk)
    _hdf5_contract_json_get (target_folder "${target_json}" folder name)
    _hdf5_contract_append (
      "target|${target_name}|${target_type}|name-on-disk=${target_name_on_disk}|folder=${target_folder}"
    )

    foreach (section IN ITEMS artifacts dependencies compileDependencies sources)
      _hdf5_contract_json_length (item_count "${target_json}" ${section})
      if (item_count GREATER 0)
        math (EXPR item_last "${item_count} - 1")
        foreach (item_index RANGE 0 ${item_last})
          if (section STREQUAL "artifacts")
            _hdf5_contract_json_get (item_value "${target_json}" ${section} ${item_index} path)
            _hdf5_contract_append ("target-artifact|${target_name}|${item_value}")
          elseif (section STREQUAL "dependencies" OR section STREQUAL "compileDependencies")
            _hdf5_contract_json_get (item_value "${target_json}" ${section} ${item_index} id)
            string (REGEX REPLACE "::@.*$" "" item_value "${item_value}")
            if (item_value MATCHES "${HDF5_CONTRACT_IGNORE_TARGET_REGEX}")
              continue ()
            endif ()
            _hdf5_contract_append ("target-${section}|${target_name}|${item_value}")
          elseif (section STREQUAL "sources")
            _hdf5_contract_json_get (item_value "${target_json}" ${section} ${item_index} path)
            _hdf5_contract_json_get (item_generated "${target_json}" ${section} ${item_index} isGenerated)
            _hdf5_contract_append (
              "target-source|${target_name}|${item_value}|generated=${item_generated}"
            )
          endif ()
        endforeach ()
      endif ()
    endforeach ()

    _hdf5_contract_json_length (destination_count "${target_json}" install destinations)
    if (destination_count GREATER 0)
      math (EXPR destination_last "${destination_count} - 1")
      foreach (destination_index RANGE 0 ${destination_last})
        _hdf5_contract_json_get (destination "${target_json}"
          install destinations ${destination_index} path
        )
        _hdf5_contract_append ("target-install|${target_name}|${destination}")
      endforeach ()
    endif ()

    _hdf5_contract_json_length (compile_group_count "${target_json}" compileGroups)
    if (compile_group_count GREATER 0)
      math (EXPR compile_group_last "${compile_group_count} - 1")
      foreach (group_index RANGE 0 ${compile_group_last})
        _hdf5_contract_json_get (language "${target_json}" compileGroups ${group_index} language)
        _hdf5_contract_json_get (standard "${target_json}"
          compileGroups ${group_index} languageStandard standard
        )
        _hdf5_contract_append (
          "target-compile-group|${target_name}|${group_index}|language=${language}|standard=${standard}"
        )

        foreach (group_section IN ITEMS compileCommandFragments defines includes)
          if (group_section STREQUAL "compileCommandFragments")
            set (group_member "fragment")
            set (record_kind "compile-option")
          elseif (group_section STREQUAL "defines")
            set (group_member "define")
            set (record_kind "compile-definition")
          else ()
            set (group_member "path")
            set (record_kind "include-directory")
          endif ()
          _hdf5_contract_json_length (group_item_count "${target_json}"
            compileGroups ${group_index} ${group_section}
          )
          if (group_item_count GREATER 0)
            math (EXPR group_item_last "${group_item_count} - 1")
            foreach (group_item_index RANGE 0 ${group_item_last})
              _hdf5_contract_json_get (group_item "${target_json}"
                compileGroups ${group_index} ${group_section} ${group_item_index} ${group_member}
              )
              _hdf5_contract_append (
                "target-${record_kind}|${target_name}|${group_index}|${group_item}"
              )
            endforeach ()
          endif ()
        endforeach ()
      endforeach ()
    endif ()

    foreach (link_section IN ITEMS archive link)
      _hdf5_contract_json_length (fragment_count "${target_json}" ${link_section} commandFragments)
      if (fragment_count GREATER 0)
        math (EXPR fragment_last "${fragment_count} - 1")
        foreach (fragment_index RANGE 0 ${fragment_last})
          _hdf5_contract_json_get (fragment "${target_json}"
            ${link_section} commandFragments ${fragment_index} fragment
          )
          _hdf5_contract_json_get (role "${target_json}"
            ${link_section} commandFragments ${fragment_index} role
          )
          _hdf5_contract_append (
            "target-${link_section}-fragment|${target_name}|${role}|${fragment}"
          )
        endforeach ()
      endif ()
    endforeach ()
  endforeach ()
endif ()

# Capture registered test names. Generated CTest files are hashed below after
# source backtraces are removed, preserving commands and test properties.
get_filename_component (cmake_bin_dir "${CMAKE_COMMAND}" DIRECTORY)
find_program (ctest_command NAMES ctest HINTS "${cmake_bin_dir}" NO_DEFAULT_PATH REQUIRED)
execute_process (
  COMMAND "${ctest_command}" --test-dir "${build_dir}" -C "${HDF5_CONTRACT_CONFIG}"
    -N
  RESULT_VARIABLE ctest_result
  OUTPUT_VARIABLE ctest_output
  ERROR_VARIABLE ctest_error
)
if (ctest_result)
  message (FATAL_ERROR "CTest contract query failed: ${ctest_error}")
endif ()
string (REPLACE "\r\n" "\n" ctest_output "${ctest_output}")
string (REPLACE "\n" ";" ctest_output_lines "${ctest_output}")
foreach (ctest_output_line IN LISTS ctest_output_lines)
  if (ctest_output_line MATCHES "Test +#[0-9]+: (.+)$")
    _hdf5_contract_append ("test|${CMAKE_MATCH_1}")
  endif ()
endforeach ()

# Capture installed paths when an install tree has already been produced.
if (EXISTS "${build_dir}/install_manifest.txt")
  file (STRINGS "${build_dir}/install_manifest.txt" installed_files)
  foreach (installed_file IN LISTS installed_files)
    _hdf5_contract_append ("installed-file|${installed_file}")
  endforeach ()
endif ()

# Hash normalized generated/package text. Binary hashes are deliberately excluded.
set (generated_contract_files
  "${build_dir}/src/H5pubconf.h"
  "${build_dir}/src/H5Epubgen.h"
  "${build_dir}/src/H5version.h"
  "${build_dir}/src/H5overflow.h"
  "${build_dir}/src/H5lib_settings.c"
  "${build_dir}/src/libhdf5.settings"
)
file (GLOB_RECURSE generated_ctest_files LIST_DIRECTORIES FALSE
  "${build_dir}/CTestTestfile.cmake"
)
list (APPEND generated_contract_files ${generated_ctest_files})
if (install_dir AND EXISTS "${install_dir}")
  file (GLOB_RECURSE installed_contract_files LIST_DIRECTORIES FALSE
    "${install_dir}/*-config.cmake"
    "${install_dir}/*-config-version.cmake"
    "${install_dir}/*-targets.cmake"
    "${install_dir}/*-targets-*.cmake"
    "${install_dir}/*.pc"
    "${install_dir}/h5cc"
    "${install_dir}/h5hlcc"
    "${install_dir}/h5c++"
    "${install_dir}/h5hlc++"
    "${install_dir}/libhdf5.settings"
  )
  list (APPEND generated_contract_files ${installed_contract_files})
endif ()
foreach (contract_file IN LISTS generated_contract_files)
  if (EXISTS "${contract_file}" AND NOT IS_DIRECTORY "${contract_file}")
    file (READ "${contract_file}" contract_content)
    if (contract_file MATCHES "(^|/)CTestTestfile\\.cmake$")
      string (REGEX REPLACE " _BACKTRACE_TRIPLES \"[^\"]*\"" "" contract_content
        "${contract_content}"
      )
    elseif (contract_file MATCHES "(^|/)libhdf5\\.settings$")
      string (REGEX REPLACE "Configured on: [^\r\n]*" "Configured on: <DATE>" contract_content
        "${contract_content}"
      )
    endif ()
    _hdf5_contract_normalize ("${contract_content}" normalized_content)
    string (SHA256 content_hash "${normalized_content}")
    _hdf5_contract_append ("text-file|${contract_file}|sha256=${content_hash}")
  endif ()
endforeach ()

list (SORT contract_records)
list (REMOVE_DUPLICATES contract_records)
list (JOIN contract_records "\n" contract_content)
get_filename_component (output_dir "${output_file}" DIRECTORY)
file (MAKE_DIRECTORY "${output_dir}")
file (WRITE "${output_file}" "${contract_content}\n")
list (LENGTH contract_records contract_record_count)
message (STATUS "Wrote ${contract_record_count} normalized build contract records to ${output_file}")
