# Copyright by The HDF Group.
# All rights reserved.
#
# This file is part of HDF5. The full HDF5 copyright notice, including terms
# governing use, modification, and redistribution, is contained in the LICENSE
# file at the root of the source code distribution tree.

cmake_minimum_required (VERSION 4.0)

foreach (required_variable IN ITEMS TEST_PROGRAM TEST_SHELL TEST_PORT TEST_FOLDER)
  if (NOT DEFINED ${required_variable} OR "${${required_variable}}" STREQUAL "")
    message (FATAL_ERROR "Require ${required_variable} to be defined")
  endif ()
endforeach ()

if (NOT EXISTS "${TEST_PROGRAM}")
  message (FATAL_ERROR "Mirror server executable does not exist: ${TEST_PROGRAM}")
endif ()

file (MAKE_DIRECTORY "${TEST_FOLDER}")
set (server_log "${TEST_FOLDER}/mirror_server.log")
set (server_pid_file "${TEST_FOLDER}/mirror_server.pid")
file (REMOVE "${server_log}" "${server_pid_file}")

execute_process (
  COMMAND "${TEST_SHELL}" -c
    "\"$1\" \"--port=$2\" \"--logpath=$3\" >/dev/null 2>&1 & echo $!"
    hdf5-mirror-server "${TEST_PROGRAM}" "${TEST_PORT}" "${server_log}"
  WORKING_DIRECTORY "${TEST_FOLDER}"
  RESULT_VARIABLE launch_result
  OUTPUT_VARIABLE server_pid
  ERROR_VARIABLE launch_error
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
if (launch_result OR NOT server_pid MATCHES "^[0-9]+$")
  message (FATAL_ERROR "Unable to launch the mirror server: ${launch_error}")
endif ()

file (WRITE "${server_pid_file}" "${server_pid}\n")
execute_process (COMMAND "${CMAKE_COMMAND}" -E sleep 1)
execute_process (
  COMMAND "${TEST_SHELL}" -c "kill -0 \"$1\"" hdf5-mirror-server "${server_pid}"
  RESULT_VARIABLE server_status
  ERROR_VARIABLE status_error
)
if (server_status)
  if (EXISTS "${server_log}")
    file (READ "${server_log}" server_output)
  endif ()
  message (FATAL_ERROR "Mirror server exited during startup: ${status_error}\n${server_output}")
endif ()
