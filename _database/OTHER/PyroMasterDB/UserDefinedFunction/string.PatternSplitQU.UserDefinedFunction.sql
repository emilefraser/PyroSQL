SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[PatternSplitQU]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'-- PatternSplitQU will split a string based on a pattern of the form 
-- supported by LIKE and PATINDEX 
-- 
-- Created by: Dwain Camps 11-Oct-2012 
CREATE FUNCTION [string].[PatternSplitQU] 
(  @String                 VARCHAR(8000)
  ,@Pattern               VARCHAR(500)
) RETURNS @Results
            TABLE
(     ItemNumber              INT
     ,Item                   VARCHAR(8000)
     ,[Matched]              INT     
) WITH SCHEMABINDING AS BEGIN;
-- Holding table for tally split by character     
DECLARE @Strings        TABLE     
(
 -- With a clustered index to facilitate the quirky update     
  ID         INT PRIMARY KEY CLUSTERED
 ,MyString   CHAR(1)
 ,[Matched]  INT
 ,Pattern    INT
);
-- Use a Tally table to split out the single characters     
WITH Nbrs_3(n) 
AS 
(
  SELECT 1 
  UNION ALL 
  SELECT 1 
  UNION ALL 
  SELECT 1 
  UNION ALL 
  SELECT 1
)
,Nbrs_2 (n)
 AS
 (SELECT 1 
   FROM Nbrs_3 n1 
    CROSS JOIN Nbrs_3 n2
)
,Nbrs_1 (n)
 AS
 (SELECT 1 
   FROM Nbrs_2 n1 
    CROSS JOIN Nbrs_2 n2)      
,Nbrs_0 (n) 
 AS
 (SELECT 1 
   FROM Nbrs_1 n1 
    CROSS JOIN Nbrs_1 n2)
,Tally  (n)
 AS
 (SELECT ROW_NUMBER() OVER (ORDER BY n) As n 
  FROM Nbrs_0)     
INSERT INTO @Strings
 SELECT n, SUBSTRING(@String, n, 1)
       ,PATINDEX(@Pattern, SUBSTRING(@String, n, 1))
       ,PATINDEX(@Pattern, SUBSTRING(@String, n, 1))
   FROM (SELECT TOP (ISNULL(DATALENGTH(@String), 0)) n
          FROM Tally) a
-- Local variables to control the quirky update     
DECLARE @CharID   INT = -1
       ,@Matched  INT = 0
-- Perform the Quirky Update     
-- At each change in Pattern (0-->1 or 1-->0) increment to a grouping value     
UPDATE @Strings     
  SET @Matched = CASE 
                   WHEN Pattern <> @CharID THEN @Matched + 1 
                   ELSE @Matched 
                 END
      ,@CharID = CASE 
                   WHEN Pattern <> @CharID THEN Pattern 
                   ELSE @CharID 
                 END     
     ,Pattern =  @Matched
-- Contenate strings from each group into the final Items returned 
INSERT INTO @Results 
 SELECT ItemNumber=ROW_NUMBER() OVER (ORDER BY (SELECT NULL))             ,Item=(
             SELECT '''' + MyString
             FROM @Strings b
             WHERE a.Pattern = b.Pattern
             ORDER BY ID
             FOR XML PATH(''''), TYPE).value(''.'', ''VARCHAR(8000)'')          ,MIN([Matched])
  FROM @Strings a
  GROUP BY Pattern
RETURN 
END' 
END
GO
