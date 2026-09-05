cmake_minimum_required (VERSION 4.0)
project(H5_API_TEST_DRIVER CXX)

include (${CMAKE_CURRENT_LIST_DIR}/../../../config/cmake/HDF5PlatformSupport.cmake)
hdf5_validate_platform_support (LANGUAGES CXX)

if (NOT KWSYS_USE_LOCALCONTENT)
  set (KWSYS_URL ${KWSYS_TGZ_ORIGPATH}/${KWSYS_TGZ_NAME})
else ()
  set (KWSYS_URL ${TGZPATH}/${KWSYS_TGZ_NAME})
endif ()
# Only tgz files
FetchContent_Declare (KWSYS
    URL ${KWSYS_URL}
    URL_HASH ""
)
FetchContent_GetProperties(KWSYS)
if(NOT kwsys_POPULATED)
  set(CMAKE_CXX_STANDARD 11)

  set(KWSYS_NAMESPACE h5_api_test_sys)
  set(KWSYS_USE_SystemTools 1)
  set(KWSYS_USE_Process 1)
  set(KWSYS_USE_RegularExpression 1)
endif()
FetchContent_MakeAvailable(KWSYS)

add_executable(h5_api_test_driver h5_api_test_driver.cpp)
target_include_directories(h5_api_test_driver
    PRIVATE
      "${HDF5_SRC_INCLUDE_DIRS}"
      "${HDF5_SRC_BINARY_DIR}"
      "${HDF5_TEST_BINARY_DIR}"
      "${kwsys_BINARY_DIR}"
)
if (COMMAND hdf5_target_use_platform)
  hdf5_target_use_platform (h5_api_test_driver)
endif ()
target_link_libraries(h5_api_test_driver h5_api_test_sys)

if (BUILD_TESTING)
  add_executable (h5_api_test_driver_process h5_api_test_driver_process.cpp)
  target_compile_features (h5_api_test_driver_process PRIVATE cxx_std_11)
  if (COMMAND hdf5_target_use_platform)
    hdf5_target_use_platform (h5_api_test_driver_process)
  endif ()
  set_target_properties (h5_api_test_driver_process PROPERTIES FOLDER test/API)

  function (add_h5_api_driver_process_test test_name test_case)
    add_test (
        NAME ${test_name}
        COMMAND ${CMAKE_COMMAND}
            "-DTEST_CASE=${test_case}"
            "-DTEST_DRIVER=$<TARGET_FILE:h5_api_test_driver>"
            "-DTEST_HELPER=$<TARGET_FILE:h5_api_test_driver_process>"
            "-DTEST_MISSING=$<TARGET_FILE_DIR:h5_api_test_driver_process>/h5_api_test_driver_missing${CMAKE_EXECUTABLE_SUFFIX}"
            "-DTEST_PID_FILE=$<TARGET_FILE_DIR:h5_api_test_driver_process>/h5_api_test_driver_timeout.pid"
            "-DTEST_SERVER_PID_FILE=$<TARGET_FILE_DIR:h5_api_test_driver_process>/h5_api_test_driver_server.pid"
            -P "${CMAKE_CURRENT_SOURCE_DIR}/HDF5APIDriverProcessTests.cmake"
    )
    set_tests_properties (${test_name} PROPERTIES
        LABELS "HDF5_API;HDF5_API_DRIVER"
        TIMEOUT 20
    )
  endfunction ()

  add_h5_api_driver_process_test (H5API-driver-success success)
  add_h5_api_driver_process_test (H5API-driver-child-failure child-failure)
  add_h5_api_driver_process_test (H5API-driver-launch-failure launch-failure)
  add_h5_api_driver_process_test (H5API-driver-timeout-cleanup timeout-cleanup)
  add_h5_api_driver_process_test (H5API-driver-server-cleanup server-cleanup)
endif ()
