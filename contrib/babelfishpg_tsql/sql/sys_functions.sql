-- SELECT FOR XML
CREATE OR REPLACE FUNCTION sys.tsql_query_to_xml_sfunc(
    state INTERNAL,
    rec ANYELEMENT,
    mode int,
    element_name text,
    binary_base64 boolean,
    root_name text
) RETURNS INTERNAL
AS 'babelfishpg_tsql', 'tsql_query_to_xml_sfunc'
LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION sys.tsql_query_to_xml_ffunc(
    state INTERNAL
)
RETURNS XML AS
'babelfishpg_tsql', 'tsql_query_to_xml_ffunc'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION sys.tsql_query_to_xml_text_ffunc(
    state INTERNAL
)
RETURNS NTEXT AS
'babelfishpg_tsql', 'tsql_query_to_xml_text_ffunc'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE AGGREGATE sys.tsql_select_for_xml_agg(
    rec ANYELEMENT,
    mode int,
    element_name text,
    binary_base64 boolean,
    root_name text)
(
    STYPE = INTERNAL,
    SFUNC = tsql_query_to_xml_sfunc,
    FINALFUNC = tsql_query_to_xml_ffunc
);

CREATE OR REPLACE AGGREGATE sys.tsql_select_for_xml_text_agg(
    rec ANYELEMENT,
    mode int,
    element_name text,
    binary_base64 boolean,
    root_name text)
(
    STYPE = INTERNAL,
    SFUNC = tsql_query_to_xml_sfunc,
    FINALFUNC = tsql_query_to_xml_text_ffunc
);

CREATE OR REPLACE FUNCTION sys.tsql_select_for_xml_result(res XML)
RETURNS setof XML AS
$$
BEGIN
IF res IS NOT NULL THEN
    return next res;
ELSE
    return;
END IF;
END;
$$
LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.tsql_select_for_xml_text_result(res NTEXT)
RETURNS setof NTEXT AS
$$
BEGIN
IF res IS NOT NULL THEN
    return next res;
ELSE
    return;
END IF;
END;
$$
LANGUAGE plpgsql IMMUTABLE;

-- SELECT FOR JSON
CREATE OR REPLACE FUNCTION sys.tsql_query_to_json_sfunc(
    state INTERNAL,
    rec ANYELEMENT,
    mode INT,
    include_null_values BOOLEAN,
    without_array_wrapper BOOLEAN,
    root_name TEXT
) RETURNS INTERNAL
AS 'babelfishpg_tsql', 'tsql_query_to_json_sfunc'
LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION sys.tsql_query_to_json_ffunc(
    state INTERNAL
)
RETURNS sys.NVARCHAR AS
'babelfishpg_tsql', 'tsql_query_to_json_ffunc'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE AGGREGATE sys.tsql_select_for_json_agg(
    rec ANYELEMENT,
    mode INT,
    include_null_values BOOLEAN,
    without_array_wrapper BOOLEAN,
    root_name TEXT)
(
    STYPE = INTERNAL,
    SFUNC = tsql_query_to_json_sfunc,
    FINALFUNC = tsql_query_to_json_ffunc
);

CREATE OR REPLACE FUNCTION sys.tsql_select_for_json_result(res sys.NVARCHAR)
RETURNS setof sys.NVARCHAR AS
$$
BEGIN
IF res IS NOT NULL THEN
    return next res;
ELSE
    return;
END IF;
END;
$$
LANGUAGE plpgsql IMMUTABLE;

-- User and Login Functions
CREATE OR REPLACE FUNCTION sys.user_name(IN id OID DEFAULT NULL)
RETURNS sys.NVARCHAR(128)
AS 'babelfishpg_tsql', 'user_name'
LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.tsql_get_constraintdef(IN constraint_id OID DEFAULT NULL)
RETURNS text
AS 'babelfishpg_tsql', 'tsql_get_constraintdef'
LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.tsql_get_functiondef(IN function_id OID DEFAULT NULL)
RETURNS text
AS 'babelfishpg_tsql', 'tsql_get_functiondef'
LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.tsql_get_expr(IN text_expr text DEFAULT NULL , IN function_id OID DEFAULT NULL)
RETURNS text
AS 'babelfishpg_tsql', 'tsql_get_expr'
LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.tsql_get_returnTypmodValue(IN function_id OID DEFAULT NULL)
RETURNS INTEGER
AS 'babelfishpg_tsql', 'tsql_get_returnTypmodValue'
LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.user_id(IN user_name sys.sysname)
RETURNS OID
AS 'babelfishpg_tsql', 'user_id'
LANGUAGE C IMMUTABLE PARALLEL SAFE STRICT;

CREATE OR REPLACE FUNCTION sys.user_id()
RETURNS OID
AS 'babelfishpg_tsql', 'user_id_noarg'
LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.suser_name_internal(IN server_user_id OID)
RETURNS sys.NVARCHAR(128)
AS 'babelfishpg_tsql', 'suser_name'
LANGUAGE C IMMUTABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION sys.suser_name(IN server_user_id OID)
RETURNS sys.NVARCHAR(128) AS $$
    SELECT CASE 
        WHEN server_user_id IS NULL THEN NULL
        ELSE sys.suser_name_internal(server_user_id)
    END;
$$
LANGUAGE SQL IMMUTABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION sys.suser_name()
RETURNS sys.NVARCHAR(128)
AS $$
    SELECT sys.suser_name_internal(NULL);
$$
LANGUAGE SQL IMMUTABLE PARALLEL RESTRICTED;

-- Since SIDs are currently not supported in Babelfish, this essentially behaves the same as suser_name but 
-- with a different input data type
CREATE OR REPLACE FUNCTION sys.suser_sname(IN server_user_sid SYS.VARBINARY(85))
RETURNS SYS.NVARCHAR(128)
AS $$
    SELECT sys.suser_name(CAST(server_user_sid AS INT)); 
$$
LANGUAGE SQL IMMUTABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION sys.suser_sname()
RETURNS SYS.NVARCHAR(128)
AS $$
    SELECT sys.suser_name();
$$
LANGUAGE SQL IMMUTABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION sys.suser_id_internal(IN login TEXT)
RETURNS OID
AS 'babelfishpg_tsql', 'suser_id'
LANGUAGE C IMMUTABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION sys.suser_id(IN login TEXT)
RETURNS OID AS $$
    SELECT CASE
        WHEN login IS NULL THEN NULL
        ELSE sys.suser_id_internal(login)
    END;
$$
LANGUAGE SQL IMMUTABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION sys.suser_id()
RETURNS OID
AS $$
    SELECT sys.suser_id_internal(NULL);
$$
LANGUAGE SQL IMMUTABLE PARALLEL RESTRICTED;

-- Since SIDs are currently not supported in Babelfish, this essentially behaves the same as suser_id but 
-- with different input/output data types. The second argument will be ignored as its functionality is not supported
CREATE OR REPLACE FUNCTION sys.suser_sid(IN login SYS.SYSNAME, IN Param2 INT DEFAULT NULL)
RETURNS SYS.VARBINARY(85) AS $$
    SELECT CASE
    WHEN login = '' 
        THEN CAST(CAST(sys.suser_id() AS INT) AS SYS.VARBINARY(85))
    ELSE 
        CAST(CAST(sys.suser_id(login) AS INT) AS SYS.VARBINARY(85))
    END;
$$
LANGUAGE SQL IMMUTABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION sys.suser_sid()
RETURNS SYS.VARBINARY(85)
AS $$
    SELECT CAST(CAST(sys.suser_id() AS INT) AS SYS.VARBINARY(85));
$$
LANGUAGE SQL IMMUTABLE PARALLEL RESTRICTED;

-- Matches and returns object name to Oid
CREATE OR REPLACE FUNCTION sys.OBJECT_NAME(IN object_id INT, IN database_id INT DEFAULT NULL)
RETURNS sys.SYSNAME AS
'babelfishpg_tsql', 'object_name'
LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION sys.scope_identity()
RETURNS numeric(38,0) AS
$BODY$
	SELECT sys.babelfish_get_scope_identity()::numeric(38,0);
$BODY$
LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION sys.ident_seed(IN tablename TEXT)
RETURNS numeric(38,0) AS
$BODY$
	SELECT sys.babelfish_get_identity_param(tablename, 'start'::text)::numeric(38,0);
$BODY$
LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION sys.ident_incr(IN tablename TEXT)
RETURNS numeric(38,0) AS
$BODY$
	SELECT sys.babelfish_get_identity_param(tablename, 'increment'::text)::numeric(38,0);
$BODY$
LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION sys.ident_current(IN tablename TEXT)
RETURNS numeric(38,0) AS
$BODY$
	SELECT sys.babelfish_get_identity_current(tablename)::numeric(38,0);
$BODY$
LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION sys.checksum(VARIADIC arr TEXT[])
RETURNS INTEGER
AS 'babelfishpg_tsql', 'checksum'
LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.datetime2fromparts(IN p_year NUMERIC,
                                                                IN p_month NUMERIC,
                                                                IN p_day NUMERIC,
                                                                IN p_hour NUMERIC,
                                                                IN p_minute NUMERIC,
                                                                IN p_seconds NUMERIC,
                                                                IN p_fractions NUMERIC,
                                                                IN p_precision NUMERIC)
RETURNS sys.DATETIME2
AS
$BODY$
DECLARE
   v_fractions VARCHAR;
   v_precision SMALLINT;
   v_err_message VARCHAR;
   v_calc_seconds NUMERIC;
   v_resdatetime TIMESTAMP WITHOUT TIME ZONE;
   v_string pg_catalog.text;
BEGIN
   v_fractions := floor(p_fractions)::INTEGER::VARCHAR;
   v_precision := p_precision::SMALLINT;

   IF (scale(p_precision) > 0) THEN
      RAISE most_specific_type_mismatch;
   ELSIF ((p_year::SMALLINT NOT BETWEEN 1 AND 9999) OR
       (p_month::SMALLINT NOT BETWEEN 1 AND 12) OR
       (p_day::SMALLINT NOT BETWEEN 1 AND 31) OR
       (p_hour::SMALLINT NOT BETWEEN 0 AND 23) OR
       (p_minute::SMALLINT NOT BETWEEN 0 AND 59) OR
       (p_seconds::SMALLINT NOT BETWEEN 0 AND 59) OR
       (p_fractions::SMALLINT NOT BETWEEN 0 AND 9999999) OR
       (p_fractions::SMALLINT != 0 AND char_length(v_fractions) > v_precision))
   THEN
      RAISE invalid_datetime_format;
   ELSIF (v_precision NOT BETWEEN 0 AND 7) THEN
      RAISE invalid_parameter_value;
   END IF;

   v_calc_seconds := pg_catalog.format('%s.%s',
                            floor(p_seconds)::SMALLINT,
                            substring(rpad(lpad(v_fractions, v_precision, '0'), 7, '0'), 1, v_precision))::NUMERIC;

   v_resdatetime := make_timestamp(floor(p_year)::SMALLINT,
                         floor(p_month)::SMALLINT,
                         floor(p_day)::SMALLINT,
                         floor(p_hour)::SMALLINT,
                         floor(p_minute)::SMALLINT,
                         v_calc_seconds);

   v_string := v_resdatetime::pg_catalog.text;

   RETURN CAST(v_string AS sys.DATETIME2);
EXCEPTION
   WHEN most_specific_type_mismatch THEN
      RAISE USING MESSAGE := 'Scale argument is not valid. Valid expressions for data type DATETIME2 scale argument are integer constants and integer constant expressions.',
                  DETAIL := 'Use of incorrect "precision" parameter value during conversion process.',
                  HINT := 'Change "precision" parameter to the proper value and try again.';

   WHEN invalid_parameter_value THEN
      RAISE USING MESSAGE := pg_catalog.format('Specified scale %s is invalid.', v_precision),
                  DETAIL := 'Use of incorrect "precision" parameter value during conversion process.',
                  HINT := 'Change "precision" parameter to the proper value and try again.';

   WHEN invalid_datetime_format THEN
      RAISE USING MESSAGE := 'Cannot construct data type DATETIME2, some of the arguments have values which are not valid.',
                  DETAIL := 'Possible use of incorrect value of date or time part (which lies outside of valid range).',
                  HINT := 'Check each input argument belongs to the valid range and try again.';

   WHEN numeric_value_out_of_range THEN
      GET STACKED DIAGNOSTICS v_err_message = MESSAGE_TEXT;
      v_err_message := upper(split_part(v_err_message, ' ', 1));

      RAISE USING MESSAGE := pg_catalog.format('Error while trying to cast to %s data type.', v_err_message),
                  DETAIL := pg_catalog.format('Source value is out of %s data type range.', v_err_message),
                  HINT := pg_catalog.format('Correct the source value you are trying to cast to %s data type and try again.',
                                 v_err_message);
END;
$BODY$
LANGUAGE plpgsql
IMMUTABLE
RETURNS NULL ON NULL INPUT;

CREATE OR REPLACE FUNCTION sys.datetime2fromparts(IN p_year TEXT,
                                                                IN p_month TEXT,
                                                                IN p_day TEXT,
                                                                IN p_hour TEXT,
                                                                IN p_minute TEXT,
                                                                IN p_seconds TEXT,
                                                                IN p_fractions TEXT,
                                                                IN p_precision TEXT)
RETURNS TIMESTAMP WITHOUT TIME ZONE
AS
$BODY$
DECLARE
    v_err_message VARCHAR;
BEGIN
    RETURN sys.datetime2fromparts(p_year::NUMERIC, p_month::NUMERIC, p_day::NUMERIC,
                                                p_hour::NUMERIC, p_minute::NUMERIC, p_seconds::NUMERIC,
                                                p_fractions::NUMERIC, p_precision::NUMERIC);
EXCEPTION
    WHEN invalid_text_representation THEN
        GET STACKED DIAGNOSTICS v_err_message = MESSAGE_TEXT;
        v_err_message := substring(lower(v_err_message), 'numeric\:\s\"(.*)\"');

        RAISE USING MESSAGE := pg_catalog.format('Error while trying to convert "%s" value to NUMERIC data type.', v_err_message),
                    DETAIL := 'Supplied string value contains illegal characters.',
                    HINT := 'Correct supplied value, remove all illegal characters and try again.';
END;
$BODY$
LANGUAGE plpgsql
IMMUTABLE
RETURNS NULL ON NULL INPUT;

CREATE OR REPLACE FUNCTION sys.datetimefromparts(IN p_year NUMERIC,
                                                               IN p_month NUMERIC,
                                                               IN p_day NUMERIC,
                                                               IN p_hour NUMERIC,
                                                               IN p_minute NUMERIC,
                                                               IN p_seconds NUMERIC,
                                                               IN p_milliseconds NUMERIC)
RETURNS TIMESTAMP WITHOUT TIME ZONE
AS
$BODY$
DECLARE
    v_err_message VARCHAR;
    v_calc_seconds NUMERIC;
    v_milliseconds SMALLINT;
    v_resdatetime TIMESTAMP WITHOUT TIME ZONE;
BEGIN
    -- Check if arguments are out of range
    IF ((floor(p_year)::SMALLINT NOT BETWEEN 1753 AND 9999) OR
        (floor(p_month)::SMALLINT NOT BETWEEN 1 AND 12) OR
        (floor(p_day)::SMALLINT NOT BETWEEN 1 AND 31) OR
        (floor(p_hour)::SMALLINT NOT BETWEEN 0 AND 23) OR
        (floor(p_minute)::SMALLINT NOT BETWEEN 0 AND 59) OR
        (floor(p_seconds)::SMALLINT NOT BETWEEN 0 AND 59) OR
        (floor(p_milliseconds)::SMALLINT NOT BETWEEN 0 AND 999))
    THEN
        RAISE invalid_datetime_format;
    END IF;

    v_milliseconds := sys.babelfish_round_fractseconds(p_milliseconds::INTEGER);

    v_calc_seconds := pg_catalog.format('%s.%s',
                             floor(p_seconds)::SMALLINT,
                             CASE v_milliseconds
                                WHEN 1000 THEN '0'
                                ELSE lpad(v_milliseconds::VARCHAR, 3, '0')
                             END)::NUMERIC;

    v_resdatetime := make_timestamp(floor(p_year)::SMALLINT,
                                    floor(p_month)::SMALLINT,
                                    floor(p_day)::SMALLINT,
                                    floor(p_hour)::SMALLINT,
                                    floor(p_minute)::SMALLINT,
                                    v_calc_seconds);
    RETURN CASE
              WHEN (v_milliseconds != 1000) THEN v_resdatetime
              ELSE v_resdatetime + INTERVAL '1 second'
           END;
EXCEPTION
    WHEN invalid_datetime_format THEN
        RAISE USING MESSAGE := 'Cannot construct data type datetime, some of the arguments have values which are not valid.',
                    DETAIL := 'Possible use of incorrect value of date or time part (which lies outside of valid range).',
                    HINT := 'Check each input argument belongs to the valid range and try again.';

    WHEN numeric_value_out_of_range THEN
        GET STACKED DIAGNOSTICS v_err_message = MESSAGE_TEXT;
        v_err_message := upper(split_part(v_err_message, ' ', 1));

        RAISE USING MESSAGE := pg_catalog.format('Error while trying to cast to %s data type.', v_err_message),
                    DETAIL := pg_catalog.format('Source value is out of %s data type range.', v_err_message),
                    HINT := pg_catalog.format('Correct the source value you are trying to cast to %s data type and try again.',
                                   v_err_message);
END;
$BODY$
LANGUAGE plpgsql
IMMUTABLE
RETURNS NULL ON NULL INPUT;

CREATE OR REPLACE FUNCTION sys.datetimefromparts(IN p_year TEXT,
                                                               IN p_month TEXT,
                                                               IN p_day TEXT,
                                                               IN p_hour TEXT,
                                                               IN p_minute TEXT,
                                                               IN p_seconds TEXT,
                                                               IN p_milliseconds TEXT)
RETURNS TIMESTAMP WITHOUT TIME ZONE
AS
$BODY$
DECLARE
    v_err_message VARCHAR;
BEGIN
    RETURN sys.datetimefromparts(p_year::NUMERIC, p_month::NUMERIC, p_day::NUMERIC,
                                               p_hour::NUMERIC, p_minute::NUMERIC,
                                               p_seconds::NUMERIC, p_milliseconds::NUMERIC);
EXCEPTION
    WHEN invalid_text_representation THEN
        GET STACKED DIAGNOSTICS v_err_message = MESSAGE_TEXT;
        v_err_message := substring(lower(v_err_message), 'numeric\:\s\"(.*)\"');

        RAISE USING MESSAGE := pg_catalog.format('Error while trying to convert "%s" value to NUMERIC data type.', v_err_message),
                    DETAIL := 'Supplied string value contains illegal characters.',
                    HINT := 'Correct supplied value, remove all illegal characters and try again.';
END;
$BODY$
LANGUAGE plpgsql
IMMUTABLE
RETURNS NULL ON NULL INPUT;

CREATE OR REPLACE FUNCTION sys.isnumeric(IN expr ANYELEMENT) RETURNS INTEGER AS
$BODY$
DECLARE 
    x NUMERIC;
    y MONEY;
BEGIN
    IF (expr IS NULL) THEN
	    RETURN 0;
    END IF;
    IF ($1::VARCHAR COLLATE "C" ~ '^\s*$') THEN 
	    RETURN 0;
    END IF;
    IF pg_typeof(expr) IN ('bigint'::regtype, 'int'::regtype, 'smallint'::regtype,'sys.tinyint'::regtype,
    'numeric'::regtype, 'float'::regtype, 'real'::regtype, 'sys.money'::regtype)
	THEN
		RETURN 1;
	END IF;
    x = $1::NUMERIC;
    RETURN 1;
EXCEPTION WHEN others THEN
    BEGIN
        y = $1::sys.MONEY;
        RETURN 1;
        EXCEPTION WHEN others THEN
            RETURN 0;
    END;
END;
$BODY$
LANGUAGE plpgsql
STABLE CALLED ON NULL INPUT;

CREATE OR REPLACE FUNCTION sys.isnumeric(IN expr TEXT) RETURNS INTEGER AS
$BODY$
DECLARE 
    x NUMERIC;
    y MONEY;
BEGIN
    IF (expr IS NULL) THEN
	    RETURN 0;
    END IF;

    -- IF ($1::VARCHAR ~ '^\s*$') THEN 
    IF (expr COLLATE "C" ~ '^\s*$') THEN 
	    RETURN 0;
    END IF;
    IF pg_typeof(expr) IN ('bigint'::regtype, 'int'::regtype, 'smallint'::regtype,'sys.tinyint'::regtype,
    'numeric'::regtype, 'float'::regtype, 'real'::regtype, 'sys.money'::regtype)
	THEN
		RETURN 1;
	END IF;
    x = $1::NUMERIC;
    RETURN 1;
EXCEPTION WHEN others THEN
    BEGIN
        y = $1::sys.MONEY;
        RETURN 1;
        EXCEPTION WHEN others THEN
            RETURN 0;
    END;
END;
$BODY$
LANGUAGE plpgsql
STABLE CALLED ON NULL INPUT;

-- Return the object ID given the object name. Can specify optional type.
CREATE OR REPLACE FUNCTION sys.object_id(IN object_name sys.VARCHAR, IN object_type sys.VARCHAR DEFAULT NULL)
RETURNS INTEGER AS
'babelfishpg_tsql', 'object_id'
LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION sys.parsename(object_name sys.VARCHAR, object_piece int)
RETURNS sys.SYSNAME
AS 'babelfishpg_tsql', 'parsename'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION sys.timefromparts(IN p_hour NUMERIC,
                                                           IN p_minute NUMERIC,
                                                           IN p_seconds NUMERIC,
                                                           IN p_fractions NUMERIC,
                                                           IN p_precision NUMERIC)
RETURNS TIME WITHOUT TIME ZONE
AS
$BODY$
DECLARE
    v_fractions VARCHAR;
    v_precision SMALLINT;
    v_err_message VARCHAR;
    v_calc_seconds NUMERIC;
BEGIN
    v_fractions := floor(p_fractions)::INTEGER::VARCHAR;
    v_precision := p_precision::SMALLINT;

    IF (scale(p_precision) > 0) THEN
        RAISE most_specific_type_mismatch;
    ELSIF ((p_hour::SMALLINT NOT BETWEEN 0 AND 23) OR
           (p_minute::SMALLINT NOT BETWEEN 0 AND 59) OR
           (p_seconds::SMALLINT NOT BETWEEN 0 AND 59) OR
           (p_fractions::SMALLINT NOT BETWEEN 0 AND 9999999) OR
           (p_fractions::SMALLINT != 0 AND char_length(v_fractions) > v_precision))
    THEN
        RAISE invalid_datetime_format;
    ELSIF (v_precision NOT BETWEEN 0 AND 7) THEN
        RAISE numeric_value_out_of_range;
    END IF;

    v_calc_seconds := pg_catalog.format('%s.%s',
                             floor(p_seconds)::SMALLINT,
                             substring(rpad(lpad(v_fractions, v_precision, '0'), 7, '0'), 1, v_precision))::NUMERIC;

    RETURN make_time(floor(p_hour)::SMALLINT,
                     floor(p_minute)::SMALLINT,
                     v_calc_seconds);
EXCEPTION
    WHEN most_specific_type_mismatch THEN
        RAISE USING MESSAGE := 'Scale argument is not valid. Valid expressions for data type DATETIME2 scale argument are integer constants and integer constant expressions.',
                    DETAIL := 'Use of incorrect "precision" parameter value during conversion process.',
                    HINT := 'Change "precision" parameter to the proper value and try again.';

    WHEN invalid_parameter_value THEN
        RAISE USING MESSAGE := pg_catalog.format('Specified scale %s is invalid.', v_precision),
                    DETAIL := 'Use of incorrect "precision" parameter value during conversion process.',
                    HINT := 'Change "precision" parameter to the proper value and try again.';

    WHEN invalid_datetime_format THEN
        RAISE USING MESSAGE := 'Cannot construct data type time, some of the arguments have values which are not valid.',
                    DETAIL := 'Possible use of incorrect value of time part (which lies outside of valid range).',
                    HINT := 'Check each input argument belongs to the valid range and try again.';

    WHEN numeric_value_out_of_range THEN
        GET STACKED DIAGNOSTICS v_err_message = MESSAGE_TEXT;
        v_err_message := upper(split_part(v_err_message, ' ', 1));

        RAISE USING MESSAGE := pg_catalog.format('Error while trying to cast to %s data type.', v_err_message),
                    DETAIL := pg_catalog.format('Source value is out of %s data type range.', v_err_message),
                    HINT := pg_catalog.format('Correct the source value you are trying to cast to %s data type and try again.',
                                   v_err_message);
END;
$BODY$
LANGUAGE plpgsql
VOLATILE
RETURNS NULL ON NULL INPUT;

CREATE OR REPLACE FUNCTION sys.timefromparts(IN p_hour TEXT,
                                                           IN p_minute TEXT,
                                                           IN p_seconds TEXT,
                                                           IN p_fractions TEXT,
                                                           IN p_precision TEXT)
RETURNS TIME WITHOUT TIME ZONE
AS
$BODY$
DECLARE
    v_err_message VARCHAR;
BEGIN
    RETURN sys.timefromparts(p_hour::NUMERIC, p_minute::NUMERIC,
                                           p_seconds::NUMERIC, p_fractions::NUMERIC,
                                           p_precision::NUMERIC);
EXCEPTION
    WHEN invalid_text_representation THEN
        GET STACKED DIAGNOSTICS v_err_message = MESSAGE_TEXT;
        v_err_message := substring(lower(v_err_message), 'numeric\:\s\"(.*)\"');

        RAISE USING MESSAGE := pg_catalog.format('Error while trying to convert "%s" value to NUMERIC data type.', v_err_message),
                    DETAIL := 'Supplied string value contains illegal characters.',
                    HINT := 'Correct supplied value, remove all illegal characters and try again.';
END;
$BODY$
LANGUAGE plpgsql
VOLATILE
RETURNS NULL ON NULL INPUT;

CREATE OR REPLACE FUNCTION sys.has_dbaccess(database_name SYSNAME) RETURNS INTEGER AS 
'babelfishpg_tsql', 'has_dbaccess'
LANGUAGE C STABLE STRICT;

CREATE OR REPLACE FUNCTION sys.datefromparts(IN year INT, IN month INT, IN day INT)
RETURNS DATE AS
$BODY$
SELECT make_date(year, month, day);
$BODY$
STRICT
LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.charindex(expressionToFind PG_CATALOG.TEXT,
										 expressionToSearch PG_CATALOG.TEXT,
										 start_location INTEGER DEFAULT 0)
RETURNS INTEGER AS
$BODY$
SELECT
CASE
WHEN start_location <= 0 THEN
	strpos(expressionToSearch, expressionToFind)
ELSE
	CASE
	WHEN strpos(substr(expressionToSearch, start_location), expressionToFind) = 0 THEN
		0
	ELSE
		strpos(substr(expressionToSearch, start_location), expressionToFind) + start_location - 1
	END
END;
$BODY$
STRICT
LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.DATETIMEOFFSETFROMPARTS(IN p_year INTEGER,
                                                               IN p_month INTEGER,
                                                               IN p_day INTEGER,
                                                               IN p_hour INTEGER,
                                                               IN p_minute INTEGER,
                                                               IN p_seconds INTEGER,
                                                               IN p_fractions INTEGER,
                                                               IN p_hour_offset INTEGER,
                                                               IN p_minute_offset INTEGER,
                                                               IN p_precision NUMERIC)
RETURNS sys.DATETIMEOFFSET
AS
$BODY$
DECLARE
    v_err_message SYS.VARCHAR;
    v_fractions SYS.VARCHAR;
    v_precision SMALLINT;
    v_calc_seconds NUMERIC; 
    v_resdatetime TIMESTAMP WITHOUT TIME ZONE;
    v_string pg_catalog.text;
    v_sign pg_catalog.text;
BEGIN
    v_fractions := p_fractions::SYS.VARCHAR;
    IF p_precision IS NULL THEN
        RAISE EXCEPTION 'Scale argument is not valid. Valid expressions for data type datetimeoffset scale argument are integer constants and integer constant expressions.';
    END IF;
    IF p_year IS NULL OR p_month is NULL OR p_day IS NULL OR p_hour IS NULL OR p_minute IS NULL OR p_seconds IS NULL OR p_fractions IS NULL
            OR p_hour_offset IS NULL OR p_minute_offset is NULL THEN
        RETURN NULL;
    END IF;
    v_precision := p_precision::SMALLINT;

    IF (scale(p_precision) > 0) THEN
        RAISE most_specific_type_mismatch;

    -- Check if arguments are out of range
    ELSIF ((p_year NOT BETWEEN 1753 AND 9999) OR
        (p_month NOT BETWEEN 1 AND 12) OR
        (p_day NOT BETWEEN 1 AND 31) OR
        (p_hour NOT BETWEEN 0 AND 23) OR
        (p_minute NOT BETWEEN 0 AND 59) OR
        (p_seconds NOT BETWEEN 0 AND 59) OR
        (p_hour_offset NOT BETWEEN -14 AND 14) OR
        (p_minute_offset NOT BETWEEN -59 AND 59) OR
        (p_hour_offset * p_minute_offset < 0) OR
        (p_hour_offset = 14 AND p_minute_offset != 0) OR
        (p_hour_offset = -14 AND p_minute_offset != 0) OR
        (p_fractions != 0 AND char_length(v_fractions) > p_precision::SMALLINT))
    THEN
        RAISE invalid_datetime_format;
    ELSIF (v_precision NOT BETWEEN 0 AND 7) THEN
        RAISE numeric_value_out_of_range;
    END IF;
    v_calc_seconds := format('%s.%s',
                             p_seconds,
                             substring(rpad(lpad(v_fractions, v_precision, '0'), 7, '0'), 1, 6))::NUMERIC;

    v_resdatetime := make_timestamp(p_year,
                                    p_month,
                                    p_day,
                                    p_hour,
                                    p_minute,
                                    v_calc_seconds);
    v_sign := (
        SELECT CASE
            WHEN (p_hour_offset) > 0
                THEN '+'
            WHEN (p_hour_offset) = 0 AND (p_minute_offset) >= 0
                THEN '+'    
            ELSE '-'
        END
    );
    v_string := PG_CATALOG.CONCAT(v_resdatetime::pg_catalog.text,v_sign,abs(p_hour_offset)::SMALLINT::text,':',
                                                          abs(p_minute_offset)::SMALLINT::text);
    RETURN CAST(v_string AS sys.DATETIMEOFFSET);
EXCEPTION
    WHEN most_specific_type_mismatch THEN
        RAISE USING MESSAGE := 'Scale argument is not valid. Valid expressions for data type datetimeoffset scale argument are integer constants and integer constant expressions',
                    DETAIL := 'Use of incorrect "precision" parameter value during conversion process.',
                    HINT := 'Change "precision" parameter to the proper value and try again.';    
    WHEN invalid_datetime_format THEN
        RAISE USING MESSAGE := 'Cannot construct data type datetimeoffset, some of the arguments have values which are not valid.',
                    DETAIL := 'Possible use of incorrect value of date or time part (which lies outside of valid range).',
                    HINT := 'Check each input argument belongs to the valid range and try again.';

    WHEN numeric_value_out_of_range THEN
        RAISE USING MESSAGE := format('Specified scale % is invalid.', p_fractions),
                    DETAIL := format('Source value is out of %s data type range.', v_err_message),
                    HINT := format('Correct the source value you are trying to cast to %s data type and try again.',
                                   v_err_message);
END;
$BODY$
LANGUAGE plpgsql
IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.SMALLDATETIMEFROMPARTS(IN p_year INTEGER,
                                                               IN p_month INTEGER,
                                                               IN p_day INTEGER,
                                                               IN p_hour INTEGER,
                                                               IN p_minute INTEGER
                                                               )
RETURNS sys.smalldatetime
AS
$BODY$
DECLARE
    v_ressmalldatetime TIMESTAMP WITHOUT TIME ZONE;
    v_string pg_catalog.text;
    p_seconds INTEGER;
BEGIN
    IF p_year IS NULL OR p_month is NULL OR p_day IS NULL OR p_hour IS NULL OR p_minute IS NULL THEN
        RETURN NULL;
    END IF;

    -- Check if arguments are out of range
    IF ((p_year NOT BETWEEN 1900 AND 2079) OR
        (p_month NOT BETWEEN 1 AND 12) OR
        (p_day NOT BETWEEN 1 AND 31) OR
        (p_hour NOT BETWEEN 0 AND 23) OR
        (p_minute NOT BETWEEN 0 AND 59) OR (p_year = 2079 AND p_month > 6) OR (p_year = 2079 AND p_month = 6 AND p_day > 6))
    THEN
        RAISE invalid_datetime_format;
    END IF;
    p_seconds := 0;
    v_ressmalldatetime := make_timestamp(p_year,
                                    p_month,
                                    p_day,
                                    p_hour,
                                    p_minute,
                                    p_seconds);

    v_string := v_ressmalldatetime::pg_catalog.text;
    RETURN CAST(v_string AS sys.SMALLDATETIME);
EXCEPTION   
    WHEN invalid_datetime_format THEN
        RAISE USING MESSAGE := 'Cannot construct data type smalldatetime, some of the arguments have values which are not valid.',
                    DETAIL := 'Possible use of incorrect value of date or time part (which lies outside of valid range).',
                    HINT := 'Check each input argument belongs to the valid range and try again.';
END;
$BODY$
LANGUAGE plpgsql
IMMUTABLE;

-- wrapper functions for stuff --
CREATE OR REPLACE FUNCTION sys.stuff(expr sys.VARBINARY, start INTEGER, length INTEGER, replace_expr sys.VARCHAR)
RETURNS sys.VARBINARY
AS
$BODY$
BEGIN
    IF start IS NULL OR expr IS NULL OR length IS NULL THEN
        RETURN NULL;
    END IF;
    IF start <= 0 OR start > sys.len(expr) OR length < 0 THEN
        RETURN NULL;
    END IF;
    IF replace_expr IS NULL THEN
        RETURN (SELECT (overlay (expr::sys.VARCHAR placing '' from start for length))::sys.VARCHAR)::sys.VARBINARY;
    END IF;
    RETURN (SELECT (overlay (expr::sys.VARCHAR placing replace_expr::sys.VARCHAR from start for length))::sys.VARCHAR)::sys.VARBINARY;
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.stuff(expr sys.VARCHAR, start INTEGER, length INTEGER, replace_expr sys.VARCHAR)
RETURNS sys.VARCHAR
AS
$BODY$
BEGIN
    IF start IS NULL OR expr IS NULL OR length IS NULL THEN
        RETURN NULL;
    END IF;
    IF start <= 0 OR start > length(expr) OR length < 0 THEN
        RETURN NULL;
    END IF;
    IF replace_expr IS NULL THEN
        RETURN (SELECT overlay (expr placing '' from start for length));
    END IF;
    RETURN (SELECT overlay (expr placing replace_expr from start for length));
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.stuff(expr sys.NVARCHAR, start INTEGER, length INTEGER, replace_expr sys.NVARCHAR)
RETURNS sys.NVARCHAR
AS
$BODY$
BEGIN
    IF start IS NULL OR expr IS NULL OR length IS NULL THEN
        RETURN NULL;
    END IF;
    IF start <= 0 OR start > length(expr) OR length < 0 THEN
        RETURN NULL;
    END IF;
    IF replace_expr IS NULL THEN
        RETURN (SELECT overlay (expr placing '' from start for length));
    END IF;
    RETURN (SELECT overlay (expr placing replace_expr from start for length));
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.len(expr TEXT) RETURNS INTEGER AS
$BODY$
SELECT length(trim(trailing from expr));
$BODY$
STRICT
LANGUAGE SQL IMMUTABLE;

-- Added for BABEL-1544
CREATE OR REPLACE FUNCTION sys.len(expr sys.BBF_VARBINARY) RETURNS INTEGER AS
'babelfishpg_common', 'varbinary_length'
STRICT
LANGUAGE c IMMUTABLE PARALLEL SAFE;

-- DATALENGTH
CREATE OR REPLACE FUNCTION sys.datalength(ANYELEMENT) RETURNS INTEGER
AS 'babelfishpg_tsql', 'datalength' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
-- provide both additional functions here to avoid implicit casting between string literals with/without N''
CREATE OR REPLACE FUNCTION sys.datalength(text) RETURNS INTEGER
AS 'babelfishpg_tsql', 'datalength' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
CREATE OR REPLACE FUNCTION sys.datalength(char) RETURNS INTEGER
AS 'babelfishpg_tsql', 'datalength' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
-- TODO: in MSSQL datalength against varchar(max) will return BIGINT instead of INTEGER. However in PG we ignore typmods in functions.
-- However this is not a critical issue so we will just leave it. We may come back to this difference later once we find out solution to typmods.

CREATE OR REPLACE FUNCTION sys.round(number PG_CATALOG.NUMERIC, length INTEGER)
RETURNS NUMERIC AS 'babelfishpg_common', 'tsql_numeric_round' LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.round(number PG_CATALOG.NUMERIC, length INTEGER, function INTEGER)
RETURNS NUMERIC AS 'babelfishpg_common', 'tsql_numeric_trunc' LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.day(date ANYELEMENT)
RETURNS INTEGER AS
$BODY$
SELECT sys.datepart('day', date);
$BODY$
STRICT
LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.month(date ANYELEMENT)
RETURNS INTEGER AS
$BODY$
SELECT sys.datepart('month', date);
$BODY$
STRICT
LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.year(date ANYELEMENT)
RETURNS INTEGER AS
$BODY$
SELECT sys.datepart('year', date);
$BODY$
STRICT
LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.space(IN number INTEGER, OUT result SYS.VARCHAR) AS $$
-- sys.varchar has default length of 1, so we have to pass in 'number' to be the
-- type modifier.
BEGIN
	EXECUTE pg_catalog.format(E'SELECT repeat(\' \', %s)::SYS.VARCHAR(%s)', number, number) INTO result;
END;
$$
STRICT
LANGUAGE plpgsql;

create or replace function sys.isdate(v text)
returns integer
as
$body$
begin
    if v is NULL THEN
        return 0;
    else
        perform v::date;
        return 1;
    end if;
    EXCEPTION WHEN others THEN
    RETURN 0;
end
$body$
language 'plpgsql' STABLE;

CREATE OR REPLACE FUNCTION sys.is_collated_ci_as_internal(IN input_string TEXT) RETURNS BOOL
AS 'babelfishpg_tsql', 'is_collated_ci_as_internal'
LANGUAGE C VOLATILE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.is_collated_ci_as(IN input_string TEXT)
RETURNS BOOL AS
$$
	SELECT sys.is_collated_ci_as_internal(input_string);
$$
LANGUAGE SQL VOLATILE PARALLEL SAFE;

create or replace function sys.PATINDEX(in pattern varchar, in expression varchar) returns bigint as
$body$
declare
  v_find_result VARCHAR;
  v_pos bigint;
  v_regexp_pattern VARCHAR;
begin
  if pattern is null or expression is null then
    return null;
  end if;
  if PG_CATALOG.left(pattern, 1) = '%' collate sys.database_default then
    v_regexp_pattern := regexp_replace(pattern, '^%', '%#"', 'i'::pg_catalog.TEXT);
  else
    v_regexp_pattern := '#"' || pattern;
  end if;

  if PG_CATALOG.right(pattern, 1) = '%' collate sys.database_default then
    v_regexp_pattern := regexp_replace(v_regexp_pattern, '%$', '#"%', 'i'::pg_catalog.TEXT);
  else
   v_regexp_pattern := v_regexp_pattern || '#"';
  end if;
  v_find_result := substring(expression, v_regexp_pattern, '#');
  if v_find_result <> '' collate sys.database_default then
    v_pos := strpos(expression, v_find_result);
  else
    v_pos := 0;
  end if;
  return v_pos;
end;
$body$
language plpgsql immutable returns null on null input;

create or replace function sys.RAND(x in int)returns double precision
AS 'babelfishpg_tsql', 'tsql_random'
LANGUAGE C IMMUTABLE STRICT COST 1 PARALLEL RESTRICTED;

create or replace function sys.square(in x double precision) returns double precision
AS
$BODY$
DECLARE
	res double precision;
BEGIN
	res = pow(x, 2::float);
	return res;
END;
$BODY$
LANGUAGE plpgsql PARALLEL SAFE IMMUTABLE RETURNS NULL ON NULL INPUT;

CREATE OR REPLACE FUNCTION sys.atn2(IN x SYS.FLOAT, IN y SYS.FLOAT) RETURNS SYS.FLOAT
AS
$$
DECLARE
    res SYS.FLOAT;
BEGIN
    IF x = 0 AND y = 0 THEN
        RAISE EXCEPTION 'An invalid floating point operation occurred.';
    ELSE
        res = PG_CATALOG.atan2(x, y);
        RETURN res;
    END IF;
END;
$$
LANGUAGE plpgsql PARALLEL SAFE IMMUTABLE RETURNS NULL ON NULL INPUT;

CREATE OR REPLACE FUNCTION sys.datepart(IN datepart PG_CATALOG.TEXT, IN arg anyelement) RETURNS INTEGER
AS
$body$
BEGIN
    IF pg_typeof(arg) = 'sys.DATETIMEOFFSET'::regtype THEN
        return sys.datepart_internal(datepart, arg::timestamp,
                     sys.babelfish_get_datetimeoffset_tzoffset(arg)::integer);
    ELSE
        return sys.datepart_internal(datepart, arg);
    END IF;
END;
$body$
LANGUAGE plpgsql IMMUTABLE;

-- Duplicate function with arg TEXT since ANYELEMENT cannot handle type unknown.
CREATE OR REPLACE FUNCTION sys.datepart(IN datepart TEXT, IN arg TEXT) RETURNS INTEGER
AS
$body$
BEGIN
    IF pg_typeof(arg) = 'sys.DATETIMEOFFSET'::regtype THEN
        return sys.datepart_internal(datepart, arg::timestamp,
                     sys.babelfish_get_datetimeoffset_tzoffset(arg)::integer);
    ELSIF pg_typeof(arg) = 'pg_catalog.text'::regtype THEN
        return sys.datepart_internal(datepart, arg::sys.datetimeoffset::timestamp, sys.babelfish_get_datetimeoffset_tzoffset(arg::sys.datetimeoffset)::integer);
    ELSE
        return sys.datepart_internal(datepart, arg);
    END IF;
END;
$body$
LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.datediff(IN datepart PG_CATALOG.TEXT, IN startdate PG_CATALOG.date, IN enddate PG_CATALOG.date) RETURNS INTEGER
AS
$body$
BEGIN
    return CAST(sys.datediff_internal_date(datepart, startdate, enddate) AS INTEGER);
END
$body$
LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.datediff(IN datepart PG_CATALOG.TEXT, IN startdate sys.datetime, IN enddate sys.datetime) RETURNS INTEGER
AS
$body$
BEGIN
    return CAST(sys.datediff_internal(datepart, startdate::TIMESTAMP, enddate::TIMESTAMP) AS INTEGER);
END
$body$
LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.datediff(IN datepart PG_CATALOG.TEXT, IN startdate sys.datetimeoffset, IN enddate sys.datetimeoffset) RETURNS INTEGER
AS
$body$
BEGIN
    return CAST(sys.datediff_internal_df(datepart, startdate, enddate) AS INTEGER);
END
$body$
LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.datediff(IN datepart PG_CATALOG.TEXT, IN startdate sys.datetime2, IN enddate sys.datetime2) RETURNS INTEGER
AS
$body$
BEGIN
    return CAST(sys.datediff_internal(datepart, startdate::TIMESTAMP, enddate::TIMESTAMP) AS INTEGER);
END
$body$
LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.datediff(IN datepart PG_CATALOG.TEXT, IN startdate sys.smalldatetime, IN enddate sys.smalldatetime) RETURNS INTEGER
AS
$body$
BEGIN
    return CAST(sys.datediff_internal(datepart, startdate::TIMESTAMP, enddate::TIMESTAMP) AS INTEGER);
END
$body$
LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.datediff(IN datepart PG_CATALOG.TEXT, IN startdate PG_CATALOG.time, IN enddate PG_CATALOG.time) RETURNS INTEGER
AS
$body$
BEGIN
    return CAST(sys.datediff_internal(datepart, startdate, enddate) AS INTEGER);
END
$body$
LANGUAGE plpgsql IMMUTABLE;

-- datediff big
CREATE OR REPLACE FUNCTION sys.datediff_big(IN datepart PG_CATALOG.TEXT, IN startdate PG_CATALOG.date, IN enddate PG_CATALOG.date) RETURNS BIGINT
AS
$body$
BEGIN
    return sys.datediff_internal_date(datepart, startdate, enddate);
END
$body$
LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.datediff_big(IN datepart PG_CATALOG.TEXT, IN startdate sys.datetime, IN enddate sys.datetime) RETURNS BIGINT
AS
$body$
BEGIN
    return sys.datediff_internal(datepart, startdate::TIMESTAMP, enddate::TIMESTAMP);
END
$body$
LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.datediff_big(IN datepart PG_CATALOG.TEXT, IN startdate sys.datetimeoffset, IN enddate sys.datetimeoffset) RETURNS BIGINT
AS
$body$
BEGIN
    return sys.datediff_internal_df(datepart, startdate, enddate);
END
$body$
LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.datediff_big(IN datepart PG_CATALOG.TEXT, IN startdate sys.datetime2, IN enddate sys.datetime2) RETURNS BIGINT
AS
$body$
BEGIN
    return sys.datediff_internal(datepart, startdate::TIMESTAMP, enddate::TIMESTAMP);
END
$body$
LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.datediff_big(IN datepart PG_CATALOG.TEXT, IN startdate sys.smalldatetime, IN enddate sys.smalldatetime) RETURNS BIGINT
AS
$body$
BEGIN
    return sys.datediff_internal(datepart, startdate::TIMESTAMP, enddate::TIMESTAMP);
END
$body$
LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.datediff_big(IN datepart PG_CATALOG.TEXT, IN startdate PG_CATALOG.time, IN enddate PG_CATALOG.time) RETURNS BIGINT
AS
$body$
BEGIN
    return sys.datediff_internal(datepart, startdate, enddate);
END
$body$
LANGUAGE plpgsql IMMUTABLE;


 -- Duplicate functions with arg TEXT since ANYELEMENT cannot handle type unknown.
CREATE OR REPLACE FUNCTION sys.dateadd(IN datepart PG_CATALOG.TEXT, IN num INTEGER, IN startdate TEXT) RETURNS DATETIME
AS
$body$
DECLARE
    is_date INT;
BEGIN
    is_date = sys.isdate(startdate);
    IF (is_date = 1) THEN 
        RETURN sys.dateadd_internal(datepart,num,startdate::datetime);
    ELSEIF (startdate is NULL) THEN
        RETURN NULL;
    ELSE
        RAISE EXCEPTION 'Conversion failed when converting date and/or time from character string.';
    END IF;
END;
$body$
LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.dateadd(IN datepart PG_CATALOG.TEXT, IN num INTEGER, IN startdate sys.bit) RETURNS DATETIME
AS
$body$
BEGIN
        return sys.dateadd_numeric_representation_helper(datepart, num, startdate);
END;
$body$
LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.dateadd(IN datepart PG_CATALOG.TEXT, IN num INTEGER, IN startdate numeric) RETURNS DATETIME
AS
$body$
BEGIN
        return sys.dateadd_numeric_representation_helper(datepart, num, startdate);
END;
$body$
LANGUAGE plpgsql IMMUTABLE;


CREATE OR REPLACE FUNCTION sys.dateadd(IN datepart PG_CATALOG.TEXT, IN num INTEGER, IN startdate real) RETURNS DATETIME
AS
$body$
BEGIN
        return sys.dateadd_numeric_representation_helper(datepart, num, startdate);
END;
$body$
LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.dateadd(IN datepart PG_CATALOG.TEXT, IN num INTEGER, IN startdate double precision) RETURNS DATETIME
AS
$body$
BEGIN
        return sys.dateadd_numeric_representation_helper(datepart, num, startdate);
END;
$body$
LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.dateadd(IN datepart PG_CATALOG.TEXT, IN num INTEGER, IN startdate ANYELEMENT) RETURNS ANYELEMENT
AS
$body$
BEGIN
    IF pg_typeof(startdate) = 'sys.DATETIMEOFFSET'::regtype THEN
        return sys.dateadd_internal_df(datepart, num,
                     startdate);
    ELSE
        return sys.dateadd_internal(datepart, num,
                     startdate);
    END IF;
END;
$body$
LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.dateadd_numeric_representation_helper(IN datepart PG_CATALOG.TEXT, IN num INTEGER, IN startdate ANYELEMENT) RETURNS DATETIME AS $$
DECLARE
    digit_to_startdate DATETIME;
BEGIN
    IF pg_typeof(startdate) IN ('bigint'::regtype, 'int'::regtype, 'smallint'::regtype,'sys.tinyint'::regtype,'sys.decimal'::regtype,
    'numeric'::regtype, 'float'::regtype,'double precision'::regtype, 'real'::regtype, 'sys.money'::regtype,'sys.smallmoney'::regtype,'sys.bit'::regtype) THEN
        digit_to_startdate := CAST('1900-01-01 00:00:00.0' AS sys.DATETIME) + CAST(startdate as sys.DATETIME);
    END IF;

    CASE datepart
	WHEN 'year' THEN
		RETURN digit_to_startdate + make_interval(years => num);
	WHEN 'quarter' THEN
		RETURN digit_to_startdate + make_interval(months => num * 3);
	WHEN 'month' THEN
		RETURN digit_to_startdate + make_interval(months => num);
	WHEN 'dayofyear', 'y' THEN
		RETURN digit_to_startdate + make_interval(days => num);
	WHEN 'day' THEN
		RETURN digit_to_startdate + make_interval(days => num);
	WHEN 'week' THEN
		RETURN digit_to_startdate + make_interval(weeks => num);
	WHEN 'weekday' THEN
		RETURN digit_to_startdate + make_interval(days => num);
	WHEN 'hour' THEN
		RETURN digit_to_startdate + make_interval(hours => num);
	WHEN 'minute' THEN
		RETURN digit_to_startdate + make_interval(mins => num);
	WHEN 'second' THEN
		RETURN digit_to_startdate + make_interval(secs => num);
	WHEN 'millisecond' THEN
		RETURN digit_to_startdate + make_interval(secs => (num::numeric) * 0.001);
	ELSE
		RAISE EXCEPTION 'The datepart % is not supported by date function dateadd for data type datetime.', datepart;
	END CASE;
END;
$$
STRICT
LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.datepart_internal(IN datepart PG_CATALOG.TEXT, IN arg anyelement,IN df_tz INTEGER DEFAULT 0) RETURNS INTEGER AS $$
DECLARE
	result INTEGER;
	first_day DATE;
	first_week_end INTEGER;
	day INTEGER;
    datapart_date sys.DATETIME;
BEGIN
    IF pg_typeof(arg) IN ('bigint'::regtype, 'int'::regtype, 'smallint'::regtype,'sys.tinyint'::regtype,'sys.decimal'::regtype,'numeric'::regtype,
     'float'::regtype, 'double precision'::regtype, 'real'::regtype, 'sys.money'::regtype,'sys.smallmoney'::regtype,'sys.bit'::regtype) THEN
        datapart_date = CAST(arg AS sys.DATETIME);
        CASE datepart
        WHEN 'dow' THEN
            result = (date_part(datepart, datapart_date)::INTEGER - current_setting('babelfishpg_tsql.datefirst')::INTEGER + 7) % 7 + 1;
        WHEN 'tsql_week' THEN
            first_day = make_date(date_part('year', datapart_date)::INTEGER, 1, 1);
            first_week_end = 8 - sys.datepart_internal('dow', first_day)::INTEGER;
            day = date_part('doy', datapart_date)::INTEGER;
            IF day <= first_week_end THEN
                result = 1;
            ELSE
                result = 2 + (day - first_week_end - 1) / 7;
            END IF;
        WHEN 'second' THEN
            result = TRUNC(date_part(datepart, datapart_date))::INTEGER;
        WHEN 'millisecond' THEN
            result = right(date_part(datepart, datapart_date)::TEXT, 3)::INTEGER;
        WHEN 'microsecond' THEN
            result = right(date_part(datepart, datapart_date)::TEXT, 6)::INTEGER;
        WHEN 'nanosecond' THEN
            -- Best we can do - Postgres does not support nanosecond precision
            result = right(date_part('microsecond', datapart_date)::TEXT, 6)::INTEGER * 1000;
        ELSE
            result = date_part(datepart, datapart_date)::INTEGER;
        END CASE;
        RETURN result;
    END IF;
	CASE datepart
	WHEN 'dow' THEN
		result = (date_part(datepart, arg)::INTEGER - current_setting('babelfishpg_tsql.datefirst')::INTEGER + 7) % 7 + 1;
	WHEN 'tsql_week' THEN
		first_day = make_date(date_part('year', arg)::INTEGER, 1, 1);
		first_week_end = 8 - sys.datepart_internal('dow', first_day)::INTEGER;
		day = date_part('doy', arg)::INTEGER;
		IF day <= first_week_end THEN
			result = 1;
		ELSE
			result = 2 + (day - first_week_end - 1) / 7;
		END IF;
	WHEN 'second' THEN
		result = TRUNC(date_part(datepart, arg))::INTEGER;
	WHEN 'millisecond' THEN
		result = right(date_part(datepart, arg)::TEXT, 3)::INTEGER;
	WHEN 'microsecond' THEN
		result = right(date_part(datepart, arg)::TEXT, 6)::INTEGER;
	WHEN 'nanosecond' THEN
		-- Best we can do - Postgres does not support nanosecond precision
		result = right(date_part('microsecond', arg)::TEXT, 6)::INTEGER * 1000;
	WHEN 'tzoffset' THEN
		-- timezone for datetimeoffset
		result = df_tz;
	ELSE
		result = date_part(datepart, arg)::INTEGER;
	END CASE;
	RETURN result;
EXCEPTION WHEN invalid_parameter_value or feature_not_supported THEN
    -- date_part() throws an exception when trying to get day/month/year etc. from
	-- TIME, so we just need to catch the exception in this case
	-- date_part() returns 0 when trying to get hour/minute/second etc. from
	-- DATE, which is the desirable behavior for datepart() as well.
    -- If the date argument data type does not have the specified datepart,
    -- date_part() will return the default value for that datepart.
    CASE datepart
	-- Case for datepart is year, yy and yyyy, all mappings are defined in gram.y.
    WHEN 'year' THEN RETURN 1900;
    -- Case for datepart is quater, qq and q
    WHEN 'quarter' THEN RETURN 1;
    -- Case for datepart is month, mm and m
    WHEN 'month' THEN RETURN 1;
    -- Case for datepart is day, dd and d
    WHEN 'day' THEN RETURN 1;
    -- Case for datepart is dayofyear, dy
    WHEN 'doy' THEN RETURN 1;
    -- Case for datepart is y(also refers to dayofyear)
    WHEN 'y' THEN RETURN 1;
    -- Case for datepart is week, wk and ww
    WHEN 'tsql_week' THEN RETURN 1;
    -- Case for datepart is iso_week, isowk and isoww
    WHEN 'week' THEN RETURN 1;
    -- Case for datepart is tzoffset and tz
    WHEN 'tzoffset' THEN RETURN 0;
    -- Case for datepart is weekday and dw, return dow according to datefirst
    WHEN 'dow' THEN
        RETURN (1 - current_setting('babelfishpg_tsql.datefirst')::INTEGER + 7) % 7 + 1 ;
	ELSE
        RAISE EXCEPTION '''%'' is not a recognized datepart option', datepart;
        RETURN -1;
	END CASE;
END;
$$
STRICT
LANGUAGE plpgsql IMMUTABLE;

/*
    This function is needed when input date is datetimeoffset type. When running the following query in postgres using tsql dialect, it faied.
        select dateadd(minute, -70, '2016-12-26 00:30:05.523456+8'::datetimeoffset);
    We tried to merge this function with sys.dateadd_internal by using '+' when adding interval to datetimeoffset, 
    but the error shows : operator does not exist: sys.datetimeoffset + interval. As the result, we should not use '+' directly
    but should keep using OPERATOR(sys.+) when input date is in datetimeoffset type.
*/
CREATE OR REPLACE FUNCTION sys.dateadd_internal_df(IN datepart PG_CATALOG.TEXT, IN num INTEGER, IN startdate datetimeoffset) RETURNS datetimeoffset AS $$
DECLARE
	timezone INTEGER;
BEGIN
	timezone = sys.babelfish_get_datetimeoffset_tzoffset(startdate)::INTEGER * 2;
	startdate = startdate OPERATOR(sys.+) make_interval(mins => timezone);
	CASE datepart
	WHEN 'year' THEN
		RETURN startdate OPERATOR(sys.+) make_interval(years => num);
	WHEN 'quarter' THEN
		RETURN startdate OPERATOR(sys.+) make_interval(months => num * 3);
	WHEN 'month' THEN
		RETURN startdate OPERATOR(sys.+) make_interval(months => num);
	WHEN 'dayofyear', 'y' THEN
		RETURN startdate OPERATOR(sys.+) make_interval(days => num);
	WHEN 'day' THEN
		RETURN startdate OPERATOR(sys.+) make_interval(days => num);
	WHEN 'week' THEN
		RETURN startdate OPERATOR(sys.+) make_interval(weeks => num);
	WHEN 'weekday' THEN
		RETURN startdate OPERATOR(sys.+) make_interval(days => num);
	WHEN 'hour' THEN
		RETURN startdate OPERATOR(sys.+) make_interval(hours => num);
	WHEN 'minute' THEN
		RETURN startdate OPERATOR(sys.+) make_interval(mins => num);
	WHEN 'second' THEN
		RETURN startdate OPERATOR(sys.+) make_interval(secs => num);
	WHEN 'millisecond' THEN
		RETURN startdate OPERATOR(sys.+) make_interval(secs => (num::numeric) * 0.001);
	WHEN 'microsecond' THEN
		RETURN startdate OPERATOR(sys.+) make_interval(secs => (num::numeric) * 0.000001);
	WHEN 'nanosecond' THEN
		-- Best we can do - Postgres does not support nanosecond precision
		RETURN startdate OPERATOR(sys.+) make_interval(secs => TRUNC((num::numeric)* 0.000000001, 6));
	ELSE
		RAISE EXCEPTION '"%" is not a recognized dateadd option.', datepart;
	END CASE;
END;
$$
STRICT
LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.dateadd_internal(IN datepart PG_CATALOG.TEXT, IN num INTEGER, IN startdate ANYELEMENT) RETURNS ANYELEMENT AS $$
BEGIN
    IF pg_typeof(startdate) = 'date'::regtype AND
		datepart IN ('hour', 'minute', 'second', 'millisecond', 'microsecond', 'nanosecond') THEN
		RAISE EXCEPTION 'The datepart % is not supported by date function dateadd for data type date.', datepart;
	END IF;
    IF pg_typeof(startdate) = 'time'::regtype AND
		datepart IN ('year', 'quarter', 'month', 'doy', 'day', 'week', 'weekday') THEN
		RAISE EXCEPTION 'The datepart % is not supported by date function dateadd for data type time.', datepart;
	END IF;

	CASE datepart
	WHEN 'year' THEN
		RETURN startdate + make_interval(years => num);
	WHEN 'quarter' THEN
		RETURN startdate + make_interval(months => num * 3);
	WHEN 'month' THEN
		RETURN startdate + make_interval(months => num);
	WHEN 'dayofyear', 'y' THEN
		RETURN startdate + make_interval(days => num);
	WHEN 'day' THEN
		RETURN startdate + make_interval(days => num);
	WHEN 'week' THEN
		RETURN startdate + make_interval(weeks => num);
	WHEN 'weekday' THEN
		RETURN startdate + make_interval(days => num);
	WHEN 'hour' THEN
		RETURN startdate + make_interval(hours => num);
	WHEN 'minute' THEN
		RETURN startdate + make_interval(mins => num);
	WHEN 'second' THEN
		RETURN startdate + make_interval(secs => num);
	WHEN 'millisecond' THEN
		RETURN startdate + make_interval(secs => (num::numeric) * 0.001);
	WHEN 'microsecond' THEN
        IF pg_typeof(startdate) = 'time'::regtype THEN
            RETURN startdate + make_interval(secs => (num::numeric) * 0.000001);
        ELSIF pg_typeof(startdate) = 'sys.datetime2'::regtype THEN
            RETURN startdate + make_interval(secs => (num::numeric) * 0.000001);
        ELSIF pg_typeof(startdate) = 'sys.smalldatetime'::regtype THEN
            RAISE EXCEPTION 'The datepart % is not supported by date function dateadd for data type smalldatetime.', datepart;
        ELSE
            RAISE EXCEPTION 'The datepart % is not supported by date function dateadd for data type datetime.', datepart;
        END IF;
	WHEN 'nanosecond' THEN
        IF pg_typeof(startdate) = 'time'::regtype THEN
            RETURN startdate + make_interval(secs => TRUNC((num::numeric)* 0.000000001, 6));
        ELSIF pg_typeof(startdate) = 'sys.datetime2'::regtype THEN
            RETURN startdate + make_interval(secs => TRUNC((num::numeric)* 0.000000001, 6));
        ELSIF pg_typeof(startdate) = 'sys.smalldatetime'::regtype THEN
            RAISE EXCEPTION 'The datepart % is not supported by date function dateadd for data type smalldatetime.', datepart;
        ELSE
            RAISE EXCEPTION 'The datepart % is not supported by date function dateadd for data type datetime.', datepart;
        END IF;
	ELSE
		RAISE EXCEPTION '''%'' is not a recognized dateadd option.', datepart;
	END CASE;
END;
$$
STRICT
LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.datediff_internal_df(IN datepart PG_CATALOG.TEXT, IN startdate anyelement, IN enddate anyelement) RETURNS BIGINT AS $$
DECLARE
	result BIGINT;
	year_diff BIGINT;
	month_diff BIGINT;
	day_diff BIGINT;
	hour_diff BIGINT;
	minute_diff BIGINT;
	second_diff BIGINT;
	millisecond_diff BIGINT;
	microsecond_diff BIGINT;
	y1 BIGINT;
	m1 BIGINT;
	d1 BIGINT;
	y2 BIGINT;
	m2 BIGINT;
	d2 BIGINT;
BEGIN
	CASE datepart
	WHEN 'year' THEN
		year_diff = sys.datepart('year', enddate) - sys.datepart('year', startdate);
		result = year_diff;
	WHEN 'quarter' THEN
		year_diff = sys.datepart('year', enddate) - sys.datepart('year', startdate);
		month_diff = sys.datepart('month', enddate) - sys.datepart('month', startdate);
		result = (year_diff * 12 + month_diff) / 3;
	WHEN 'month' THEN
		year_diff = sys.datepart('year', enddate) - sys.datepart('year', startdate);
		month_diff = sys.datepart('month', enddate) - sys.datepart('month', startdate);
		result = year_diff * 12 + month_diff;
	WHEN 'doy', 'y' THEN
		day_diff = sys.datepart('day', enddate OPERATOR(sys.-) startdate);
		result = day_diff;
	WHEN 'day' THEN
		y1 = sys.datepart('year', enddate);
		m1 = sys.datepart('month', enddate);
		d1 = sys.datepart('day', enddate);
		y2 = sys.datepart('year', startdate);
		m2 = sys.datepart('month', startdate);
		d2 = sys.datepart('day', startdate);
		result = sys.num_days_in_date(d1, m1, y1) - sys.num_days_in_date(d2, m2, y2);
	WHEN 'week' THEN
		day_diff = sys.datepart('day', enddate OPERATOR(sys.-) startdate);
		result = day_diff / 7;
	WHEN 'hour' THEN
		y1 = sys.datepart('year', enddate);
		m1 = sys.datepart('month', enddate);
		d1 = sys.datepart('day', enddate);
		y2 = sys.datepart('year', startdate);
		m2 = sys.datepart('month', startdate);
		d2 = sys.datepart('day', startdate);
		day_diff = sys.num_days_in_date(d1, m1, y1) - sys.num_days_in_date(d2, m2, y2);
		hour_diff = sys.datepart('hour', enddate) - sys.datepart('hour', startdate);
		result = day_diff * 24 + hour_diff;
	WHEN 'minute' THEN
		day_diff = sys.datepart('day', enddate OPERATOR(sys.-) startdate);
		hour_diff = sys.datepart('hour', enddate OPERATOR(sys.-) startdate);
		minute_diff = sys.datepart('minute', enddate OPERATOR(sys.-) startdate);
		result = (day_diff * 24 + hour_diff) * 60 + minute_diff;
	WHEN 'second' THEN
		day_diff = sys.datepart('day', enddate OPERATOR(sys.-) startdate);
		hour_diff = sys.datepart('hour', enddate OPERATOR(sys.-) startdate);
		minute_diff = sys.datepart('minute', enddate OPERATOR(sys.-) startdate);
		second_diff = TRUNC(sys.datepart('second', enddate OPERATOR(sys.-) startdate));
		result = ((day_diff * 24 + hour_diff) * 60 + minute_diff) * 60 + second_diff;
	WHEN 'millisecond' THEN
		-- millisecond result from date_part by default contains second value,
		-- so we do not need to add second_diff again
		day_diff = sys.datepart('day', enddate OPERATOR(sys.-) startdate);
		hour_diff = sys.datepart('hour', enddate OPERATOR(sys.-) startdate);
		minute_diff = sys.datepart('minute', enddate OPERATOR(sys.-) startdate);
		second_diff = TRUNC(sys.datepart('second', enddate OPERATOR(sys.-) startdate));
		millisecond_diff = TRUNC(sys.datepart('millisecond', enddate OPERATOR(sys.-) startdate));
		result = (((day_diff * 24 + hour_diff) * 60 + minute_diff) * 60) * 1000 + millisecond_diff;
	WHEN 'microsecond' THEN
		-- microsecond result from date_part by default contains second and millisecond values,
		-- so we do not need to add second_diff and millisecond_diff again
		day_diff = sys.datepart('day', enddate OPERATOR(sys.-) startdate);
		hour_diff = sys.datepart('hour', enddate OPERATOR(sys.-) startdate);
		minute_diff = sys.datepart('minute', enddate OPERATOR(sys.-) startdate);
		second_diff = TRUNC(sys.datepart('second', enddate OPERATOR(sys.-) startdate));
		millisecond_diff = TRUNC(sys.datepart('millisecond', enddate OPERATOR(sys.-) startdate));
		microsecond_diff = TRUNC(sys.datepart('microsecond', enddate OPERATOR(sys.-) startdate));
		result = ((((day_diff * 24 + hour_diff) * 60 + minute_diff) * 60) * 1000) * 1000 + microsecond_diff;
	WHEN 'nanosecond' THEN
		-- Best we can do - Postgres does not support nanosecond precision
		day_diff = sys.datepart('day', enddate - startdate);
		hour_diff = sys.datepart('hour', enddate OPERATOR(sys.-) startdate);
		minute_diff = sys.datepart('minute', enddate OPERATOR(sys.-) startdate);
		second_diff = TRUNC(sys.datepart('second', enddate OPERATOR(sys.-) startdate));
		millisecond_diff = TRUNC(sys.datepart('millisecond', enddate OPERATOR(sys.-) startdate));
		microsecond_diff = TRUNC(sys.datepart('microsecond', enddate OPERATOR(sys.-) startdate));
		result = (((((day_diff * 24 + hour_diff) * 60 + minute_diff) * 60) * 1000) * 1000 + microsecond_diff) * 1000;
	ELSE
		RAISE EXCEPTION '"%" is not a recognized datediff option.', datepart;
	END CASE;

	return result;
END;
$$
STRICT
LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.datediff_internal_date(IN datepart PG_CATALOG.TEXT, IN startdate PG_CATALOG.date, IN enddate PG_CATALOG.date) RETURNS BIGINT AS $$
DECLARE
	result BIGINT;
	year_diff BIGINT;
	month_diff BIGINT;
	day_diff BIGINT;
	hour_diff BIGINT;
	minute_diff BIGINT;
	second_diff BIGINT;
	millisecond_diff BIGINT;
	microsecond_diff BIGINT;
BEGIN
	CASE datepart
	WHEN 'year' THEN
		year_diff = date_part('year', enddate)::BIGINT - date_part('year', startdate)::BIGINT;
		result = year_diff;
	WHEN 'quarter' THEN
		year_diff = date_part('year', enddate)::BIGINT - date_part('year', startdate)::BIGINT;
		month_diff = date_part('month', enddate)::BIGINT - date_part('month', startdate)::BIGINT;
		result = (year_diff * 12 + month_diff) / 3;
	WHEN 'month' THEN
		year_diff = date_part('year', enddate)::BIGINT - date_part('year', startdate)::BIGINT;
		month_diff = date_part('month', enddate)::BIGINT - date_part('month', startdate)::BIGINT;
		result = year_diff * 12 + month_diff;
	-- for all intervals smaller than month, (DATE - DATE) already returns the integer number of days
	-- between the dates, so just use that directly as the day_diff. There is no finer resolution
	-- than days with the DATE type anyways.
	WHEN 'doy', 'y' THEN
		day_diff = enddate - startdate;
		result = day_diff;
	WHEN 'day' THEN
		day_diff = enddate - startdate;
		result = day_diff;
	WHEN 'week' THEN
		day_diff = enddate - startdate;
		result = day_diff / 7;
	WHEN 'hour' THEN
		day_diff = enddate - startdate;
		result = day_diff * 24;
	WHEN 'minute' THEN
		day_diff = enddate - startdate;
		result = day_diff * 24 * 60;
	WHEN 'second' THEN
		day_diff = enddate - startdate;
		result = day_diff * 24 * 60 * 60;
	WHEN 'millisecond' THEN
		-- millisecond result from date_part by default contains second value,
		-- so we do not need to add second_diff again
		day_diff = enddate - startdate;
		result = day_diff * 24 * 60 * 60 * 1000;
	WHEN 'microsecond' THEN
		-- microsecond result from date_part by default contains second and millisecond values,
		-- so we do not need to add second_diff and millisecond_diff again
		day_diff = enddate - startdate;
		result = day_diff * 24 * 60 * 60 * 1000 * 1000;
	WHEN 'nanosecond' THEN
		-- Best we can do - Postgres does not support nanosecond precision
		day_diff = enddate - startdate;
		result = day_diff * 24 * 60 * 60 * 1000 * 1000 * 1000;
	ELSE
		RAISE EXCEPTION '"%" is not a recognized datediff option.', datepart;
	END CASE;

	return result;
END;
$$
STRICT
LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.datediff_internal(IN datepart PG_CATALOG.TEXT, IN startdate anyelement, IN enddate anyelement) RETURNS BIGINT AS $$
DECLARE
	result BIGINT;
	year_diff BIGINT;
	month_diff BIGINT;
	day_diff BIGINT;
	hour_diff BIGINT;
	minute_diff BIGINT;
	second_diff BIGINT;
	millisecond_diff BIGINT;
	microsecond_diff BIGINT;
	y1 BIGINT;
	m1 BIGINT;
	d1 BIGINT;
	y2 BIGINT;
	m2 BIGINT;
	d2 BIGINT;
BEGIN
	CASE datepart
	WHEN 'year' THEN
		year_diff = date_part('year', enddate)::BIGINT - date_part('year', startdate)::BIGINT;
		result = year_diff;
	WHEN 'quarter' THEN
		year_diff = date_part('year', enddate)::BIGINT - date_part('year', startdate)::BIGINT;
		month_diff = date_part('month', enddate)::BIGINT - date_part('month', startdate)::BIGINT;
		result = (year_diff * 12 + month_diff) / 3;
	WHEN 'month' THEN
		year_diff = date_part('year', enddate)::BIGINT - date_part('year', startdate)::BIGINT;
		month_diff = date_part('month', enddate)::BIGINT - date_part('month', startdate)::BIGINT;
		result = year_diff * 12 + month_diff;
	WHEN 'doy', 'y' THEN
		day_diff = date_part('day', enddate OPERATOR(sys.-) startdate)::BIGINT;
		result = day_diff;
	WHEN 'day' THEN
		y1 = date_part('year', enddate)::BIGINT;
		m1 = date_part('month', enddate)::BIGINT;
		d1 = date_part('day', enddate)::BIGINT;
		y2 = date_part('year', startdate)::BIGINT;
		m2 = date_part('month', startdate)::BIGINT;
		d2 = date_part('day', startdate)::BIGINT;
		result = sys.num_days_in_date(d1, m1, y1) - sys.num_days_in_date(d2, m2, y2);
	WHEN 'week' THEN
		day_diff = date_part('day', enddate OPERATOR(sys.-) startdate)::BIGINT;
		result = day_diff / 7;
	WHEN 'hour' THEN
		y1 = date_part('year', enddate)::BIGINT;
		m1 = date_part('month', enddate)::BIGINT;
		d1 = date_part('day', enddate)::BIGINT;
		y2 = date_part('year', startdate)::BIGINT;
		m2 = date_part('month', startdate)::BIGINT;
		d2 = date_part('day', startdate)::BIGINT;
		day_diff = sys.num_days_in_date(d1, m1, y1) - sys.num_days_in_date(d2, m2, y2);
		hour_diff = date_part('hour', enddate)::BIGINT - date_part('hour', startdate)::BIGINT;
		result = day_diff * 24 + hour_diff;
	WHEN 'minute' THEN
		day_diff = date_part('day', enddate OPERATOR(sys.-) startdate)::BIGINT;
		hour_diff = date_part('hour', enddate OPERATOR(sys.-) startdate)::BIGINT;
		minute_diff = date_part('minute', enddate OPERATOR(sys.-) startdate)::BIGINT;
		result = (day_diff * 24 + hour_diff) * 60 + minute_diff;
	WHEN 'second' THEN
		day_diff = date_part('day', enddate OPERATOR(sys.-) startdate)::BIGINT;
		hour_diff = date_part('hour', enddate OPERATOR(sys.-) startdate)::BIGINT;
		minute_diff = date_part('minute', enddate OPERATOR(sys.-) startdate)::BIGINT;
		second_diff = TRUNC(date_part('second', enddate OPERATOR(sys.-) startdate));
		result = ((day_diff * 24 + hour_diff) * 60 + minute_diff) * 60 + second_diff;
	WHEN 'millisecond' THEN
		-- millisecond result from date_part by default contains second value,
		-- so we do not need to add second_diff again
		day_diff = date_part('day', enddate OPERATOR(sys.-) startdate)::BIGINT;
		hour_diff = date_part('hour', enddate OPERATOR(sys.-) startdate)::BIGINT;
		minute_diff = date_part('minute', enddate OPERATOR(sys.-) startdate)::BIGINT;
		second_diff = TRUNC(date_part('second', enddate OPERATOR(sys.-) startdate));
		millisecond_diff = TRUNC(date_part('millisecond', enddate OPERATOR(sys.-) startdate));
		result = (((day_diff * 24 + hour_diff) * 60 + minute_diff) * 60) * 1000 + millisecond_diff;
	WHEN 'microsecond' THEN
		-- microsecond result from date_part by default contains second and millisecond values,
		-- so we do not need to add second_diff and millisecond_diff again
		day_diff = date_part('day', enddate OPERATOR(sys.-) startdate)::BIGINT;
		hour_diff = date_part('hour', enddate OPERATOR(sys.-) startdate)::BIGINT;
		minute_diff = date_part('minute', enddate OPERATOR(sys.-) startdate)::BIGINT;
		second_diff = TRUNC(date_part('second', enddate OPERATOR(sys.-) startdate));
		millisecond_diff = TRUNC(date_part('millisecond', enddate OPERATOR(sys.-) startdate));
		microsecond_diff = TRUNC(date_part('microsecond', enddate OPERATOR(sys.-) startdate));
		result = ((((day_diff * 24 + hour_diff) * 60 + minute_diff) * 60) * 1000) * 1000 + microsecond_diff;
	WHEN 'nanosecond' THEN
		-- Best we can do - Postgres does not support nanosecond precision
		day_diff = date_part('day', enddate OPERATOR(sys.-) startdate)::BIGINT;
		hour_diff = date_part('hour', enddate OPERATOR(sys.-) startdate)::BIGINT;
		minute_diff = date_part('minute', enddate OPERATOR(sys.-) startdate)::BIGINT;
		second_diff = TRUNC(date_part('second', enddate OPERATOR(sys.-) startdate));
		millisecond_diff = TRUNC(date_part('millisecond', enddate OPERATOR(sys.-) startdate));
		microsecond_diff = TRUNC(date_part('microsecond', enddate OPERATOR(sys.-) startdate));
		result = (((((day_diff * 24 + hour_diff) * 60 + minute_diff) * 60) * 1000) * 1000 + microsecond_diff) * 1000;
	ELSE
		RAISE EXCEPTION '"%" is not a recognized datediff option.', datepart;
	END CASE;

	return result;
END;
$$
STRICT
LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.datename(IN dp PG_CATALOG.TEXT, IN arg anyelement) RETURNS TEXT AS 
$BODY$
SELECT
    CASE
    WHEN dp = 'month'::text THEN
        to_char(arg::sys.DATETIME, 'TMMonth')
    -- '1969-12-28' is a Sunday
    WHEN dp = 'dow'::text THEN
        to_char(arg::sys.DATETIME, 'TMDay')
    ELSE
        sys.datepart(dp, arg)::TEXT
    END 
$BODY$
STRICT
LANGUAGE sql IMMUTABLE;

-- Duplicate functions with arg TEXT since ANYELEMENT cannot handle type unknown.
CREATE OR REPLACE FUNCTION sys.datename(IN dp PG_CATALOG.TEXT, IN arg TEXT) RETURNS TEXT AS
$BODY$
SELECT
    CASE
    WHEN dp = 'month'::text THEN
        to_char(arg::date, 'TMMonth')
    -- '1969-12-28' is a Sunday
    WHEN dp = 'dow'::text THEN
        to_char(arg::date, 'TMDay')
    ELSE
        sys.datepart(dp, arg)::TEXT
    END
$BODY$
STRICT
LANGUAGE sql IMMUTABLE;

-- These come from the built-in pg_catalog.count in pg_aggregate.dat
CREATE AGGREGATE sys.count(*)
(
	sfunc = int8inc,
	combinefunc = int8pl,
	msfunc = int8inc,
	minvfunc = int8dec,
	stype = int8,
	mstype = int8,
	initcond = 0,
	minitcond = 0,
	finalfunc = int4,
	mfinalfunc = int4,
	parallel = safe
);

CREATE AGGREGATE sys.count("any")
(
	sfunc = int8inc_any,
	combinefunc = int8pl,
	msfunc = int8inc_any,
	minvfunc = int8dec_any,
	stype = int8,
	mstype = int8,
	initcond = 0,
	minitcond = 0,
	finalfunc = int4,
	mfinalfunc = int4,
	parallel = safe
);

CREATE AGGREGATE sys.count_big(*)
(
	sfunc = int8inc,
	combinefunc = int8pl,
	msfunc = int8inc,
	minvfunc = int8dec,
	stype = int8,
	mstype = int8,
	initcond = 0,
	minitcond = 0,
	parallel = safe
);

CREATE AGGREGATE sys.count_big("any")
(
	sfunc = int8inc_any,
	combinefunc = int8pl,
	msfunc = int8inc_any,
	minvfunc = int8dec_any,
	stype = int8,
	mstype = int8,
	initcond = 0,
	minitcond = 0,
	parallel = safe
);

-- wrapper functions for replicate
CREATE OR REPLACE FUNCTION sys.replicate(string ANYELEMENT, i INTEGER)
RETURNS sys.VARCHAR
AS
$BODY$
DECLARE
    string_arg_datatype text;
    string_arg_typeid oid;
    string_basetype oid;
BEGIN
    string_arg_typeid := pg_typeof(string)::oid;
    string_arg_datatype := sys.translate_pg_type_to_tsql(string_arg_typeid);
    IF string_arg_datatype IS NULL THEN
        -- for User Defined Datatype, use immediate base type to check for argument datatype validation
        string_basetype := sys.bbf_get_immediate_base_type_of_UDT(string_arg_typeid);
        string_arg_datatype := sys.translate_pg_type_to_tsql(string_basetype);
    END IF;

    -- restricting arguments with invalid datatypes for replicate function
    IF string_arg_datatype IN ('image', 'sql_variant', 'xml', 'geometry', 'geography') THEN
        RAISE EXCEPTION 'Argument data type % is invalid for argument 1 of replicate function.', string_arg_datatype;
    END IF;

    IF i < 0 THEN
        RETURN NULL;
    END IF;

    RETURN PG_CATALOG.repeat(string::sys.varchar, i);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.replicate(string sys.NCHAR, i INTEGER)
RETURNS sys.NVARCHAR
AS
$BODY$
BEGIN
    IF i < 0 THEN
        RETURN NULL;
    END IF;

    RETURN PG_CATALOG.repeat(string, i);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.replicate(string sys.NVARCHAR, i INTEGER)
RETURNS sys.NVARCHAR
AS
$BODY$
BEGIN
    IF i < 0 THEN
        RETURN NULL;
    END IF;

    RETURN PG_CATALOG.repeat(string, i);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

-- Adding following definition will make sure that replicate with text input
-- will use following definition instead of PG replicate
CREATE OR REPLACE FUNCTION sys.replicate(string TEXT, i INTEGER)
RETURNS sys.VARCHAR
AS
$BODY$
BEGIN
    IF i < 0 THEN
        RETURN NULL;
    END IF;

    RETURN PG_CATALOG.repeat(string, i);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

-- Adding following definition will make sure that replicate with ntext input
-- will use following definition instead of PG replicate
CREATE OR REPLACE FUNCTION sys.replicate(string NTEXT, i INTEGER)
RETURNS sys.NVARCHAR
AS
$BODY$
BEGIN
    IF i < 0 THEN
        RETURN NULL;
    END IF;

    RETURN PG_CATALOG.repeat(string, i);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

-- @@ functions
CREATE OR REPLACE FUNCTION sys.rowcount()
RETURNS INT AS 'babelfishpg_tsql' LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION sys.rowcount_big()
RETURNS BIGINT AS 'babelfishpg_tsql' LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION sys.error()
	   RETURNS INT AS 'babelfishpg_tsql' LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION sys.pgerror()
	   RETURNS VARCHAR AS 'babelfishpg_tsql' LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION sys.trancount()
	   RETURNS INT AS 'babelfishpg_tsql' LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION sys.datefirst()
	   RETURNS INT AS 'babelfishpg_tsql' LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION sys.options()
	   RETURNS INT AS 'babelfishpg_tsql' LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION sys.version()
        RETURNS sys.NVARCHAR(255)  AS 'babelfishpg_tsql' LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION sys.servername()
        RETURNS sys.NVARCHAR(128)  AS 'babelfishpg_tsql' LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION sys.servicename()
        RETURNS sys.NVARCHAR(128)  AS 'babelfishpg_tsql' LANGUAGE C STABLE;


CREATE OR REPLACE FUNCTION sys.database_principal_id(IN user_name sys.sysname)
RETURNS OID
AS 'babelfishpg_tsql', 'user_id'
LANGUAGE C IMMUTABLE PARALLEL SAFE STRICT;

CREATE OR REPLACE FUNCTION sys.database_principal_id()
RETURNS OID
AS 'babelfishpg_tsql', 'user_id_noarg'
LANGUAGE C IMMUTABLE PARALLEL SAFE;

-- In tsql @@max_precision represents max precision that server supports
-- As of now, we do not support change in max_precision. So, returning default value
CREATE OR REPLACE FUNCTION sys.max_precision()
RETURNS sys.TINYINT  AS 
$$
BEGIN
  RETURN 38;
END;
$$
LANGUAGE plpgsql;

-- not supported, only syntax support
CREATE OR REPLACE FUNCTION sys.PROCID()
	RETURNS INT AS 'babelfishpg_tsql' LANGUAGE C;

CREATE OR REPLACE FUNCTION sys.spid()
RETURNS INTEGER AS
$BODY$
SELECT pg_backend_pid();
$BODY$
STRICT
LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION sys.get_current_full_xact_id()
    RETURNS XID8 AS 'babelfishpg_tsql' LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION sys.DBTS()
RETURNS sys.ROWVERSION AS
$$
DECLARE
    eh_setting text;
BEGIN
    eh_setting = (select s.setting FROM pg_catalog.pg_settings s where name = 'babelfishpg_tsql.escape_hatch_rowversion');
    IF eh_setting = 'strict' THEN
        RAISE EXCEPTION 'To use @@DBTS, set ''babelfishpg_tsql.escape_hatch_rowversion'' to ''ignore''';
    ELSE
        RETURN sys.get_current_full_xact_id()::sys.ROWVERSION;
    END IF;
END;
$$
STRICT
LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION sys.nestlevel() RETURNS INTEGER AS
$$
DECLARE
    stack text;
    result integer;
BEGIN
    GET DIAGNOSTICS stack = PG_CONTEXT;
    result := array_length(string_to_array(stack, 'function'), 1) - 3; 
    IF result < -1 THEN
        RAISE EXCEPTION 'Invalid output, check stack trace %', stack;
    ELSE
        RETURN result;
    END IF;
END;
$$
LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION sys.fetch_status()
RETURNS INT AS 'babelfishpg_tsql' LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION sys.cursor_rows()
RETURNS INT AS 'babelfishpg_tsql' LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION sys.cursor_status(text, text)
RETURNS INT AS 'babelfishpg_tsql' LANGUAGE C STABLE;

-- Floor for bit
CREATE OR REPLACE FUNCTION sys.floor(sys.bit) RETURNS DOUBLE PRECISION
AS 'babelfishpg_tsql', 'bit_floor' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- Floor overloading for all int types
CREATE OR REPLACE FUNCTION sys.floor(bigint) RETURNS BIGINT
AS 'babelfishpg_tsql', 'int_floor' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.floor(int) RETURNS INT
AS 'babelfishpg_tsql', 'int_floor' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.floor(smallint) RETURNS SMALLINT
AS 'babelfishpg_tsql', 'int_floor' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.floor(tinyint) RETURNS TINYINT
AS 'babelfishpg_tsql', 'int_floor' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- Ceiling for bit
CREATE OR REPLACE FUNCTION sys.ceiling(sys.bit) RETURNS DOUBLE PRECISION
AS 'babelfishpg_tsql', 'bit_ceiling' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

-- Ceiling overloading for all int types
CREATE OR REPLACE FUNCTION sys.ceiling(bigint) RETURNS BIGINT
AS 'babelfishpg_tsql', 'int_ceiling' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.ceiling(int) RETURNS INT
AS 'babelfishpg_tsql', 'int_ceiling' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.ceiling(smallint) RETURNS SMALLINT
AS 'babelfishpg_tsql', 'int_ceiling' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.ceiling(tinyint) RETURNS TINYINT
AS 'babelfishpg_tsql', 'int_ceiling' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE AGGREGATE sys.STDEV(float8) (
    SFUNC = float8_accum,
    FINALFUNC = float8_stddev_samp,
    STYPE = float8[],
    COMBINEFUNC = float8_combine,
    PARALLEL = SAFE,
    INITCOND = '{0,0,0}'
);

CREATE AGGREGATE sys.STDEVP(float8) (
    SFUNC = float8_accum,
    FINALFUNC = float8_stddev_pop,
    STYPE = float8[],
    COMBINEFUNC = float8_combine,
    PARALLEL = SAFE,
    INITCOND = '{0,0,0}'
);

CREATE AGGREGATE sys.VAR(float8) (
    SFUNC = float8_accum,
    FINALFUNC = float8_var_samp,
    STYPE = float8[],
    COMBINEFUNC = float8_combine,
    PARALLEL = SAFE,
    INITCOND = '{0,0,0}'
);

CREATE AGGREGATE sys.VARP(float8) (
    SFUNC = float8_accum,
    FINALFUNC = float8_var_pop,
    STYPE = float8[],
    COMBINEFUNC = float8_combine,
    PARALLEL = SAFE,
    INITCOND = '{0,0,0}'
);

CREATE OR REPLACE FUNCTION sys.microsoftversion()
RETURNS INTEGER AS
$BODY$
	SELECT 201332885::INTEGER;
$BODY$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;
CREATE OR REPLACE FUNCTION sys.APPLOCK_MODE(IN "@dbprincipal" varchar(32),
                                            IN "@resource" varchar(255),
                                            IN "@lockowner" varchar(32) DEFAULT 'TRANSACTION')
RETURNS TEXT
AS 'babelfishpg_tsql', 'APPLOCK_MODE' LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION sys.APPLOCK_TEST(IN "@dbprincipal" varchar(32),
                                            IN "@resource" varchar(255),
											IN "@lockmode" varchar(32),
                                            IN "@lockowner" varchar(32) DEFAULT 'TRANSACTION')
RETURNS SMALLINT
AS 'babelfishpg_tsql', 'APPLOCK_TEST' LANGUAGE C STABLE;

-- Error handling functions
CREATE OR REPLACE FUNCTION sys.xact_state()
RETURNS SMALLINT
AS 'babelfishpg_tsql', 'xact_state' LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION sys.error_line()
RETURNS INT
AS 'babelfishpg_tsql', 'pltsql_error_line' LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION sys.error_message()
RETURNS sys.NVARCHAR(4000)
AS 'babelfishpg_tsql', 'pltsql_error_message' LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION sys.error_number()
RETURNS INT
AS 'babelfishpg_tsql', 'pltsql_error_number' LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION sys.error_procedure()
RETURNS sys.NVARCHAR(128)
AS 'babelfishpg_tsql', 'pltsql_error_procedure' LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION sys.error_severity()
RETURNS INT
AS 'babelfishpg_tsql', 'pltsql_error_severity' LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION sys.error_state()
RETURNS INT
AS 'babelfishpg_tsql', 'pltsql_error_state' LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION sys.rand() RETURNS FLOAT AS
$$
	SELECT random();
$$
LANGUAGE SQL STABLE STRICT PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION sys.DEFAULT_DOMAIN()
RETURNS TEXT
AS 'babelfishpg_tsql', 'default_domain' LANGUAGE C;

CREATE OR REPLACE FUNCTION sys.db_id(sys.nvarchar(128)) RETURNS SMALLINT
AS 'babelfishpg_tsql', 'babelfish_db_id'
LANGUAGE C PARALLEL SAFE IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.db_id() RETURNS SMALLINT
AS 'babelfishpg_tsql', 'babelfish_db_id'
LANGUAGE C PARALLEL SAFE IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.db_name(int) RETURNS sys.nvarchar(128)
AS 'babelfishpg_tsql', 'babelfish_db_name'
LANGUAGE C PARALLEL SAFE IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.db_name() RETURNS sys.nvarchar(128)
AS 'babelfishpg_tsql', 'babelfish_db_name'
LANGUAGE C PARALLEL SAFE IMMUTABLE;

CREATE OR REPLACE FUNCTION sys.exp(IN arg DOUBLE PRECISION)
RETURNS DOUBLE PRECISION
AS 'babelfishpg_tsql', 'tsql_exp'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;
GRANT EXECUTE ON FUNCTION sys.exp(DOUBLE PRECISION) TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.exp(IN arg NUMERIC)
RETURNS DOUBLE PRECISION
AS
$BODY$
SELECT sys.exp(arg::DOUBLE PRECISION);
$BODY$
LANGUAGE SQL IMMUTABLE PARALLEL SAFE;
GRANT EXECUTE ON FUNCTION sys.exp(NUMERIC) TO PUBLIC;

-- For numeric/decimal and float/double precision there is already inbuilt functions,
-- Following sign functions are for remaining datatypes
CREATE OR REPLACE FUNCTION sys.sign(IN arg INT) RETURNS INT AS
$BODY$
SELECT
	CASE
		WHEN arg > 0 THEN 1::INT
		WHEN arg < 0 THEN -1::INT
		ELSE 0::INT
	END;
$BODY$
STRICT
LANGUAGE SQL IMMUTABLE PARALLEL SAFE;
GRANT EXECUTE ON FUNCTION sys.sign(INT) TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.sign(IN arg SMALLINT) RETURNS INT AS
$BODY$
SELECT sys.sign(arg::INT);
$BODY$
LANGUAGE SQL IMMUTABLE PARALLEL SAFE;
GRANT EXECUTE ON FUNCTION sys.sign(SMALLINT) TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.sign(IN arg SYS.TINYINT) RETURNS INT AS
$BODY$
SELECT sys.sign(arg::INT);
$BODY$
LANGUAGE SQL IMMUTABLE PARALLEL SAFE;
GRANT EXECUTE ON FUNCTION sys.sign(SYS.TINYINT) TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.sign(IN arg BIGINT) RETURNS BIGINT AS
$BODY$
SELECT
	CASE
		WHEN arg > 0::BIGINT THEN 1::BIGINT
		WHEN arg < 0::BIGINT THEN -1::BIGINT
		ELSE 0::BIGINT
	END;
$BODY$
LANGUAGE SQL IMMUTABLE PARALLEL SAFE;
GRANT EXECUTE ON FUNCTION sys.sign(BIGINT) TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.sign(IN arg SYS.MONEY) RETURNS SYS.MONEY AS
$BODY$
SELECT
	CASE
		WHEN arg > 0::SYS.MONEY THEN 1::SYS.MONEY
		WHEN arg < 0::SYS.MONEY THEN -1::SYS.MONEY
		ELSE 0::SYS.MONEY
	END;
$BODY$
LANGUAGE SQL IMMUTABLE PARALLEL SAFE;
GRANT EXECUTE ON FUNCTION sys.sign(SYS.MONEY) TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.sign(IN arg SYS.SMALLMONEY) RETURNS SYS.MONEY AS
$BODY$
SELECT sys.sign(arg::SYS.MONEY);
$BODY$
LANGUAGE SQL IMMUTABLE PARALLEL SAFE;
GRANT EXECUTE ON FUNCTION sys.sign(SYS.SMALLMONEY) TO PUBLIC;

-- To handle remaining input datatypes
CREATE OR REPLACE FUNCTION sys.sign(IN arg ANYELEMENT) RETURNS SYS.FLOAT AS
$BODY$
SELECT
	sign(arg::SYS.FLOAT);
$BODY$
LANGUAGE SQL IMMUTABLE PARALLEL SAFE;
GRANT EXECUTE ON FUNCTION sys.sign(ANYELEMENT) TO PUBLIC;

-- Duplicate functions with arg TEXT since ANYELEMNT cannot handle type unknown.
CREATE OR REPLACE FUNCTION sys.sign(IN arg TEXT) RETURNS SYS.FLOAT AS
$BODY$
SELECT
	sign(arg::SYS.FLOAT);
$BODY$
LANGUAGE SQL IMMUTABLE PARALLEL SAFE;
GRANT EXECUTE ON FUNCTION sys.sign(TEXT) TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.lock_timeout()
RETURNS integer
LANGUAGE plpgsql
STABLE STRICT
AS $$
declare return_value integer;
begin
    return_value := (select s.setting FROM pg_catalog.pg_settings s where name = 'babelfishpg_tsql.lock_timeout');
    RETURN return_value;
EXCEPTION
    WHEN others THEN
        RETURN NULL;
END;
$$;
GRANT EXECUTE ON FUNCTION sys.lock_timeout() TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.max_connections()
RETURNS integer
LANGUAGE plpgsql
STABLE STRICT
AS $$
declare return_value integer;
begin
    return_value := (select s.setting FROM pg_catalog.pg_settings s where name = 'max_connections');
    RETURN return_value;
EXCEPTION
    WHEN others THEN
        RETURN NULL;
END;
$$;
GRANT EXECUTE ON FUNCTION sys.max_connections() TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.trigger_nestlevel()
RETURNS integer
LANGUAGE plpgsql
STABLE STRICT
AS $$
declare return_value integer;
begin
    return_value := (select pg_trigger_depth());
    RETURN return_value;
EXCEPTION
    WHEN others THEN
        RETURN NULL;
END;
$$;
GRANT EXECUTE ON FUNCTION sys.trigger_nestlevel() TO PUBLIC;

CREATE OR REPLACE VIEW babelfish_has_perms_by_name_permissions
AS
SELECT t.securable_type,t.permission_name,t.implied_dbo_permissions,t.fully_supported FROM
(
  VALUES
    ('application role', 'alter', 'f', 'f'),
    ('application role', 'any', 'f', 'f'),
    ('application role', 'control', 'f', 'f'),
    ('application role', 'view definition', 'f', 'f'),
    ('assembly', 'alter', 'f', 'f'),
    ('assembly', 'any', 'f', 'f'),
    ('assembly', 'control', 'f', 'f'),
    ('assembly', 'references', 'f', 'f'),
    ('assembly', 'take ownership', 'f', 'f'),
    ('assembly', 'view definition', 'f', 'f'),
    ('asymmetric key', 'alter', 'f', 'f'),
    ('asymmetric key', 'any', 'f', 'f'),
    ('asymmetric key', 'control', 'f', 'f'),
    ('asymmetric key', 'references', 'f', 'f'),
    ('asymmetric key', 'take ownership', 'f', 'f'),
    ('asymmetric key', 'view definition', 'f', 'f'),
    ('availability group', 'alter', 'f', 'f'),
    ('availability group', 'any', 'f', 'f'),
    ('availability group', 'control', 'f', 'f'),
    ('availability group', 'take ownership', 'f', 'f'),
    ('availability group', 'view definition', 'f', 'f'),
    ('certificate', 'alter', 'f', 'f'),
    ('certificate', 'any', 'f', 'f'),
    ('certificate', 'control', 'f', 'f'),
    ('certificate', 'references', 'f', 'f'),
    ('certificate', 'take ownership', 'f', 'f'),
    ('certificate', 'view definition', 'f', 'f'),
    ('contract', 'alter', 'f', 'f'),
    ('contract', 'any', 'f', 'f'),
    ('contract', 'control', 'f', 'f'),
    ('contract', 'references', 'f', 'f'),
    ('contract', 'take ownership', 'f', 'f'),
    ('contract', 'view definition', 'f', 'f'),
    ('database', 'administer database bulk operations', 'f', 'f'),
    ('database', 'alter', 't', 'f'),
    ('database', 'alter any application role', 'f', 'f'),
    ('database', 'alter any assembly', 'f', 'f'),
    ('database', 'alter any asymmetric key', 'f', 'f'),
    ('database', 'alter any certificate', 'f', 'f'),
    ('database', 'alter any column encryption key', 'f', 'f'),
    ('database', 'alter any column master key', 'f', 'f'),
    ('database', 'alter any contract', 'f', 'f'),
    ('database', 'alter any database audit', 'f', 'f'),
    ('database', 'alter any database ddl trigger', 'f', 'f'),
    ('database', 'alter any database event notification', 'f', 'f'),
    ('database', 'alter any database event session', 'f', 'f'),
    ('database', 'alter any database scoped configuration', 'f', 'f'),
    ('database', 'alter any dataspace', 'f', 'f'),
    ('database', 'alter any external data source', 'f', 'f'),
    ('database', 'alter any external file format', 'f', 'f'),
    ('database', 'alter any external language', 'f', 'f'),
    ('database', 'alter any external library', 'f', 'f'),
    ('database', 'alter any fulltext catalog', 'f', 'f'),
    ('database', 'alter any mask', 'f', 'f'),
    ('database', 'alter any message type', 'f', 'f'),
    ('database', 'alter any remote service binding', 'f', 'f'),
    ('database', 'alter any role', 'f', 'f'),
    ('database', 'alter any route', 'f', 'f'),
    ('database', 'alter any schema', 't', 'f'),
    ('database', 'alter any security policy', 'f', 'f'),
    ('database', 'alter any sensitivity classification', 'f', 'f'),
    ('database', 'alter any service', 'f', 'f'),
    ('database', 'alter any symmetric key', 'f', 'f'),
    ('database', 'alter any user', 't', 'f'),
    ('database', 'any', 't', 'f'),
    ('database', 'authenticate', 't', 'f'),
    ('database', 'backup database', 'f', 'f'),
    ('database', 'backup log', 'f', 'f'),
    ('database', 'checkpoint', 'f', 'f'),
    ('database', 'connect', 't', 'f'),
    ('database', 'connect replication', 'f', 'f'),
    ('database', 'control', 't', 'f'),
    ('database', 'create aggregate', 'f', 'f'),
    ('database', 'create assembly', 'f', 'f'),
    ('database', 'create asymmetric key', 'f', 'f'),
    ('database', 'create certificate', 'f', 'f'),
    ('database', 'create contract', 'f', 'f'),
    ('database', 'create database', 't', 'f'),
    ('database', 'create database ddl event notification', 'f', 'f'),
    ('database', 'create default', 'f', 'f'),
    ('database', 'create external language', 'f', 'f'),
    ('database', 'create external library', 'f', 'f'),
    ('database', 'create fulltext catalog', 'f', 'f'),
    ('database', 'create function', 't', 'f'),
    ('database', 'create message type', 'f', 'f'),
    ('database', 'create procedure', 't', 'f'),
    ('database', 'create queue', 'f', 'f'),
    ('database', 'create remote service binding', 'f', 'f'),
    ('database', 'create role', 'f', 'f'),
    ('database', 'create route', 'f', 'f'),
    ('database', 'create rule', 'f', 'f'),
    ('database', 'create schema', 't', 'f'),
    ('database', 'create service', 'f', 'f'),
    ('database', 'create symmetric key', 'f', 'f'),
    ('database', 'create synonym', 't', 'f'),
    ('database', 'create table', 't', 'f'),
    ('database', 'create type', 'f', 'f'),
    ('database', 'create view', 't', 'f'),
    ('database', 'create xml schema collection', 'f', 'f'),
    ('database', 'delete', 't', 'f'),
    ('database', 'execute', 't', 'f'),
    ('database', 'execute any external script', 'f', 'f'),
    ('database', 'insert', 't', 'f'),
    ('database', 'kill database connection', 'f', 'f'),
    ('database', 'references', 't', 'f'),
    ('database', 'select', 't', 'f'),
    ('database', 'showplan', 'f', 'f'),
    ('database', 'subscribe query notifications', 'f', 'f'),
    ('database', 'take ownership', 't', 'f'),
    ('database', 'unmask', 'f', 'f'),
    ('database', 'update', 't', 'f'),
    ('database', 'view any column encryption key definition', 'f', 'f'),
    ('database', 'view any column master key definition', 'f', 'f'),
    ('database', 'view any sensitivity classification', 'f', 'f'),
    ('database', 'view database state', 't', 'f'),
    ('database', 'view definition', 'f', 'f'),
    ('database scoped credential', 'alter', 'f', 'f'),
    ('database scoped credential', 'any', 'f', 'f'),
    ('database scoped credential', 'control', 'f', 'f'),
    ('database scoped credential', 'references', 'f', 'f'),
    ('database scoped credential', 'take ownership', 'f', 'f'),
    ('database scoped credential', 'view definition', 'f', 'f'),
    ('endpoint', 'alter', 'f', 'f'),
    ('endpoint', 'any', 'f', 'f'),
    ('endpoint', 'connect', 'f', 'f'),
    ('endpoint', 'control', 'f', 'f'),
    ('endpoint', 'take ownership', 'f', 'f'),
    ('endpoint', 'view definition', 'f', 'f'),
    ('external language', 'alter', 'f', 'f'),
    ('external language', 'any', 'f', 'f'),
    ('external language', 'control', 'f', 'f'),
    ('external language', 'execute external script', 'f', 'f'),
    ('external language', 'references', 'f', 'f'),
    ('external language', 'take ownership', 'f', 'f'),
    ('external language', 'view definition', 'f', 'f'),
    ('fulltext catalog', 'alter', 'f', 'f'),
    ('fulltext catalog', 'any', 'f', 'f'),
    ('fulltext catalog', 'control', 'f', 'f'),
    ('fulltext catalog', 'references', 'f', 'f'),
    ('fulltext catalog', 'take ownership', 'f', 'f'),
    ('fulltext catalog', 'view definition', 'f', 'f'),
    ('fulltext stoplist', 'alter', 'f', 'f'),
    ('fulltext stoplist', 'any', 'f', 'f'),
    ('fulltext stoplist', 'control', 'f', 'f'),
    ('fulltext stoplist', 'references', 'f', 'f'),
    ('fulltext stoplist', 'take ownership', 'f', 'f'),
    ('fulltext stoplist', 'view definition', 'f', 'f'),
    ('login', 'alter', 'f', 'f'),
    ('login', 'any', 'f', 'f'),
    ('login', 'control', 'f', 'f'),
    ('login', 'impersonate', 'f', 'f'),
    ('login', 'view definition', 'f', 'f'),
    ('message type', 'alter', 'f', 'f'),
    ('message type', 'any', 'f', 'f'),
    ('message type', 'control', 'f', 'f'),
    ('message type', 'references', 'f', 'f'),
    ('message type', 'take ownership', 'f', 'f'),
    ('message type', 'view definition', 'f', 'f'),
    ('object', 'alter', 't', 'f'),
    ('object', 'any', 't', 't'),
    ('object', 'control', 't', 'f'),
    ('object', 'delete', 't', 't'),
    ('object', 'execute', 't', 't'),
    ('object', 'insert', 't', 't'),
    ('object', 'receive', 'f', 'f'),
    ('object', 'references', 't', 't'),
    ('object', 'select', 't', 't'),
    ('object', 'take ownership', 'f', 'f'),
    ('object', 'update', 't', 't'),
    ('object', 'view change tracking', 'f', 'f'),
    ('object', 'view definition', 'f', 'f'),
    ('remote service binding', 'alter', 'f', 'f'),
    ('remote service binding', 'any', 'f', 'f'),
    ('remote service binding', 'control', 'f', 'f'),
    ('remote service binding', 'take ownership', 'f', 'f'),
    ('remote service binding', 'view definition', 'f', 'f'),
    ('role', 'alter', 'f', 'f'),
    ('role', 'any', 'f', 'f'),
    ('role', 'control', 'f', 'f'),
    ('role', 'take ownership', 'f', 'f'),
    ('role', 'view definition', 'f', 'f'),
    ('route', 'alter', 'f', 'f'),
    ('route', 'any', 'f', 'f'),
    ('route', 'control', 'f', 'f'),
    ('route', 'take ownership', 'f', 'f'),
    ('route', 'view definition', 'f', 'f'),
    ('schema', 'alter', 't', 'f'),
    ('schema', 'any', 't', 'f'),
    ('schema', 'control', 't', 'f'),
    ('schema', 'create sequence', 'f', 'f'),
    ('schema', 'delete', 't', 'f'),
    ('schema', 'execute', 't', 'f'),
    ('schema', 'insert', 't', 'f'),
    ('schema', 'references', 't', 'f'),
    ('schema', 'select', 't', 'f'),
    ('schema', 'take ownership', 't', 'f'),
    ('schema', 'update', 't', 'f'),
    ('schema', 'view change tracking', 'f', 'f'),
    ('schema', 'view definition', 'f', 'f'),
    ('search property list', 'alter', 'f', 'f'),
    ('search property list', 'any', 'f', 'f'),
    ('search property list', 'control', 'f', 'f'),
    ('search property list', 'references', 'f', 'f'),
    ('search property list', 'take ownership', 'f', 'f'),
    ('search property list', 'view definition', 'f', 'f'),
    ('server', 'administer bulk operations', 'f', 'f'),
    ('server', 'alter any availability group', 'f', 'f'),
    ('server', 'alter any connection', 'f', 'f'),
    ('server', 'alter any credential', 'f', 'f'),
    ('server', 'alter any database', 't', 'f'),
    ('server', 'alter any endpoint', 'f', 'f'),
    ('server', 'alter any event notification', 'f', 'f'),
    ('server', 'alter any event session', 'f', 'f'),
    ('server', 'alter any linked server', 'f', 'f'),
    ('server', 'alter any login', 'f', 'f'),
    ('server', 'alter any server audit', 'f', 'f'),
    ('server', 'alter any server role', 'f', 'f'),
    ('server', 'alter resources', 'f', 'f'),
    ('server', 'alter server state', 'f', 'f'),
    ('server', 'alter settings', 't', 'f'),
    ('server', 'alter trace', 'f', 'f'),
    ('server', 'any', 't', 'f'),
    ('server', 'authenticate server', 't', 'f'),
    ('server', 'connect any database', 't', 'f'),
    ('server', 'connect sql', 't', 'f'),
    ('server', 'control server', 't', 'f'),
    ('server', 'create any database', 't', 'f'),
    ('server', 'create availability group', 'f', 'f'),
    ('server', 'create ddl event notification', 'f', 'f'),
    ('server', 'create endpoint', 'f', 'f'),
    ('server', 'create server role', 'f', 'f'),
    ('server', 'create trace event notification', 'f', 'f'),
    ('server', 'external access assembly', 'f', 'f'),
    ('server', 'impersonate any login', 'f', 'f'),
    ('server', 'select all user securables', 't', 'f'),
    ('server', 'shutdown', 'f', 'f'),
    ('server', 'unsafe assembly', 'f', 'f'),
    ('server', 'view any database', 't', 'f'),
    ('server', 'view any definition', 'f', 'f'),
    ('server', 'view server state', 't', 'f'),
    ('server role', 'alter', 'f', 'f'),
    ('server role', 'any', 'f', 'f'),
    ('server role', 'control', 'f', 'f'),
    ('server role', 'take ownership', 'f', 'f'),
    ('server role', 'view definition', 'f', 'f'),
    ('service', 'alter', 'f', 'f'),
    ('service', 'any', 'f', 'f'),
    ('service', 'control', 'f', 'f'),
    ('service', 'send', 'f', 'f'),
    ('service', 'take ownership', 'f', 'f'),
    ('service', 'view definition', 'f', 'f'),
    ('symmetric key', 'alter', 'f', 'f'),
    ('symmetric key', 'any', 'f', 'f'),
    ('symmetric key', 'control', 'f', 'f'),
    ('symmetric key', 'references', 'f', 'f'),
    ('symmetric key', 'take ownership', 'f', 'f'),
    ('symmetric key', 'view definition', 'f', 'f'),
    ('type', 'any', 'f', 'f'),
    ('type', 'control', 'f', 'f'),
    ('type', 'execute', 'f', 'f'),
    ('type', 'references', 'f', 'f'),
    ('type', 'take ownership', 'f', 'f'),
    ('type', 'view definition', 'f', 'f'),
    ('user', 'alter', 'f', 'f'),
    ('user', 'any', 'f', 'f'),
    ('user', 'control', 'f', 'f'),
    ('user', 'impersonate', 'f', 'f'),
    ('user', 'view definition', 'f', 'f'),
    ('xml schema collection', 'alter', 'f', 'f'),
    ('xml schema collection', 'any', 'f', 'f'),
    ('xml schema collection', 'control', 'f', 'f'),
    ('xml schema collection', 'execute', 'f', 'f'),
    ('xml schema collection', 'references', 'f', 'f'),
    ('xml schema collection', 'take ownership', 'f', 'f'),
    ('xml schema collection', 'view definition', 'f', 'f')
) t(securable_type, permission_name, implied_dbo_permissions, fully_supported);
GRANT SELECT ON babelfish_has_perms_by_name_permissions TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.has_perms_by_name(
    securable SYS.SYSNAME, 
    securable_class SYS.NVARCHAR(60), 
    permission SYS.SYSNAME,
    sub_securable SYS.SYSNAME DEFAULT NULL,
    sub_securable_class SYS.NVARCHAR(60) DEFAULT NULL
)
RETURNS integer
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    db_name text COLLATE sys.database_default; 
    bbf_schema_name text;
    pg_schema text COLLATE sys.database_default;
    implied_dbo_permissions boolean;
    fully_supported boolean;
    is_cross_db boolean := false;
    object_name text COLLATE sys.database_default;
    database_id smallint;
    namespace_id oid;
    userid oid;
    object_type text;
    function_signature text;
    qualified_name text;
    return_value integer;
    cs_as_securable text COLLATE "C" := securable;
    cs_as_securable_class text COLLATE "C" := securable_class;
    cs_as_permission text COLLATE "C" := permission;
    cs_as_sub_securable text COLLATE "C" := sub_securable;
    cs_as_sub_securable_class text COLLATE "C" := sub_securable_class;
BEGIN
    return_value := NULL;

    -- Lower-case to avoid case issues, remove trailing whitespace to match SQL SERVER behavior
    -- Objects created in Babelfish are stored in lower-case in pg_class/pg_proc
    cs_as_securable = lower(PG_CATALOG.rtrim(cs_as_securable));
    cs_as_securable_class = lower(PG_CATALOG.rtrim(cs_as_securable_class));
    cs_as_permission = lower(PG_CATALOG.rtrim(cs_as_permission));
    cs_as_sub_securable = lower(PG_CATALOG.rtrim(cs_as_sub_securable));
    cs_as_sub_securable_class = lower(PG_CATALOG.rtrim(cs_as_sub_securable_class));

    -- Assert that sub_securable and sub_securable_class are either both NULL or both defined
    IF cs_as_sub_securable IS NOT NULL AND cs_as_sub_securable_class IS NULL THEN
        RETURN NULL;
    ELSIF cs_as_sub_securable IS NULL AND cs_as_sub_securable_class IS NOT NULL THEN
        RETURN NULL;
    -- If they are both defined, user must be evaluating column privileges.
    -- Check that inputs are valid for column privileges: sub_securable_class must 
    -- be column, securable_class must be object, and permission cannot be any.
    ELSIF cs_as_sub_securable_class IS NOT NULL 
            AND (cs_as_sub_securable_class != 'column' 
                    OR cs_as_securable_class IS NULL 
                    OR cs_as_securable_class != 'object' 
                    OR cs_as_permission = 'any') THEN
        RETURN NULL;

    -- If securable is null, securable_class must be null
    ELSIF cs_as_securable IS NULL AND cs_as_securable_class IS NOT NULL THEN
        RETURN NULL;
    -- If securable_class is null, securable must be null
    ELSIF cs_as_securable IS NOT NULL AND cs_as_securable_class IS NULL THEN
        RETURN NULL;
    END IF;

    IF cs_as_securable_class = 'server' THEN
        -- SQL Server does not permit a securable_class value of 'server'.
        -- securable_class should be NULL to evaluate server permissions.
        RETURN NULL;
    ELSIF cs_as_securable_class IS NULL THEN
        -- NULL indicates a server permission. Set this variable so that we can
        -- search for the matching entry in babelfish_has_perms_by_name_permissions
        cs_as_securable_class = 'server';
    END IF;

    IF cs_as_sub_securable IS NOT NULL THEN
        cs_as_sub_securable := babelfish_remove_delimiter_pair(cs_as_sub_securable);
        IF cs_as_sub_securable IS NULL THEN
            RETURN NULL;
        END IF;
    END IF;

    SELECT p.implied_dbo_permissions,p.fully_supported 
    INTO implied_dbo_permissions,fully_supported 
    FROM babelfish_has_perms_by_name_permissions p 
    WHERE p.securable_type = cs_as_securable_class AND p.permission_name = cs_as_permission;
    
    IF implied_dbo_permissions IS NULL OR fully_supported IS NULL THEN
        -- Securable class or permission is not valid, or permission is not valid for given securable
        RETURN NULL;
    END IF;

    IF cs_as_securable_class = 'database' AND cs_as_securable IS NOT NULL THEN
        db_name = babelfish_remove_delimiter_pair(cs_as_securable);
        IF db_name IS NULL THEN
            RETURN NULL;
        ELSIF (SELECT COUNT(name) FROM sys.databases WHERE name = db_name) != 1 THEN
            RETURN 0;
        END IF;
    ELSIF cs_as_securable_class = 'schema' THEN
        bbf_schema_name = babelfish_remove_delimiter_pair(cs_as_securable);
        IF bbf_schema_name IS NULL THEN
            RETURN NULL;
        ELSIF (SELECT COUNT(nspname) FROM sys.babelfish_namespace_ext ext
                WHERE ext.orig_name = bbf_schema_name 
                    AND CAST(ext.dbid AS oid) = CAST(sys.db_id() AS oid)) != 1 THEN
            RETURN 0;
        END IF;
    END IF;

    IF fully_supported = 'f' AND
		(SELECT orig_username FROM sys.babelfish_authid_user_ext WHERE rolname = CURRENT_USER) = 'dbo' THEN
        RETURN CAST(implied_dbo_permissions AS integer);
    ELSIF fully_supported = 'f' THEN
        RETURN 0;
    END IF;

    -- The only permissions that are fully supported belong to the OBJECT securable class.
    -- The block above has dealt with all permissions that are not fully supported, so 
    -- if we reach this point we know the securable class is OBJECT.
    SELECT s.db_name, s.schema_name, s.object_name INTO db_name, bbf_schema_name, object_name 
    FROM babelfish_split_object_name(cs_as_securable) s;

    -- Invalid securable name
    IF object_name IS NULL OR object_name = '' THEN
        RETURN NULL;
    END IF;

    -- If schema was not specified, use the default
    IF bbf_schema_name IS NULL OR bbf_schema_name = '' THEN
        bbf_schema_name := sys.schema_name();
    END IF;

    database_id := (
        SELECT CASE 
            WHEN db_name IS NULL OR db_name = '' THEN (sys.db_id())
            ELSE (sys.db_id(db_name))
        END);

	IF database_id <> sys.db_id() THEN
        is_cross_db = true;
	END IF;

	userid := (
        SELECT CASE
            WHEN is_cross_db THEN sys.suser_id()
            ELSE sys.user_id()
        END);
  
    -- Translate schema name from bbf to postgres, e.g. dbo -> master_dbo
    pg_schema := (SELECT nspname 
                    FROM sys.babelfish_namespace_ext ext 
                    WHERE ext.orig_name = bbf_schema_name 
                        AND CAST(ext.dbid AS oid) = CAST(database_id AS oid));

    IF pg_schema IS NULL THEN
        -- Shared schemas like sys and pg_catalog do not exist in the table above.
        -- These schemas do not need to be translated from Babelfish to Postgres
        pg_schema := bbf_schema_name;
    END IF;

    -- Surround with double-quotes to handle names that contain periods/spaces
    qualified_name := PG_CATALOG.concat('"', pg_schema, '"."', object_name, '"');

    SELECT oid INTO namespace_id FROM pg_catalog.pg_namespace WHERE nspname = pg_schema COLLATE sys.database_default;

    object_type := (
        SELECT CASE
            WHEN cs_as_sub_securable_class = 'column'
                THEN CASE 
                    WHEN (SELECT count(a.attname)
                        FROM pg_attribute a
                        INNER JOIN pg_class c ON c.oid = a.attrelid
                        INNER JOIN pg_namespace s ON s.oid = c.relnamespace
                        WHERE
                        a.attname = cs_as_sub_securable COLLATE sys.database_default
                        AND c.relname = object_name COLLATE sys.database_default
                        AND s.nspname = pg_schema COLLATE sys.database_default
                        AND NOT a.attisdropped
                        AND (s.nspname IN (SELECT nspname FROM sys.babelfish_namespace_ext) OR s.nspname = 'sys')
                        -- r = ordinary table, i = index, S = sequence, t = TOAST table, v = view, m = materialized view, c = composite type, f = foreign table, p = partitioned table
                        AND c.relkind IN ('r', 'v', 'm', 'f', 'p')
                        AND a.attnum > 0) = 1
                                THEN 'column'
                    ELSE NULL
                END

            WHEN (SELECT count(relname) 
                    FROM pg_catalog.pg_class 
                    WHERE relname = object_name COLLATE sys.database_default
                        AND relnamespace = namespace_id) = 1
                THEN 'table'

            WHEN (SELECT count(proname) 
                    FROM pg_catalog.pg_proc 
                    WHERE proname = object_name COLLATE sys.database_default 
                        AND pronamespace = namespace_id
                        AND prokind = 'f') = 1
                THEN 'function'
                
            WHEN (SELECT count(proname) 
                    FROM pg_catalog.pg_proc 
                    WHERE proname = object_name COLLATE sys.database_default
                        AND pronamespace = namespace_id
                        AND prokind = 'p') = 1
                THEN 'procedure'
            ELSE NULL
        END
    );
    
    -- Object was not found
    IF object_type IS NULL THEN
        RETURN 0;
    END IF;
  
    -- Get signature for function-like objects
    IF object_type IN('function', 'procedure') THEN
        SELECT CAST(oid AS regprocedure) 
            INTO function_signature 
            FROM pg_catalog.pg_proc 
            WHERE proname = object_name COLLATE sys.database_default
                AND pronamespace = namespace_id;
    END IF;

    return_value := (
        SELECT CASE
            WHEN cs_as_permission = 'any' THEN babelfish_has_any_privilege(userid, object_type, pg_schema, object_name)

            WHEN object_type = 'column'
                THEN CASE
                    WHEN cs_as_permission IN('insert', 'delete', 'execute') THEN NULL
                    ELSE CAST(has_column_privilege(userid, qualified_name, cs_as_sub_securable, cs_as_permission) AS integer)
                END

            WHEN object_type = 'table'
                THEN CASE
                    WHEN cs_as_permission = 'execute' THEN 0
                    ELSE CAST(has_table_privilege(userid, qualified_name, cs_as_permission) AS integer)
                END

            WHEN object_type = 'function'
                THEN CASE
                    WHEN cs_as_permission IN('select', 'execute')
                        THEN CAST(has_function_privilege(userid, function_signature, 'execute') AS integer)
                    WHEN cs_as_permission IN('update', 'insert', 'delete', 'references')
                        THEN 0
                    ELSE NULL
                END

            WHEN object_type = 'procedure'
                THEN CASE
                    WHEN cs_as_permission = 'execute'
                        THEN CAST(has_function_privilege(userid, function_signature, 'execute') AS integer)
                    WHEN cs_as_permission IN('select', 'update', 'insert', 'delete', 'references')
                        THEN 0
                    ELSE NULL
                END

            ELSE NULL
        END
    );

    RETURN return_value;
    EXCEPTION WHEN OTHERS THEN RETURN NULL;
END;
$$;

GRANT EXECUTE ON FUNCTION sys.has_perms_by_name(
    securable sys.SYSNAME, 
    securable_class sys.nvarchar(60), 
    permission sys.SYSNAME, 
    sub_securable sys.SYSNAME,
    sub_securable_class sys.nvarchar(60)) TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.schema_name()
RETURNS sys.sysname
LANGUAGE plpgsql
STABLE STRICT
AS $function$
begin
    RETURN (select orig_name from sys.babelfish_namespace_ext ext  
                    where ext.nspname = (select current_schema()) and  ext.dbid::oid = sys.db_id()::oid)::sys.sysname;
EXCEPTION 
    WHEN others THEN
        RETURN NULL;
END;
$function$
;
GRANT EXECUTE ON FUNCTION sys.schema_name() TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.original_login()
RETURNS sys.sysname
LANGUAGE plpgsql
STABLE STRICT
AS $$
declare return_value text;
begin
	RETURN (select orig_loginname from sys.babelfish_authid_login_ext where rolname = session_user)::sys.sysname;
EXCEPTION 
	WHEN others THEN
 		RETURN NULL;
END;
$$;
GRANT EXECUTE ON FUNCTION sys.original_login() TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.columnproperty(object_id oid, property name, property_name text)
RETURNS integer
LANGUAGE plpgsql
STABLE STRICT
AS $$

declare extra_bytes CONSTANT integer := 4;
declare return_value integer;
begin
	return_value := (
					select 
						case  LOWER(property_name)
							when 'charmaxlen' COLLATE sys.database_default then 
								(select CASE WHEN a.atttypmod > 0 THEN a.atttypmod - extra_bytes ELSE NULL END  from pg_catalog.pg_attribute a where a.attrelid = object_id and a.attname = property)
							when 'allowsnull' COLLATE sys.database_default then
								(select CASE WHEN a.attnotnull THEN 0 ELSE 1 END from pg_catalog.pg_attribute a where a.attrelid = object_id and a.attname = property)
							else
								null
						end
					);
	
  RETURN return_value::integer;
EXCEPTION 
	WHEN others THEN
 		RETURN NULL;
END;
$$;
GRANT EXECUTE ON FUNCTION sys.columnproperty(object_id oid, property name, property_name text) TO PUBLIC;

COMMENT ON FUNCTION sys.columnproperty 
IS 'This function returns column or parameter information. Currently only works with "charmaxlen", and "allowsnull" otherwise returns 0.';

-- substring --
CREATE OR REPLACE FUNCTION sys.substring(string TEXT, i INTEGER, j INTEGER)
RETURNS sys.VARCHAR
AS 'babelfishpg_tsql', 'tsql_varchar_substr' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.substring(string NTEXT, i INTEGER, j INTEGER)
RETURNS sys.NVARCHAR
AS 'babelfishpg_tsql', 'tsql_varchar_substr' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.substring(string sys.VARCHAR, i INTEGER, j INTEGER)
RETURNS sys.VARCHAR
AS 'babelfishpg_tsql', 'tsql_varchar_substr' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.substring(string sys.BPCHAR, i INTEGER, j INTEGER)
RETURNS sys.VARCHAR
AS 'babelfishpg_tsql', 'tsql_varchar_substr' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.substring(string sys.NVARCHAR, i INTEGER, j INTEGER)
RETURNS sys.NVARCHAR
AS 'babelfishpg_tsql', 'tsql_varchar_substr' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.substring(string sys.NCHAR, i INTEGER, j INTEGER)
RETURNS sys.NVARCHAR
AS 'babelfishpg_tsql', 'tsql_varchar_substr' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.substring(string sys.VARBINARY, i INTEGER, j INTEGER)
RETURNS sys.VARBINARY
AS 'babelfishpg_tsql', 'tsql_varbinary_substr' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.substring(string ANYELEMENT, i INTEGER, j INTEGER)
RETURNS sys.VARBINARY
AS
$BODY$
DECLARE
    type_oid oid;
    string_arg_datatype text;
    string_basetype oid;
BEGIN
    type_oid := pg_typeof(string);
    string_arg_datatype := sys.translate_pg_type_to_tsql(type_oid);
    IF string_arg_datatype IS NULL THEN
        -- for User Defined Datatype, use immediate base type to check for argument datatype validation
        string_basetype := sys.bbf_get_immediate_base_type_of_UDT(type_oid);
        string_arg_datatype := sys.translate_pg_type_to_tsql(string_basetype);
    END IF;

    -- restricting arguments with invalid datatypes for substring function
    IF string_arg_datatype NOT IN ('binary', 'image') THEN
        RAISE EXCEPTION 'Argument data type % is invalid for argument 1 of substring function.', string_arg_datatype;
    END IF;

    RETURN sys.substring(string::sys.VARBINARY, i, j);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;

-- wrapper functions for upper --
-- Function to handle datatypes which are implicitly convertable to VARCHAR
CREATE OR REPLACE FUNCTION sys.upper(ANYELEMENT)
RETURNS sys.VARCHAR
AS $$
DECLARE
    type_oid oid;
    typ_base_oid oid;
    typnam text;
BEGIN
    typnam := NULL;
    type_oid := pg_typeof($1);
    typnam := sys.translate_pg_type_to_tsql(type_oid);
    IF typnam IS NULL THEN
        typ_base_oid := sys.bbf_get_immediate_base_type_of_UDT(type_oid);
        typnam := sys.translate_pg_type_to_tsql(typ_base_oid);
    END IF;
    IF typnam IN ('image', 'sql_variant', 'xml', 'geometry', 'geography') THEN
        RAISE EXCEPTION 'Argument data type % is invalid for argument 1 of upper function.', typnam;
    END IF;
    IF $1 IS NULL THEN
        RETURN NULL;
    END IF;
    -- Call the underlying function after preprocessing
    RETURN pg_catalog.upper($1::sys.varchar);
END;
$$ LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;

-- Function to handle NCHAR because of return type NVARCHAR
CREATE OR REPLACE FUNCTION sys.upper(sys.NCHAR)
RETURNS sys.NVARCHAR
AS $$
BEGIN
    RETURN pg_catalog.upper($1);
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

-- Function to handle NVARCHAR because of return type NVARCHAR
CREATE OR REPLACE FUNCTION sys.upper(sys.NVARCHAR)
RETURNS sys.NVARCHAR
AS $$
BEGIN
    RETURN pg_catalog.upper($1);
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

-- Function to handle TEXT because of return type VARCHAR
CREATE OR REPLACE FUNCTION sys.upper(TEXT)
RETURNS sys.VARCHAR
AS $$
BEGIN
    RETURN pg_catalog.upper($1);
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

-- Function to handle NTEXT because of return type VARCHAR
CREATE OR REPLACE FUNCTION sys.upper(NTEXT)
RETURNS sys.NVARCHAR
AS $$
BEGIN
    RETURN pg_catalog.upper($1);
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

-- wrapper functions for lower --
-- Function to handle datatypes which are implicitly convertable to VARCHAR
CREATE OR REPLACE FUNCTION sys.lower(ANYELEMENT)
RETURNS sys.VARCHAR
AS $$
DECLARE
    type_oid oid;
    typ_base_oid oid;
    typnam text;
BEGIN
    typnam := NULL;
    type_oid := pg_typeof($1);
    typnam := sys.translate_pg_type_to_tsql(type_oid);
    IF typnam IS NULL THEN
        typ_base_oid := sys.bbf_get_immediate_base_type_of_UDT(type_oid);
        typnam := sys.translate_pg_type_to_tsql(typ_base_oid);
    END IF;
    IF typnam IN ('image', 'sql_variant', 'xml', 'geometry', 'geography') THEN
        RAISE EXCEPTION 'Argument data type % is invalid for argument 1 of lower function.', typnam;
    END IF;
    IF $1 IS NULL THEN
        RETURN NULL;
    END IF;
    -- Call the underlying function after preprocessing
    RETURN pg_catalog.lower($1::sys.varchar);
END;
$$ LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;

-- Function to handle NCHAR because of return type NVARCHAR
CREATE OR REPLACE FUNCTION sys.lower(sys.NCHAR)
RETURNS sys.NVARCHAR
AS $$
BEGIN
    RETURN pg_catalog.lower($1);
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

-- Function to handle NVARCHAR because of return type NVARCHAR
CREATE OR REPLACE FUNCTION sys.lower(sys.NVARCHAR)
RETURNS sys.NVARCHAR
AS $$
BEGIN
    RETURN pg_catalog.lower($1);
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

-- Function to handle TEXT because of return type VARCHAR
CREATE OR REPLACE FUNCTION sys.lower(TEXT)
RETURNS sys.VARCHAR
AS $$
BEGIN
    RETURN pg_catalog.lower($1);
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

-- Function to handle NTEXT because of return type VARCHAR
CREATE OR REPLACE FUNCTION sys.lower(NTEXT)
RETURNS sys.NVARCHAR
AS $$
BEGIN
    RETURN pg_catalog.lower($1);
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

-- wrapper functions for TRIM
CREATE OR REPLACE FUNCTION sys.TRIM(string sys.BPCHAR)
RETURNS sys.VARCHAR
AS 
$BODY$
BEGIN
    RETURN PG_CATALOG.btrim(string);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.TRIM(string sys.VARCHAR)
RETURNS sys.VARCHAR
AS 
$BODY$
BEGIN
    RETURN PG_CATALOG.btrim(string);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.TRIM(string sys.NCHAR)
RETURNS sys.NVARCHAR
AS 
$BODY$
BEGIN
    RETURN PG_CATALOG.btrim(string);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.TRIM(string sys.NVARCHAR)
RETURNS sys.NVARCHAR
AS 
$BODY$
BEGIN
    RETURN PG_CATALOG.btrim(string);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.TRIM(string ANYELEMENT)
RETURNS sys.VARCHAR
AS 
$BODY$
DECLARE
    string_arg_datatype text;
    string_basetype oid;
BEGIN
    string_arg_datatype := sys.translate_pg_type_to_tsql(pg_typeof(string)::oid);
    IF string_arg_datatype IS NULL THEN
        -- for User Defined Datatype, use immediate base type to check for argument datatype validation
        string_basetype := sys.bbf_get_immediate_base_type_of_UDT(pg_typeof(string)::oid);
        string_arg_datatype := sys.translate_pg_type_to_tsql(string_basetype);
    END IF;

    -- restricting arguments with invalid datatypes for trim function
    IF string_arg_datatype NOT IN ('char', 'varchar', 'nchar', 'nvarchar', 'text', 'ntext') THEN
        RAISE EXCEPTION 'Argument data type % is invalid for argument 1 of Trim function.', string_arg_datatype;
    END IF;

    IF string IS NULL THEN
        RETURN NULL;
    END IF;

    RETURN PG_CATALOG.btrim(string::sys.varchar);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;

-- Additional handling is added for TRIM function with 2 arguments, 
-- hence only following two definitions are required.
CREATE OR REPLACE FUNCTION sys.TRIM(characters sys.VARCHAR, string sys.NVARCHAR)
RETURNS sys.NVARCHAR
AS 
$BODY$
BEGIN
    RETURN PG_CATALOG.btrim(string, characters);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.TRIM(characters sys.VARCHAR, string sys.VARCHAR)
RETURNS sys.VARCHAR
AS 
$BODY$
BEGIN
    RETURN PG_CATALOG.btrim(string, characters);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

-- wrapper functions for LTRIM
CREATE OR REPLACE FUNCTION sys.LTRIM(string ANYELEMENT)
RETURNS sys.VARCHAR
AS
$BODY$
DECLARE
    string_arg_datatype text;
    string_basetype oid;
BEGIN
    string_arg_datatype := sys.translate_pg_type_to_tsql(pg_typeof(string)::oid);
    IF string_arg_datatype IS NULL THEN
        -- for User Defined Datatype, use immediate base type to check for argument datatype validation
        string_basetype := sys.bbf_get_immediate_base_type_of_UDT(pg_typeof(string)::oid);
        string_arg_datatype := sys.translate_pg_type_to_tsql(string_basetype);
    END IF;

    -- restricting arguments with invalid datatypes for ltrim function
    IF string_arg_datatype IN ('image', 'sql_variant', 'xml', 'geometry', 'geography') THEN
        RAISE EXCEPTION 'Argument data type % is invalid for argument 1 of ltrim function.', string_arg_datatype;
    END IF;

    IF string IS NULL THEN
        RETURN NULL;
    END IF;

    RETURN PG_CATALOG.ltrim(string::sys.varchar);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.LTRIM(string sys.BPCHAR)
RETURNS sys.VARCHAR
AS
$BODY$
BEGIN
    RETURN PG_CATALOG.ltrim(string);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.LTRIM(string sys.VARCHAR)
RETURNS sys.VARCHAR
AS
$BODY$
BEGIN
    RETURN PG_CATALOG.ltrim(string);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.LTRIM(string sys.NCHAR)
RETURNS sys.NVARCHAR
AS
$BODY$
BEGIN
    RETURN PG_CATALOG.ltrim(string);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.LTRIM(string sys.NVARCHAR)
RETURNS sys.NVARCHAR
AS
$BODY$
BEGIN
    RETURN PG_CATALOG.ltrim(string);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

-- Adding following definition will make sure that ltrim with text input
-- will use following definition instead of PG ltrim
CREATE OR REPLACE FUNCTION sys.LTRIM(string TEXT)
RETURNS sys.VARCHAR
AS
$BODY$
BEGIN
    RETURN PG_CATALOG.ltrim(string);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

-- Adding following definition will make sure that ltrim with ntext input
-- will use following definition instead of PG ltrim
CREATE OR REPLACE FUNCTION sys.LTRIM(string NTEXT)
RETURNS sys.NVARCHAR
AS
$BODY$
BEGIN
    RETURN PG_CATALOG.ltrim(string);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

-- wrapper functions for RTRIM
CREATE OR REPLACE FUNCTION sys.RTRIM(string ANYELEMENT)
RETURNS sys.VARCHAR
AS
$BODY$
DECLARE
    string_arg_datatype text;
    string_basetype oid;
BEGIN
    string_arg_datatype := sys.translate_pg_type_to_tsql(pg_typeof(string)::oid);
    IF string_arg_datatype IS NULL THEN
        -- for User Defined Datatype, use immediate base type to check for argument datatype validation
        string_basetype := sys.bbf_get_immediate_base_type_of_UDT(pg_typeof(string)::oid);
        string_arg_datatype := sys.translate_pg_type_to_tsql(string_basetype);
    END IF;

    -- restricting arguments with invalid datatypes for rtrim function
    IF string_arg_datatype IN ('image', 'sql_variant', 'xml', 'geometry', 'geography') THEN
        RAISE EXCEPTION 'Argument data type % is invalid for argument 1 of rtrim function.', string_arg_datatype;
    END IF;

    IF string IS NULL THEN
        RETURN NULL;
    END IF;

    RETURN PG_CATALOG.rtrim(string::sys.varchar);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.RTRIM(string sys.BPCHAR)
RETURNS sys.VARCHAR
AS
$BODY$
BEGIN
    RETURN PG_CATALOG.rtrim(string);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.RTRIM(string sys.VARCHAR)
RETURNS sys.VARCHAR
AS
$BODY$
BEGIN
    RETURN PG_CATALOG.rtrim(string);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.RTRIM(string sys.NCHAR)
RETURNS sys.NVARCHAR
AS
$BODY$
BEGIN
    RETURN PG_CATALOG.rtrim(string);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.RTRIM(string sys.NVARCHAR)
RETURNS sys.NVARCHAR
AS
$BODY$
BEGIN
    RETURN PG_CATALOG.rtrim(string);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

-- Adding following definition will make sure that rtrim with text input
-- will use following definition instead of PG rtrim
CREATE OR REPLACE FUNCTION sys.RTRIM(string TEXT)
RETURNS sys.VARCHAR
AS
$BODY$
BEGIN
    RETURN PG_CATALOG.rtrim(string);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

-- Adding following definition will make sure that rtrim with ntext input
-- will use following definition instead of PG rtrim
CREATE OR REPLACE FUNCTION sys.RTRIM(string NTEXT)
RETURNS sys.NVARCHAR
AS
$BODY$
BEGIN
    RETURN PG_CATALOG.rtrim(string);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;


-- wrapper functions for LEFT
CREATE OR REPLACE FUNCTION sys.LEFT(string ANYELEMENT, i INTEGER)
RETURNS sys.VARCHAR
AS
$BODY$
DECLARE
    string_arg_datatype text;
    string_basetype oid;
BEGIN
    string_arg_datatype := sys.translate_pg_type_to_tsql(pg_typeof(string)::oid);
    IF string_arg_datatype IS NULL THEN
        -- for User Defined Datatype, use immediate base type to check for argument datatype validation
        string_basetype := sys.bbf_get_immediate_base_type_of_UDT(pg_typeof(string)::oid);
        string_arg_datatype := sys.translate_pg_type_to_tsql(string_basetype);
    END IF;

    -- restricting arguments with invalid datatypes for left function
    IF string_arg_datatype IN ('image', 'sql_variant', 'xml', 'geometry', 'geography') THEN
        RAISE EXCEPTION 'Argument data type % is invalid for argument 1 of left function.', string_arg_datatype;
    END IF;

    IF i IS NULL THEN
        RETURN NULL;
    END IF;

    IF i < 0 THEN
        RAISE EXCEPTION 'Invalid length parameter passed to the left function.';
    END IF;

    IF string IS NULL THEN
        RETURN NULL;
    END IF;

    RETURN PG_CATALOG.left(string::sys.varchar, i);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.LEFT(string sys.BPCHAR, i INTEGER)
RETURNS sys.VARCHAR
AS
$BODY$
BEGIN
    IF i IS NULL THEN
        RETURN NULL;
    END IF;

    IF i < 0 THEN
        RAISE EXCEPTION 'Invalid length parameter passed to the left function.';
    END IF;

    IF string IS NULL THEN
        RETURN NULL;
    END IF;

    RETURN PG_CATALOG.left(string, i);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.LEFT(string sys.VARCHAR, i INTEGER)
RETURNS sys.VARCHAR
AS
$BODY$
BEGIN
    IF i IS NULL THEN
        RETURN NULL;
    END IF;

    IF i < 0 THEN
        RAISE EXCEPTION 'Invalid length parameter passed to the left function.';
    END IF;

    IF string IS NULL THEN
        RETURN NULL;
    END IF;

    RETURN PG_CATALOG.left(string, i);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.LEFT(string sys.NCHAR, i INTEGER)
RETURNS sys.NVARCHAR
AS
$BODY$
BEGIN
    IF i IS NULL THEN
        RETURN NULL;
    END IF;

    IF i < 0 THEN
        RAISE EXCEPTION 'Invalid length parameter passed to the left function.';
    END IF;

    IF string IS NULL THEN
        RETURN NULL;
    END IF;

    RETURN PG_CATALOG.left(string, i);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.LEFT(string sys.NVARCHAR, i INTEGER)
RETURNS sys.NVARCHAR
AS
$BODY$
BEGIN
    IF i IS NULL THEN
        RETURN NULL;
    END IF;

    IF i < 0 THEN
        RAISE EXCEPTION 'Invalid length parameter passed to the left function.';
    END IF;

    IF string IS NULL THEN
        RETURN NULL;
    END IF;

    RETURN PG_CATALOG.left(string, i);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;

-- Adding following definition will make sure that left with text input
-- will use following definition instead of PG left
CREATE OR REPLACE FUNCTION sys.LEFT(string TEXT, i INTEGER)
RETURNS sys.VARCHAR
AS
$BODY$
BEGIN
    IF i IS NULL THEN
        RETURN NULL;
    END IF;

    IF i < 0 THEN
        RAISE EXCEPTION 'Invalid length parameter passed to the left function.';
    END IF;

    IF string IS NULL THEN
        RETURN NULL;
    END IF;

    RETURN PG_CATALOG.left(string, i);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;

-- Adding following definition will make sure that left with ntext input
-- will use following definition instead of PG left
CREATE OR REPLACE FUNCTION sys.LEFT(string NTEXT, i INTEGER)
RETURNS sys.NVARCHAR
AS
$BODY$
BEGIN
    IF i IS NULL THEN
        RETURN NULL;
    END IF;

    IF i < 0 THEN
        RAISE EXCEPTION 'Invalid length parameter passed to the left function.';
    END IF;

    IF string IS NULL THEN
        RETURN NULL;
    END IF;

    RETURN PG_CATALOG.left(string, i);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;


-- wrapper functions for RIGHT
CREATE OR REPLACE FUNCTION sys.RIGHT(string ANYELEMENT, i INTEGER)
RETURNS sys.VARCHAR
AS
$BODY$
DECLARE
    string_arg_datatype text;
    string_basetype oid;
BEGIN
    string_arg_datatype := sys.translate_pg_type_to_tsql(pg_typeof(string)::oid);
    IF string_arg_datatype IS NULL THEN
        -- for User Defined Datatype, use immediate base type to check for argument datatype validation
        string_basetype := sys.bbf_get_immediate_base_type_of_UDT(pg_typeof(string)::oid);
        string_arg_datatype := sys.translate_pg_type_to_tsql(string_basetype);
    END IF;

    -- restricting arguments with invalid datatypes for right function
    IF string_arg_datatype IN ('image', 'sql_variant', 'xml', 'geometry', 'geography') THEN
        RAISE EXCEPTION 'Argument data type % is invalid for argument 1 of right function.', string_arg_datatype;
    END IF;

    IF i IS NULL THEN
        RETURN NULL;
    END IF;

    IF i < 0 THEN
        RAISE EXCEPTION 'Invalid length parameter passed to the right function.';
    END IF;

    IF string IS NULL THEN
        RETURN NULL;
    END IF;
    RETURN PG_CATALOG.right(string::sys.varchar, i);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.RIGHT(string sys.BPCHAR, i INTEGER)
RETURNS sys.VARCHAR
AS
$BODY$
BEGIN
    IF i IS NULL THEN
        RETURN NULL;
    END IF;

    IF i < 0 THEN
        RAISE EXCEPTION 'Invalid length parameter passed to the right function.';
    END IF;

    IF string IS NULL THEN
        RETURN NULL;
    END IF;

    RETURN PG_CATALOG.right(string, i);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.RIGHT(string sys.VARCHAR, i INTEGER)
RETURNS sys.VARCHAR
AS
$BODY$
BEGIN
    IF i IS NULL THEN
        RETURN NULL;
    END IF;

    IF i < 0 THEN
        RAISE EXCEPTION 'Invalid length parameter passed to the right function.';
    END IF;

    IF string IS NULL THEN
        RETURN NULL;
    END IF;

    RETURN PG_CATALOG.right(string, i);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.RIGHT(string sys.NCHAR, i INTEGER)
RETURNS sys.NVARCHAR
AS
$BODY$
BEGIN
    IF i IS NULL THEN
        RETURN NULL;
    END IF;

    IF i < 0 THEN
        RAISE EXCEPTION 'Invalid length parameter passed to the right function.';
    END IF;

    IF string IS NULL THEN
        RETURN NULL;
    END IF;

    RETURN PG_CATALOG.right(string, i);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.RIGHT(string sys.NVARCHAR, i INTEGER)
RETURNS sys.NVARCHAR
AS
$BODY$
BEGIN
    IF i IS NULL THEN
        RETURN NULL;
    END IF;

    IF i < 0 THEN
        RAISE EXCEPTION 'Invalid length parameter passed to the right function.';
    END IF;

    IF string IS NULL THEN
        RETURN NULL;
    END IF;

    RETURN PG_CATALOG.right(string, i);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;

-- Adding following definition will make sure that right with text input
-- will use following definition instead of PG right
CREATE OR REPLACE FUNCTION sys.RIGHT(string TEXT, i INTEGER)
RETURNS sys.VARCHAR
AS
$BODY$
BEGIN
    IF i IS NULL THEN
        RETURN NULL;
    END IF;

    IF i < 0 THEN
        RAISE EXCEPTION 'Invalid length parameter passed to the right function.';
    END IF;

    IF string IS NULL THEN
        RETURN NULL;
    END IF;

    RETURN PG_CATALOG.right(string, i);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;

-- Adding following definition will make sure that right with ntext input
-- will use following definition instead of PG right
CREATE OR REPLACE FUNCTION sys.RIGHT(string NTEXT, i INTEGER)
RETURNS sys.NVARCHAR
AS
$BODY$
BEGIN
    IF i IS NULL THEN
        RETURN NULL;
    END IF;

    IF i < 0 THEN
        RAISE EXCEPTION 'Invalid length parameter passed to the right function.';
    END IF;

    IF string IS NULL THEN
        RETURN NULL;
    END IF;

    RETURN PG_CATALOG.right(string, i);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;

-- wrapper functions for translate --
CREATE OR REPLACE FUNCTION sys.translate(string sys.VARCHAR, characters sys.VARCHAR, translations sys.VARCHAR)
RETURNS sys.VARCHAR
AS $$
BEGIN
    IF length(characters) != length(translations) THEN
        RAISE EXCEPTION 'The second and third arguments of the TRANSLATE built-in function must contain an equal number of characters.';
    END IF;
    
    RETURN PG_CATALOG.TRANSLATE(string, characters, translations);
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.translate(string sys.NVARCHAR, characters sys.VARCHAR, translations sys.VARCHAR)
RETURNS sys.NVARCHAR
AS $$
BEGIN
    IF length(characters) != length(translations) THEN
        RAISE EXCEPTION 'The second and third arguments of the TRANSLATE built-in function must contain an equal number of characters.';
    END IF;

    RETURN PG_CATALOG.TRANSLATE(string, characters, translations);
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

-- wrapper functions for concat --
CREATE OR REPLACE FUNCTION sys.concat(VARIADIC args sys.VARCHAR[] DEFAULT '{}')
RETURNS sys.VARCHAR
AS $$
DECLARE
    arr_len INTEGER;
BEGIN
    arr_len := array_length(args, 1);

    -- PG has limitation for max number of args = 100
    IF arr_len IS NULL OR arr_len < 2 OR arr_len > 100 THEN
        RAISE EXCEPTION 'The concat function requires 2 to 100 arguments.';
    END IF;

    RETURN (PG_CATALOG.ARRAY_TO_STRING(args, ''));
END;
$$ LANGUAGE plpgsql STABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.concat(VARIADIC args sys.NVARCHAR[])
RETURNS sys.NVARCHAR
AS $$
DECLARE
    arr_len INTEGER;
BEGIN
    arr_len := array_length(args, 1);

    -- PG has limitation for max number of args = 100
    IF arr_len < 2 OR arr_len > 100 THEN
        RAISE EXCEPTION 'The concat function requires 2 to 100 arguments.';
    END IF;

    RETURN (PG_CATALOG.ARRAY_TO_STRING(args, ''));
END;
$$ LANGUAGE plpgsql STABLE PARALLEL SAFE;

-- wrapper functions for concat_ws --
CREATE OR REPLACE FUNCTION sys.concat_ws(seperator sys.VARCHAR DEFAULT '', VARIADIC args sys.VARCHAR[] DEFAULT '{}')
RETURNS sys.VARCHAR
AS $$
DECLARE
    arr_len INTEGER;
BEGIN
    arr_len := array_length(args, 1);

    -- PG has limitation for max number of args = 100
    IF arr_len IS NULL OR arr_len < 2 OR arr_len > 99 THEN
        RAISE EXCEPTION 'The concat_ws function requires 3 to 100 arguments.';
    END IF;

    IF seperator IS NULL THEN
        RETURN (PG_CATALOG.ARRAY_TO_STRING(args, ''));
    END IF;

    RETURN (PG_CATALOG.ARRAY_TO_STRING(args, seperator));
END;
$$ LANGUAGE plpgsql STABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.concat_ws(seperator sys.NVARCHAR, VARIADIC args sys.NVARCHAR[])
RETURNS sys.NVARCHAR
AS $$
DECLARE
    arr_len INTEGER;
BEGIN
    arr_len := array_length(args, 1);

    -- PG has limitation for max number of args = 100
    IF arr_len < 2 OR arr_len > 99 THEN
        RAISE EXCEPTION 'The concat_ws function requires 3 to 100 arguments.';
    END IF;

    IF seperator IS NULL THEN
        RETURN (PG_CATALOG.ARRAY_TO_STRING(args, ''));
    END IF;

    RETURN (PG_CATALOG.ARRAY_TO_STRING(args, seperator));
END;
$$ LANGUAGE plpgsql STABLE PARALLEL SAFE;

-- For getting host os from PG_VERSION_STR
CREATE OR REPLACE FUNCTION sys.get_host_os()
RETURNS sys.NVARCHAR
AS 'babelfishpg_tsql', 'host_os' LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.tsql_stat_get_activity(
  IN view_name text,
  OUT procid int,
  OUT client_version int,
  OUT library_name VARCHAR(32),
  OUT language VARCHAR(128),
  OUT quoted_identifier bool,
  OUT arithabort bool,
  OUT ansi_null_dflt_on bool,
  OUT ansi_defaults bool,
  OUT ansi_warnings bool,
  OUT ansi_padding bool,
  OUT ansi_nulls bool,
  OUT concat_null_yields_null bool,
  OUT textsize int,
  OUT datefirst int,
  OUT lock_timeout int,
  OUT transaction_isolation int2,
  OUT client_pid int,
  OUT row_count bigint,
  OUT error int,
  OUT trancount int,
  OUT protocol_version int,
  OUT packet_size int,
  OUT encrypyt_option VARCHAR(40),
  OUT database_id int2,
  OUT host_name varchar(128),
  OUT context_info bytea)
RETURNS SETOF RECORD
AS 'babelfishpg_tsql', 'tsql_stat_get_activity'
LANGUAGE C VOLATILE STRICT;

/*
 * Table type can identified by reverse dependency between table and
 * type in pg_depend.
 * If a table is dependent upon it's row type with dependency type
 * as DEPENDENCY_INTERNAL (i) then it's a T-SQL table type.
 */
CREATE OR REPLACE FUNCTION sys.is_table_type(object_id oid) RETURNS bool AS
$BODY$
SELECT
  EXISTS(
    SELECT 1
    FROM pg_catalog.pg_type pt
    INNER JOIN pg_catalog.pg_depend dep
    ON pt.typrelid = dep.objid AND pt.oid = dep.refobjid
    join sys.schemas sch on pt.typnamespace = sch.schema_id
    JOIN pg_catalog.pg_class pc ON pc.oid = dep.objid
    WHERE pt.typtype = 'c' AND dep.deptype = 'i' AND pt.typrelid = object_id AND pc.relkind = 'r'
    AND dep.classid = 'pg_catalog.pg_class'::regclass AND dep.refclassid = 'pg_catalog.pg_type'::regclass);
$BODY$
LANGUAGE SQL STABLE STRICT;

-- JSON Functions
CREATE OR REPLACE FUNCTION sys.isjson(json_string text)
RETURNS INTEGER
AS 'babelfishpg_tsql', 'tsql_isjson' LANGUAGE C STRICT IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.json_value(json_string text, path text)
RETURNS sys.NVARCHAR(4000)
AS 'babelfishpg_tsql', 'tsql_json_value' LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.json_query(json_string text, path text default '$')
RETURNS sys.NVARCHAR
AS 'babelfishpg_tsql', 'tsql_json_query' LANGUAGE C IMMUTABLE PARALLEL SAFE;

/*
 * JSON MODIFY
 * This function is used to update the value of a property in a JSON string and returns the updated JSON string.
 * It has been implemented in three parts:
 *  1) Set the append and create_if_missing flag as postgres functions do not directly take append and lax/strict mode in the jsonb_path.
 *  2) To convert the input path into the expected jsonb_path.
 *  3) To implement the main logic of the JSON_MODIFY function by dividing it into 8 different cases.
 */
CREATE OR REPLACE FUNCTION sys.json_modify(in expression sys.NVARCHAR,in path_json TEXT, in new_value ANYELEMENT, in escape bool)
RETURNS sys.NVARCHAR
AS
$BODY$
DECLARE
    json_path TEXT;
    json_path_convert TEXT;
    new_jsonb_path TEXT[];
    key_value_type TEXT;
    path_split_array TEXT[];
    comparison_string TEXT COLLATE "C";
    len_array INTEGER;
    word_count INTEGER;
    create_if_missing BOOL = TRUE;
    append_modifier BOOL = FALSE;
    key_exists BOOL;
    key_value JSONB;
    json_expression JSONB = expression::JSONB;
    json_new_value JSONB;
    result_json sys.NVARCHAR;
BEGIN
    path_split_array = regexp_split_to_array(TRIM(path_json) COLLATE "C",'\s+');
    word_count = array_length(path_split_array,1);
    /* 
     * This if else block is added to set the create_if_missing and append_modifier flags.
     * These flags will be used to know the mode and if the optional modifier append is present in the input path_json.
     * It is necessary as postgres functions do not directly take append and lax/strict mode in the jsonb_path.
     * Comparisons for comparison_string are case-sensitive.    
     */
    IF word_count = 1 THEN
        json_path = path_split_array[1];
        create_if_missing = TRUE;
        append_modifier = FALSE;
    ELSIF word_count = 2 THEN 
        json_path = path_split_array[2];
        comparison_string = path_split_array[1]; -- append or lax/strict mode
        IF comparison_string = 'append' THEN
            append_modifier = TRUE;
        ELSIF comparison_string = 'strict' THEN
            create_if_missing = FALSE;
        ELSIF comparison_string = 'lax' THEN
            create_if_missing = TRUE;
        ELSE
            RAISE invalid_json_text;
        END IF;
    ELSIF word_count = 3 THEN
        json_path = path_split_array[3];
        comparison_string = path_split_array[1]; -- append mode 
        IF comparison_string = 'append' THEN
            append_modifier = TRUE;
        ELSE
            RAISE invalid_json_text;
        END IF;
        comparison_string = path_split_array[2]; -- lax/strict mode
        IF comparison_string = 'strict' THEN
            create_if_missing = FALSE;
        ELSIF comparison_string = 'lax' THEN
            create_if_missing = TRUE;
        ELSE
            RAISE invalid_json_text;
        END IF;
    ELSE
        RAISE invalid_json_text;
    END IF;

    -- To convert input jsonpath to the required jsonb_path format
    json_path_convert = regexp_replace(json_path, '\$\.|]|\$\[' , '' , 'ig'); -- To remove "$." and "]" sign from the string 
    json_path_convert = regexp_replace(json_path_convert, '\.|\[' , ',' , 'ig'); -- To replace "." and "[" with "," to change into required format
    new_jsonb_path = PG_CATALOG.CONCAT('{',json_path_convert,'}'); -- Final required format of path by jsonb_set

    key_exists = jsonb_path_exists(json_expression,json_path::jsonpath); -- To check if key exist in the given path

    IF escape THEN
        json_new_value = new_value::JSONB;
    ELSE
        json_new_value = to_jsonb(new_value);
    END IF;

    --This if else block is to call the jsonb_set function based on the create_if_missing and append_modifier flags
    IF append_modifier THEN 
        IF key_exists THEN
            key_value = jsonb_path_query_first(json_expression,json_path::jsonpath); -- To get the value of the key
            key_value_type = jsonb_typeof(key_value);
            IF key_value_type = 'array' THEN
                len_array = jsonb_array_length(key_value);
                /*
                 * As jsonb_insert requires the index of the value to be inserted, so the below FORMAT function changes the path format into the required jsonb_insert path format.
                 * Eg: JSON_MODIFY('{"name":"John","skills":["C#","SQL"]}','append $.skills','Azure'); -> converts the path from '$.skills' to '{skills,2}' instead of '{skills}'
                 */
                new_jsonb_path = FORMAT('%s,%s}',TRIM('}' FROM new_jsonb_path::TEXT),len_array);
                IF new_value IS NULL THEN
                    result_json = jsonb_insert(json_expression,new_jsonb_path,'null'); -- This needs to be done because "to_jsonb(coalesce(new_value, 'null'))" does not result in a JSON NULL
                ELSE
                    result_json = jsonb_insert(json_expression,new_jsonb_path,json_new_value);
                END IF;
            ELSE
                IF NOT create_if_missing THEN
                    RAISE sql_json_array_not_found;
                ELSE
                    result_json = json_expression;
                END IF;
            END IF;
        ELSE
            IF NOT create_if_missing THEN
                RAISE sql_json_object_not_found;
            ELSE
                result_json = jsonb_insert(json_expression,new_jsonb_path,to_jsonb(array_agg(new_value))); -- array_agg is used to convert the new_value text into array format as we append functionality is being used
            END IF;
        END IF;
    ELSE --When no append modifier is present
        IF new_value IS NOT NULL THEN
            IF key_exists OR create_if_missing THEN
                result_json = jsonb_set_lax(json_expression,new_jsonb_path,json_new_value,create_if_missing);
            ELSE
                RAISE sql_json_object_not_found;
            END IF;
        ELSE
            IF key_exists THEN
                IF NOT create_if_missing THEN
                    result_json = jsonb_set_lax(json_expression,new_jsonb_path,json_new_value);
                ELSE
                    result_json = jsonb_set_lax(json_expression,new_jsonb_path,json_new_value,create_if_missing,'delete_key');
                END IF;
            ELSE
                IF NOT create_if_missing THEN
                    RAISE sql_json_object_not_found;
                ELSE
                    result_json = jsonb_set_lax(json_expression,new_jsonb_path,json_new_value,FALSE);
                END IF;
            END IF;
        END IF;
    END IF;  -- If append_modifier block ends here
    RETURN result_json;
EXCEPTION
    WHEN invalid_json_text THEN
            RAISE USING MESSAGE = 'JSON path is not properly formatted',
                        DETAIL = FORMAT('Unexpected keyword "%s" is found.',comparison_string),
                        HINT = 'Change "modifier/mode" parameter to the proper value and try again.';
    WHEN sql_json_array_not_found THEN
            RAISE USING MESSAGE = 'array cannot be found in the specified JSON path',
                        HINT = 'Change JSON path to target array property and try again.';
    WHEN sql_json_object_not_found THEN
            RAISE USING MESSAGE = 'property cannot be found on the specified JSON path';
END;        
$BODY$
LANGUAGE plpgsql STABLE;


CREATE OR REPLACE FUNCTION sys.openjson_object(json_string text)
RETURNS TABLE
(
    key sys.NVARCHAR(4000),
    value sys.NVARCHAR,
    type INTEGER
)
AS
$BODY$
SELECT  key,
        CASE json_typeof(value) WHEN 'null'     THEN NULL
                                ELSE            TRIM (BOTH '"' FROM value::TEXT)
        END,
        CASE json_typeof(value) WHEN 'null'     THEN 0
                                WHEN 'string'   THEN 1
                                WHEN 'number'   THEN 2
                                WHEN 'boolean'  THEN 3
                                WHEN 'array'    THEN 4
                                WHEN 'object'   THEN 5
        END
    FROM json_each(json_string::JSON)
$BODY$
LANGUAGE SQL;

CREATE OR REPLACE FUNCTION sys.openjson_array(json_string text)
RETURNS TABLE
(
    key sys.NVARCHAR(4000),
    value sys.NVARCHAR,
    type INTEGER
)
AS
$BODY$
SELECT  (row_number() over ())-1,
        CASE json_typeof(value) WHEN 'null'     THEN NULL
                                ELSE            TRIM (BOTH '"' FROM value::TEXT)
        END,
        CASE json_typeof(value) WHEN 'null'     THEN 0
                                WHEN 'string'   THEN 1
                                WHEN 'number'   THEN 2
                                WHEN 'boolean'  THEN 3
                                WHEN 'array'    THEN 4
                                WHEN 'object'   THEN 5
        END
    FROM json_array_elements(json_string::JSON) AS value
$BODY$
LANGUAGE SQL;

CREATE OR REPLACE FUNCTION sys.openjson_simple(json_string text, path text default '$')
RETURNS TABLE
(
    key sys.NVARCHAR(4000),
    value sys.NVARCHAR,
    type INTEGER
)
AS
$BODY$
DECLARE
    sub_json text := sys.json_query(json_string, path);
BEGIN
    IF json_typeof(sub_json::JSON) = 'array' THEN
        RETURN QUERY SELECT * FROM sys.openjson_array(sub_json);
    ELSE
        RETURN QUERY SELECT * FROM sys.openjson_object(sub_json);
    END IF;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sys.openjson_with(json_string text, path text, VARIADIC column_paths text[])
RETURNS SETOF RECORD
AS 'babelfishpg_tsql', 'tsql_openjson_with' LANGUAGE C STRICT IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.sp_datatype_info_helper(
    IN odbcVer smallint,
    IN is_100 bool,
    OUT TYPE_NAME VARCHAR(20),
    OUT DATA_TYPE INT,
    OUT "PRECISION" BIGINT,
    OUT LITERAL_PREFIX VARCHAR(20),
    OUT LITERAL_SUFFIX VARCHAR(20),
    OUT CREATE_PARAMS VARCHAR(20),
    OUT NULLABLE INT,
    OUT CASE_SENSITIVE INT,
    OUT SEARCHABLE INT,
    OUT UNSIGNED_ATTRIBUTE INT,
    OUT MONEY INT,
    OUT AUTO_INCREMENT INT,
    OUT LOCAL_TYPE_NAME VARCHAR(20),
    OUT MINIMUM_SCALE INT,
    OUT MAXIMUM_SCALE INT,
    OUT SQL_DATA_TYPE INT,
    OUT SQL_DATETIME_SUB INT,
    OUT NUM_PREC_RADIX INT,
    OUT INTERVAL_PRECISION INT,
    OUT USERTYPE INT,
    OUT LENGTH INT,
    OUT SS_DATA_TYPE smallint,
-- below column is added in order to join information_schema.columns of PG for sys.sp_columns_100_view
    OUT PG_TYPE_NAME VARCHAR(20)
)
RETURNS SETOF RECORD
AS 'babelfishpg_tsql', 'sp_datatype_info_helper'
LANGUAGE C IMMUTABLE STRICT;

-- Role member functions
CREATE OR REPLACE FUNCTION sys.is_rolemember_internal(
	IN role sys.SYSNAME,
	IN database_principal sys.SYSNAME
)
RETURNS INT AS 'babelfishpg_tsql', 'is_rolemember'
LANGUAGE C STABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.is_member(IN role sys.SYSNAME)
RETURNS INT AS
$$
	SELECT sys.is_rolemember_internal(role, NULL);
$$
LANGUAGE SQL STRICT STABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.is_rolemember(IN role sys.SYSNAME)
RETURNS INT AS
$$
	SELECT sys.is_rolemember_internal(role, NULL);
$$
LANGUAGE SQL STRICT STABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.is_rolemember(
	IN role sys.SYSNAME, 
	IN database_principal sys.SYSNAME
)
RETURNS INT AS
$$
	SELECT sys.is_rolemember_internal(role, database_principal);
$$
LANGUAGE SQL STRICT STABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.replace (input_string sys.VARCHAR, pattern sys.VARCHAR, replacement sys.VARCHAR)
RETURNS sys.VARCHAR AS
$BODY$
BEGIN
   if PG_CATALOG.length(pattern) = 0 then
       return input_string;
   elsif sys.is_collated_ci_as(input_string) then
       return regexp_replace(input_string, '***=' || pattern, replacement, 'ig'::pg_catalog.TEXT);
   else
       return regexp_replace(input_string, '***=' || pattern, replacement, 'g'::pg_catalog.TEXT);
   end if;
END
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE STRICT;

CREATE OR REPLACE FUNCTION sys.replace (input_string sys.NVARCHAR, pattern sys.NVARCHAR, replacement sys.NVARCHAR)
RETURNS sys.NVARCHAR AS
$BODY$
BEGIN
   if PG_CATALOG.length(pattern) = 0 then
       return input_string;
   elsif sys.is_collated_ci_as(input_string) then
       return regexp_replace(input_string, '***=' || pattern, replacement, 'ig'::pg_catalog.TEXT);
   else
       return regexp_replace(input_string, '***=' || pattern, replacement, 'g'::pg_catalog.TEXT);
   end if;
END
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE STRICT;

CREATE OR REPLACE FUNCTION objectproperty(
    id INT,
    property SYS.VARCHAR
    )
RETURNS INT AS
'babelfishpg_tsql', 'objectproperty_internal'
LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION OBJECTPROPERTYEX(
    id INT,
    property SYS.VARCHAR
)
RETURNS SYS.SQL_VARIANT
AS $$
BEGIN
	property := PG_CATALOG.RTRIM(LOWER(COALESCE(property, '')));
	
	IF NOT EXISTS(SELECT ao.object_id FROM sys.all_objects ao WHERE object_id = id)
	THEN
		RETURN NULL;
	END IF;

	IF property = 'basetype' -- BaseType
	THEN
		RETURN (SELECT CAST(ao.type AS SYS.SQL_VARIANT) 
                FROM sys.all_objects ao
                WHERE ao.object_id = id
                LIMIT 1
                );
    END IF;

    RETURN CAST(OBJECTPROPERTY(id, property) AS SYS.SQL_VARIANT);
END
$$
LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION sys.sid_binary(IN login sys.nvarchar)
RETURNS SYS.VARBINARY
AS $$
    SELECT CAST(NULL AS SYS.VARBINARY);
$$ 
LANGUAGE SQL IMMUTABLE PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION sys.language()
RETURNS sys.NVARCHAR(128)  AS 'babelfishpg_tsql' LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION sys.host_name()
RETURNS sys.NVARCHAR(128)  AS 'babelfishpg_tsql' LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.host_id()
RETURNS sys.VARCHAR(10)  AS 'babelfishpg_tsql' LANGUAGE C IMMUTABLE PARALLEL SAFE;
GRANT EXECUTE ON FUNCTION sys.host_id() TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.identity_into_int(IN typename INT, IN seed INT, IN increment INT)
RETURNS int AS 'babelfishpg_tsql' LANGUAGE C STABLE;
GRANT EXECUTE ON FUNCTION sys.identity_into_int(INT, INT, INT) TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.identity_into_smallint(IN typename INT, IN seed SMALLINT, IN increment SMALLINT)
RETURNS smallint AS 'babelfishpg_tsql' LANGUAGE C STABLE;
GRANT EXECUTE ON FUNCTION sys.identity_into_smallint(INT, SMALLINT, SMALLINT) TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.identity_into_bigint(IN typename INT, IN seed BIGINT, IN increment BIGINT)
RETURNS bigint AS 'babelfishpg_tsql' LANGUAGE C STABLE;
GRANT EXECUTE ON FUNCTION sys.identity_into_bigint(INT, BIGINT, BIGINT) TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.degrees(IN arg1 BIGINT)
RETURNS bigint  AS 'babelfishpg_tsql','bigint_degrees' LANGUAGE C STRICT IMMUTABLE PARALLEL SAFE;
GRANT EXECUTE ON FUNCTION sys.degrees(BIGINT) TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.degrees(IN arg1 INT)
RETURNS int AS 'babelfishpg_tsql','int_degrees' LANGUAGE C STRICT IMMUTABLE PARALLEL SAFE;
GRANT EXECUTE ON FUNCTION sys.degrees(INT) TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.degrees(IN arg1 SMALLINT)
RETURNS int AS 'babelfishpg_tsql','smallint_degrees' LANGUAGE C STRICT IMMUTABLE PARALLEL SAFE;
GRANT EXECUTE ON FUNCTION sys.degrees(SMALLINT) TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.degrees(IN arg1 TINYINT)
RETURNS int AS 'babelfishpg_tsql','smallint_degrees' LANGUAGE C STRICT IMMUTABLE PARALLEL SAFE;
GRANT EXECUTE ON FUNCTION sys.degrees(TINYINT) TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.radians(IN arg1 BIGINT)
RETURNS bigint  AS 'babelfishpg_tsql','bigint_radians' LANGUAGE C STRICT IMMUTABLE PARALLEL SAFE;
GRANT EXECUTE ON FUNCTION sys.radians(BIGINT) TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.radians(IN arg1 INT)
RETURNS int  AS 'babelfishpg_tsql','int_radians' LANGUAGE C STRICT IMMUTABLE PARALLEL SAFE;
GRANT EXECUTE ON FUNCTION sys.radians(INT) TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.radians(IN arg1 SMALLINT)
RETURNS int  AS 'babelfishpg_tsql','smallint_radians' LANGUAGE C STRICT IMMUTABLE PARALLEL SAFE;
GRANT EXECUTE ON FUNCTION sys.radians(SMALLINT) TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.radians(IN arg1 TINYINT)
RETURNS int  AS 'babelfishpg_tsql','smallint_radians' LANGUAGE C STRICT IMMUTABLE PARALLEL SAFE;
GRANT EXECUTE ON FUNCTION sys.radians(TINYINT) TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.power(IN arg1 BIGINT, IN arg2 NUMERIC)
RETURNS bigint  AS 'babelfishpg_tsql','bigint_power' LANGUAGE C IMMUTABLE PARALLEL SAFE;
GRANT EXECUTE ON FUNCTION sys.power(BIGINT,NUMERIC) TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.power(IN arg1 INT, IN arg2 NUMERIC)
RETURNS int  AS 'babelfishpg_tsql','int_power' LANGUAGE C IMMUTABLE PARALLEL SAFE;
GRANT EXECUTE ON FUNCTION sys.power(INT,NUMERIC) TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.power(IN arg1 SMALLINT, IN arg2 NUMERIC)
RETURNS int  AS 'babelfishpg_tsql','smallint_power' LANGUAGE C IMMUTABLE PARALLEL SAFE;
GRANT EXECUTE ON FUNCTION sys.power(SMALLINT,NUMERIC) TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.power(IN arg1 TINYINT, IN arg2 NUMERIC)
RETURNS int  AS 'babelfishpg_tsql','smallint_power' LANGUAGE C IMMUTABLE PARALLEL SAFE;
GRANT EXECUTE ON FUNCTION sys.power(TINYINT,NUMERIC) TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.degrees(IN arg1 NUMERIC)
RETURNS numeric  AS 'babelfishpg_tsql','numeric_degrees' LANGUAGE C STRICT IMMUTABLE PARALLEL SAFE;
GRANT EXECUTE ON FUNCTION sys.degrees(NUMERIC) TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.radians(IN arg1 NUMERIC)
RETURNS numeric  AS 'babelfishpg_tsql','numeric_radians' LANGUAGE C STRICT IMMUTABLE PARALLEL SAFE;
GRANT EXECUTE ON FUNCTION sys.radians(NUMERIC) TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.INDEXPROPERTY(IN object_id INT, IN index_or_statistics_name sys.nvarchar(128), IN property sys.varchar(128))
RETURNS INT AS
$BODY$
DECLARE
ret_val INT;
BEGIN
	index_or_statistics_name = LOWER(TRIM(index_or_statistics_name));
	property = LOWER(TRIM(property));
    SELECT INTO ret_val
    CASE
       
        WHEN (SELECT CAST(type AS int) FROM sys.indexes i WHERE i.object_id = $1 AND i.name = $2 COLLATE sys.database_default) = 3 -- is XML index
        THEN CAST(NULL AS int)
	    
        WHEN property = 'indexdepth'
        THEN CAST(0 AS int)

        WHEN property = 'indexfillfactor'
        THEN (SELECT CAST(fill_factor AS int) FROM sys.indexes i WHERE i.object_id = $1 AND i.name = $2 COLLATE sys.database_default)

        WHEN property = 'indexid'
        THEN (SELECT CAST(index_id AS int) FROM sys.indexes i WHERE i.object_id = $1 AND i.name = $2 COLLATE sys.database_default)

        WHEN property = 'isautostatistics'
        THEN CAST(0 AS int)

        WHEN property = 'isclustered'
        THEN (SELECT CAST(CASE WHEN type = 1 THEN 1 ELSE 0 END AS int) FROM sys.indexes i WHERE i.object_id = $1 AND i.name = $2 COLLATE sys.database_default)
        
        WHEN property = 'isdisabled'
        THEN (SELECT CAST(is_disabled AS int) FROM sys.indexes i WHERE i.object_id = $1 AND i.name = $2 COLLATE sys.database_default)
        
        WHEN property = 'isfulltextkey'
        THEN CAST(0 AS int)
        
        WHEN property = 'ishypothetical'
        THEN (SELECT CAST(is_hypothetical AS int) FROM sys.indexes i WHERE i.object_id = $1 AND i.name = $2 COLLATE sys.database_default)
        
        WHEN property = 'ispadindex'
        THEN (SELECT CAST(is_padded AS int) FROM sys.indexes i WHERE i.object_id = $1 AND i.name = $2 COLLATE sys.database_default)
        
        WHEN property = 'ispagelockdisallowed'
        THEN (SELECT CAST(CASE WHEN allow_page_locks = 1 THEN 0 ELSE 1 END AS int) FROM sys.indexes i WHERE i.object_id = $1 AND i.name = $2 COLLATE sys.database_default)
        
        WHEN property = 'isrowlockdisallowed'
        THEN (SELECT CAST(CASE WHEN allow_row_locks = 1 THEN 0 ELSE 1 END AS int) FROM sys.indexes i WHERE i.object_id=$1 AND i.name = $2 COLLATE sys.database_default)
        
        WHEN property = 'isstatistics'
        THEN CAST(0 AS int)
        
        WHEN property = 'isunique'
        THEN (SELECT CAST(is_unique AS int) FROM sys.indexes i WHERE i.object_id = $1 AND i.name = $2 COLLATE sys.database_default)
        
        WHEN property = 'iscolumnstore'
        THEN CAST(0 AS int)
        
        WHEN property = 'isoptimizedforsequentialkey'
        THEN CAST(0 AS int)
    ELSE
        CAST(NULL AS int)
    END;
RETURN ret_val;
END;
$BODY$
LANGUAGE plpgsql STABLE;
GRANT EXECUTE ON FUNCTION sys.INDEXPROPERTY(IN object_id INT, IN index_or_statistics_name sys.nvarchar(128),  IN property sys.varchar(128)) TO PUBLIC;

CREATE OR REPLACE FUNCTION sys.APP_NAME() RETURNS SYS.NVARCHAR(128)
AS
$$
    SELECT current_setting('application_name');
$$
LANGUAGE sql PARALLEL SAFE STABLE;

CREATE OR REPLACE FUNCTION sys.OBJECT_SCHEMA_NAME(IN object_id INT, IN database_id INT DEFAULT NULL)
RETURNS sys.SYSNAME AS
'babelfishpg_tsql', 'object_schema_name'
LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION OBJECT_DEFINITION(IN object_id INT)
RETURNS sys.NVARCHAR(4000)
AS $$
DECLARE
    definition sys.nvarchar(4000);
BEGIN

    definition = (SELECT cc.definition FROM sys.check_constraints cc WHERE cc.object_id = $1);
    IF (definition IS NULL)
    THEN
        definition = (SELECT dc.definition FROM sys.default_constraints dc WHERE dc.object_id = $1);
        IF (definition IS NULL)
        THEN
            definition = (SELECT asm.definition FROM sys.all_sql_modules asm WHERE asm.object_id = $1);
            IF (definition IS NULL)
            THEN
                RETURN NULL;
            END IF;
        END IF;
    END IF;

    RETURN definition;
END;
$$
LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION sys.openquery_internal(
IN linked_server text,
IN query text)
RETURNS SETOF RECORD
AS 'babelfishpg_tsql', 'openquery_internal'
LANGUAGE C VOLATILE;

CREATE OR REPLACE FUNCTION sys.EOMONTH(date,int DEFAULT 0)
RETURNS date
AS 'babelfishpg_tsql', 'EOMONTH'
LANGUAGE C STABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.fn_listextendedproperty
(
    IN "@name" sys.sysname DEFAULT NULL,
    IN "@level0type" VARCHAR(128) DEFAULT NULL,
    IN "@level0name" sys.sysname DEFAULT NULL,
    IN "@level1type" VARCHAR(128) DEFAULT NULL,
    IN "@level1name" sys.sysname DEFAULT NULL,
    IN "@level2type" VARCHAR(128) DEFAULT NULL,
    IN "@level2name" sys.sysname DEFAULT NULL,
    OUT objtype sys.sysname,
    OUT objname sys.sysname,
    OUT name sys.sysname,
    OUT value sys.sql_variant
)
RETURNS SETOF RECORD
AS 'babelfishpg_tsql' LANGUAGE C STABLE;
GRANT EXECUTE ON FUNCTION sys.fn_listextendedproperty TO PUBLIC;

CREATE OR REPLACE FUNCTION SYS.TYPE_NAME(IN type_id INT)
RETURNS SYS.NVARCHAR(128) AS
'babelfishpg_tsql', 'type_name'
LANGUAGE C STABLE;

CREATE OR REPLACE FUNCTION SYS.TYPE_ID(IN type_name SYS.NVARCHAR)
RETURNS INT AS
'babelfishpg_tsql', 'type_id'
LANGUAGE C STABLE;

-- wrapper functions for reverse
CREATE OR REPLACE FUNCTION sys.reverse(string ANYELEMENT)
RETURNS sys.VARCHAR
AS
$BODY$
DECLARE
    string_arg_datatype text;
    string_arg_typeid oid;
    string_basetype oid;
BEGIN
    string_arg_typeid := pg_typeof(string)::oid;
    string_arg_datatype := sys.translate_pg_type_to_tsql(string_arg_typeid);
    IF string_arg_datatype IS NULL THEN
        -- for User Defined Datatype, use immediate base type to check for argument datatype validation
        string_basetype := sys.bbf_get_immediate_base_type_of_UDT(string_arg_typeid);
        string_arg_datatype := sys.translate_pg_type_to_tsql(string_basetype);
    END IF;

    -- restricting arguments with invalid datatypes for reverse function
    IF string_arg_datatype IN ('image', 'sql_variant', 'xml', 'geometry', 'geography') THEN
        RAISE EXCEPTION 'Argument data type % is invalid for argument 1 of reverse function.', string_arg_datatype;
    END IF;

    IF string IS NULL THEN
        RETURN NULL;
    END IF;

    RETURN PG_CATALOG.reverse(string::sys.varchar);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.reverse(string sys.NCHAR)
RETURNS sys.NVARCHAR
AS
$BODY$
BEGIN
    RETURN PG_CATALOG.reverse(string);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.reverse(string sys.NVARCHAR)
RETURNS sys.NVARCHAR
AS
$BODY$
BEGIN
    RETURN PG_CATALOG.reverse(string);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE STRICT PARALLEL SAFE;

-- Adding following definition will make sure that reverse with text input
-- will use following definition instead of PG reverse
CREATE OR REPLACE FUNCTION sys.reverse(string TEXT)
RETURNS sys.VARCHAR
AS
$BODY$
BEGIN
    RETURN PG_CATALOG.reverse(string);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;

-- Adding following definition will make sure that reverse with ntext input
-- will use following definition instead of PG reverse
CREATE OR REPLACE FUNCTION sys.reverse(string NTEXT)
RETURNS sys.NVARCHAR
AS
$BODY$
BEGIN
    RETURN PG_CATALOG.reverse(string);
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION bbf_string_agg_finalfn_varchar(INTERNAL)
RETURNS sys.VARCHAR
AS 'string_agg_finalfn' LANGUAGE INTERNAL;

CREATE OR REPLACE FUNCTION bbf_string_agg_finalfn_nvarchar(INTERNAL)
RETURNS sys.NVARCHAR
AS 'string_agg_finalfn' LANGUAGE INTERNAL;

CREATE OR REPLACE AGGREGATE sys.string_agg(sys.VARCHAR, sys.VARCHAR) (
    SFUNC = string_agg_transfn,
    FINALFUNC = bbf_string_agg_finalfn_varchar,
    STYPE = INTERNAL,
    PARALLEL = SAFE
);

CREATE OR REPLACE AGGREGATE sys.string_agg(sys.NVARCHAR, sys.VARCHAR) (
    SFUNC = string_agg_transfn,
    FINALFUNC = bbf_string_agg_finalfn_nvarchar,
    STYPE = INTERNAL,
    PARALLEL = SAFE
);
