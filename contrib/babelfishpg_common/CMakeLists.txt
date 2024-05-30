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

project ( babelfishpg_common C )

set ( BBFPGCMN_MAJOR_VERSION 3 )
set ( BBFPGCMN_MINOR_VERSION 3 )
set ( BBFPGCMN_MICRO_VERSION 3 )
set ( EXTVERSION ${BBFPGCMN_MAJOR_VERSION}.${BBFPGCMN_MINOR_VERSION}.${BBFPGCMN_MICRO_VERSION} )
set ( MODULEPATH $libdir/${PROJECT_NAME}-${BBFPGCMN_MAJOR_VERSION} )

if ( NOT DEFINED ENV{PGWIN_DEPS_DIR} )
    message( FATAL_ERROR "Environment variable 'PGWIN_DEPS_DIR' (pointing to the pgwin_deps installation directory) must be specified" )
endif ()
if ( NOT DEFINED ENV{PGWIN_INSTALL_DIR} )
    message( FATAL_ERROR "Environment variable 'PGWIN_INSTALL_DIR' (pointing to the postgresql_modified_for_babelfish installation directory) must be specified" )
endif ()
if ( NOT DEFINED ENV{PGWIN_SRC_DIR} )
    message( FATAL_ERROR "Environment variable 'PGWIN_SRC_DIR' (pointing to the postgresql_modified_for_babelfish source directory) must be specified" )
endif ()

add_library ( ${PROJECT_NAME} SHARED 
    src/${PROJECT_NAME}.c
    src/varchar.c
    src/bit.c
    src/instr.c
    src/typecode.c
    src/numeric.c
    src/varbinary.c
    src/uniqueidentifier.c
    src/datetime.c
    src/datetime2.c
    src/smalldatetime.c
    src/datetimeoffset.c
    src/sqlvariant.c
    src/coerce.c
    src/collation.c
    src/encoding/encoding_utils.c
    src/encoding/mb/conv.c
    src/encoding/mb/conversion_procs/utf8_and_big5/utf8_and_big5.c
    src/encoding/mb/conversion_procs/utf8_and_gbk/utf8_and_gbk.c
    src/encoding/mb/conversion_procs/utf8_and_sjis/utf8_and_sjis.c
    src/encoding/mb/conversion_procs/utf8_and_uhc/utf8_and_uhc.c
    src/encoding/mb/conversion_procs/utf8_and_win/utf8_and_win.c

    src/babelfishpg_common.h
    src/collation.h
    src/datetime.h
    src/datetime2.h
    src/datetimeoffset.h
    src/instr.h
    src/numeric.h
    src/sqlvariant.h
    src/typecode.h
    src/varchar.h
    
    ${PROJECT_NAME}.def )

target_include_directories ( ${PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_LIST_DIR} )

target_include_directories ( ${PROJECT_NAME} PRIVATE
    $ENV{PGWIN_INSTALL_DIR}/include/server/port/win32_msvc 
    $ENV{PGWIN_INSTALL_DIR}/include/server/port/win32
    $ENV{PGWIN_INSTALL_DIR}/include/server
    $ENV{PGWIN_INSTALL_DIR}/include
    $ENV{PGWIN_DEPS_DIR}/icu/include
    $ENV{PGWIN_SRC_DIR} )

target_compile_options ( ${PROJECT_NAME} PRIVATE
    /wd4244
    /wd4267 )

target_compile_definitions ( ${PROJECT_NAME} PRIVATE
    _CRT_SECURE_NO_WARNINGS )
 
target_link_libraries ( ${PROJECT_NAME} PRIVATE
    $ENV{PGWIN_INSTALL_DIR}/lib/postgres.lib
    $ENV{PGWIN_DEPS_DIR}/icu/lib64/icuuc.lib
    $ENV{PGWIN_DEPS_DIR}/icu/lib64/icuin.lib )

configure_file ( ${PROJECT_NAME}.control.in
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.control 
    @ONLY 
    NEWLINE_STYLE LF )

file ( READ sql/${PROJECT_NAME}.prologue.sql PROLOGUE_SQL )
file ( READ sql/money/fixeddecimal--1.1.0_base_parallel.sql MONEY_BASE_SQL )
file ( READ sql/money/fixeddecimal--parallelaggs.sql MONEY_AGGFUNC_SQL )
file ( READ sql/money/fixeddecimal--brin.sql MONEY_BRIN_SQL )
file ( READ sql/collation.sql COLLATION_SQL )
file ( READ sql/bpchar.sql BPCHAR_SQL )
file ( READ sql/varchar.sql VARCHAR_SQL )
file ( READ sql/numerics.sql NUMERICS_SQL )
file ( READ sql/strings.sql STRINGS_SQL )
file ( READ sql/bit.sql BIT_SQL )
file ( READ sql/varbinary.sql VARBINARY_SQL )
file ( READ sql/binary.sql BINARY_SQL )
file ( READ sql/uniqueidentifier.sql UNIQUEIDENTIFIER_SQL )
file ( READ sql/datetime.sql DATETIME_SQL )
file ( READ sql/datetime2.sql DATETIME2_SQL )
file ( READ sql/smalldatetime.sql SMALLDATETIME_SQL )
file ( READ sql/datetimeoffset.sql DATETIMEOFFSET_SQL )
file ( READ sql/sqlvariant.sql SQLVARIANT_SQL )
file ( READ sql/string_operators.sql STRING_OPERATORS_SQL )
file ( READ sql/coerce.sql COERCE_SQL)
file ( READ sql/rowversion.sql ROWVERSION_SQL)
file ( READ sql/utils.sql UTILS_SQL)
file ( READ sql/${PROJECT_NAME}.epilogue.sql EPILOGUE_SQL )
string ( CONCAT ${PROJECT_NAME}_SQL
    "${PROLOGUE_SQL}"
    "${MONEY_BASE_SQL}"
    "${MONEY_AGGFUNC_SQL}"
    "${MONEY_BRIN_SQL}"
    "${COLLATION_SQL}"
    "${BPCHAR_SQL}"
    "${VARCHAR_SQL}"
    "${NUMERICS_SQL}"
    "${STRINGS_SQL}"
    "${BIT_SQL}"
    "${VARBINARY_SQL}"
    "${BINARY_SQL}"
    "${UNIQUEIDENTIFIER_SQL}"
    "${DATETIME_SQL}"
    "${DATETIME2_SQL}"
    "${SMALLDATETIME_SQL}"
    "${DATETIMEOFFSET_SQL}"
    "${SQLVARIANT_SQL}"
    "${STRING_OPERATORS_SQL}"
    "${COERCE_SQL}"
    "${ROWVERSION_SQL}"
    "${UTILS_SQL}"
    "${EPILOGUE_SQL}" )
file ( GENERATE
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}--${EXTVERSION}.sql
    CONTENT "${${PROJECT_NAME}_SQL}"
    NEWLINE_STYLE LF )

install ( TARGETS ${PROJECT_NAME} RUNTIME
    DESTINATION $ENV{PGWIN_INSTALL_DIR}/lib )

install( FILES
    $<TARGET_PDB_FILE:${PROJECT_NAME}>
    DESTINATION $ENV{PGWIN_INSTALL_DIR}/symbols )

install ( FILES
    sql/upgrades/${PROJECT_NAME}--1.0.0--1.1.0.sql
    sql/upgrades/${PROJECT_NAME}--1.1.0--1.2.0.sql
    sql/upgrades/${PROJECT_NAME}--1.2.0--1.2.1.sql
    sql/upgrades/${PROJECT_NAME}--1.2.1--2.0.0.sql
    sql/upgrades/${PROJECT_NAME}--2.0.0--2.1.0.sql
    sql/upgrades/${PROJECT_NAME}--2.1.0--2.2.0.sql
    sql/upgrades/${PROJECT_NAME}--2.2.0--2.3.0.sql
    sql/upgrades/${PROJECT_NAME}--2.3.0--2.4.0.sql
    sql/upgrades/${PROJECT_NAME}--2.3.0--3.0.0.sql
    sql/upgrades/${PROJECT_NAME}--2.4.0--3.0.0.sql
    sql/upgrades/${PROJECT_NAME}--2.5.0--3.0.0.sql
    sql/upgrades/${PROJECT_NAME}--3.0.0--3.1.0.sql
    sql/upgrades/${PROJECT_NAME}--3.1.0--3.2.0.sql
    sql/upgrades/${PROJECT_NAME}--3.1.0--3.3.0.sql
    sql/upgrades/${PROJECT_NAME}--3.3.0--3.3.1.sql
    sql/upgrades/${PROJECT_NAME}--3.3.1--3.3.2.sql
    sql/upgrades/${PROJECT_NAME}--3.3.2--3.3.3.sql
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}--${EXTVERSION}.sql
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.control
    DESTINATION $ENV{PGWIN_INSTALL_DIR}/share/extension )
