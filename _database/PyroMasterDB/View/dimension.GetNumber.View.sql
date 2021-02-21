SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dimension].[GetNumber]'))
EXEC dbo.sp_executesql @statement = N'CREATE   VIEW [dimension].[GetNumber]
WITH SCHEMABINDING
AS

WITH e1(n) AS (
	SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
	SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
	SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
)															-- 10
	,	e2(n) AS (
		SELECT 1 FROM e1 CROSS JOIN e1 AS b					-- 10*10
	)			
	,	e3(n) AS (
		SELECT 1 FROM e1 CROSS JOIN e2 AS c					-- 10*100
	)			
	,	e4(n) AS (
		SELECT 1 FROM e1 CROSS JOIN e3 AS d					-- 10*1000
	)			
	,	e5(n) AS (
		SELECT 1 FROM e1 CROSS JOIN e4 AS e					-- 10*10000
	)			
	--,e6(n) AS (SELECT 1 FROM e1 CROSS JOIN e5 AS e)		-- 10*100000
SELECT 
	n = ROW_NUMBER() OVER (ORDER BY n)  - 1
FROM 
	e5
' 
GO
