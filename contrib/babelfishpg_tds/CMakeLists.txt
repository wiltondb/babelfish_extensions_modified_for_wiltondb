# Copyright 2023 alex@staticlibs.net
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

cmake_minimum_required ( VERSION 3.0 )

project ( babelfishpg_tds C )

if ( NOT DEFINED ENV{PGWIN_DEPS_DIR} )
    message( FATAL_ERROR "Environment variable 'PGWIN_DEPS_DIR' (pointing to the pgwin_deps installation directory) must be specified" )
endif ()
if ( NOT DEFINED ENV{PGWIN_INSTALL_DIR} )
    message( FATAL_ERROR "Environment variable 'PGWIN_INSTALL_DIR' (pointing to the postgresql_modified_for_babelfish installation directory) must be specified" )
endif ()
if ( NOT DEFINED ENV{PGWIN_SRC_DIR} )
    message( FATAL_ERROR "Environment variable 'PGWIN_SRC_DIR' (pointing to the postgresql_modified_for_babelfish source directory) must be specified" )
endif ()

execute_process ( COMMAND perl
    ${CMAKE_CURRENT_LIST_DIR}/generate_error_mapping.pl
    ${CMAKE_CURRENT_LIST_DIR}/error_mapping.txt
    OUTPUT_FILE ${CMAKE_CURRENT_LIST_DIR}/src/include/error_mapping.h )

add_library ( ${PROJECT_NAME} SHARED 
    src/backend/fault_injection/fault_injection.c 
    src/backend/fault_injection/fault_injection_tests.c 

    src/backend/tds/err_handler.c
    src/backend/tds/guc.c
    src/backend/tds/tdsbulkload.c
    src/backend/tds/tds.c
    src/backend/tds/tdscomm.c
    src/backend/tds/tdslogin.c
    src/backend/tds/tdsprotocol.c
    src/backend/tds/tdsresponse.c
    src/backend/tds/tdsrpc.c
    src/backend/tds/tdssecure.c
    src/backend/tds/tds-secure-openssl.c
    src/backend/tds/tdssqlbatch.c
    src/backend/tds/tds_srv.c
    src/backend/tds/tds_win.c
    src/backend/tds/tdstimestamp.c
    src/backend/tds/tdstypeio.c
    src/backend/tds/tdsutils.c
    src/backend/tds/tdsxact.c

    src/backend/utils/adt/numeric.c
    src/backend/utils/adt/varchar.c
    src/backend/utils/adt/xml.c
    
    src/include/err_handler.h
    src/include/faultinjection.h
    src/include/guc.h
    src/include/tds_debug.h
    src/include/tds.h
    src/include/tds_instr.h
    src/include/tds_int.h
    src/include/tds_iofuncmap.h
    src/include/tdsprinttup.h
    src/include/tds_protocol.h
    src/include/tds_request.h
    src/include/tds_response.h
    src/include/tds_secure.h
    src/include/tds_timestamp.h
    src/include/tds_typecode.h
    src/include/tds_typeio.h
    src/include/tds_win.h

    ${PROJECT_NAME}.def )

target_include_directories ( ${PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}
    ${CMAKE_CURRENT_LIST_DIR}/../babelfishpg_tsql
    $ENV{PGWIN_INSTALL_DIR}/include/server/port/win32_msvc 
    $ENV{PGWIN_INSTALL_DIR}/include/server/port/win32
    $ENV{PGWIN_INSTALL_DIR}/include/server
    $ENV{PGWIN_INSTALL_DIR}/include
    $ENV{PGWIN_DEPS_DIR}/int128
    $ENV{PGWIN_DEPS_DIR}/openssl/include
    $ENV{PGWIN_DEPS_DIR}/xml/include/libxml2
    $ENV{PGWIN_SRC_DIR} )

target_compile_options ( ${PROJECT_NAME} PRIVATE
    /wd4018
    /wd4244
    /wd4267
    /wd4996 )

target_compile_definitions ( ${PROJECT_NAME} PRIVATE
    _CRT_SECURE_NO_WARNINGS
    USE_LIBXML )

target_link_libraries ( ${PROJECT_NAME} PRIVATE
    $ENV{PGWIN_INSTALL_DIR}/lib/postgres.lib
    $ENV{PGWIN_DEPS_DIR}/xml/lib/libxml2.lib
    $ENV{PGWIN_DEPS_DIR}/openssl/lib/libssl.lib
    $ENV{PGWIN_DEPS_DIR}/openssl/lib/libcrypto.lib
    secur32
    shlwapi
    ws2_32 )

install ( TARGETS ${PROJECT_NAME} RUNTIME
    DESTINATION $ENV{PGWIN_INSTALL_DIR}/lib )

install( FILES
    $<TARGET_PDB_FILE:${PROJECT_NAME}>
    DESTINATION $ENV{PGWIN_INSTALL_DIR}/symbols )

install ( FILES
    ${PROJECT_NAME}--1.0.0.sql
    ${PROJECT_NAME}.control
    DESTINATION $ENV{PGWIN_INSTALL_DIR}/share/extension )