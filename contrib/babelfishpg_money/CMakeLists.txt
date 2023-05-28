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

project ( babelfishpg_money C )

if ( NOT DEFINED ENV{PGWIN_DEPS_DIR} )
    message( FATAL_ERROR "Environment variable 'PGWIN_DEPS_DIR' (pointing to the pgwin_deps installation directory) must be specified" )
endif ()
if ( NOT DEFINED ENV{PGWIN_INSTALL_DIR} )
    message( FATAL_ERROR "Environment variable 'PGWIN_INSTALL_DIR' (pointing to the postgresql_modified_for_babelfish installation directory) must be specified" )
endif ()

add_library ( ${PROJECT_NAME} SHARED
    fixeddecimal.c
    ${PROJECT_NAME}.def )

target_include_directories ( ${PROJECT_NAME} PRIVATE
    $ENV{PGWIN_INSTALL_DIR}/include/server/port/win32_msvc 
    $ENV{PGWIN_INSTALL_DIR}/include/server/port/win32
    $ENV{PGWIN_INSTALL_DIR}/include/server
    $ENV{PGWIN_INSTALL_DIR}/include
    $ENV{PGWIN_DEPS_DIR}/int128 )

target_compile_options ( ${PROJECT_NAME} PRIVATE
    /wd4244
    /wd4267 )

target_compile_definitions ( ${PROJECT_NAME} PRIVATE
    _CRT_SECURE_NO_WARNINGS )

target_link_libraries ( ${PROJECT_NAME} PRIVATE
    $ENV{PGWIN_INSTALL_DIR}/lib/postgres.lib )

file ( READ fixeddecimal--1.1.0_base.sql BASESQL )
file ( READ fixeddecimal--aggs.sql AGGFUNCSSQL )
file ( GENERATE
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}--1.1.0.sql
    CONTENT "${BASESQL}${AGGFUNCSSQL}"
    NEWLINE_STYLE LF )

install ( TARGETS ${PROJECT_NAME}
    DESTINATION $ENV{PGWIN_INSTALL_DIR}/lib )

install ( FILES
    fixeddecimal--1.0.0--1.1.0.sql
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}--1.1.0.sql
    ${PROJECT_NAME}.control
    DESTINATION $ENV{PGWIN_INSTALL_DIR}/share/extension )