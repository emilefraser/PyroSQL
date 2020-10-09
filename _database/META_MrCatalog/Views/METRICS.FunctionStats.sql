SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

			CREATE   VIEW METRICS.FunctionStats AS
			SELECT
				CONVERT(VARCHAR(40), 
					HASHBYTES('SHA1',
						CONVERT(VARCHAR(MAX), 'DataManager') + '|' +
						 CONVERT(VARCHAR(MAX), s.name) + '|' +
						 CONVERT(VARCHAR(MAX), o.name)
					)
				, 2) AS ProcedureID
			,	'DataManager' AS DatabaseName
			,	s.name AS SchemaName
			,	o.name AS FunctionName
			,	(len(m.definition) - len(replace(m.definition, CHAR(0x0d) + CHAR(0x0a), ''))) / 2 AS Line_Count
			FROM 
				DataManager.sys.sql_modules AS m
			INNER JOIN
				DataManager.sys.objects AS o
				ON o.object_id = m.object_id
			INNER JOIN 
				DataManager.sys.schemas AS s
				ON s.schema_id = o.schema_id
			WHERE
				type IN ('TVF', 'FN')

GO
