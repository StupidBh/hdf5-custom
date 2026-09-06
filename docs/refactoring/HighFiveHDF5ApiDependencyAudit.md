# HighFive HDF5 API Dependency Audit

State: Complete (snapshot audit only)

Last updated: 2026-09-06

## Decision and Scope

This document records which HDF5 interfaces are referenced by the workspace
`highfive/` header tree. It is an input to roadmap Stage 4, which will remove the
native HDF5 C++ and high-level products while retaining the core C interfaces
needed by the future HighFive consumer.

The workspace header copy is present but was untracked at audit time. This
audit does not wire it into CMake, install it, export it, package it, or make it
part of the current HDF5 product. A temporary external checkout was used only
as a read-only upstream comparison and is not a repository input.

## Audited Snapshot

| Field | Value |
| --- | --- |
| Workspace source | Untracked header-only tree at repository path `highfive/` |
| Declared version | 3.3.0 |
| Content-manifest SHA-256 | `25c7d5e69a69c446b8024941465449b51c9a62c2eb3ce2f981babd9fa6137910` |
| Upstream comparison | HighFive `main` commit `959ec30c5cee48ff4dbb458b9f233beded708a36` dated 2026-05-09 |
| Audited surface | `highfive/**/*.hpp` and `highfive/**/*.in` |
| Header count | 76 `.hpp` files plus 1 `.in` template |
| Method | Lexical symbol inventory followed by manual review of wrappers, function-pointer forwarding, feature guards, and CMake linkage |

The content-manifest digest is calculated from sorted relative paths and each
file's SHA-256 digest. The workspace tree matches the upstream comparison
snapshot except for four files: `H5PropertyList.hpp`,
`bits/h5p_wrapper.hpp`, `bits/H5PropertyList_misc.hpp`, and
`bits/H5Slice_traits_misc.hpp`. The first three remove the `FileLocking`
facility and its `H5Pset_file_locking` call; the fourth contains a one-character
error-message spacing change. Therefore the workspace tree, not the upstream
commit, is the authority for the 147-function table below. A future import must
repeat the audit against the exact selected content.

## Dependency Result

| Dependency surface | Result | Stage 4 consequence |
| --- | --- | --- |
| HDF5 core C API | Required; 147 distinct function symbols are referenced | Preserve these public C declarations and their providing core-library targets |
| HDF5 native C++ API (`c++/`, `H5Cpp.h`, `H5::`) | No dependency found | Native C++ products may be removed without replacing them for HighFive |
| HDF5 high-level API (`hl/`, `hdf5_hl.h`, `H5LT*`, `H5TB*`, and peers) | No dependency found | The complete HL product may be removed without replacing it for HighFive |
| HDF5 Map API (`H5M*`) | No direct HighFive dependency found | `map` remains a business-profile core feature, not a HighFive requirement |
| Parallel HDF5 | Conditional | Preserve parallel C APIs and MPI usage; HighFive links `MPI::MPI_C` and `MPI::MPI_CXX` when `HDF5_IS_PARALLEL` is true |
| Thread safety | No dedicated HighFive API call found | Thread safety is a selected HDF5 library mode, not a HighFive interface dependency |
| zlib/DEFLATE | Conditional through `H5Pset_deflate` and `H5Zfilter_avail` | Preserve core filter/property-list support and the selected dependency packaging |
| SZIP | Conditional through `H5Pset_szip` and `H5Zfilter_avail` | Preserve core filter/property-list support and the selected dependency packaging |
| HDF5 tools | No HighFive link dependency | Retain tools because they are part of the business profiles; remove `h5watch` because it belongs to HL |
| CMake consumption | Not present in this header-only workspace copy; upstream 3.3.0 uses `find_package(HDF5 REQUIRED)` and `HDF5::HDF5` | Do not integrate HighFive now; a future integration decision must define and test the package route |

HighFive is header-only, but that does not mean it is HDF5-header-only: its
inline implementation directly calls the HDF5 C library. It includes the
public HDF5 headers `H5Apublic.h`, `H5Dpublic.h`, `H5Epublic.h`, `H5Fpublic.h`,
`H5Gpublic.h`, `H5Ipublic.h`, `H5Lpublic.h`, `H5Opublic.h`, `H5Ppublic.h`,
`H5public.h`, `H5Rpublic.h`, `H5Spublic.h`, and `H5Tpublic.h`. Parallel builds
also include `H5FDmpi.h`.

## Function Dependency Table

The count includes calls compiled only under an HDF5 version or parallel
feature guard. It also includes seven property-list getter functions passed as
function pointers rather than called with direct call syntax.

All 147 identifiers were cross-checked against the current installed-public-
header closure and all were found. All 14 directly included HDF5 headers also
exist in the current `src/` tree; `H5Pget_dxpl_mpio` and `H5Zfilter_avail` are
reached through their normal public transitive includes. This proves source-
level declaration availability; it does not replace the future compile, link,
runtime, or package consumer gates.

| Package | Count | Referenced HDF5 C functions |
| --- | ---: | --- |
| General | 1 | `H5free_memory` |
| H5A | 13 | `H5Acreate2`, `H5Adelete`, `H5Aexists`, `H5Aget_create_plist`, `H5Aget_name`, `H5Aget_num_attrs`, `H5Aget_space`, `H5Aget_storage_size`, `H5Aget_type`, `H5Aiterate2`, `H5Aopen`, `H5Aread`, `H5Awrite` |
| H5D | 14 | `H5Dcreate2`, `H5Dflush`, `H5Dget_access_plist`, `H5Dget_create_plist`, `H5Dget_offset`, `H5Dget_space`, `H5Dget_storage_size`, `H5Dget_type`, `H5Dopen2`, `H5Dread`, `H5Drefresh`, `H5Dset_extent`, `H5Dvlen_reclaim`, `H5Dwrite` |
| H5E | 7 | `H5Eclear2`, `H5Eget_auto2`, `H5Eget_current_stack`, `H5Eget_major`, `H5Eget_minor`, `H5Eset_auto2`, `H5Ewalk2` |
| H5F | 9 | `H5Fcreate`, `H5Fflush`, `H5Fget_access_plist`, `H5Fget_create_plist`, `H5Fget_filesize`, `H5Fget_freespace`, `H5Fget_name`, `H5Fopen`, `H5Fstart_swmr_write` |
| H5G | 4 | `H5Gcreate2`, `H5Gget_create_plist`, `H5Gget_num_objs`, `H5Gopen2` |
| H5I | 6 | `H5Idec_ref`, `H5Iget_file_id`, `H5Iget_name`, `H5Iget_type`, `H5Iinc_ref`, `H5Iis_valid` |
| H5L | 9 | `H5Lcreate_external`, `H5Lcreate_hard`, `H5Lcreate_soft`, `H5Ldelete`, `H5Lexists`, `H5Lget_info`, `H5Lget_name_by_idx`, `H5Literate`, `H5Lmove` |
| H5O | 6 | `H5Oclose`, `H5Oget_info`, `H5Oget_info1`, `H5Oget_info2`, `H5Oget_info3`, `H5Oopen` |
| H5P | 36 | `H5Pcreate`, `H5Pget_all_coll_metadata_ops`, `H5Pget_alloc_time`, `H5Pget_attr_phase_change`, `H5Pget_chunk`, `H5Pget_chunk_cache`, `H5Pget_coll_metadata_write`, `H5Pget_create_intermediate_group`, `H5Pget_dxpl_mpio`, `H5Pget_est_link_info`, `H5Pget_file_space_page_size`, `H5Pget_file_space_strategy`, `H5Pget_libver_bounds`, `H5Pget_link_creation_order`, `H5Pget_meta_block_size`, `H5Pget_mpio_no_collective_cause`, `H5Pget_page_buffer_size`, `H5Pset_all_coll_metadata_ops`, `H5Pset_alloc_time`, `H5Pset_attr_phase_change`, `H5Pset_chunk`, `H5Pset_chunk_cache`, `H5Pset_coll_metadata_write`, `H5Pset_create_intermediate_group`, `H5Pset_deflate`, `H5Pset_dxpl_mpio`, `H5Pset_est_link_info`, `H5Pset_fapl_mpio`, `H5Pset_file_space_page_size`, `H5Pset_file_space_strategy`, `H5Pset_libver_bounds`, `H5Pset_link_creation_order`, `H5Pset_meta_block_size`, `H5Pset_page_buffer_size`, `H5Pset_shuffle`, `H5Pset_szip` |
| H5R | 2 | `H5Rcreate`, `H5Rdereference` |
| H5S | 13 | `H5Scombine_select`, `H5Scopy`, `H5Screate`, `H5Screate_simple`, `H5Sget_select_npoints`, `H5Sget_select_type`, `H5Sget_simple_extent_dims`, `H5Sget_simple_extent_ndims`, `H5Sget_simple_extent_npoints`, `H5Sget_simple_extent_type`, `H5Sselect_elements`, `H5Sselect_hyperslab`, `H5Sselect_none` |
| H5T | 26 | `H5Tclose`, `H5Tcommit2`, `H5Tcopy`, `H5Tcreate`, `H5Tenum_create`, `H5Tenum_insert`, `H5Tequal`, `H5Tget_class`, `H5Tget_create_plist`, `H5Tget_cset`, `H5Tget_member_name`, `H5Tget_member_offset`, `H5Tget_member_type`, `H5Tget_nmembers`, `H5Tget_sign`, `H5Tget_size`, `H5Tget_strpad`, `H5Tinsert`, `H5Tis_variable_str`, `H5Topen2`, `H5Treclaim`, `H5Tset_cset`, `H5Tset_ebias`, `H5Tset_fields`, `H5Tset_size`, `H5Tset_strpad` |
| H5Z | 1 | `H5Zfilter_avail` |
| Total | 147 | Distinct function symbols in the audited workspace snapshot |

## Types, Constants, and Compile-Time Contracts

Function names are not the whole dependency. HighFive also exposes or uses
HDF5 public types and constants in inline code and public declarations.

| Family | Representative dependencies | Required handling |
| --- | --- | --- |
| Handles and sizes | `hid_t`, `herr_t`, `htri_t`, `hsize_t`, `hssize_t`, `ssize_t`, `hbool_t` | Remain available from installed core headers |
| Object and callback metadata | `H5A_info_t`, `H5A_operator2_t`, `H5E_*`, `H5I_type_t`, `H5L_info_t`, `H5O_info*` | Preserve public declarations and callback signatures |
| Dataspaces and selections | `H5S_class_t`, `H5S_sel_type`, `H5S_seloper_t`, `H5S_ALL`, `H5S_UNLIMITED`, selection constants | Preserve core H5S public contract |
| Datatypes | `H5T_class_t`, `H5T_cset_t`, `H5T_sign_t`, predefined native types, string padding and variable-length constants | Preserve core H5T public contract |
| Files and property lists | file open flags, `H5F_scope_t`, `H5F_libver_t`, file-space strategies, `H5P_*` classes and flags | Preserve core H5F/H5P public contract |
| References and links | `H5R_type_t`, `H5R_OBJECT`, link types and iteration types | Preserve core H5R/H5L public contract |
| Filters | `H5Z_filter_t`, `H5Z_FILTER_DEFLATE`, `H5Z_FILTER_SHUFFLE`, `H5Z_FILTER_SZIP` | Preserve core filter declarations and configured implementations |
| Parallel | `H5FD_mpio_xfer_t`, MPIO transfer constants, MPI communicator/info types | Available only in the parallel profile and accompanied by MPI C/C++ targets |
| Version selection | `H5_VERSION_GE`, `H5O_info_t_vers`, `H5Oget_info_vers`, `H5Rdereference_vers` | Do not remove compatibility/version-selection macros as an incidental cleanup |

Version guards select `H5Dvlen_reclaim` before HDF5 1.12 and `H5Treclaim`
from 1.12 onward; select the applicable `H5Oget_info*` and
`H5Rdereference` signatures; and conditionally expose SWMR, dataset refresh,
file-space, collective metadata, and combined-selection support.
The current project version is newer than these thresholds, but Stage 4 is not
authorized to prune core compatibility macros used by the audited consumer.

## Acceptance-Profile Mapping

| Requested profile | HighFive-relevant dependencies | Non-HighFive product requirements |
| --- | --- | --- |
| Shared: `map,szip,threadsafe,tools,zlib,parallel` | Core C API, shared HDF5 linkage, SZIP/zlib filter APIs, parallel H5P/MPIO APIs, MPI C and C++ usage | Map, tools, and thread-safe mode remain required even though HighFive does not call a dedicated API for them |
| Static: `map,szip,tools,zlib,parallel`; thread safety off | Core C API, static HDF5 linkage, SZIP/zlib filter APIs, parallel H5P/MPIO APIs, MPI C and C++ usage | Map and tools remain required business-profile products |

The shared parallel-plus-thread-safe row currently requires
`HDF5_ALLOW_UNSUPPORTED=ON` because the repository rejects that combination by
default. Stage 4 validation must record the override rather than silently
changing the feature-support policy. Promoting the combination to supported
status is a separate decision.

## Audit Conclusions

1. Removing the native HDF5 C++ and complete HL products is compatible with the
   audited HighFive interface dependency set.
2. The removal must preserve the core installed headers, C symbols, configured
   filter implementations, and parallel C surface listed above.
3. Package cleanup must preserve the current core package targets. Upstream
   HighFive's `HDF5::HDF5` expectation is a future integration question, not
   authority to add or change an HDF5 package target during Stage 4.
4. HighFive source ownership/tracking, version policy, CMake integration,
   installation layout, exported targets, tests, and public API policy remain
   future work. They are not authorized by this audit or by Stage 4 removal.
