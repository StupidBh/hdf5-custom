foreach (inherited_property IN ITEMS
    CMAKE_C_STANDARD
    CMAKE_C_STANDARD_REQUIRED
    CMAKE_C_EXTENSIONS
)
  if (NOT "${${inherited_property}}" STREQUAL "")
    message (FATAL_ERROR
      "Dependency inherited ${inherited_property}=${${inherited_property}} from HDF5"
    )
  endif ()
endforeach ()

add_library (dependency_default STATIC dependency.c)

set (CMAKE_C_STANDARD 11)
set (CMAKE_C_STANDARD_REQUIRED TRUE)
set (CMAKE_C_EXTENSIONS OFF)
add_library (dependency_declared STATIC dependency.c)
