-- complain if script is sourced in psql, rather than via ALTER EXTENSION
\echo Use "ALTER EXTENSION ""babelfishpg_tsql"" UPDATE TO '3.3.1'" to load this file. \quit

-- Revert "Support WAITFOR TIME/DELAY (#1495)" (#1784) (#1928)
DROP PROCEDURE IF EXISTS sys.bbf_sleep_for;
DROP PROCEDURE IF EXISTS sys.bbf_sleep_until;

-- Restrict privileges from Unauthorised TSQL logins (#2162) (#2173)
CREATE OR REPLACE PROCEDURE sys.bbf_remove_createrole_from_logins()
LANGUAGE C
AS 'babelfishpg_tsql', 'remove_createrole_from_logins';
CALL sys.bbf_remove_createrole_from_logins();

-- Implemented sys.availability_replicas and sys.availability_groups as an empty views (#2184)
CREATE OR REPLACE VIEW sys.availability_replicas 
AS SELECT  
    CAST(NULL as sys.UNIQUEIDENTIFIER) AS replica_id
    , CAST(NULL as sys.UNIQUEIDENTIFIER) AS group_id
    , CAST(0 as INT) AS replica_metadata_id
    , CAST(NULL as sys.NVARCHAR(256)) AS replica_server_name
    , CAST(NULL as sys.VARBINARY(85)) AS owner_sid
    , CAST(NULL as sys.NVARCHAR(128)) AS endpoint_url
    , CAST(0 as sys.TINYINT) AS availability_mode
    , CAST(NULL as sys.NVARCHAR(60)) AS availability_mode_desc
    , CAST(0 as sys.TINYINT) AS failover_mode
    , CAST(NULL as sys.NVARCHAR(60)) AS failover_mode_desc
    , CAST(0 as INT) AS session_timeout
    , CAST(0 as sys.TINYINT) AS primary_role_allow_connections
    , CAST(NULL as sys.NVARCHAR(60)) AS primary_role_allow_connections_desc
    , CAST(0 as sys.TINYINT) AS secondary_role_allow_connections
    , CAST(NULL as sys.NVARCHAR(60)) AS secondary_role_allow_connections_desc
    , CAST(NULL as sys.DATETIME) AS create_date
    , CAST(NULL as sys.DATETIME) AS modify_date
    , CAST(0 as INT) AS backup_priority
    , CAST(NULL as sys.NVARCHAR(256)) AS read_only_routing_url
    , CAST(NULL as sys.NVARCHAR(256)) AS read_write_routing_url
    , CAST(0 as sys.TINYINT) AS seeding_mode
    , CAST(NULL as sys.NVARCHAR(60)) AS seeding_mode_desc
WHERE FALSE;
GRANT SELECT ON sys.availability_replicas TO PUBLIC;

CREATE OR REPLACE VIEW sys.availability_groups 
AS SELECT  
    CAST(NULL as sys.UNIQUEIDENTIFIER) AS group_id
    , CAST(NULL as sys.SYSNAME) AS name
    , CAST(NULL as sys.NVARCHAR(40)) AS resource_id
    , CAST(NULL as sys.NVARCHAR(40)) AS resource_group_id
    , CAST(0 as INT) AS failure_condition_level
    , CAST(0 as INT) AS health_check_timeout
    , CAST(0 as sys.TINYINT) AS automated_backup_preference
    , CAST(NULL as sys.NVARCHAR(60)) AS automated_backup_preference_desc
    , CAST(0 as SMALLINT) AS version
    , CAST(0 as sys.BIT) AS basic_features
    , CAST(0 as sys.BIT) AS dtc_support
    , CAST(0 as sys.BIT) AS db_failover
    , CAST(0 as sys.BIT) AS is_distributed
    , CAST(0 as sys.TINYINT) AS cluster_type
    , CAST(NULL as sys.NVARCHAR(60)) AS cluster_type_desc
    , CAST(0 as INT) AS required_synchronized_secondaries_to_commit
    , CAST(0 as sys.BIGINT) AS sequence_number
    , CAST(0 as sys.BIT) AS is_contained
WHERE FALSE;
GRANT SELECT ON sys.availability_groups TO PUBLIC;

-- Support invalid quotation in sp_tables procedure
CREATE OR REPLACE FUNCTION sys.sp_tables_internal(
	in_table_name sys.nvarchar(384) = '',
	in_table_owner sys.nvarchar(384) = '', 
	in_table_qualifier sys.sysname = '',
	in_table_type sys.varchar(100) = '',
	in_fusepattern sys.bit = '1')
	RETURNS TABLE (
		out_table_qualifier sys.sysname,
		out_table_owner sys.sysname,
		out_table_name sys.sysname,
		out_table_type sys.varchar(32),
		out_remarks sys.varchar(254)
	)
	AS $$
		DECLARE opt_table sys.varchar(16) = '';
		DECLARE opt_view sys.varchar(16) = '';
		DECLARE cs_as_in_table_type varchar COLLATE "C" = in_table_type;
	BEGIN
		IF cs_as_in_table_type LIKE '%''TABLE''%' THEN
			opt_table = 'TABLE';
		END IF;
		IF cs_as_in_table_type LIKE '%''VIEW''%' THEN
			opt_view = 'VIEW';
		END IF;
		IF in_fusepattern = 1 THEN
			RETURN query
			SELECT 
			CAST(table_qualifier AS sys.sysname) AS TABLE_QUALIFIER,
			CAST(table_owner AS sys.sysname) AS TABLE_OWNER,
			CAST(table_name AS sys.sysname) AS TABLE_NAME,
			CAST(table_type AS sys.varchar(32)) AS TABLE_TYPE,
			CAST(remarks AS sys.varchar(254)) AS REMARKS
			FROM sys.sp_tables_view
			WHERE ((SELECT coalesce(in_table_name,'')) = '' OR table_name LIKE in_table_name collate sys.database_default)
			AND ((SELECT coalesce(in_table_owner,'')) = '' OR table_owner LIKE in_table_owner collate sys.database_default)
			AND ((SELECT coalesce(in_table_qualifier,'')) = '' OR table_qualifier LIKE in_table_qualifier collate sys.database_default)
			AND ((SELECT coalesce(cs_as_in_table_type,'')) = ''
			    OR table_type = opt_table
			    OR table_type = opt_view)
			ORDER BY table_qualifier, table_owner, table_name;
		ELSE 
			RETURN query
			SELECT 
			CAST(table_qualifier AS sys.sysname) AS TABLE_QUALIFIER,
			CAST(table_owner AS sys.sysname) AS TABLE_OWNER,
			CAST(table_name AS sys.sysname) AS TABLE_NAME,
			CAST(table_type AS sys.varchar(32)) AS TABLE_TYPE,
			CAST(remarks AS sys.varchar(254)) AS REMARKS
			FROM sys.sp_tables_view
			WHERE ((SELECT coalesce(in_table_name,'')) = '' OR table_name = in_table_name collate sys.database_default)
			AND ((SELECT coalesce(in_table_owner,'')) = '' OR table_owner = in_table_owner collate sys.database_default)
			AND ((SELECT coalesce(in_table_qualifier,'')) = '' OR table_qualifier = in_table_qualifier collate sys.database_default)
			AND ((SELECT coalesce(cs_as_in_table_type,'')) = ''
			    OR table_type = opt_table
			    OR table_type = opt_view)
			ORDER BY table_qualifier, table_owner, table_name;
		END IF;
	END;
$$
LANGUAGE plpgsql STABLE;
