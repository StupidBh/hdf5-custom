cmake_minimum_required (VERSION 4.0)
project (HDFCXX_EXAMPLES CXX)

include (${CMAKE_CURRENT_LIST_DIR}/../config/cmake/HDF5PlatformSupport.cmake)
hdf5_validate_platform_support (LANGUAGES CXX)

add_subdirectory (H5D)
add_subdirectory (TUTR)

#-- Add High Level Examples
if (H5EXAMPLE_BUILD_HL AND HDF5_PROVIDES_HL_LIB)
  add_subdirectory (HL)
endif ()
