IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'ProcessingStageDetails' AND schema_id = SCHEMA_ID(N'procfwk'))
CREATE SYNONYM [procfwk].[ProcessingStageDetails] FOR [procfwk].[Stages]
GO
