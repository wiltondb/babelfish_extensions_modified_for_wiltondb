# minimum required CMAKE version
CMAKE_MINIMUM_REQUIRED(VERSION 3.7 FATAL_ERROR)

project ( babelfishpg_tsql_antlr C CXX )

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake-dir)

# compiler must be 11 or 14
if ( DEFINED ENV{CXXSTANDARD} )
	set( CMAKE_CXX_STANDARD $ENV{CXXSTANDARD} )
else ()
	set( CMAKE_CXX_STANDARD 14 )
endif ()
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -DUSE_UTF8_INSTEAD_OF_CODECVT")

message(STATUS "CMAKE_C_FLAGS=${CMAKE_C_FLAGS}")
message(STATUS "CMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}")

# add antrl4cpp artifacts to project environment
include_directories ( /usr/include/antlr4-runtime/ )

# set variable pointing to the antlr tool that supports C++
# this is not required if the jar file can be found under PATH environment
set(ANTLR_EXECUTABLE ${PROJECT_SOURCE_DIR}/thirdparty/antlr/antlr-4.9.3-complete.jar)
# add macros to generate ANTLR Cpp code from grammar
find_package(ANTLR REQUIRED)

antlr_target(SampleGrammarLexer TSqlLexer.g4 LEXER)
antlr_target(SampleGrammarParser TSqlParser.g4 PARSER LISTENER VISITOR
			 DEPENDS_ANTLR SampleGrammarLexer
			 COMPILE_FLAGS -lib ${ANTLR_SampleGrammarLexer_OUTPUT_DIR})

# include generated files in project environment
include_directories(${ANTLR_SampleGrammarLexer_OUTPUT_DIR})
include_directories(${ANTLR_SampleGrammarParser_OUTPUT_DIR})

add_library(antlr_tsql STATIC ${ANTLR_SampleGrammarLexer_CXX_OUTPUTS} ${ANTLR_SampleGrammarParser_CXX_OUTPUTS})
