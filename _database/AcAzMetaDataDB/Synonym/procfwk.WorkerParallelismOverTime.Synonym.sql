IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'WorkerParallelismOverTime' AND schema_id = SCHEMA_ID(N'procfwk'))
CREATE SYNONYM [procfwk].[WorkerParallelismOverTime] FOR [procfwkReporting].[WorkerParallelismOverTime]
GO
