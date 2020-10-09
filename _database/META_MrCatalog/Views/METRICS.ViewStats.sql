SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- Metrics on Views
			CREATE   VIEW METRICS.ViewStats AS
			SELECT
				CONVERT(VARCHAR(40), 
					HASHBYTES('SHA1',
						CONVERT(VARCHAR(MAX), 'DataManager') + '|' +
						 CONVERT(VARCHAR(MAX), s.name) + '|' +
						 CONVERT(VARCHAR(MAX), v.name)
					)
				, 2) AS ViewID
			,	'DataManager' AS DatabaseName
			,	s.name AS SchemaName
			,	v.name AS ViewName
			,	MAX(column_id) AS Count_Column
			,	NULL AS Count_Row
			FROM 
				DataManager.sys.views AS v
			INNER JOIN 
				DataManager.sys.schemas AS s
				ON s.schema_id = v.schema_id
			INNER JOIN 
				DataManager.sys.columns AS c
				ON c.object_id = v.object_id
			WHERE
				type = 'V'
			GROUP BY 
				s.name
			,	v.name
GO
