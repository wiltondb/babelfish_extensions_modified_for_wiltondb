SELECT PARSENAME('tempdb.dbo.Employee', 3) AS [Database Name],
PARSENAME('tempdb.dbo.Employee', 2) AS [Schema Name],
PARSENAME('tempdb.dbo.Employee', 1) AS [Table Name],
*
FROM
parsename_Employee
ORDER BY HireDate DESC;
GO

SELECT * FROM parsename_EmployeeDatabaseView1
GO

EXEC parsename_GetEmployeeDatabaseName1
GO

SELECT * FROM parsename_EmployeeDatabaseView2
GO

EXEC parsename_GetEmployeeDatabaseName2
GO

SELECT * FROM parsename_EmployeeDatabaseView3
GO

EXEC parsename_GetEmployeeDatabaseName3
GO

--Checking PARSENAME to return the first part of a four-part name, 'mytable'.
SELECT PARSENAME('tempdb.dbo.Employee.mytable',1)
GO

--Checking PARSENAME to return the second part of a four-part name, 'Employee'.
SELECT PARSENAME('tempdb.dbo.Employee.mytable',2)
GO

--Checking PARSENAME to return the third part of a four-part name, 'dbo'.
SELECT PARSENAME('tempdb.dbo.Employee.mytable',3)
GO

--Checking PARSENAME to the fourth part of a four-part name, 'tempdb'.
SELECT PARSENAME('tempdb.dbo.Employee.mytable',4)
GO

--Checking PARSENAME to return the fifth part of a four-part name which does not exist. Will return NULL.
SELECT PARSENAME('tempdb.dbo.Employee.mytable',5)
GO

--Checking PARSENAME to return 'Employee', the first part of a three-part name.
SELECT PARSENAME('tempdb.dbo.Employee',1)
GO

--Checking PARSENAME to return 'dbo', the second part of a three-part name..
SELECT PARSENAME('tempdb.dbo.Employee',2)
GO

--Checking PARSENAME to return 'tempdb', the third part of a three-part name.
SELECT PARSENAME('tempdb.dbo.Employee',3)
GO

--Checking PARSENAME to return the fifth part of a three-part name which does not exist. Will return NULL.
SELECT PARSENAME('tempdb.dbo.Employee',5)
GO

--Checking PARSENAME to return 'Employee', the first part of a three-part name starting with a dot.
SELECT PARSENAME('.dbo.Employee',1)
GO

--Checking PARSENAME to return 'dbo', the second part of a three-part name starting with a dot.
SELECT PARSENAME('.dbo.Employee',2)
GO

--Checking PARSENAME to return NULL, because the third part of a three-part name starting with a dot is not defined.
SELECT PARSENAME('.dbo.Employee',3)
GO

--Checking PARSENAME to return 'Employee', the first part of a three-part name with no first,second part.
SELECT PARSENAME('..Employee',1)
GO

--Checking PARSENAME to return NULL, because the second part of a three-part name with no second part is not defined.
SELECT PARSENAME('..Employee',2)
GO

--Checking PARSENAME to return NULL, because the third part of a three-part name with no second and third parts is not defined.
SELECT PARSENAME('..Employee',3)
GO

--Checking PARSENAME to return NULL, because there's no first part defined in a two-part name with no parts defined.
SELECT PARSENAME('..',1)
GO

--Checking PARSENAME to return NULL, because there's no second part defined in a three-part name with no second part.
SELECT PARSENAME('tempdb..Employee',2)
GO

--Checking PARSENAME to return 'tempdb', the third part of a three-part name with no second part.
SELECT PARSENAME('tempdb..Employee',3)
GO

--Checking PARSENAME to return NULL for the third part of a three-part name starting with a dot.
SELECT PARSENAME('.dbo.Employee',3)
GO

--Checking the third part of a four-part name starting with a dot, which is 'dbo'.
SELECT PARSENAME('.dbo.Employee.table',3)
GO

--Checking for the first part of a four-part name with an empty fourth part, should return NULL.
SELECT PARSENAME('tempdb.dbo.Employee.', 1)
GO

--Checking if 3 parts are given and object_piece = 2 and the first part is having more than 128 characters so it will should NULL.
SELECT PARSENAME('tempdbvdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd.dbo.Employee',2)
GO

--Checking if 3 parts are given and object_piece = 2 and the first part is having than 127 characters so it will return the object_piece value'dbo'.
SELECT PARSENAME('tempdbvddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd.dbo.Employee',2)
GO

--Checking if 3 parts are given and object_piece = 1 and the second part is having more than 128 characters so it will should return NULL.
SELECT PARSENAME('tempdb.dbopdbvdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd.Employee',1)
GO

--Checking if 3 parts are given and object_piece = 1 and the third part is having more than 128 characters so it will should return NULL.
SELECT PARSENAME('tempdb.dbo.Employeeddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd',1)
GO

---Checking PARSENAME to return 'Employee' - from a fully bracketed four-part name.
SELECT PARSENAME('[tempdb].[dbo].[Employee]',1)
GO

---Checking PARSENAME to return 'dbo' - from a fully bracketed four-part name.
SELECT PARSENAME('[tempdb].[dbo].[Employee]',2)
GO

---Checking PARSENAME to return 'tempdb' - a fully bracketed four-part name
SELECT PARSENAME('[tempdb].[dbo].[Employee]',3)
GO

---Checking if inside brackets as [Object_name] and there is an open bracket inside object_name so it should return the value 'Empl[oyee'
SELECT PARSENAME('tempdb.dbo.[Empl[oyee]',1)
GO

--Checking if inside brackets as [Object_name] and there is an close bracket inside object_name so it should return NULL.
SELECT PARSENAME('tempdb.dbo.[Empl]oyee]',1)
GO

--Checking if inside brackets as [Object_name] and there are 2 close bracket inside object_name so it should escape 1 close bracket and return 'Empl]oyee'.
SELECT PARSENAME('tempdb.dbo.[Empl]]oyee]',1)
GO

--Checking there is continuous double close brackets inside open and close bracket it should escape one bracket evertime if it encounter a continuous close bracket.
SELECT PARSENAME('tempdb.dbo.[Empl]]oy]]ee]',1)
GO

--Checking if inside brackets as [Object_nam]e but the object name is not properly enclosed so it will return NULL. 
SELECT PARSENAME('tempdb.dbo.[Employe]e',1)
GO

--Checking if inside brackets as [Object_name] and there is a double quotes it should return the value 'Empl"oyee'.
SELECT PARSENAME('[tempdb].[dbo].[Empl"oyee]',1)
GO

--Checking if inside brackets as [Object_name] and there is a double quotes it should return the value 'Empl""oyee'.
SELECT PARSENAME('[tempdb].[dbo].[Empl""oyee]',1)
GO

--Checking if inside brackets as Ob[ject_name] but the object name is not properly enclosed so it will return NULL. 
SELECT PARSENAME('tempdb.dbo.Em[ployee]',1)
GO

--Checking for syntax error as there is only 1 open bracket.
SELECT PARSENAME('tempdb.dbo.Em[ployee',1)
GO

--Checking for syntax error as there is only 1 close bracket.
SELECT PARSENAME('tempdb.dbo.Em]ployee',1)
GO

--Checking if inside brackets as [Object_name] and there is a dot it should return 'tempdb.dbo.Employee'.
SELECT PARSENAME('[tempdb.dbo.Employee]',1)
GO

--Checking if inside double quotes as "Object_name" and there is a single double quotes "object"name" so it should return NULL.
SELECT PARSENAME('tempdb.dbo."Emp"loyee"',1)
GO

--Checking if inside double quotes as "Object_name" and there are 2 continuous double quotes "object""name" so it will escape " and it should return 'Emp"loyee'.
SELECT PARSENAME('tempdb.dbo."Emp""loyee"',1)
GO

--Checking there is continuous double quotes inside a double quotes it should escape one double quotes evertime if it encounter a continuous double quotes.
SELECT PARSENAME('tempdb.dbo."Emp""loy""ee"',1)
GO

--Checking if inside double quotes as "Object_name" and there is a closing bracket it should return the value 'Empl]oyee'.
SELECT PARSENAME('tempdb.dbo."Empl]oyee"',1)
GO

--Checking if inside double quotes as "Object_name" and there is a closing bracket it should return the value 'Empl]]oyee'.
SELECT PARSENAME('tempdb.dbo."Empl]]oyee"',1)
GO

--Checking if inside double quotes as "Object_nam"e but the object name is not properly enclosed so it will return NULL. 
SELECT PARSENAME('tempdb.dbo."Employe"e',1)
GO

--Checking for syntax error as there is only 1 double quotes.
SELECT PARSENAME('tempdb.dbo.Em"ployee',1)
GO

--Checking if inside double quotes as Ob"ject_name" but the object name is not properly enclosed so it will return NULL. 
SELECT PARSENAME('tempdb.dbo.Em"ployee"',1)
GO

--Checking if inside double quotes as "Object_name" and there is a dot it should return 'tempdb.dbo.Employee'.
SELECT PARSENAME('"tempdb.dbo.Employee"',1)
GO

SELECT PARSENAME('AdventureWorksPDW2012.dbo.DimCustomer', 1) AS 'Object Name';
GO

SELECT PARSENAME('AdventureWorksPDW2012.dbo.DimCustomer', 2) AS 'Schema Name';
GO

SELECT PARSENAME('AdventureWorksPDW2012.dbo.DimCustomer', 3) AS 'Database Name';
GO

SELECT PARSENAME('AdventureWorksPDW2012.dbo.DimCustomer', 4) AS 'Server Name';  
GO

--Checking for very long character input it should return NULL.
SELECT PARSENAME('tempdbvddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddbopdbvdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddEmployeedddddddddddddddddddddddddddtempdbvddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddbopdbvdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddEmployeedddddddddddddddddddddddddddtempdbvddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddbopdbvdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddEmployeedddddddddddddddddddddddddddtempdbvddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddbopdbvdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddEmployeeddddddddddddddddddddddddddd',1)
GO

--128 unicode characters
SELECT PARSENAME('ちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちち',1)
GO

--129 unicode characters
SELECT PARSENAME('ちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちちち',1)
GO

--Checking for 0 parts returns NULL
SELECT PARSENAME('',1)
GO