-- complain if script is sourced in psql, rather than via ALTER EXTENSION
\echo Use "ALTER EXTENSION ""babelfishpg_common"" UPDATE TO '3.3.5'" to load this file. \quit

-- add 'sys' to search path for the convenience
SELECT set_config('search_path', 'sys, '||current_setting('search_path'), false);

-- Fixed CONVERT function behavior for BINARY and VARBINARY types (#3042)
CREATE FUNCTION sys.numericeqint(NUMERIC, INTEGER)
RETURNS BOOL
AS $$
  SELECT $1 = $2::NUMERIC;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR sys.= (
    LEFTARG    = NUMERIC,
    RIGHTARG   = INTEGER,
    COMMUTATOR = =,
    PROCEDURE  = sys.numericeqint
);

-- Reset search_path to not affect any subsequent scripts
SELECT set_config('search_path', trim(leading 'sys, ' from current_setting('search_path')), false);
