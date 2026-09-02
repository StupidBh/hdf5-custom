cmake_minimum_required (VERSION 4.0)
project(H5_API_TEST_DRIVER CXX)

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

include_directories(${kwsys_BINARY_DIR})

add_executable(h5_api_test_driver h5_api_test_driver.cpp)
target_link_libraries(h5_api_test_driver h5_api_test_sys)
