-- MASTER is a T-SQL keyword in ANTLR however according to T-SQL it isn't
-- When doing T-SQL parsing it will not throw syntax error and rewrite will
-- happen as expected. We will throw server does not exist error
SELECT COLUMN_NAME from master.[JDG_Refund_Requests].information_schema.columns where [TABLE_NAME] = 'vw_All_Requests'
GO

SELECT * FROM OPENQUERY(master, 'select * from a.b.c.d')
GO

-- MERGE is a T-SQL keyword and in ANTLR as well
-- So we will throw syntax error in T-SQL parsing itself
SELECT COLUMN_NAME from merge.[JDG_Refund_Requests].information_schema.columns where [TABLE_NAME] = 'vw_All_Requests'
GO

SELECT * FROM OPENQUERY(merge, 'select * from a.b.c.d')
GO
