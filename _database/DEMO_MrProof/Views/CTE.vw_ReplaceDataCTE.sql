SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW CTE.vw_ReplaceDataCTE
AS

WITH cte_replace (orig_value, calc_value, new_value, clevel) AS
(
    SELECT 
		  val as orig_value
		, val AS calc_value
		, val AS calc_value
		, 0 AS lev
    FROM CTE.Original 

    UNION ALL

    SELECT 
		  cr.orig_value
		, cr.new_value
        , CONVERT(NVARCHAR(50), REPLACE(cr.new_value, rd.old, rd.new))
		, cr.clevel + 1
    FROM cte_replace AS cr

    INNER JOIN CTE.ReplaceData AS rd

	ON cr.calc_value LIKE '%' + rd.old + '%' COLLATE Latin1_General_CS_AS


)
SELECT DISTINCT orig_value, calc_value, clevel
FROM cte_replace AS cr
WHERE clevel =
    (SELECT MAX(clevel) FROM cte_replace AS crml WHERE crml.orig_value = cr.orig_value)

GO
