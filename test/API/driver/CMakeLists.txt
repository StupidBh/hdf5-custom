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
target_include_directories(h5_api_test_driver PRIVATE "${kwsys_BINARY_DIR}")
if (COMMAND hdf5_target_use_platform)
  hdf5_target_use_platform (h5_api_test_driver)
endif ()
target_link_libraries(h5_api_test_driver h5_api_test_sys)
