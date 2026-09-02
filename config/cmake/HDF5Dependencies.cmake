#
# Copyright by The HDF Group.
# All rights reserved.
#
# This file is part of HDF5. The full HDF5 copyright notice, including
# terms governing use, modification, and redistribution, is contained in
# the LICENSE file, which can be found at the root of the source code
# distribution tree, or in https://www.hdfgroup.org/licenses.
#

include_guard (GLOBAL)

function (hdf5_configure_dependencies system_libraries compression_libraries public_libraries)
  set_property (TARGET hdf5_dependencies PROPERTY HDF5_SYSTEM_LINK_LIBRARIES
      "${system_libraries}"
  )
  set_property (TARGET hdf5_dependencies PROPERTY HDF5_COMPRESSION_LINK_LIBRARIES
      "${compression_libraries}"
  )
  set_property (TARGET hdf5_dependencies PROPERTY HDF5_PUBLIC_LINK_LIBRARIES
      "${public_libraries}"
  )
endfunction ()

function (hdf5_target_link_dependencies target)
  get_property (system_libraries TARGET hdf5_dependencies
      PROPERTY HDF5_SYSTEM_LINK_LIBRARIES
  )
  get_property (compression_libraries TARGET hdf5_dependencies
      PROPERTY HDF5_COMPRESSION_LINK_LIBRARIES
  )
  get_property (public_libraries TARGET hdf5_dependencies
      PROPERTY HDF5_PUBLIC_LINK_LIBRARIES
  )

  if (system_libraries OR compression_libraries)
    target_link_libraries (${target} PRIVATE ${system_libraries} ${compression_libraries})
  endif ()
  if (public_libraries)
    target_link_libraries (${target} PUBLIC ${public_libraries})
  endif ()
endfunction ()

function (hdf5_target_link_system_dependencies target visibility)
  if (NOT visibility MATCHES "^(PRIVATE|PUBLIC|INTERFACE)$")
    message (FATAL_ERROR "Invalid dependency visibility for ${target}: ${visibility}")
  endif ()

  get_property (system_libraries TARGET hdf5_dependencies
      PROPERTY HDF5_SYSTEM_LINK_LIBRARIES
  )
  if (system_libraries)
    target_link_libraries (${target} ${visibility} ${system_libraries})
  endif ()
endfunction ()

function (hdf5_target_link_compression_dependencies target visibility)
  if (NOT visibility MATCHES "^(PRIVATE|PUBLIC|INTERFACE)$")
    message (FATAL_ERROR "Invalid dependency visibility for ${target}: ${visibility}")
  endif ()

  get_property (compression_libraries TARGET hdf5_dependencies
      PROPERTY HDF5_COMPRESSION_LINK_LIBRARIES
  )
  if (compression_libraries)
    target_link_libraries (${target} ${visibility} ${compression_libraries})
  endif ()
endfunction ()

# Compression setup must run after UserMacros.cmake has applied any dependency
# overrides. A macro retains the root directory's generated-header variables.
macro (hdf5_configure_compression_dependencies)
  unset (SETTINGS_EXTERNAL_FILTERS)
  include (${HDF_CONFIG_DIR}/HDF5UseZLIB.cmake)
  include (${HDF_CONFIG_DIR}/HDF5UseLibaec.cmake)

  # Process the filter list for libhdf5.settings and H5build_settings.
  list (REMOVE_DUPLICATES SETTINGS_EXTERNAL_FILTERS)
  string (REPLACE ";" " " SETTINGS_EXTERNAL_FILTERS "${SETTINGS_EXTERNAL_FILTERS}")

  message (VERBOSE "LINK_COMP_LIBS=${LINK_COMP_LIBS}")
  hdf5_configure_dependencies (
      "${LINK_LIBS}"
      "${LINK_COMP_LIBS}"
      "${LINK_PUB_LIBS}"
  )
endmacro ()

macro (hdf5_configure_parallel_tool_dependencies)
  if (HDF5_BUILD_PARALLEL_TOOLS AND HDF5_ENABLE_PARALLEL)
    set (CMAKE_PREFIX_PATH "$HDF_RESOURCES_DIR")
    find_package (MFU REQUIRED)
    if (MFU_FOUND)
      message (VERBOSE "LL_PATH=${LL_PATH}")
      set (H5_HAVE_LIBMFU 1)
      set (H5_HAVE_MFU_H 1)
      set (CMAKE_REQUIRED_INCLUDES "${MFU_INCLUDE_DIR}")
      set (MFU_LIBRARY_DEBUG "$MFU_LIBRARY")
      set (MFU_LIBRARY_RELEASE "$MFU_LIBRARY")
    endif ()
    find_package (CIRCLE REQUIRED)
    if (CIRCLE_FOUND)
      set (H5_HAVE_LIBCIRCLE 1)
      set (H5_HAVE_CIRCLE_H 1)
      set (CMAKE_REQUIRED_INCLUDES "${CIRCLE_INCLUDE_DIR}")
    endif ()
    find_package (DTCMP REQUIRED)
    if (DTCMP_FOUND)
      set (H5_HAVE_LIBDTCMP 1)
      set (H5_HAVE_DTCMP_H 1)
      set (CMAKE_REQUIRED_INCLUDES "${DTCMP_INCLUDE_DIR}")
    endif ()
  endif ()
endmacro ()

#-----------------------------------------------------------------------------
# Option to Enable HDFS
#-----------------------------------------------------------------------------
if (HDF5_ENABLE_HDFS)
  find_package (JNI REQUIRED)
  if (JNI_FOUND)
    set (H5_HAVE_LIBJVM 1)
  endif ()
  find_package (HDFS REQUIRED)
  if (HDFS_FOUND)
    set (H5_HAVE_LIBHDFS 1)
    set (H5_HAVE_HDFS_H 1)
    if (NOT MSVC)
      list (APPEND LINK_LIBS -pthread)
    endif ()
  else ()
    set (HDF5_ENABLE_HDFS OFF CACHE BOOL "Enable HDFS" FORCE)
    message (FATAL_ERROR "Set to use libhdfs library, but could not find or use libhdfs. Please verify that the path to HADOOP_HOME is valid, and/or reconfigure without HDF5_ENABLE_HDFS")
  endif ()
endif ()

#-----------------------------------------------------------------------------
# Option to Require Digitally Signed plugins
#-----------------------------------------------------------------------------
if (HDF5_REQUIRE_SIGNED_PLUGINS)
  # KeyStore directory for multiple trusted public keys
  set(HDF5_PLUGIN_KEYSTORE_DIR "" CACHE PATH
      "Directory containing trusted public keys (.pem files) for plugin verification")
  # Find OpenSSL for RSA signature verification
  find_package(OpenSSL REQUIRED)
  if (NOT OPENSSL_FOUND)
    message(FATAL_ERROR "OpenSSL is required for HDF5_REQUIRE_SIGNED_PLUGINS but was not found")
  endif ()

  # Check minimum OpenSSL version
  # The signature verification implementation uses modern EVP API (EVP_DigestVerifyInit,
  # EVP_DigestVerifyUpdate, EVP_DigestVerifyFinal) which requires OpenSSL 1.1.0+
  if (OPENSSL_VERSION VERSION_LESS "1.1.0")
    message(FATAL_ERROR
      "OpenSSL 1.1.0 or later is required for HDF5_REQUIRE_SIGNED_PLUGINS\n"
      "  Found: OpenSSL ${OPENSSL_VERSION}\n"
      "  Required: OpenSSL 1.1.0 or later\n"
      "\n"
      "The signature verification implementation uses modern EVP API which is not\n"
      "available in OpenSSL 1.0.2 and earlier versions.\n"
      "\n"
      "Solutions:\n"
      "  1. Upgrade to OpenSSL 3.0 or later (recommended)\n"
      "     - OpenSSL 3.0 is LTS (supported until 2026-09-07)\n"
      "     - OpenSSL 3.4+ is also supported\n"
      "  2. Use LibreSSL 2.7.0 or later (compatible alternative)\n"
      "  3. Disable signed plugins: -DHDF5_REQUIRE_SIGNED_PLUGINS=OFF\n"
      "\n"
      "Note: OpenSSL 1.0.2 reached end-of-life in December 2019\n"
      "      CentOS 7 users should install openssl11 package")
  endif ()

  # Informational message for OpenSSL 3.0+ (APIs are compatible, not deprecated)
  if (OPENSSL_VERSION VERSION_GREATER_EQUAL "3.0.0")
    message(STATUS "OpenSSL 3.0+ detected - all EVP_* APIs are compatible (not deprecated)")
  endif ()

  # KeyStore directory is optional at build time; the HDF5_PLUGIN_KEYSTORE
  # environment variable can be used at runtime instead.  Require a compile-time
  # directory only when the environment variable override is locked out.
  if (HDF5_LOCK_PLUGIN_KEYSTORE AND NOT HDF5_PLUGIN_KEYSTORE_DIR)
    message(FATAL_ERROR
      "HDF5_LOCK_PLUGIN_KEYSTORE=ON requires a compile-time KeyStore directory:\n"
      "  -DHDF5_PLUGIN_KEYSTORE_DIR=/etc/hdf5/trusted_keys")
  endif ()

  # Configure KeyStore directory if provided.
  # Note: the path is embedded as a string literal in the library binary.
  # Use the HDF5_PLUGIN_KEYSTORE environment variable instead if the path
  # should not be visible in the binary.
  if (HDF5_PLUGIN_KEYSTORE_DIR)
    add_compile_definitions(H5PL_KEYSTORE_DIR="${HDF5_PLUGIN_KEYSTORE_DIR}")
  else ()
    message(NOTICE "No compile-time KeyStore directory configured; "
      "set HDF5_PLUGIN_KEYSTORE environment variable at runtime.")
  endif ()

  # Enable digital signature verification (goes into H5pubconf.h)
  set(H5_REQUIRE_DIGITAL_SIGNATURE 1)

  # Security: Disable environment variable override if requested
  if (HDF5_LOCK_PLUGIN_KEYSTORE)
    add_compile_definitions(H5PL_DISABLE_ENV_KEYSTORE)
    message(VERBOSE "HDF5_PLUGIN_KEYSTORE environment variable override: DISABLED (security hardening)")
  endif ()

  # Add OpenSSL to link libraries for the HDF5 library
  # Only libcrypto is needed (EVP, PEM, BIO, ERR APIs); libssl (TLS) is not used
  list(APPEND LINK_LIBS OpenSSL::Crypto)

  message(VERBOSE "Digital signature verification enabled (OpenSSL ${OPENSSL_VERSION})")
endif ()

#-----------------------------------------------------------------------------
# Option to Enable MPI Parallel
#-----------------------------------------------------------------------------
if (HDF5_ENABLE_PARALLEL)
  find_package (MPI REQUIRED COMPONENTS C)
  set (H5_HAVE_PARALLEL 1)

  # Require MPI standard 3.0 and greater
  if (MPI_VERSION LESS 3)
    message (FATAL_ERROR "HDF5 requires MPI standard 3.0 or greater")
  endif ()

  set (CMAKE_REQUIRED_LIBRARIES "${MPI_C_LIBRARIES}")
  set (CMAKE_REQUIRED_INCLUDES "${MPI_C_INCLUDE_DIRS}")
  # Used by Parallel Compression feature
  set (PARALLEL_FILTERED_WRITES ON)
  CHECK_SYMBOL_EXISTS (MPI_Ibarrier "mpi.h" H5_HAVE_MPI_Ibarrier)
  CHECK_SYMBOL_EXISTS (MPI_Issend "mpi.h" H5_HAVE_MPI_Issend)
  CHECK_SYMBOL_EXISTS (MPI_Iprobe "mpi.h" H5_HAVE_MPI_Iprobe)
  CHECK_SYMBOL_EXISTS (MPI_Irecv "mpi.h" H5_HAVE_MPI_Irecv)
  if (H5_HAVE_MPI_Ibarrier AND H5_HAVE_MPI_Issend AND H5_HAVE_MPI_Iprobe AND H5_HAVE_MPI_Irecv)
    set (H5_HAVE_PARALLEL_FILTERED_WRITES 1)
  else ()
    message (WARNING "The MPI_Ibarrier/MPI_Issend/MPI_Iprobe/MPI_Irecv functions could not be located.
             Parallel writes of filtered data will be disabled.")
    set (PARALLEL_FILTERED_WRITES OFF)
  endif ()

  # Used by big I/O feature
  set (LARGE_PARALLEL_IO ON)
  CHECK_SYMBOL_EXISTS (MPI_Get_elements_x "mpi.h" H5_HAVE_MPI_Get_elements_x)
  CHECK_SYMBOL_EXISTS (MPI_Type_size_x "mpi.h" H5_HAVE_MPI_Type_size_x)
  if (NOT H5_HAVE_MPI_Get_elements_x OR NOT H5_HAVE_MPI_Type_size_x)
    message (WARNING "The MPI_Get_elements_x and/or MPI_Type_size_x functions could not be located.
             Reading/Writing >2GB of data in a single parallel I/O operation will be disabled.")
    set (LARGE_PARALLEL_IO OFF)
  endif ()

  # Used by Subfiling VFD feature
  CHECK_SYMBOL_EXISTS (MPI_Comm_split_type "mpi.h" H5_HAVE_MPI_Comm_split_type)
endif ()

# Parallel IO usage requires MPI to be Linked and Included
if (H5_HAVE_PARALLEL)
  list (APPEND LINK_PUB_LIBS MPI::MPI_C)
  if (MPI_C_LINK_FLAGS)
    set (CMAKE_EXE_LINKER_FLAGS "${MPI_C_LINK_FLAGS} ${CMAKE_EXE_LINKER_FLAGS}")
  endif ()
endif ()

# Determine if a threading package is available on this system
set (THREADS_PREFER_PTHREAD_FLAG ON)
find_package (Threads)
if (Threads_FOUND)
  set (H5_HAVE_THREADS 1)
  set (CMAKE_REQUIRED_LIBRARIES ${CMAKE_THREAD_LIBS_INIT})

  # Determine which threading package to use
  # Comment out check for C11 threads for now, since it conflicts with the
  # current --std=c99 compile flags at configuration time.  When we switch to
  # --std=c11, this can be uncommented.
  #CHECK_INCLUDE_FILE("threads.h" HAVE_THREADS_H)
  if (WIN32)
    # When Win32 is available, we use those threads
    set (H5_HAVE_WIN_THREADS 1)
  elseif (HAVE_THREADS_H)
    # When C11 threads are available, those are the top choice
    set (H5_HAVE_C11_THREADS 1)
  elseif (CMAKE_USE_PTHREADS_INIT)
    set (H5_HAVE_PTHREAD_H 1)
  else ()
    message (FATAL_ERROR " **** thread support requires C11 threads, Win32 threads or Pthreads **** ")
  endif ()
  set (HDF5_THREADS_ENABLED ON) # Used to init hdf5-config.cmake
  list (APPEND LINK_LIBS Threads::Threads)

  # Check for compiler support for atomic variables
  CHECK_INCLUDE_FILE("stdatomic.h" HAVE_STDATOMIC_H)
  if (HAVE_STDATOMIC_H)
    set (H5_HAVE_STDATOMIC_H 1)
  endif()
else ()
  set (HDF5_THREADS_ENABLED OFF) # Used to init hdf5-config.cmake
endif ()

# Determine whether to build the HDF5 Subfiling VFD
set (H5FD_SUBFILING_DIR ${HDF5_SRC_DIR}/H5FDsubfiling)
set (HDF5_SRC_INCLUDE_DIRS
    ${HDF5_SRC_INCLUDE_DIRS}
    ${H5FD_SUBFILING_DIR}
)

if (HDF5_ENABLE_SUBFILING_VFD)
  # Make sure we found MPI_Comm_split_type previously
  if (NOT H5_HAVE_MPI_Comm_split_type)
    message (FATAL_ERROR "Subfiling VFD requires MPI-3 support for MPI_Comm_split_type")
  endif ()

  # Subfiling requires thread operations
  if (NOT Threads_FOUND)
    message (FATAL_ERROR "Subfiling requires thread operations support")
  endif ()

  set (H5_HAVE_SUBFILING_VFD 1)
  # IOC VFD is currently only built when subfiling is enabled
  set (H5_HAVE_IOC_VFD 1)
endif()
