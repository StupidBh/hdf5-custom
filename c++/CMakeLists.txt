cmake_minimum_required (VERSION 4.0)
project (HDF5_CPP CXX)

include (${CMAKE_CURRENT_LIST_DIR}/../config/cmake/HDF5PlatformSupport.cmake)
hdf5_validate_platform_support (LANGUAGES CXX)

add_subdirectory (src)

#-----------------------------------------------------------------------------
# Build the CPP unit tests
#-----------------------------------------------------------------------------
if (NOT HDF5_EXTERNALLY_CONFIGURED AND BUILD_TESTING)
  add_subdirectory (test)
endif ()
