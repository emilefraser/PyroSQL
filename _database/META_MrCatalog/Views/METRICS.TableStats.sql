SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE   VIEW METRICS.TableStats AS
			SELECT
				CONVERT(VARCHAR(40), 
					HASHBYTES('SHA1',
						CONVERT(VARCHAR(MAX), 'DataManager') + '|' +
						 CONVERT(VARCHAR(MAX), s.name) + '|' +
						 CONVERT(VARCHAR(MAX), t.name)
					)
				, 2) AS TableID
			,	'DataManager' AS DatabaseName
			,	s.name AS SchemaName
			,	t.name AS TableName
			,	t.max_column_id_used AS Count_Column
			,	NULL AS Count_Row
			FROM 
				DataManager.sys.tables AS t
			INNER JOIN 
				DataManager.sys.schemas AS s
				ON s.schema_id = t.schema_id
			WHERE
				type = 'U'
			GROUP BY 
				s.name
			,	t.name
			,	t.max_column_id_used
GO
