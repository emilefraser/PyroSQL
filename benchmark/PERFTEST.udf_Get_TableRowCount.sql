SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- TEST
-- SELECT PERFTEST.udf_Get_TableRowCount('[PERFTEST].[MetricsLog]')
-- SELECT PERFTEST.udf_Get_TableRowCount('PERFTEST.MetricsLog')
-- SELECT PERFTEST.udf_Get_TableRowCount('PERFTEST.MetricsLog')
-- SELECT PERFTEST.udf_Get_TableRowCount('MetricsLog')
-- SELECT PERFTEST.udf_Get_TableRowCount('')
-- SELECT PERFTEST.udf_Get_TableRowCount(NULL)
-- SELECT PARSENAME('[PERFTEST].[sp_Create_MetricsLog]', 1)
CREATE   FUNCTION PERFTEST.udf_Get_TableRowCount
(
	@TableName SYSNAME
)
RETURNS INT
AS
BEGIN
	DECLARE @Table_RowCount INT = (
		SELECT 
			SUM(P.rows)

			--SELECT *
		FROM
			sys.tables t
		INNER JOIN 
			sys.schemas s 
			ON s.schema_id = t.schema_id
		INNER JOIN 
			sys.partitions p 
			ON t.object_id = p.object_id
		INNER JOIN 
			sys.indexes i 
			ON p.object_id = i.object_id
			AND p.index_id = i.index_id
			AND i.index_id < 2
		WHERE
			t.name = PARSENAME(@TableName, 1)
		GROUP BY 
			t.object_id
			, t.name
			, S.name
	)


	-- Return the result of the function
	RETURN @Table_RowCount

END

GO
