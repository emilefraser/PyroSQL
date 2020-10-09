SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

			CREATE   VIEW METRICS.IndexStats AS
			SELECT
				CONVERT(VARCHAR(40), 
					HASHBYTES('SHA1',
						CONVERT(VARCHAR(MAX), 'DataManager') + '|' +
						 CONVERT(VARCHAR(MAX), s.name) + '|' +
						 CONVERT(VARCHAR(MAX), o.name)
					)
				, 2) AS IndexID
			,	'DataManager' AS DatabaseName
			,	s.name AS SchemaName
			,	i.name AS IndexName
			,	1 AS Count_Index
			FROM 
				DataManager.sys.indexes AS i
			INNER JOIN
				DataManager.sys.objects AS o
				ON o.object_id = i.object_id
			INNER JOIN 
				DataManager.sys.schemas AS s
				ON s.schema_id = o.schema_id
			WHERE
				o.type NOT IN ('0')
			AND
				o.is_ms_shipped = 0
			AND
				i.Name IS NOT NULL
				
GO
