

CREATE TABLE test_identity_vu_prepare_t1
(id   INT IDENTITY(1, 1), 
 Name NVARCHAR(20) NULL
)
GO

INSERT INTO test_identity_vu_prepare_t1 VALUES ('Nirmit_Shah')
GO

SELECT MAX(id) AS MaximumUsedIdentity FROM test_identity_vu_prepare_t1
SELECT SCOPE_IDENTITY()
SELECT @@IDENTITY
SELECT IDENT_CURRENT('test_identity_vu_prepare_t1')
GO

-- should succeed on atleast 14_7 or 15_2, should still succeed after upgrade
SELECT sys.babelfish_get_scope_identity()
GO

CREATE PROCEDURE test_identity_vu_prepare_p1
AS
INSERT INTO test_identity_vu_prepare_t1 VALUES ('Nirmit_Shah')
SELECT MAX(id) AS MaximumUsedIdentity FROM test_identity_vu_prepare_t1
SELECT SCOPE_IDENTITY()
SELECT @@IDENTITY
SELECT IDENT_CURRENT('test_identity_vu_prepare_t1')
SELECT sys.babelfish_get_scope_identity()
GO

CREATE FUNCTION test_identity_vu_prepare_func1()
RETURNS TINYINT
AS
BEGIN
RETURN IDENT_CURRENT('test_identity_vu_prepare_t1')
END
GO

CREATE TABLE test_identity_vu_prepare_t2
(id   SMALLINT IDENTITY(1, 1)  , 
 Name NVARCHAR(20) NULL
)
GO

INSERT test_identity_vu_prepare_t2 VALUES ('Babelfish1'),('Babelfish2'),('Babelfish3')
GO

CREATE PROCEDURE test_identity_vu_prepare_p2
AS
INSERT INTO test_identity_vu_prepare_t2 VALUES ('Babelfish4')
SELECT MAX(id) AS MaximumUsedIdentity FROM test_identity_vu_prepare_t2
SELECT SCOPE_IDENTITY()
SELECT @@IDENTITY
SELECT IDENT_CURRENT('test_identity_vu_prepare_t2')
SELECT sys.babelfish_get_scope_identity()
GO

CREATE TABLE test_identity_vu_prepare_t3
(DepartmentID   INT IDENTITY(100, 5) , 
 Departmentname VARCHAR(20) NULL
);
GO

CREATE PROCEDURE test_identity_vu_prepare_p3
AS
INSERT INTO test_identity_vu_prepare_t3 VALUES ('Babelfish5')
SELECT MAX(DepartmentID) AS MaximumUsedIdentity FROM test_identity_vu_prepare_t3
SELECT SCOPE_IDENTITY()
SELECT @@IDENTITY
SELECT IDENT_CURRENT('test_identity_vu_prepare_t3')
SELECT sys.babelfish_get_scope_identity()
GO

INSERT test_identity_vu_prepare_t3 VALUES ('Babelfish6'),('Babelfish7'),('Babelfish8')
GO

CREATE TRIGGER test_indentity_vu_prepare_trig1  
ON test_identity_vu_prepare_t2  
FOR INSERT AS   
   BEGIN  
   INSERT test_identity_vu_prepare_t3  VALUES ('Babelfish11')  
   END;
GO

INSERT INTO test_identity_vu_prepare_t2 VALUES('Babelfish12')
GO

-- IDENTITY vs SCOPE_IDENTITY vs IDENT_CURRENT
-- The value of IDENTITY should not be the same as SCOPE_IDENTITY
-- IDENTITY should return value of identity from trigger (t3)
-- SCOPE_IDENTITY should return value of identity in scope of last INSERT (t2)
-- IDENT_CURRENT(t2) should return value of identity of t2 regardless of scope
-- The output in expected files are verified against SQL Server
SELECT MAX(id) AS MaximumUsedIdentity FROM test_identity_vu_prepare_t2
SELECT MAX(DepartmentID) AS MaximumUsedIdentity FROM test_identity_vu_prepare_t3
SELECT @@IDENTITY
SELECT SCOPE_IDENTITY()
SELECT IDENT_CURRENT('test_identity_vu_prepare_t2')
SELECT sys.babelfish_get_scope_identity()
GO

CREATE FUNCTION test_identity_vu_prepare_func2()
RETURNS TINYINT
AS
BEGIN
RETURN IDENT_CURRENT('test_identity_vu_prepare_t2')
END
GO

CREATE FUNCTION test_identity_vu_prepare_func3()
RETURNS TINYINT
AS
BEGIN
RETURN IDENT_CURRENT('test_identity_vu_prepare_t3')
END
GO

CREATE TABLE test_identity_vu_prepare_t4
(
   Name VARCHAR(20),
   Age  INT NOT NULL
)
GO

INSERT test_identity_vu_prepare_t4 VALUES ('Babelfish13',21),('Babelfish14',20),('Babelfish15',23)
GO

CREATE TABLE test_identity_vu_prepare_t5
(
   Name VARCHAR(20),
   Age  INT NOT NULL
)
GO

INSERT test_identity_vu_prepare_t5 VALUES ('Babelfish16',21),('Babelfish17',20),('Babelfish18',23)
GO

CREATE PROCEDURE test_identity_vu_prepare_p4
AS
ALTER TABLE test_identity_vu_prepare_t5 ADD id INT IDENTITY(1,1) NOT NULL
GO

CREATE FUNCTION test_identity_vu_prepare_func4()
RETURNS TINYINT
AS
BEGIN
RETURN IDENT_CURRENT('test_identity_vu_prepare_t5')
END
GO

--test for OUTPUT Clause
CREATE TABLE test_identity_vu_prepare_t6
(
   ID INT IDENTITY(1,1),
   Name VARCHAR(20)
)
GO

CREATE PROCEDURE test_identity_vu_prepare_p5
AS
INSERT INTO test_identity_vu_prepare_t6 
OUTPUT INSERTED.ID
VALUES ('Babelfish19')
GO

CREATE VIEW scope_identity_view AS
SELECT sys.babelfish_get_scope_identity()
GO