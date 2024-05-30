-- complain if script is sourced in psql, rather than via ALTER EXTENSION
\echo Use "ALTER EXTENSION ""babelfishpg_common"" UPDATE TO '3.3.1'" to load this file. \quit

--  Fix differences in T-SQL COALESCE function while calling the function with variables and constants together (#2635) 
DO $$
DECLARE 
    schema_oid oid;
    cast_source oid;
    cast_target oid;
BEGIN
    select oid INTO schema_oid from pg_namespace where nspname='sys';
    select oid into cast_source from pg_type where typname='bbf_varbinary' and typnamespace=schema_oid;
    select oid into cast_target from pg_type where typname='varchar' and typnamespace=schema_oid;
    UPDATE pg_catalog.pg_cast SET castcontext='i' WHERE castsource=cast_source AND casttarget=cast_target;
END $$;

-- Reset search_path to not affect any subsequent scripts
SELECT set_config('search_path', trim(leading 'sys, ' from current_setting('search_path')), false);
