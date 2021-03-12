IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'GetExecutionDetails' AND schema_id = SCHEMA_ID(N'procfwk'))
CREATE SYNONYM [procfwk].[GetExecutionDetails] FOR [procfwkHelpers].[GetExecutionDetails]
GO
