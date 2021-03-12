IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'AverageStageDuration' AND schema_id = SCHEMA_ID(N'procfwk'))
CREATE SYNONYM [procfwk].[AverageStageDuration] FOR [procfwkReporting].[AverageStageDuration]
GO
