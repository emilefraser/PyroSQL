IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'PipelineProcesses' AND schema_id = SCHEMA_ID(N'procfwk'))
CREATE SYNONYM [procfwk].[PipelineProcesses] FOR [procfwk].[Pipelines]
GO
