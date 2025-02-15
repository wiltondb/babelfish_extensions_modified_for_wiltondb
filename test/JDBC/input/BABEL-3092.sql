-- Tests that using SET with dynamic SQL will not cause the change to persist

-- EXECUTE
EXEC (N'SET DATEFIRST 1; SELECT DATE_FIRST FROM sys.dm_exec_sessions where session_id = @@spid;');
GO

SELECT DATE_FIRST FROM sys.dm_exec_sessions where session_id = @@spid;
GO

EXECUTE (N'SET NOCOUNT ON; SELECT current_setting(''babelfishpg_tsql.nocount'', true)');
GO

SELECT current_setting('babelfishpg_tsql.nocount', true);
GO


-- sp_executesql
sp_executesql N'SET CONCAT_NULL_YIELDS_NULL off; SELECT CONCAT_NULL_YIELDS_NULL FROM sys.dm_exec_sessions where session_id = @@spid;';
GO

SELECT CONCAT_NULL_YIELDS_NULL FROM sys.dm_exec_sessions where session_id = @@spid;
GO


-- Errors in EXEC / sp_execute sql. Ensure stack level is removed. Confirm can
-- still revert with FMTONLY
DECLARE @v NVARCHAR(10);
EXEC (@v);
GO

sp_executesql NULL;
GO

CREATE TABLE t_3092_fmtonly(a INT);
GO
INSERT INTO t_3092_fmtonly (a) VALUES (1);
GO

EXEC (N'SET FMTONLY ON; SELECT * FROM t_3092_fmtonly;')
GO

SELECT * FROM t_3092_fmtonly;
GO

DROP TABLE t_3092_fmtonly;
GO


-- TEXTSIZE
sp_executesql N'SET TEXTSIZE 0; SELECT TEXT_SIZE FROM sys.dm_exec_sessions where session_id = @@spid;'
GO

SELECT TEXT_SIZE FROM sys.dm_exec_sessions where session_id = @@spid;
GO


-- IMPLICIT_TRANSACTIONS
sp_executesql N'SET IMPLICIT_TRANSACTIONS ON;
DECLARE @IMPLICIT_TRANSACTIONS VARCHAR(3) = ''OFF'';  
IF ( (2 & @@OPTIONS) = 2 ) SET @IMPLICIT_TRANSACTIONS = ''ON'';  
SELECT @IMPLICIT_TRANSACTIONS AS IMPLICIT_TRANSACTIONS;'
GO

DECLARE @IMPLICIT_TRANSACTIONS VARCHAR(3) = 'OFF';  
IF ( (2 & @@OPTIONS) = 2 ) SET @IMPLICIT_TRANSACTIONS = 'ON';  
SELECT @IMPLICIT_TRANSACTIONS AS IMPLICIT_TRANSACTIONS;
GO


-- XACT_ABORT
EXEC (N' SET XACT_ABORT ON; 
    DECLARE @XACT_ABORT VARCHAR(3) = ''OFF'';
    IF ( (16384 & @@OPTIONS) = 16384 ) SET @XACT_ABORT = ''ON'';
    SELECT @XACT_ABORT AS XACT_ABORT;'
);
GO

DECLARE @XACT_ABORT VARCHAR(3) = 'OFF';
IF ( (16384 & @@OPTIONS) = 16384 ) SET @XACT_ABORT = 'ON';
SELECT @XACT_ABORT AS XACT_ABORT;
GO


-- Multiple SETs 
EXECUTE (N'SET LOCK_TIMEOUT 1500; SET DATEFIRST 5; SELECT LOCK_TIMEOUT, DATE_FIRST FROM sys.dm_exec_sessions where session_id = @@spid;');
GO

SELECT LOCK_TIMEOUT, DATE_FIRST FROM sys.dm_exec_sessions where session_id = @@spid;
GO

sp_executesql N'SET ANSI_NULLS, QUOTED_IDENTIFIER OFF; SELECT ansi_nulls, QUOTED_IDENTIFIER FROM sys.dm_exec_sessions where session_id = @@spid; ';
GO

SELECT ANSI_NULLS, QUOTED_IDENTIFIER FROM sys.dm_exec_sessions where session_id = @@spid;
GO


-- Nested
DECLARE @Nested NVARCHAR(500);
SET @Nested = N'SET DATEFIRST 3; 
    EXEC (N''SET DATEFIRST 4; SELECT DATE_FIRST FROM sys.dm_exec_sessions where session_id = @@spid;''); 
SELECT DATE_FIRST FROM sys.dm_exec_sessions where session_id = @@spid;'
  
EXECUTE sp_executesql N'sp_executesql @level; 
    SELECT DATE_FIRST FROM sys.dm_exec_sessions where session_id = @@spid;', N'@level NVARCHAR(500)', @level = @Nested;  
GO


-- Identity Insert
-- Revert Off
CREATE TABLE table_3092_1 (test_id INT IDENTITY, test_col INT);

GO

sp_executesql N'SET IDENTITY_INSERT table_3092_1 ON; INSERT INTO table_3092_1 (test_id, test_col) VALUES (1, 1);';
GO

INSERT INTO table_3092_1 (test_id, test_col) VALUES (2, 2);
GO

SELECT * FROM table_3092_1;
GO

DROP TABLE table_3092_1;
GO

-- Revert On Case
CREATE TABLE table_3092_1 (test_id INT IDENTITY, test_col INT);
CREATE TABLE table_3092_2 (test_id INT IDENTITY, test_col INT);
GO

SET IDENTITY_INSERT table_3092_1 ON;
GO

INSERT INTO table_3092_1 (test_id, test_col) VALUES (1, 1);
GO

sp_executesql N'SET IDENTITY_INSERT table_3092_1 OFF; SET IDENTITY_INSERT table_3092_2 ON; INSERT INTO table_3092_2 (test_id, test_col) VALUES (2, 2);';
GO

INSERT INTO table_3092_1 (test_id, test_col) VALUES (3, 3);
GO
INSERT INTO table_3092_2 (test_id, test_col) VALUES (4, 4);
GO

SELECT * FROM table_3092_1;
GO
SELECT * FROM table_3092_2;
GO

DROP TABLE table_3092_1;
DROP TABLE table_3092_2;
GO


-- Negative Test Case, transactions should not revert
begin transaction;
GO

SET IMPLICIT_TRANSACTIONS ON;
GO

DECLARE @IMPLICIT_TRANSACTIONS VARCHAR(3) = 'OFF';  
IF ( (2 & @@OPTIONS) = 2 ) SET @IMPLICIT_TRANSACTIONS = 'ON';  
SELECT @IMPLICIT_TRANSACTIONS AS IMPLICIT_TRANSACTIONS;

commit;
go

DECLARE @IMPLICIT_TRANSACTIONS VARCHAR(3) = 'OFF';  
IF ( (2 & @@OPTIONS) = 2 ) SET @IMPLICIT_TRANSACTIONS = 'ON';  
SELECT @IMPLICIT_TRANSACTIONS AS IMPLICIT_TRANSACTIONS;
GO

SET IMPLICIT_TRANSACTIONS OFF;
GO

-- BABEL-4816 will fix EXEC dynamic SQL with double quotes
SET QUOTED_IDENTIFIER ON
GO
EXEC('SELECT * FROM t')
GO
EXEC("SELECT * FROM t")
GO
EXEC(@v)
GO
SET QUOTED_IDENTIFIER OFF
GO
EXEC('SELECT * FROM t')
GO
EXEC("SELECT * FROM t")
GO
EXEC(@v)
GO
