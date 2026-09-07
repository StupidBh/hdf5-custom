cmake_minimum_required (VERSION 4.0)

foreach (required_variable IN ITEMS
    HDF5_REMOVED_PRODUCT_TEST_BINARY_ROOT
    HDF5_REMOVED_PRODUCT_TEST_GENERATOR
    HDF5_REMOVED_PRODUCT_TEST_BUILD_PACKAGE_DIR
    HDF5_REMOVED_PRODUCT_TEST_INSTALL_PACKAGE_DIR
    HDF5_REMOVED_PRODUCT_TEST_BUILD_RUNTIME_DIR
    HDF5_REMOVED_PRODUCT_TEST_INSTALL_RUNTIME_DIR
)
  if (NOT DEFINED ${required_variable} OR "${${required_variable}}" STREQUAL "")
    message (FATAL_ERROR "Missing required test variable: ${required_variable}")
  endif ()
endforeach ()

cmake_path (GET CMAKE_CURRENT_LIST_DIR PARENT_PATH cmake_dir)
cmake_path (GET cmake_dir PARENT_PATH config_dir)
cmake_path (GET config_dir PARENT_PATH source_dir)
cmake_path (ABSOLUTE_PATH source_dir NORMALIZE OUTPUT_VARIABLE source_dir)
cmake_path (ABSOLUTE_PATH HDF5_REMOVED_PRODUCT_TEST_BINARY_ROOT NORMALIZE
  OUTPUT_VARIABLE binary_root
)
cmake_path (IS_PREFIX source_dir "${binary_root}" NORMALIZE binary_in_source)
if (binary_in_source)
  message (FATAL_ERROR "The removed-product test root must be outside the source tree")
endif ()

if (NOT DEFINED HDF5_REMOVED_PRODUCT_TEST_CONFIG)
  set (HDF5_REMOVED_PRODUCT_TEST_CONFIG Release)
endif ()

function (_hdf5_removed_product_generator_args output_variable)
  set (generator_args -G "${HDF5_REMOVED_PRODUCT_TEST_GENERATOR}")
  if (DEFINED HDF5_REMOVED_PRODUCT_TEST_GENERATOR_PLATFORM AND
      NOT HDF5_REMOVED_PRODUCT_TEST_GENERATOR_PLATFORM STREQUAL "")
    list (APPEND generator_args -A "${HDF5_REMOVED_PRODUCT_TEST_GENERATOR_PLATFORM}")
  endif ()
  if (DEFINED HDF5_REMOVED_PRODUCT_TEST_GENERATOR_TOOLSET AND
      NOT HDF5_REMOVED_PRODUCT_TEST_GENERATOR_TOOLSET STREQUAL "")
    list (APPEND generator_args -T "${HDF5_REMOVED_PRODUCT_TEST_GENERATOR_TOOLSET}")
  endif ()
  set (${output_variable} ${generator_args} PARENT_SCOPE)
endfunction ()

function (_hdf5_removed_product_expect_failure description expected_regex)
  execute_process (
    COMMAND ${ARGN}
    RESULT_VARIABLE result
    OUTPUT_VARIABLE output
    ERROR_VARIABLE error
  )
  string (CONCAT diagnostic "${output}" "${error}")
  string (REGEX REPLACE "[ \r\n\t]+" " " normalized_diagnostic "${diagnostic}")
  if (NOT result)
    message (FATAL_ERROR "${description} unexpectedly succeeded")
  elseif (NOT normalized_diagnostic MATCHES "${expected_regex}")
    message (FATAL_ERROR
      "${description} omitted the expected diagnostic '${expected_regex}':\n${diagnostic}"
    )
  endif ()
endfunction ()

_hdf5_removed_product_generator_args (generator_args)
file (REMOVE_RECURSE "${binary_root}")
file (MAKE_DIRECTORY "${binary_root}")

foreach (removed_option IN ITEMS HDF5_BUILD_CPP_LIB HDF5_BUILD_HL_LIB)
  _hdf5_removed_product_expect_failure (
    "Removed option ${removed_option}"
    "${removed_option} was removed with the native C\\+\\+ and high-level products"
    "${CMAKE_COMMAND}" -S "${source_dir}" -B "${binary_root}/option-${removed_option}"
    ${generator_args} -DBUILD_TESTING=OFF "-D${removed_option}=ON"
  )
endforeach ()

set (negative_source "${binary_root}/negative-component-source")
file (MAKE_DIRECTORY "${negative_source}")
file (WRITE "${negative_source}/CMakeLists.txt" [=[
cmake_minimum_required (VERSION 4.0)
project (HDF5RemovedComponent C)
find_package (HDF5 CONFIG REQUIRED COMPONENTS "${REMOVED_COMPONENT}")
]=])

foreach (package_dir IN ITEMS
    "${HDF5_REMOVED_PRODUCT_TEST_BUILD_PACKAGE_DIR}"
    "${HDF5_REMOVED_PRODUCT_TEST_INSTALL_PACKAGE_DIR}"
)
  foreach (removed_component IN ITEMS CXX HL CXX_HL)
    cmake_path (GET package_dir FILENAME package_dir_name)
    _hdf5_removed_product_expect_failure (
      "Removed component ${removed_component} from ${package_dir}"
      "Unsupported HDF5 component '${removed_component}'"
      "${CMAKE_COMMAND}" -S "${negative_source}"
      -B "${binary_root}/component-${package_dir_name}-${removed_component}"
      ${generator_args} "-DHDF5_DIR=${package_dir}"
      "-DREMOVED_COMPONENT=${removed_component}"
    )
  endforeach ()
endforeach ()

set (positive_source "${binary_root}/retained-consumer-source")
file (MAKE_DIRECTORY "${positive_source}")
file (WRITE "${positive_source}/main.c" [=[
#include <hdf5.h>

int
main(void)
{
    unsigned major;
    unsigned minor;
    unsigned release;

    return H5get_libversion(&major, &minor, &release) < 0;
}
]=])
file (WRITE "${positive_source}/CMakeLists.txt" [=[
cmake_minimum_required (VERSION 4.0)
project (HDF5RetainedConsumer C)
find_package (HDF5 CONFIG REQUIRED COMPONENTS C shared)

foreach (removed_target IN ITEMS
    hdf5_cpp-shared hdf5_cpp-static hdf5_hl-shared hdf5_hl-static
    hdf5_hl_cpp-shared hdf5_hl_cpp-static
)
  if (TARGET ${removed_target})
    message (FATAL_ERROR "Removed target remains available: ${removed_target}")
  endif ()
endforeach ()
foreach (removed_variable IN ITEMS
    HDF5_PROVIDES_CPP HDF5_PROVIDES_HL HDF5_BUILD_CPP_LIB HDF5_BUILD_HL_LIB
    HDF5_INCLUDE_DIR_CPP HDF5_INCLUDE_DIR_HL
)
  if (DEFINED ${removed_variable})
    message (FATAL_ERROR "Removed package variable remains defined: ${removed_variable}")
  endif ()
endforeach ()
if (NOT TARGET hdf5-shared)
  message (FATAL_ERROR "Retained hdf5-shared target is unavailable")
endif ()

add_executable (retained_consumer main.c)
target_link_libraries (retained_consumer PRIVATE hdf5-shared)
enable_testing ()
add_test (NAME retained-consumer COMMAND retained_consumer)
if (WIN32)
  set_tests_properties (retained-consumer PROPERTIES
    ENVIRONMENT_MODIFICATION "PATH=path_list_prepend:${HDF5_RUNTIME_DIR}"
  )
else ()
  set_tests_properties (retained-consumer PROPERTIES
    ENVIRONMENT_MODIFICATION "LD_LIBRARY_PATH=path_list_prepend:${HDF5_RUNTIME_DIR}"
  )
endif ()
]=])

foreach (package_dir IN ITEMS
    "${HDF5_REMOVED_PRODUCT_TEST_BUILD_PACKAGE_DIR}"
    "${HDF5_REMOVED_PRODUCT_TEST_INSTALL_PACKAGE_DIR}"
)
  cmake_path (GET package_dir FILENAME package_dir_name)
  if (package_dir STREQUAL HDF5_REMOVED_PRODUCT_TEST_BUILD_PACKAGE_DIR)
    set (runtime_dir "${HDF5_REMOVED_PRODUCT_TEST_BUILD_RUNTIME_DIR}")
  else ()
    set (runtime_dir "${HDF5_REMOVED_PRODUCT_TEST_INSTALL_RUNTIME_DIR}")
  endif ()
  set (consumer_build "${binary_root}/consumer-${package_dir_name}")
  execute_process (
    COMMAND "${CMAKE_COMMAND}" -S "${positive_source}" -B "${consumer_build}"
            ${generator_args} "-DHDF5_DIR=${package_dir}"
            "-DHDF5_RUNTIME_DIR=${runtime_dir}"
    RESULT_VARIABLE configure_result
    OUTPUT_VARIABLE configure_output
    ERROR_VARIABLE configure_error
  )
  if (configure_result)
    message (FATAL_ERROR
      "Retained consumer configure failed for ${package_dir}:\n${configure_output}${configure_error}"
    )
  endif ()
  execute_process (
    COMMAND "${CMAKE_COMMAND}" --build "${consumer_build}"
            --config "${HDF5_REMOVED_PRODUCT_TEST_CONFIG}" --parallel 4
    RESULT_VARIABLE build_result
    OUTPUT_VARIABLE build_output
    ERROR_VARIABLE build_error
  )
  if (build_result)
    message (FATAL_ERROR
      "Retained consumer build failed for ${package_dir}:\n${build_output}${build_error}"
    )
  endif ()
  execute_process (
    COMMAND "${CMAKE_CTEST_COMMAND}" --test-dir "${consumer_build}"
            -C "${HDF5_REMOVED_PRODUCT_TEST_CONFIG}" --output-on-failure
    RESULT_VARIABLE test_result
    OUTPUT_VARIABLE test_output
    ERROR_VARIABLE test_error
  )
  if (test_result)
    message (FATAL_ERROR
      "Retained consumer test failed for ${package_dir}:\n${test_output}${test_error}"
    )
  endif ()
endforeach ()

set (integration_source "${binary_root}/integration-consumer-source")
file (MAKE_DIRECTORY "${integration_source}")
file (WRITE "${integration_source}/main.c" [=[
#include <hdf5.h>

int
main(void)
{
    unsigned major;
    unsigned minor;
    unsigned release;

    return H5get_libversion(&major, &minor, &release) < 0;
}
]=])
file (WRITE "${integration_source}/CMakeLists.txt" [=[
cmake_minimum_required (VERSION 4.0)
project (HDF5IntegrationConsumer C)

set (BUILD_TESTING OFF CACHE BOOL "" FORCE)
set (BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set (BUILD_STATIC_LIBS ON CACHE BOOL "" FORCE)
set (HDF5_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set (HDF5_BUILD_TOOLS OFF CACHE BOOL "" FORCE)
set (HDF5_BUILD_UTILS OFF CACHE BOOL "" FORCE)

if (INTEGRATION_MODE STREQUAL "add-subdirectory")
  add_subdirectory ("${HDF5_SOURCE_TREE}" hdf5-build EXCLUDE_FROM_ALL)
elseif (INTEGRATION_MODE STREQUAL "fetch-content")
  include (FetchContent)
  FetchContent_Declare (local_hdf5 SOURCE_DIR "${HDF5_SOURCE_TREE}")
  FetchContent_MakeAvailable (local_hdf5)
else ()
  message (FATAL_ERROR "Unknown integration mode: ${INTEGRATION_MODE}")
endif ()

add_executable (integration_consumer main.c)
target_link_libraries (integration_consumer PRIVATE hdf5-static)
enable_testing ()
add_test (NAME integration-consumer COMMAND integration_consumer)
]=])

foreach (integration_mode IN ITEMS add-subdirectory fetch-content)
  set (integration_build "${binary_root}/integration-${integration_mode}")
  execute_process (
    COMMAND "${CMAKE_COMMAND}" -S "${integration_source}" -B "${integration_build}"
            ${generator_args} "-DHDF5_SOURCE_TREE=${source_dir}"
            "-DINTEGRATION_MODE=${integration_mode}"
    RESULT_VARIABLE configure_result
    OUTPUT_VARIABLE configure_output
    ERROR_VARIABLE configure_error
  )
  if (configure_result)
    message (FATAL_ERROR
      "${integration_mode} consumer configure failed:\n${configure_output}${configure_error}"
    )
  endif ()
  execute_process (
    COMMAND "${CMAKE_COMMAND}" --build "${integration_build}"
            --target integration_consumer
            --config "${HDF5_REMOVED_PRODUCT_TEST_CONFIG}" --parallel 4
    RESULT_VARIABLE build_result
    OUTPUT_VARIABLE build_output
    ERROR_VARIABLE build_error
  )
  if (build_result)
    message (FATAL_ERROR
      "${integration_mode} consumer build failed:\n${build_output}${build_error}"
    )
  endif ()
  execute_process (
    COMMAND "${CMAKE_CTEST_COMMAND}" --test-dir "${integration_build}"
            -C "${HDF5_REMOVED_PRODUCT_TEST_CONFIG}" --output-on-failure
    RESULT_VARIABLE test_result
    OUTPUT_VARIABLE test_output
    ERROR_VARIABLE test_error
  )
  if (test_result)
    message (FATAL_ERROR
      "${integration_mode} consumer test failed:\n${test_output}${test_error}"
    )
  endif ()
endforeach ()

if (DEFINED HDF5_REMOVED_PRODUCT_TEST_HIGHFIVE_INCLUDE_ROOT AND
    NOT HDF5_REMOVED_PRODUCT_TEST_HIGHFIVE_INCLUDE_ROOT STREQUAL "")
  set (highfive_source "${binary_root}/highfive-consumer-source")
  file (MAKE_DIRECTORY "${highfive_source}")
  file (WRITE "${highfive_source}/main.cpp" [=[
#include <highfive/H5File.hpp>

#include <vector>

int
main()
{
    const std::vector<int> expected{2, 3, 5, 7};
    HighFive::File file("highfive-contract.h5", HighFive::File::Overwrite);
    auto dataset = file.createDataSet<int>("values", HighFive::DataSpace::From(expected));
    dataset.write(expected);

    std::vector<int> actual;
    dataset.read(actual);
    return actual == expected ? 0 : 1;
}
]=])
  file (WRITE "${highfive_source}/CMakeLists.txt" [=[
cmake_minimum_required (VERSION 4.0)
project (HDF5HighFiveConsumer CXX)
find_package (HDF5 CONFIG REQUIRED COMPONENTS C shared)
if (NOT TARGET hdf5-shared)
  message (FATAL_ERROR "Retained hdf5-shared target is unavailable")
endif ()

add_executable (highfive_consumer main.cpp)
target_compile_features (highfive_consumer PRIVATE cxx_std_20)
target_include_directories (highfive_consumer PRIVATE "${HIGHFIVE_INCLUDE_ROOT}")
target_link_libraries (highfive_consumer PRIVATE hdf5-shared)
enable_testing ()
add_test (NAME highfive-consumer COMMAND highfive_consumer)
if (WIN32)
  set_tests_properties (highfive-consumer PROPERTIES
    ENVIRONMENT_MODIFICATION "PATH=path_list_prepend:${HDF5_RUNTIME_DIR}"
  )
else ()
  set_tests_properties (highfive-consumer PROPERTIES
    ENVIRONMENT_MODIFICATION "LD_LIBRARY_PATH=path_list_prepend:${HDF5_RUNTIME_DIR}"
  )
endif ()
]=])

  foreach (package_dir IN ITEMS
      "${HDF5_REMOVED_PRODUCT_TEST_BUILD_PACKAGE_DIR}"
      "${HDF5_REMOVED_PRODUCT_TEST_INSTALL_PACKAGE_DIR}"
  )
    cmake_path (GET package_dir FILENAME package_dir_name)
    if (package_dir STREQUAL HDF5_REMOVED_PRODUCT_TEST_BUILD_PACKAGE_DIR)
      set (runtime_dir "${HDF5_REMOVED_PRODUCT_TEST_BUILD_RUNTIME_DIR}")
    else ()
      set (runtime_dir "${HDF5_REMOVED_PRODUCT_TEST_INSTALL_RUNTIME_DIR}")
    endif ()
    set (highfive_build "${binary_root}/highfive-${package_dir_name}")
    execute_process (
      COMMAND "${CMAKE_COMMAND}" -S "${highfive_source}" -B "${highfive_build}"
              ${generator_args} "-DHDF5_DIR=${package_dir}"
              "-DHDF5_RUNTIME_DIR=${runtime_dir}"
              "-DHIGHFIVE_INCLUDE_ROOT=${HDF5_REMOVED_PRODUCT_TEST_HIGHFIVE_INCLUDE_ROOT}"
      RESULT_VARIABLE configure_result
      OUTPUT_VARIABLE configure_output
      ERROR_VARIABLE configure_error
    )
    if (configure_result)
      message (FATAL_ERROR
        "HighFive consumer configure failed for ${package_dir}:\n${configure_output}${configure_error}"
      )
    endif ()
    execute_process (
      COMMAND "${CMAKE_COMMAND}" --build "${highfive_build}"
              --config "${HDF5_REMOVED_PRODUCT_TEST_CONFIG}" --parallel 4
      RESULT_VARIABLE build_result
      OUTPUT_VARIABLE build_output
      ERROR_VARIABLE build_error
    )
    if (build_result)
      message (FATAL_ERROR
        "HighFive consumer build failed for ${package_dir}:\n${build_output}${build_error}"
      )
    endif ()
    execute_process (
      COMMAND "${CMAKE_CTEST_COMMAND}" --test-dir "${highfive_build}"
              -C "${HDF5_REMOVED_PRODUCT_TEST_CONFIG}" --output-on-failure
      RESULT_VARIABLE test_result
      OUTPUT_VARIABLE test_output
      ERROR_VARIABLE test_error
    )
    if (test_result)
      message (FATAL_ERROR
        "HighFive consumer test failed for ${package_dir}:\n${test_output}${test_error}"
      )
    endif ()
  endforeach ()
endif ()

foreach (product_root IN ITEMS
    "${HDF5_REMOVED_PRODUCT_TEST_BUILD_PACKAGE_DIR}"
    "${HDF5_REMOVED_PRODUCT_TEST_INSTALL_PACKAGE_DIR}"
)
  file (GLOB_RECURSE product_paths LIST_DIRECTORIES TRUE "${product_root}/*")
  foreach (product_path IN LISTS product_paths)
    if (product_path MATCHES
        "(^|[/\\\\])(H5Cpp[^/\\\\]*|h5c\\+\\+|h5watch|hdf5_(cpp|hl)(_|[.-]|$)|HDF5Examples[/\\\\]CXX|c\\+\\+)([/\\\\]|$)")
      message (FATAL_ERROR "Removed product artifact remains: ${product_path}")
    endif ()
  endforeach ()
  file (GLOB_RECURSE contract_files LIST_DIRECTORIES FALSE
    "${product_root}/*.cmake" "${product_root}/*.pc" "${product_root}/*.settings"
  )
  foreach (contract_file IN LISTS contract_files)
    file (READ "${contract_file}" contract_content)
    if (contract_content MATCHES
        "H5Cpp|hdf5_cpp|hdf5_hl|h5c\\+\\+|h5watch|HDF5_BUILD_CPP_LIB|HDF5_BUILD_HL_LIB")
      message (FATAL_ERROR "Removed product contract remains in ${contract_file}")
    endif ()
  endforeach ()
endforeach ()

message (STATUS "All removed-product and retained package consumer contracts passed")
