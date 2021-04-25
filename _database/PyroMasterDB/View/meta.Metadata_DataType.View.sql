SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_DataType]'))
EXEC dbo.sp_executesql @statement = N'
CREATE   VIEW [meta].[Metadata_DataType]
AS
SELECT
	t.name						  AS data_type
  , COUNT(*)					  AS [columns]
  , CAST(100.0 * COUNT(*) / (
		SELECT COUNT(*)
		FROM
			sys.tables AS tab
			INNER JOIN
				sys.columns AS col
				ON tab.object_id = col.object_id
	) AS NUMERIC(36, 1))		  AS percent_columns
  , COUNT(DISTINCT tab.object_id) AS [tables]
  , CAST(100.0 * COUNT(DISTINCT tab.object_id) / (
		SELECT COUNT(*)
		FROM
			sys.tables
	) AS NUMERIC(36, 1))		  AS percent_tables
FROM
	sys.tables AS tab
INNER JOIN
	sys.columns AS col
	ON tab.object_id = col.object_id
LEFT JOIN
	sys.types AS t
	ON col.user_type_id = t.user_type_id
GROUP BY
	t.name

' 
GO
