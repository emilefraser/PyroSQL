IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'PipelineDependencyChains' AND schema_id = SCHEMA_ID(N'procfwk'))
CREATE SYNONYM [procfwk].[PipelineDependencyChains] FOR [procfwkHelpers].[PipelineDependencyChains]
GO
