-- complain if script is sourced in psql, rather than via ALTER EXTENSION
\echo Use "ALTER EXTENSION ""babelfishpg_common"" UPDATE TO '3.3.5'" to load this file. \quit

-- add 'sys' to search path for the convenience
SELECT set_config('search_path', 'sys, '||current_setting('search_path'), false);

--  UNION could not convert type "varchar" to tinyint (#78)

-- numerics.sql
DROP CAST (sys.VARCHAR AS sys.TINYINT); 

CREATE CAST (sys.VARCHAR AS sys.TINYINT)
WITH FUNCTION sys.varchar2tinyint(sys.VARCHAR) AS IMPLICIT;

CREATE OR REPLACE FUNCTION sys.tinyint2varchar(sys.TINYINT)
RETURNS sys.VARCHAR
AS $$
  SELECT $1::SMALLINT;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

DROP CAST (sys.TINYINT AS sys.VARCHAR); 

CREATE CAST (sys.TINYINT AS sys.VARCHAR)
WITH FUNCTION sys.tinyint2varchar(sys.TINYINT) AS IMPLICIT;

-- sqlvariant.sql
CREATE CAST (sys.TINYINT AS sys.SQL_VARIANT)
WITH FUNCTION sys.tinyint_sqlvariant (sys.TINYINT) AS IMPLICIT;

CREATE OR REPLACE FUNCTION sys.sqlvariant_tinyint(sys.SQL_VARIANT)
RETURNS sys.TINYINT
AS 'babelfishpg_common', 'sqlvariant2tinyint'
LANGUAGE C VOLATILE STRICT PARALLEL SAFE;

CREATE CAST (sys.SQL_VARIANT AS sys.TINYINT)
WITH FUNCTION sys.sqlvariant_tinyint (sys.SQL_VARIANT) AS ASSIGNMENT;

-- varbinary.sql
CREATE OR REPLACE FUNCTION sys.tinyintvarbinary(sys.TINYINT, integer, boolean)
RETURNS sys.BBF_VARBINARY
AS 'babelfishpg_common', 'int2varbinary'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (sys.TINYINT AS sys.BBF_VARBINARY)
WITH FUNCTION sys.tinyintvarbinary (sys.TINYINT, integer, boolean) AS ASSIGNMENT;

-- Reimplemented sys.babelfish_concat_wrapper in C to improve the performance (#1911)
CREATE OR REPLACE FUNCTION sys.babelfish_concat_wrapper(leftarg text, rightarg text) RETURNS TEXT
AS 'babelfishpg_tsql', 'babelfish_concat_wrapper'
LANGUAGE C STABLE PARALLEL SAFE;

-- Reset search_path to not affect any subsequent scripts
SELECT set_config('search_path', trim(leading 'sys, ' from current_setting('search_path')), false);
