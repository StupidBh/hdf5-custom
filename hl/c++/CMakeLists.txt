cmake_minimum_required (VERSION 4.0)
project (HDF5_HL_CPP CXX)

#-----------------------------------------------------------------------------
# Main HL lib is in /src
#-----------------------------------------------------------------------------
add_subdirectory (src)

# --------------------------------------------------------------------
# Add in the unit tests for the packet table c++ wrapper
# --------------------------------------------------------------------

if (BUILD_TESTING)
  add_subdirectory (test)
endif ()
