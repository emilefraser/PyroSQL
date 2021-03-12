IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'AddPipelineDependant' AND schema_id = SCHEMA_ID(N'procfwk'))
CREATE SYNONYM [procfwk].[AddPipelineDependant] FOR [procfwkHelpers].[AddPipelineDependant]
GO
