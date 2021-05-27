IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'CompleteExecutionErrorLog' AND schema_id = SCHEMA_ID(N'procfwk'))
CREATE SYNONYM [procfwk].[CompleteExecutionErrorLog] FOR [procfwkReporting].[CompleteExecutionErrorLog]
GO
