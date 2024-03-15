-- complain if script is sourced in psql, rather than via ALTER EXTENSION
\echo Use "ALTER EXTENSION ""babelfishpg_common"" UPDATE TO '3.3.1'" to load this file. \quit

-- fix conversion of varchar to binary varbinary and vice versa (#1957)
CREATE CAST (sys.BBF_BINARY AS sys.BBF_VARBINARY)
WITHOUT FUNCTION AS IMPLICIT;

CREATE CAST (sys.BBF_VARBINARY AS sys.BBF_BINARY)
WITHOUT FUNCTION AS IMPLICIT;
