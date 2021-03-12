IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'CheckStageAndPiplineIntegrity' AND schema_id = SCHEMA_ID(N'procfwk'))
CREATE SYNONYM [procfwk].[CheckStageAndPiplineIntegrity] FOR [procfwkHelpers].[CheckStageAndPiplineIntegrity]
GO
