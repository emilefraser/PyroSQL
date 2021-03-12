IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'LastExecutionSummary' AND schema_id = SCHEMA_ID(N'procfwk'))
CREATE SYNONYM [procfwk].[LastExecutionSummary] FOR [procfwkReporting].[LastExecutionSummary]
GO
