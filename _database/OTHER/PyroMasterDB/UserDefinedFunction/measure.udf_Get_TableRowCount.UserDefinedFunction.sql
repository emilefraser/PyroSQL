SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[measure].[udf_Get_TableRowCount]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- TEST
-- SELECT PERFTEST.udf_Get_TableRowCount(''[PERFTEST].[MetricsLog]'')
-- SELECT PERFTEST.udf_Get_TableRowCount(''PERFTEST.MetricsLog'')
-- SELECT PERFTEST.udf_Get_TableRowCount(''PERFTEST.MetricsLog'')
-- SELECT PERFTEST.udf_Get_TableRowCount(''MetricsLog'')
-- SELECT PERFTEST.udf_Get_TableRowCount('''')
-- SELECT PERFTEST.udf_Get_TableRowCount(NULL)
-- SELECT PARSENAME(''[PERFTEST].[sp_Create_MetricsLog]'', 1)
CREATE   FUNCTION [measure].[udf_Get_TableRowCount]
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

' 
END
GO
