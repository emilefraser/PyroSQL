IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'CompleteExecutionLog' AND schema_id = SCHEMA_ID(N'procfwk'))
CREATE SYNONYM [procfwk].[CompleteExecutionLog] FOR [procfwkReporting].[CompleteExecutionLog]
GO
