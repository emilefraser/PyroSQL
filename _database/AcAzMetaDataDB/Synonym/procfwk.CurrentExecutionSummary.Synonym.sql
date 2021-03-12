IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'CurrentExecutionSummary' AND schema_id = SCHEMA_ID(N'procfwk'))
CREATE SYNONYM [procfwk].[CurrentExecutionSummary] FOR [procfwkReporting].[CurrentExecutionSummary]
GO
