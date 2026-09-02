# Put all top-level build options into one place
# This file will be included at the beginning of the root CMakeLists.txt
option (HDF5_USE_FOLDERS "Enable folder grouping of projects in IDEs." ON)
mark_as_advanced (HDF5_USE_FOLDERS)

option (HDF5_NO_PACKAGES "CPACK - Disable packaging" OFF)
mark_as_advanced (HDF5_NO_PACKAGES)
option (HDF5_ALLOW_UNSUPPORTED "Allow unsupported combinations of configure options" OFF)
mark_as_advanced (HDF5_ALLOW_UNSUPPORTED)

option (HDF5_ONLY_SHARED_LIBS "Only Build Shared Libraries" OFF)
mark_as_advanced (HDF5_ONLY_SHARED_LIBS)
option (BUILD_STATIC_LIBS "Build Static Libraries" ON)
option (BUILD_SHARED_LIBS "Build Shared Libraries" ON)

set (HDF5_EXTERNAL_LIB_PREFIX "" CACHE STRING "Use prefix for custom library naming.")
mark_as_advanced (HDF5_EXTERNAL_LIB_PREFIX)
set (HDF5_LIB_INFIX "" CACHE STRING "Use infix for custom library naming.")
mark_as_advanced (HDF5_LIB_INFIX)
set (HDF5_EXTERNAL_LIB_SUFFIX "" CACHE STRING "Use suffix for custom library naming.")
mark_as_advanced (HDF5_EXTERNAL_LIB_SUFFIX)

option (HDF5_BUILD_STATIC_TOOLS "Build Static Tools NOT Shared Tools" OFF)
mark_as_advanced (HDF5_BUILD_STATIC_TOOLS)

function (hdf5_validate_library_options)
  set (H5_ENABLE_STATIC_LIB NO)
  set (H5_ENABLE_SHARED_LIB NO)

  # only shared libraries/tools is true if user forces static OFF
  if (NOT BUILD_STATIC_LIBS)
    set (HDF5_ONLY_SHARED_LIBS ON CACHE BOOL "Only Build Shared Libraries" FORCE)
  endif ()

  # only shared libraries is set ON by user then force settings
  if (HDF5_ONLY_SHARED_LIBS)
    set (H5_ENABLE_STATIC_LIB NO)
    set (BUILD_SHARED_LIBS ON CACHE BOOL "Build Shared Libraries" FORCE)
    set (BUILD_STATIC_LIBS OFF CACHE BOOL "Build Static Libraries" FORCE)
    if (HDF5_BUILD_STATIC_TOOLS)
      message (WARNING "Cannot build static tools without static libraries. Building shared tools.")
    endif ()
    set (HDF5_BUILD_STATIC_TOOLS OFF CACHE BOOL "Build Static Tools NOT Shared Tools" FORCE)
  endif ()

  if (NOT BUILD_SHARED_LIBS AND NOT HDF5_BUILD_STATIC_TOOLS)
    message (VERBOSE "Cannot build shared tools without shared libraries. Building static tools.")
    set (HDF5_BUILD_STATIC_TOOLS ON CACHE BOOL "Build Static Tools NOT Shared Tools" FORCE)
  endif ()

  if (BUILD_STATIC_LIBS)
    set (H5_ENABLE_STATIC_LIB YES)
  endif ()
  if (BUILD_SHARED_LIBS)
    set (H5_ENABLE_SHARED_LIB YES)
  endif ()

  return (PROPAGATE H5_ENABLE_STATIC_LIB H5_ENABLE_SHARED_LIB)
endfunction ()

option (BUILD_STATIC_EXECS "Build Static Executables" OFF)
mark_as_advanced (BUILD_STATIC_EXECS)

option (HDF5_ENABLE_ANALYZER_TOOLS "enable the use of Clang tools" OFF)
mark_as_advanced (HDF5_ENABLE_ANALYZER_TOOLS)
option (HDF5_ENABLE_SANITIZERS "execute the Clang sanitizer" OFF)
mark_as_advanced (HDF5_ENABLE_SANITIZERS)
option (HDF5_ENABLE_FORMATTERS "format source files" OFF)
mark_as_advanced (HDF5_ENABLE_FORMATTERS)

option (HDF5_ENABLE_COVERAGE "Enable code coverage for Libraries and Programs" OFF)
mark_as_advanced (HDF5_ENABLE_COVERAGE)

option (HDF5_ENABLE_USING_MEMCHECKER "Indicate that a memory checker is used" OFF)
mark_as_advanced (HDF5_ENABLE_USING_MEMCHECKER)

option (HDF5_ENABLE_PREADWRITE "Use pread/pwrite in sec2/log/core VFDs in place of read/write (when available)" ON)
mark_as_advanced (HDF5_ENABLE_PREADWRITE)

option (HDF5_ENABLE_DEPRECATED_SYMBOLS "Enable deprecated public API symbols" ON)
mark_as_advanced (HDF5_ENABLE_DEPRECATED_SYMBOLS)

option (HDF5_MINGW_STATIC_GCC_LIBS "Statically link libgcc/libstdc++" OFF)
mark_as_advanced (HDF5_MINGW_STATIC_GCC_LIBS)

option (HDF5_ENABLE_TRACE "Enable API tracing capability" OFF)
mark_as_advanced (HDF5_ENABLE_TRACE)
if (HDF5_ENABLE_TRACE)
  message (DEPRECATION "HDF5_ENABLE_TRACE has been deprecated and may be removed in a future release of HDF5")
endif ()

option (HDF5_ENABLE_EMBEDDED_LIBINFO "Embed library info into executables" OFF)
mark_as_advanced (HDF5_ENABLE_EMBEDDED_LIBINFO)
if (HDF5_ENABLE_EMBEDDED_LIBINFO)
  message (DEPRECATION "HDF5_ENABLE_EMBEDDED_LIBINFO has been deprecated and may be removed in a future release of HDF5")
endif ()


option (HDF5_ENABLE_HDFS "Enable HDFS" OFF)

option (HDF5_ENABLE_PARALLEL "Enable parallel build (requires MPI)" OFF)
cmake_dependent_option (HDF5_ENABLE_SUBFILING_VFD
  "Build Parallel HDF5 Subfiling VFD"
  OFF "HDF5_ENABLE_PARALLEL;NOT WIN32" OFF
)

option (HDF5_ENABLE_SZIP_SUPPORT "Use SZip Filter" OFF)
option (HDF5_ENABLE_ZLIB_SUPPORT "Enable Zlib Filters" OFF)

option (HDF5_PACKAGE_EXTLIBS "CPACK - include external libraries" OFF)
mark_as_advanced (HDF5_PACKAGE_EXTLIBS)

option (HDF5_ENABLE_THREADSAFE "Enable thread-safety" OFF)

option (HDF5_ENABLE_CONCURRENCY "Enable multi-threaded concurrency" OFF)

option (HDF5_ENABLE_MAP_API "Build the map API" OFF)
mark_as_advanced (HDF5_ENABLE_MAP_API)

option (HDF5_BUILD_DOC "Build documentation" OFF)

option (HDF5_BUILD_PARALLEL_TOOLS "Build MPI-enabled HDF5 tools" OFF)
mark_as_advanced (HDF5_BUILD_PARALLEL_TOOLS)

option (HDF5_BUILD_TOOLS "Build HDF5 Tools" ON)

option (HDF5_ENABLE_PLUGIN_SUPPORT "Enable PLUGIN Filters" OFF)
mark_as_advanced (HDF5_ENABLE_PLUGIN_SUPPORT)

option (HDF5_REQUIRE_SIGNED_PLUGINS "Require digitally signed plugins" OFF)
cmake_dependent_option (HDF5_LOCK_PLUGIN_KEYSTORE
  "Disable HDF5_PLUGIN_KEYSTORE environment variable override (security hardening)"
  OFF "HDF5_REQUIRE_SIGNED_PLUGINS" OFF
)
mark_as_advanced (HDF5_LOCK_PLUGIN_KEYSTORE)

option (HDF5_BUILD_HL_LIB "Build HIGH Level HDF5 Library" ON)

option (HDF5_BUILD_CPP_LIB "Build HDF5 C++ Library" OFF)

option (HDF5_BUILD_EXAMPLES "Build HDF5 Library Examples" ON)

option (BUILD_TESTING "Build HDF5 Unit Testing" ON)

#################################
# Options with multiple choices #
#################################
set (allow_external_support_types "NO" "GIT" "TGZ")
set (HDF5_ALLOW_EXTERNAL_SUPPORT "NO" CACHE STRING "If not set to NO, specifies where to obtain sources when building or using external libraries (NO GIT TGZ)")
set_property (CACHE HDF5_ALLOW_EXTERNAL_SUPPORT PROPERTY STRINGS ${allow_external_support_types})
if (NOT "${HDF5_ALLOW_EXTERNAL_SUPPORT}" IN_LIST allow_external_support_types)
  message (FATAL_ERROR "HDF5_ALLOW_EXTERNAL_SUPPORT must be set to one of ${allow_external_support_types}")
endif ()
