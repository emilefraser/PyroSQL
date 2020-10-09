SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE   VIEW METRICS.StoredProcedureStats AS
			SELECT
				CONVERT(VARCHAR(40), 
					HASHBYTES('SHA1',
						CONVERT(VARCHAR(MAX), 'DataManager') + '|' +
						 CONVERT(VARCHAR(MAX), s.name) + '|' +
						 CONVERT(VARCHAR(MAX), p.name)
					)
				, 2) AS ProcedureID
			,	'DataManager' AS DatabaseName
			,	s.name AS SchemaName
			,	p.name AS TableName
			,	(len(m.definition) - len(replace(m.definition, CHAR(0x0d) + CHAR(0x0a), ''))) / 2 AS Line_Count
			FROM 
				DataManager.sys.procedures AS p
			INNER JOIN 
				DataManager.sys.sql_modules AS m
				ON m.object_id = p.object_id
			INNER JOIN 
				DataManager.sys.schemas AS s
				ON s.schema_id = p.schema_id
			WHERE
				type = 'P'

GO
