foreach (inherited_property IN ITEMS
    CMAKE_C_STANDARD
    CMAKE_C_STANDARD_REQUIRED
    CMAKE_C_EXTENSIONS
    CMAKE_CXX_STANDARD
    CMAKE_CXX_STANDARD_REQUIRED
    CMAKE_CXX_EXTENSIONS
)
  if (NOT "${${inherited_property}}" STREQUAL "")
    message (FATAL_ERROR
      "Dependency inherited ${inherited_property}=${${inherited_property}} from HDF5"
    )
  endif ()
endforeach ()

add_library (dependency_default STATIC dependency.c)
add_library (dependency_cxx_default STATIC dependency.cpp)

set (CMAKE_C_STANDARD 11)
set (CMAKE_C_STANDARD_REQUIRED TRUE)
set (CMAKE_C_EXTENSIONS OFF)
set (CMAKE_CXX_STANDARD 11)
set (CMAKE_CXX_STANDARD_REQUIRED TRUE)
set (CMAKE_CXX_EXTENSIONS OFF)
add_library (dependency_declared STATIC dependency.c)
add_library (dependency_cxx_declared STATIC dependency.cpp)
