SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[GetStringOrBinaryTruncated]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [string].[GetStringOrBinaryTruncated] AS' 
END
GO

ALTER     PROCEDURE [string].[GetStringOrBinaryTruncated]
	@String VARCHAR(MAX)
AS
 
DECLARE @VARCHAR AS VARCHAR(MAX)
DECLARE @Xml AS XML
DECLARE @TCount AS INT
SET @String= REPLACE(REPLACE(REPLACE(REPLACE(@String,'''','')
             ,'[',''),']',''),CHAR(13) + CHAR(10),'')
SET @Xml = CAST(('<a>'+REPLACE(@String,'(','</a><a>')
           +'</a>') AS XML)
 

 select @String
SELECT @TCount=COUNT(*)
FROM @Xml.nodes('A') AS FN(A)
  select @TCount
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
 

select * from cte
GO
