SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[StringOrBinaryTruncated]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[StringOrBinaryTruncated] AS' 
END
GO
--CREATE SCHEMA tool
--go

--String or binary data would be truncated (Error number 8152) is a very common error. It usually happens when we try to insert any data in string (varchar,nvarchar,char,nchar) data type column which is more than size of the column. So you need to check the data size with respect to the column width and identify which column is creating problem and fix it. It is very simple if you are dealing with less columns in a table. But it becomes nightmare if you are dealing with inert into query with huge number of columns and you need to check one by one column. I received this query from one of my Blog readers Mr Ram Kumar asking if there is a shortcut to resolve this issue and give the column name along with the data creating problems. I started searching for the solution but could not get proper one. So I started developing this solution.
--Before proceeding with the solution, I would like to create a sample to demonstrate the problem.

--This script is compatible with SQL Server 2005 and above.
--DROP TABLE tbl_sample
--GO
--CREATE TABLE dbo.tbl_sample
--(
-- [ID] INT,
-- [NAME] VARCHAR(10),
--)
--GO
--INSERT INTO tool.tbl_sample VALUES (1,'Bob Jack Creasey')
--GO
--INSERT INTO tool.tbl_sample ([ID],[NAME]) VALUES (2,'Frank Richard Wedge')
--GO
--OUTPUT
--Msg 8152, Level 16, State 14, Line 1
--String or binary data would be truncated.
--The statement has been terminated.
--Msg 8152, Level 16, State 14, Line 2
--String or binary data would be truncated.
--The statement has been terminated.

--DROP PROCEDURE usp_String_or_binary_data_truncated
--GO
ALTER   PROCEDURE [dbo].[StringOrBinaryTruncated]
	@String VARCHAR(MAX)
AS
 
DECLARE @VARCHAR AS VARCHAR(MAX)
DECLARE @Xml AS XML
DECLARE @TCount AS INT
SET @String= REPLACE(REPLACE(REPLACE(REPLACE(@String,'''','')
             ,'[',''),']',''),CHAR(13) + CHAR(10),'')
SET @Xml = CAST(('<a>'+REPLACE(@String,'(','</a><a>')
           +'</a>') AS XML)
 
SELECT @TCount=COUNT(*)
FROM @Xml.nodes('A') AS FN(A)
 
;WITH CTE AS
     (SELECT
     (CASE
     WHEN (CHARINDEX('INSERT INTO',A.value('.', 'varchar(max)'))>0)
     THEN 1
     WHEN CHARINDEX('VALUES',A.value('.', 'varchar(max)'))>0
     THEN 2
     WHEN (CHARINDEX('INSERT INTO',A.value('.', 'varchar(max)'))=0
     AND CHARINDEX('VALUES',A.value('.', 'varchar(max)'))=0)
     AND @TCount=2  THEN 2
     WHEN (CHARINDEX('INSERT INTO',A.value('.', 'varchar(max)'))=0
     AND CHARINDEX('VALUES',A.value('.', 'varchar(max)'))=0)
     AND @TCount=3  THEN 3
     END) AS[Batch Number],
     REPLACE(REPLACE(A.value('.', 'varchar(max)')
     ,'INSERT INTO',''),'VALUES ','') AS [Column]
     FROM @Xml.nodes('A') AS FN(A))
 
, [CTE2] AS
(
    SELECT
    [Batch Number],
    CAST('' + REPLACE([Column], ',' , '')
    + '' AS XML)
    AS [Column name And Data]
    FROM  [CTE]
)
,[CTE3] AS
(
    SELECT [Batch Number],
    ROW_NUMBER() OVER(PARTITION BY [Batch Number]
    ORDER BY [Batch Number] DESC) AS [Row Number],
    Split.a.value('.', 'VARCHAR(MAX)') AS [Column name And Data]
FROM [CTE2]
CROSS APPLY [Column name And Data].nodes('/M')Split(A))
 
SELECT
 ISNULL(B.[Column name And Data],C.name) AS [Column Name]
,A.[Column name And Data] AS [Column Data]
,C.max_length As [Column Length]
,DATALENGTH(A.[Column name And Data])
AS [Column Data Length]
 
FROM [CTE3] A
LEFT JOIN [CTE3] B
ON A.[Batch Number]=2 AND B.[Batch Number]=3
AND A.[Row Number] =B.[Row Number]
LEFT JOIN sys.columns C
ON C.object_id =(
    SELECT object_ID(LTRIM(RTRIM([Column name And Data])))
    FROM [CTE3] WHERE [Batch Number]=1
)
AND (C.name = B.[Column name And Data]
OR  (C.column_id =A.[Row Number]
And A.[Batch Number]<>1))
WHERE a.[Batch Number] <>1
AND DATALENGTH(A.[Column name And Data]) >C.max_length
AND C.system_type_id IN (167,175,231,239)
AND C.max_length>0
 


EXEC dbo.GetStringOrBinaryTruncated 'INSERT INTO tbl_sample VALUES (1,''Bob Jack Creasey'')'
GO
