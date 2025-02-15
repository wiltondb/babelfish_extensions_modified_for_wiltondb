CREATE TYPE dbo.babel_3409_concat_imageUDT FROM image;
GO

CREATE TYPE dbo.babel_3409_concat_varUDT FROM varchar(50);
GO

-- Test with different datatypes supported & non-supported for arguments
-- Supported: char, varchar, nchar, nvarchar, int, bigint, smallint, tinyint, numeric, float, real, bit, decimal, smallmoney, money, datetime, datetime2, binary, varbinary, date, time, datetimeoffset, smalldatetime, image, text, ntext
-- Unsupported: geometry, geography, sql_variant, xml
CREATE TABLE babel_3409_concat_t1(
    id int,
    col_char char(20),
    col_varchar varchar(50),
    col_nchar nchar(20),
    col_nvarchar nvarchar(50),
    col_int int,
    col_bigint bigint,
    col_smallint smallint,
    col_tinyint tinyint,
    col_numeric numeric,
    col_float float,
    col_real real,
    col_bit bit,
    col_decimal decimal,
    col_smallmoney smallmoney,
    col_money money,
    col_datetime datetime,
    col_datetime2 datetime2,
    col_binary binary(20),
    col_varbinary varbinary(20),
    col_date date,
    col_time time,
    col_datetimeoffset datetimeoffset,
    col_smalldatetime smalldatetime,
    col_image image,
    col_text text,
    col_ntext ntext,
    col_sql_variant sql_variant,
    col_xml xml,
    col_varUDT dbo.babel_3409_concat_varUDT,
    col_imageUDT dbo.babel_3409_concat_imageUDT
)
GO


INSERT INTO babel_3409_concat_t1 VALUES(
    1,
    N'abc',
    N'abc',
    N'abc',
    N'abc',
    CAST(12 AS INT),
    CAST(12 AS BIGINT),
    CAST(12 AS SMALLINT),
    CAST(12 AS TINYINT),
    CAST(12.1 AS NUMERIC),
    CAST(12.1 AS FLOAT),
    CAST(12.1 AS REAL),
    CAST(1 AS BIT),
    CAST(12 AS DECIMAL),
    CAST(12 AS SMALLMONEY),
    CAST(12 AS MONEY),
    CAST(N'2000-12-12 12:43:10' AS DATETIME),
    CAST(N'2000-12-12 12:43:10' AS DATETIME2),
    0x6162,
    0x6162,
    CAST(N'2000-12-12' AS DATE),
    CAST(N'12:43:10' AS TIME),
    CAST(N'2000-12-12 12:43:10.1234 +10:0' AS DATETIMEOFFSET),
    CAST(N'2000-12-12 12:43:10' AS SMALLDATETIME),
    CAST('abc' AS IMAGE),
    N'abc',
    N'abc',
    CAST(N'abc' AS SQL_VARIANT),
    CAST ('<body><apple/></body>' AS xml),
    'abc',
    0x6364
),
(
    2,
    N'🙂defghi',
    N'🙂defghi',
    N'🙂defghi',
    N'🙂defghi',
    CAST(13 AS INT),
    CAST(13 AS BIGINT),
    CAST(13 AS SMALLINT),
    CAST(13 AS TINYINT),
    CAST(13.1 AS NUMERIC),
    CAST(13.1 AS FLOAT),
    CAST(13.1 AS REAL),
    CAST(0 AS BIT),
    CAST(13 AS DECIMAL),
    CAST(13 AS SMALLMONEY),
    CAST(13 AS MONEY),
    CAST(N'2000-12-13 12:43:10' AS DATETIME),
    CAST(N'2000-12-13 12:43:10' AS DATETIME2),
    0x6364,
    0x6364,
    CAST(N'2000-12-13' AS DATE),
    CAST(N'12:43:10' AS TIME),
    CAST(N'2000-12-13 12:43:10.1234 +10:0' AS DATETIMEOFFSET),
    CAST(N'2000-12-13 12:43:10' AS SMALLDATETIME),
    CAST('🙂defghi' AS IMAGE),
    N'🙂defghi',
    N'🙂defghi',
    CAST(N'🙂defghi' AS SQL_VARIANT),
    CAST ('<body><banana/></body>' AS xml),
    '🙂defghi',
    0x6364
),
(
    3,
    N'🙂🙂',
    N'🙂🙂',
    N'🙂🙂',
    N'🙂🙂',
    CAST(14 AS INT),
    CAST(14 AS BIGINT),
    CAST(14 AS SMALLINT),
    CAST(14 AS TINYINT),
    CAST(14.1 AS NUMERIC),
    CAST(14.1 AS FLOAT),
    CAST(14.1 AS REAL),
    CAST(1 AS BIT),
    CAST(14 AS DECIMAL),
    CAST(14 AS SMALLMONEY),
    CAST(14 AS MONEY),
    CAST(N'2000-12-14 12:43:10' AS DATETIME),
    CAST(N'2000-12-14 12:43:10' AS DATETIME2),
    0x6566,
    0x6566,
    CAST(N'2000-12-14' AS DATE),
    CAST(N'12:43:10' AS TIME),
    CAST(N'2000-12-14 12:43:10.1234 +10:0' AS DATETIMEOFFSET),
    CAST(N'2000-12-14 12:43:10' AS SMALLDATETIME),
    CAST('🙂🙂' AS IMAGE),
    N'🙂🙂',
    N'🙂🙂',
    CAST(N'🙂🙂' AS SQL_VARIANT),
    CAST ('<body><chikoo/></body>' AS xml),
    '🙂🙂',
    0x6566
),
(
    4,
    N'比尔·拉',
    N'比尔·拉',
    N'比尔·拉',
    N'比尔·拉',
    CAST(15 AS INT),
    CAST(15 AS BIGINT),
    CAST(15 AS SMALLINT),
    CAST(15 AS TINYINT),
    CAST(15.1 AS NUMERIC),
    CAST(15.1 AS FLOAT),
    CAST(15.1 AS REAL),
    CAST(0 AS BIT),
    CAST(15 AS DECIMAL),
    CAST(15 AS SMALLMONEY),
    CAST(15 AS MONEY),
    CAST(N'2000-12-15 12:43:10' AS DATETIME),
    CAST(N'2000-12-15 12:43:10' AS DATETIME2),
    0x6768,
    0x6768,
    CAST(N'2000-12-15' AS DATE),
    CAST(N'12:43:10' AS TIME),
    CAST(N'2000-12-15 12:43:10.1234 +10:0' AS DATETIMEOFFSET),
    CAST(N'2000-12-15 12:43:10' AS SMALLDATETIME),
    CAST('比尔·拉' AS IMAGE),
    N'比尔·拉',
    N'比尔·拉',
    CAST(N'比尔·拉' AS SQL_VARIANT),
    CAST ('<body><dragonfruit/></body>' AS xml),
    '比尔·拉',
    0x6768
),
(
    5,
    N'莫斯',
    N'莫斯',
    N'莫斯',
    N'莫斯',
    CAST(16 AS INT),
    CAST(16 AS BIGINT),
    CAST(16 AS SMALLINT),
    CAST(16 AS TINYINT),
    CAST(16.1 AS NUMERIC),
    CAST(16.1 AS FLOAT),
    CAST(16.1 AS REAL),
    CAST(1 AS BIT),
    CAST(16 AS DECIMAL),
    CAST(16 AS SMALLMONEY),
    CAST(16 AS MONEY),
    CAST(N'2000-12-16 12:43:10' AS DATETIME),
    CAST(N'2000-12-16 12:43:10' AS DATETIME2),
    0x6970,
    0x6970,
    CAST(N'2000-12-16' AS DATE),
    CAST(N'12:43:10' AS TIME),
    CAST(N'2000-12-16 12:43:10.1234 +10:0' AS DATETIMEOFFSET),
    CAST(N'2000-12-16 12:43:10' AS SMALLDATETIME),
    CAST('莫斯' AS IMAGE),
    N'莫斯',
    N'莫斯',
    CAST(N'莫斯' AS SQL_VARIANT),
    CAST ('<body><mango/></body>' AS xml),
    '莫斯',
    0x6970
),
(
    6,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL
),
(
    7,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL
),
(
    8,
    'Anikait',
    'Anikait',
    'Anikait',
    'Anikait',
    CAST(17 AS INT),
    CAST(17 AS BIGINT),
    CAST(17 AS SMALLINT),
    CAST(17 AS TINYINT),
    CAST(17.1 AS NUMERIC),
    CAST(17.1 AS FLOAT),
    CAST(17.1 AS REAL),
    CAST(0 AS BIT),
    CAST(17 AS DECIMAL),
    CAST(17 AS SMALLMONEY),
    CAST(17 AS MONEY),
    CAST(N'2000-12-17 12:43:10' AS DATETIME),
    CAST(N'2000-12-17 12:43:10' AS DATETIME2),
    0x7172,
    0x7172,
    CAST(N'2000-12-17' AS DATE),
    CAST(N'12:43:10' AS TIME),
    CAST(N'2000-12-17 12:43:10.1234 +10:0' AS DATETIMEOFFSET),
    CAST(N'2000-12-17 12:43:10' AS SMALLDATETIME),
    CAST('Anikait' AS IMAGE),
    N'Anikait',
    N'Anikait',
    CAST(N'Anikait' AS SQL_VARIANT),
    CAST ('<body><papaya/></body>' AS xml),
    'Anikait',
    0x7172
),
(
    9,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL
),
(
    10,
    'Agrawal',
    'Agrawal',
    'Agrawal',
    'Agrawal',
    CAST(18 AS INT),
    CAST(18 AS BIGINT),
    CAST(18 AS SMALLINT),
    CAST(18 AS TINYINT),
    CAST(18.1 AS NUMERIC),
    CAST(18.1 AS FLOAT),
    CAST(18.1 AS REAL),
    CAST(0 AS BIT),
    CAST(18 AS DECIMAL),
    CAST(18 AS SMALLMONEY),
    CAST(18 AS MONEY),
    CAST(N'2000-12-18 12:43:10' AS DATETIME),
    CAST(N'2000-12-18 12:43:10' AS DATETIME2),
    0x7273,
    0x7273,
    CAST(N'2000-12-18' AS DATE),
    CAST(N'12:43:10' AS TIME),
    CAST(N'2000-12-18 12:43:10.1234 +10:0' AS DATETIMEOFFSET),
    CAST(N'2000-12-18 12:43:10' AS SMALLDATETIME),
    CAST('Agrawal' AS IMAGE),
    N'Agrawal',
    N'Agrawal',
    CAST(N'Agrawal' AS SQL_VARIANT),
    CAST ('<body><orange/></body>' AS xml),
    'Agrawal',
    0x7273
)
GO

CREATE TABLE babel_3409_concat_t2(
    id int,
    col1_cias varchar(50) collate chinese_prc_ci_as,
    col1_ciai varchar(50) collate chinese_prc_ci_ai,
    col1_csas varchar(50) collate chinese_prc_cs_as,
    col2_cias varchar(50) collate arabic_ci_as,
    col2_ciai varchar(50) collate arabic_ci_ai,
    col2_csas varchar(50) collate arabic_cs_as
)
GO

INSERT INTO babel_3409_concat_t2 VALUES
(
    1,
    N'比尔·拉',
    N'比尔·拉',
    N'比尔·拉',
    N'الله',
    N'الله',
    N'الله'
),
(
    2,
    N'莫',
    N'莫',
    N'莫',
    N' مع ',
    N' مع ',
    N' مع '
),
(
    3,
    N'斯',
    N'斯',
    N'斯',
    N'المتقين',
    N'المتقين',
    N'المتقين'
)
GO

CREATE VIEW babel_3409_concat_dep_view1 AS
    SELECT CONCAT(col_varchar, col_char, col_varbinary, col_text) AS concatenated_column FROM babel_3409_concat_t1
GO

CREATE PROCEDURE babel_3409_concat_dep_proc1 AS
    SELECT CONCAT(col_varchar, col_char, col_varbinary, col_text) FROM babel_3409_concat_t1 ORDER BY id
GO

CREATE FUNCTION babel_3409_concat_dep_func1()
RETURNS NVARCHAR(50)
AS
BEGIN
RETURN (SELECT TOP 1 CONCAT(col_varchar, col_char, col_varbinary, col_text) FROM babel_3409_concat_t1 ORDER BY id)
END
GO

CREATE FUNCTION babel_3409_concat_itvf_func1()
RETURNS TABLE
AS
RETURN (SELECT TOP 1 CONCAT(col_nvarchar, col_nchar, col_int, col_bigint, col_smallint, col_tinyint, col_numeric, col_float, col_real, col_bit) AS concatenated_column FROM babel_3409_concat_t1 ORDER BY id)
GO

CREATE VIEW babel_3409_concat_dep_view2 AS
    SELECT CONCAT(col_nvarchar, col_nchar, col_varchar, col_decimal, col_smallmoney, col_smalldatetime) AS concatenated_column FROM babel_3409_concat_t1
GO

CREATE PROCEDURE babel_3409_concat_dep_proc2 AS
    SELECT CONCAT(col_nvarchar, col_money, col_datetime, col_datetime2, col_binary, col_date, col_time, col_datetimeoffset) FROM babel_3409_concat_t1 ORDER BY id
GO

CREATE FUNCTION babel_3409_concat_dep_func2()
RETURNS NVARCHAR(50)
AS
BEGIN
RETURN (SELECT TOP 1 CONCAT(col_nvarchar, col_varbinary, col_text, col_ntext) FROM babel_3409_concat_t1 ORDER BY id)
END
GO

CREATE FUNCTION babel_3409_concat_itvf_func2()
RETURNS TABLE
AS
RETURN (SELECT TOP 1 CONCAT(col_nvarchar, col_varchar, col_char, col_nchar) AS concatenated_column FROM babel_3409_concat_t1 ORDER BY id)
GO

CREATE PROCEDURE babel_3409_cast_time_to_varchar_proc @a VARCHAR(100) AS
    SELECT @a;
GO

CREATE FUNCTION babel_3409_cast_time_to_varchar_func(@a VARCHAR(100))
RETURNS VARCHAR(100)
AS
BEGIN
RETURN @a;
END
GO

CREATE PROCEDURE babel_3409_cast_time_to_nvarchar_proc @a NVARCHAR(100) AS
    SELECT @a;
GO

CREATE FUNCTION babel_3409_cast_time_to_nvarchar_func(@a NVARCHAR(100))
RETURNS NVARCHAR(100)
AS
BEGIN
RETURN @a;
END
GO

CREATE PROCEDURE babel_3409_cast_date_to_varchar_proc @a VARCHAR(100) AS
    SELECT @a;
GO

CREATE FUNCTION babel_3409_cast_date_to_varchar_func(@a VARCHAR(100))
RETURNS VARCHAR(100)
AS
BEGIN
RETURN @a;
END
GO

CREATE PROCEDURE babel_3409_cast_date_to_nvarchar_proc @a NVARCHAR(100) AS
    SELECT @a;
GO

CREATE FUNCTION babel_3409_cast_date_to_nvarchar_func(@a NVARCHAR(100))
RETURNS NVARCHAR(100)
AS
BEGIN
RETURN @a;
END
GO

CREATE PROCEDURE babel_3409_cast_datetimeoffset_to_varchar_proc @a VARCHAR(100) AS
    SELECT @a;
GO

CREATE FUNCTION babel_3409_cast_datetimeoffset_to_varchar_func(@a VARCHAR(100))
RETURNS VARCHAR(100)
AS
BEGIN
RETURN @a;
END
GO

CREATE PROCEDURE babel_3409_cast_datetimeoffset_to_nvarchar_proc @a NVARCHAR(100) AS
    SELECT @a;
GO

CREATE FUNCTION babel_3409_cast_datetimeoffset_to_nvarchar_func(@a NVARCHAR(100))
RETURNS NVARCHAR(100)
AS
BEGIN
RETURN @a;
END
GO
