SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_SpacePerIndex]'))
EXEC dbo.sp_executesql @statement = N'/*
	SELECT * FROM [meta].[Metadata_RowsPerTable]
*/
CREATE   VIEW [meta].[Metadata_SpacePerIndex]
AS
SELECT
	SCHEMA_NAME(tab.schema_id) + ''.'' + tab.name AS [table]
  , SUM(part.rows)								AS [rows]
FROM
	sys.tables tab
INNER JOIN
	sys.partitions part
	ON tab.object_id = part.object_id
WHERE
	part.index_id IN (1, 0) -- 0 - table without PK, 1 table with PK
GROUP BY
	SCHEMA_NAME(tab.schema_id) + ''.'' + tab.name;
' 
GO
