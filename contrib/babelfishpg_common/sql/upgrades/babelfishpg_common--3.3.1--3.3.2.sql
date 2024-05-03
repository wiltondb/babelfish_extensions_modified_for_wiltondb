-- complain if script is sourced in psql, rather than via ALTER EXTENSION
\echo Use "ALTER EXTENSION ""babelfishpg_common"" UPDATE TO '3.3.1'" to load this file. \quit

-- Make NEWID() and NEWSEQUENTIALID() functions VOLATILE (#2540) 
ALTER FUNCTION sys.newid() VOLATILE;
ALTER FUNCTION sys.NEWSEQUENTIALID() VOLATILE;

-- Reset search_path to not affect any subsequent scripts
SELECT set_config('search_path', trim(leading 'sys, ' from current_setting('search_path')), false);
