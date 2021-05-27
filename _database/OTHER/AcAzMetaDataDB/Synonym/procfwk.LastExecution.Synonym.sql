IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'LastExecution' AND schema_id = SCHEMA_ID(N'procfwk'))
CREATE SYNONYM [procfwk].[LastExecution] FOR [procfwkReporting].[LastExecution]
GO
