-- complain if script is sourced in psql, rather than via ALTER EXTENSION
\echo Use "ALTER EXTENSION ""babelfishpg_tsql"" UPDATE TO '3.3.2'" to load this file. \quit

-- add 'sys' to search path for the convenience
SELECT set_config('search_path', 'sys, '||current_setting('search_path'), false);

--  Time data type precision difference between SQL and PostgreSQL (#91)
CREATE OR REPLACE FUNCTION sys.tsql_type_scale_helper(IN type TEXT, IN typemod INT, IN return_null_for_rest bool) RETURNS sys.TINYINT
AS $$
DECLARE
	scale INT;
BEGIN
	IF type IS NULL THEN 
		RETURN -1;
	END IF;

	IF typemod = -1 THEN
		CASE type
		WHEN 'date' THEN scale = 0;
		WHEN 'datetime' THEN scale = 3;
		WHEN 'smalldatetime' THEN scale = 0;
		WHEN 'datetime2' THEN scale = 7;
		WHEN 'datetimeoffset' THEN scale = 7;
		WHEN 'decimal' THEN scale = 38;
		WHEN 'numeric' THEN scale = 38;
		WHEN 'money' THEN scale = 4;
		WHEN 'smallmoney' THEN scale = 4;
		WHEN 'time' THEN scale = 7;
		WHEN 'tinyint' THEN scale = 0;
		ELSE
			IF return_null_for_rest
				THEN scale = NULL;
			ELSE scale = 0;
			END IF;
		END CASE;
		RETURN scale;
	END IF;

	CASE type 
	WHEN 'decimal' THEN scale = (typemod - 4) & 65535;
	WHEN 'numeric' THEN scale = (typemod - 4) & 65535;
	WHEN 'smalldatetime' THEN scale = 0;
	WHEN 'datetime2' THEN
		CASE typemod 
		WHEN 0 THEN scale = 0;
		WHEN 1 THEN scale = 1;
		WHEN 2 THEN scale = 2;
		WHEN 3 THEN scale = 3;
		WHEN 4 THEN scale = 4;
		WHEN 5 THEN scale = 5;
		WHEN 6 THEN scale = 6;
		-- typemod = 7 is not possible for datetime2 in Babelfish but
		-- adding the case just in case we support it in future
		WHEN 7 THEN scale = 7;
		END CASE;
	WHEN 'datetimeoffset' THEN
		CASE typemod
		WHEN 0 THEN scale = 0;
		WHEN 1 THEN scale = 1;
		WHEN 2 THEN scale = 2;
		WHEN 3 THEN scale = 3;
		WHEN 4 THEN scale = 4;
		WHEN 5 THEN scale = 5;
		WHEN 6 THEN scale = 6;
		-- typemod = 7 is not possible for datetimeoffset in Babelfish
		-- but adding the case just in case we support it in future
		WHEN 7 THEN scale = 7;
		END CASE;
	WHEN 'time' THEN
		CASE typemod
		WHEN 0 THEN scale = 0;
		WHEN 1 THEN scale = 1;
		WHEN 2 THEN scale = 2;
		WHEN 3 THEN scale = 3;
		WHEN 4 THEN scale = 4;
		WHEN 5 THEN scale = 5;
		WHEN 6 THEN scale = 6;
		-- typemod = 7 is not possible for time in Babelfish but
		-- adding the case just in case we support it in future
		WHEN 7 THEN scale = 7;
		END CASE;
	ELSE
		IF return_null_for_rest
			THEN scale = NULL;
		ELSE scale = 0;
		END IF;
	END CASE;
	RETURN scale;
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;


-- Fixed CONVERT function behavior for BINARY and VARBINARY types (#3042)

CREATE OR REPLACE FUNCTION sys.babelfish_conv_helper_to_varbinary(IN arg anyelement,
                                                                  IN try BOOL,
                                                                  IN p_style NUMERIC DEFAULT 0)
RETURNS sys.varbinary
AS
$BODY$
BEGIN
    IF try THEN
        RETURN sys.babelfish_try_conv_to_varbinary(arg, p_style);
    ELSE
        IF pg_typeof(arg) IN ('text'::regtype, 'sys.ntext'::regtype, 'sys.nvarchar'::regtype, 'sys.bpchar'::regtype, 'sys.nchar'::regtype) THEN
            RETURN sys.babelfish_conv_string_to_varbinary(arg, p_style);
        ELSE
            RETURN CAST(arg AS sys.varbinary);
        END IF;
    END IF;
END;
$BODY$
LANGUAGE plpgsql
IMMUTABLE;  

CREATE OR REPLACE FUNCTION sys.babelfish_conv_helper_to_varbinary(IN arg sys.VARCHAR,
                                                                  IN try BOOL,
                                                                  IN p_style NUMERIC DEFAULT 0)
RETURNS sys.varbinary
AS
$BODY$
BEGIN
    IF try THEN
        RETURN sys.babelfish_try_conv_string_to_varbinary(arg, p_style);
    ELSE
        RETURN sys.babelfish_conv_string_to_varbinary(arg, p_style);
    END IF;
END;
$BODY$
LANGUAGE plpgsql
IMMUTABLE; 

CREATE OR REPLACE FUNCTION sys.babelfish_try_conv_string_to_varbinary(IN arg sys.VARCHAR,                                                       
                                                                      IN p_style NUMERIC DEFAULT 0)
RETURNS sys.varbinary
AS
$BODY$
BEGIN
    RETURN sys.babelfish_conv_string_to_varbinary(arg, p_style);
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
END;
$BODY$
LANGUAGE plpgsql
IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.babelfish_try_conv_to_varbinary(IN arg anyelement,
                                                               IN p_style NUMERIC DEFAULT 0)
RETURNS sys.varbinary
AS
$BODY$
BEGIN
    IF pg_typeof(arg) IN ('text'::regtype, 'sys.ntext'::regtype, 'sys.nvarchar'::regtype, 'sys.bpchar'::regtype, 'sys.nchar'::regtype) THEN
        RETURN sys.babelfish_conv_string_to_varbinary(arg, p_style);
    ELSE
        RETURN CAST(arg AS sys.varbinary);
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
END;
$BODY$
LANGUAGE plpgsql
IMMUTABLE;  

-- Helper function to convert to binary or varbinary
CREATE OR REPLACE FUNCTION sys.babelfish_conv_string_to_varbinary(IN input_value sys.VARCHAR, IN style NUMERIC DEFAULT 0) 
RETURNS sys.varbinary 
AS 
$BODY$
DECLARE
    result bytea; 
BEGIN
    IF style = 0 THEN
        RETURN CAST(input_value AS sys.varbinary);
    ELSIF style = 1 THEN
        -- Handle hexadecimal conversion
        IF (PG_CATALOG.left(input_value, 2) = '0x' COLLATE "C" AND PG_CATALOG.length(input_value) % 2 = 0) THEN
            result := decode(substring(input_value from 3), 'hex');
        ELSE
            RAISE EXCEPTION 'Error converting data type varchar to varbinary.';
        END IF;
    ELSIF style = 2 THEN
        IF PG_CATALOG.left(input_value, 2) = '0x' COLLATE "C" THEN
            RAISE EXCEPTION 'Error converting data type varchar to varbinary.';
        ELSE
            result := decode(input_value, 'hex');
        END IF;
    ELSE
        RAISE EXCEPTION 'The style % is not supported for conversions from varchar to varbinary.', style;
    END IF;

    RETURN CAST(result AS sys.varbinary);
END;
$BODY$ 
LANGUAGE plpgsql
IMMUTABLE
STRICT;


-- use PG_CATALOG.RIGHT in upgrade scripts to mVU issues (#3078)
CREATE OR REPLACE VIEW information_schema_tsql.schemata AS
	SELECT CAST(sys.db_name() AS sys.sysname) AS "CATALOG_NAME",
	CAST(CASE WHEN np.nspname LIKE PG_CATALOG.CONCAT(sys.db_name(),'%') THEN PG_CATALOG.RIGHT(np.nspname, LENGTH(np.nspname) - LENGTH(sys.db_name()) - 1)
	     ELSE np.nspname END AS sys.nvarchar(128)) AS "SCHEMA_NAME",
	-- For system-defined schemas, schema-owner name will be same as schema_name
	-- For user-defined schemas having default owner, schema-owner will be dbo
	-- For user-defined schemas with explicit owners, rolname contains dbname followed
	-- by owner name, so need to extract the owner name from rolname always.
	CAST(CASE WHEN sys.bbf_is_shared_schema(np.nspname) = TRUE THEN np.nspname
		  WHEN r.rolname LIKE PG_CATALOG.CONCAT(sys.db_name(),'%') THEN
			CASE WHEN PG_CATALOG.RIGHT(r.rolname, LENGTH(r.rolname) - LENGTH(sys.db_name()) - 1) = 'db_owner' THEN 'dbo'
			     ELSE PG_CATALOG.RIGHT(r.rolname, LENGTH(r.rolname) - LENGTH(sys.db_name()) - 1) END ELSE 'dbo' END
			AS sys.nvarchar(128)) AS "SCHEMA_OWNER",
	CAST(null AS sys.varchar(6)) AS "DEFAULT_CHARACTER_SET_CATALOG",
	CAST(null AS sys.varchar(3)) AS "DEFAULT_CHARACTER_SET_SCHEMA",
	-- TODO: We need to first create mapping of collation name to char-set name;
	-- Until then return null for DEFAULT_CHARACTER_SET_NAME
	CAST(null AS sys.sysname) AS "DEFAULT_CHARACTER_SET_NAME"
	FROM ((pg_catalog.pg_namespace np LEFT JOIN sys.pg_namespace_ext nc on np.nspname = nc.nspname)
		LEFT JOIN pg_catalog.pg_roles r on r.oid = nc.nspowner) LEFT JOIN sys.babelfish_namespace_ext ext on nc.nspname = ext.nspname
	WHERE (ext.dbid = cast(sys.db_id() as oid) OR np.nspname in ('sys', 'information_schema_tsql')) AND
	      (pg_has_role(np.nspowner, 'USAGE') OR has_schema_privilege(np.oid, 'CREATE, USAGE'))
	ORDER BY nc.nspname, np.nspname;

GRANT SELECT ON information_schema_tsql.schemata TO PUBLIC;

-- Reset search_path to not affect any subsequent scripts
SELECT set_config('search_path', trim(leading 'sys, ' from current_setting('search_path')), false);
