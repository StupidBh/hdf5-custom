cmake_minimum_required (VERSION 4.0)

cmake_path (GET CMAKE_CURRENT_LIST_DIR PARENT_PATH test_parent_dir)
set (policy_module "${test_parent_dir}/HDF5PlatformSupport.cmake")
set (case_script "${CMAKE_CURRENT_LIST_DIR}/HDF5PlatformSupportCase.cmake")
set (example_case_script "${CMAKE_CURRENT_LIST_DIR}/HDF5ExamplePlatformSupportCase.cmake")
set (supported_message
  "Supported HDF5 source-build compiler pairs are Windows with MSVC, or Linux with GNU."
)

function (run_policy_case
    name expected_result system processor generator generator_platform language compiler_id expected_field
)
  execute_process (
    COMMAND "${CMAKE_COMMAND}"
      "-DHDF5_PLATFORM_TEST_MODULE=${policy_module}"
      "-DHDF5_PLATFORM_TEST_SYSTEM=${system}"
      "-DHDF5_PLATFORM_TEST_PROCESSOR=${processor}"
      "-DHDF5_PLATFORM_TEST_GENERATOR=${generator}"
      "-DHDF5_PLATFORM_TEST_GENERATOR_PLATFORM=${generator_platform}"
      "-DHDF5_PLATFORM_TEST_LANGUAGE=${language}"
      "-DHDF5_PLATFORM_TEST_COMPILER_ID=${compiler_id}"
      -DHDF5_ALLOW_UNSUPPORTED=ON
      -P "${case_script}"
    RESULT_VARIABLE result
    OUTPUT_VARIABLE output
    ERROR_VARIABLE error
  )
  set (diagnostic "${output}${error}")
  string (REGEX REPLACE "[ \r\n\t]+" " " normalized_diagnostic "${diagnostic}")

  if (expected_result STREQUAL "PASS")
    if (result)
      message (FATAL_ERROR "Policy case ${name} unexpectedly failed:\n${diagnostic}")
    endif ()
  elseif (NOT result)
    message (FATAL_ERROR "Policy case ${name} unexpectedly passed")
  elseif (NOT normalized_diagnostic MATCHES "${supported_message}")
    message (FATAL_ERROR "Policy case ${name} omitted the supported matrix:\n${diagnostic}")
  elseif (NOT normalized_diagnostic MATCHES "${expected_field}")
    message (FATAL_ERROR "Policy case ${name} omitted rejected field '${expected_field}':\n${diagnostic}")
  endif ()
endfunction ()

function (run_example_case name expected_result system compiler_id)
  execute_process (
    COMMAND "${CMAKE_COMMAND}"
      "-DHDF5_PLATFORM_TEST_MODULE=${policy_module}"
      "-DHDF5_PLATFORM_TEST_SYSTEM=${system}"
      "-DHDF5_PLATFORM_TEST_COMPILER_ID=${compiler_id}"
      -P "${example_case_script}"
    RESULT_VARIABLE result
    OUTPUT_VARIABLE output
    ERROR_VARIABLE error
  )
  set (diagnostic "${output}${error}")
  string (REGEX REPLACE "[ \r\n\t]+" " " normalized_diagnostic "${diagnostic}")

  if (expected_result STREQUAL "PASS")
    if (result)
      message (FATAL_ERROR "Example entry case ${name} unexpectedly failed:\n${diagnostic}")
    endif ()
  elseif (NOT result)
    message (FATAL_ERROR "Example entry case ${name} unexpectedly passed")
  elseif (NOT normalized_diagnostic MATCHES "${supported_message}")
    message (FATAL_ERROR "Example entry case ${name} omitted the supported matrix:\n${diagnostic}")
  elseif (NOT normalized_diagnostic MATCHES "CXX compiler ID")
    message (FATAL_ERROR "Example entry case ${name} omitted the rejected CXX compiler:\n${diagnostic}")
  endif ()
endfunction ()

# These cases validate policy branching only. Generator and architecture
# variations prove that neither field is part of the admission firewall.
# Synthetic Linux cases are not native Linux configure, build, or test evidence.
run_policy_case (windows-c PASS Windows AMD64 "Visual Studio 18 2026" x64 C MSVC "")
run_policy_case (windows-cxx-default-platform PASS Windows AMD64 "Visual Studio 18 2026" "" CXX MSVC "")
run_policy_case (windows-ninja-arm64 PASS Windows ARM64 Ninja "" C MSVC "")
run_policy_case (windows-vs-win32 PASS Windows x86 "Visual Studio 18 2026" Win32 C MSVC "")
run_policy_case (linux-ninja-c PASS Linux x86_64 Ninja "" C GNU "")
run_policy_case (linux-make-cxx PASS Linux x86_64 "Unix Makefiles" "" CXX GNU "")
run_policy_case (linux-ninja-multi-aarch64 PASS Linux aarch64 "Ninja Multi-Config" "" C GNU "")

run_policy_case (unsupported-system FAIL Darwin arm64 Ninja "" C AppleClang "target system")
run_policy_case (windows-gnu FAIL Windows AMD64 "Visual Studio 18 2026" x64 C GNU "C compiler ID")
run_policy_case (windows-clang FAIL Windows AMD64 "Visual Studio 18 2026" x64 C Clang "C compiler ID")
run_policy_case (linux-clang FAIL Linux x86_64 Ninja "" C Clang "C compiler ID")
run_policy_case (linux-msvc FAIL Linux x86_64 Ninja "" C MSVC "C compiler ID")

# Exercise the combined standalone examples entry point, where BASIC_SETTINGS
# enables the optional C++ language after the initial C-only policy check.
run_example_case (windows-example-cxx PASS Windows MSVC)
run_example_case (windows-example-clang FAIL Windows Clang)
run_example_case (linux-example-cxx PASS Linux GNU)
run_example_case (linux-example-clang FAIL Linux Clang)

message (STATUS "All HDF5 platform-support policy cases passed")
