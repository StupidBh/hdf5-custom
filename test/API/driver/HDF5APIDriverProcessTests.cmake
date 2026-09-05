# Copyright by The HDF Group.
# All rights reserved.
#
# This file is part of HDF5.  The full HDF5 copyright notice, including
# terms governing use, modification, and redistribution, is contained in
# the LICENSE file, which can be found at the root of the source code
# distribution tree, or in https://www.hdfgroup.org/licenses.
# If you do not have access to either file, you may request a copy from
# help@hdfgroup.org.

cmake_minimum_required (VERSION 4.0)

foreach (required_variable IN ITEMS TEST_CASE TEST_DRIVER TEST_HELPER TEST_MISSING TEST_PID_FILE TEST_SERVER_PID_FILE)
  if (NOT DEFINED ${required_variable} OR "${${required_variable}}" STREQUAL "")
    message (FATAL_ERROR "${required_variable} is required")
  endif ()
endforeach ()

if (TEST_CASE STREQUAL "success")
  set (driver_arguments --client "${TEST_HELPER}" exit 0 --serial)
  set (expected_result 0)
  set (expected_output "client process exited with code 0")
elseif (TEST_CASE STREQUAL "child-failure")
  set (driver_arguments --client "${TEST_HELPER}" exit 7 --serial --allow-errors)
  set (expected_result 7)
  set (expected_output "client process exited with code 7")
elseif (TEST_CASE STREQUAL "launch-failure")
  set (driver_arguments --client "${TEST_MISSING}" --serial)
  set (expected_output "Error executing client process")
elseif (TEST_CASE STREQUAL "timeout-cleanup")
  file (REMOVE "${TEST_PID_FILE}")
  set (driver_arguments --client "${TEST_HELPER}" sleep 30000 "${TEST_PID_FILE}" --serial --timeout 1)
  set (expected_output "killed client process due to timeout")
  set (cleanup_pid_file "${TEST_PID_FILE}")
elseif (TEST_CASE STREQUAL "server-cleanup")
  file (REMOVE "${TEST_SERVER_PID_FILE}")
  set (driver_arguments
      --server "${TEST_HELPER}" server "${TEST_SERVER_PID_FILE}"
      --client "${TEST_HELPER}" exit 0
      --serial --allow-server-errors
  )
  set (expected_result 0)
  set (expected_output "server successfully started")
  set (cleanup_pid_file "${TEST_SERVER_PID_FILE}")
else ()
  message (FATAL_ERROR "Unknown TEST_CASE: ${TEST_CASE}")
endif ()

execute_process (
    COMMAND "${TEST_DRIVER}" ${driver_arguments}
    RESULT_VARIABLE driver_result
    OUTPUT_VARIABLE driver_stdout
    ERROR_VARIABLE driver_stderr
    TIMEOUT 12
)
set (driver_output "${driver_stdout}${driver_stderr}")

if (DEFINED cleanup_pid_file)
  execute_process (
      COMMAND "${TEST_HELPER}" verify-terminated "${cleanup_pid_file}"
      RESULT_VARIABLE cleanup_result
      OUTPUT_VARIABLE cleanup_stdout
      ERROR_VARIABLE cleanup_stderr
      TIMEOUT 8
  )
  file (REMOVE "${cleanup_pid_file}")
  if (NOT "${cleanup_result}" STREQUAL "0")
    message (FATAL_ERROR
        "A controlled process was not cleaned up by the driver.\n"
        "Driver output:\n${driver_output}\n"
        "Cleanup output:\n${cleanup_stdout}${cleanup_stderr}"
    )
  endif ()
endif ()

if (DEFINED expected_result)
  if (NOT "${driver_result}" STREQUAL "${expected_result}")
    message (FATAL_ERROR
        "Driver result ${driver_result} did not match ${expected_result}.\n${driver_output}"
    )
  endif ()
elseif ("${driver_result}" STREQUAL "0")
  message (FATAL_ERROR "Driver unexpectedly succeeded.\n${driver_output}")
endif ()

if (NOT driver_output MATCHES "${expected_output}")
  message (FATAL_ERROR
      "Driver output did not contain '${expected_output}'.\n${driver_output}"
  )
endif ()
