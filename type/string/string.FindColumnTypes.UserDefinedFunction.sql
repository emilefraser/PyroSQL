/* 

Find the column types by name: Only change where the comment is below this

*/

-- STEP ONE: Change OurDatabaseName to the database name

USE OurDatabaseName
GO

SELECT 
    sc.name AS [Columne Name], 
    st1.name AS [User Type],
    st2.name AS [Base Type]
FROM dbo.syscolumns sc
	INNER JOIN dbo.systypes st1 ON st1.xusertype = sc.xusertype
	INNER JOIN dbo.systypes st2 ON st2.xusertype = sc.xtype
-- STEP TWO: Change OurTableName to the table name
WHERE sc.id = OBJECT_ID('OurTableName')
ORDER BY sc.colid