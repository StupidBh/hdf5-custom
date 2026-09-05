cmake_minimum_required (VERSION 4.0)
project (HDF5_C99_CONSUMER C)

set (CMAKE_C_STANDARD 99)
set (CMAKE_C_STANDARD_REQUIRED TRUE)
set (CMAKE_C_EXTENSIONS OFF)

find_package (hdf5 CONFIG REQUIRED COMPONENTS C shared)

add_executable (hdf5_c99_consumer main.c)
target_link_libraries (hdf5_c99_consumer PRIVATE hdf5-shared)
