SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE VIEW CTE.vw_ReplaceDataCTE_Count
AS
--Common Table Expression for Translation
--WITH TranslationTable
--AS (
--    SELECT FindValue = '{' + convert(varchar(5),id) + '}' ,ReplaceValue = display,ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
--    FROM testing
--    )
--Recursive CTE to loop through the TranslationTable and replace FindValue with ReplaceValue

WITH Replacements
AS (
    SELECT 
		rd.old
	,	rd.new
	,	ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
    FROM CTE.ReplaceData AS rd
)
, RecursiveCte as
(
	SELECT
		CONVERT(VARCHAR(MAX), cor.val) AS val
	,	COUNT(1) as cnt
    FROM CTE.Original AS cor
	CROSS JOIN Replacements as cr
	GROUP BY cor.val


	UNION ALL

	SELECT 
		CONVERT(VARCHAR(MAX), replace(rcte.val, rep.old, rep.new)) AS val
	,	rcte.cnt - 1 AS cnt
	FROM RecursiveCte AS rcte
	INNER JOIN Replacements AS rep
		ON rep.rn = cnt 

)
SELECT 
	 rcte.val
    ,rcte.cnt
FROM RecursiveCte AS rcte 
where cnt = 0

GO
