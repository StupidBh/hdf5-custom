cmake_minimum_required (VERSION 4.0)

cmake_path (GET CMAKE_CURRENT_LIST_DIR PARENT_PATH test_parent_dir)
set (policy_module "${test_parent_dir}/HDF5PlatformSupport.cmake")
set (case_script "${CMAKE_CURRENT_LIST_DIR}/HDF5PlatformSupportCase.cmake")
set (supported_message
  "Supported HDF5 source-build configurations are Windows x64 with MSVC and the Visual Studio 18 2026 generator, or Linux x86_64 with GNU and the Ninja or Unix Makefiles generator."
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

# The Linux cases validate policy branching only. They are not native Linux
# configure, build, or test evidence.
run_policy_case (windows-c PASS Windows AMD64 "Visual Studio 18 2026" x64 C MSVC "")
run_policy_case (windows-cxx PASS Windows AMD64 "Visual Studio 18 2026" x64 CXX MSVC "")
run_policy_case (linux-ninja-c PASS Linux x86_64 Ninja "" C GNU "")
run_policy_case (linux-make-cxx PASS Linux x86_64 "Unix Makefiles" "" CXX GNU "")

run_policy_case (unsupported-system FAIL Darwin arm64 Ninja "" C AppleClang "target system")
run_policy_case (windows-gnu FAIL Windows AMD64 "Visual Studio 18 2026" x64 C GNU "C compiler ID")
run_policy_case (windows-clang FAIL Windows AMD64 "Visual Studio 18 2026" x64 C Clang "C compiler ID")
run_policy_case (linux-clang FAIL Linux x86_64 Ninja "" C Clang "C compiler ID")
run_policy_case (windows-generator FAIL Windows AMD64 Ninja x64 C MSVC generator)
run_policy_case (linux-generator FAIL Linux x86_64 "Ninja Multi-Config" "" C GNU generator)
run_policy_case (windows-architecture FAIL Windows x86 "Visual Studio 18 2026" Win32 C MSVC "target architecture")
run_policy_case (linux-architecture FAIL Linux aarch64 Ninja "" C GNU "target architecture")

message (STATUS "All HDF5 platform-support policy cases passed")
