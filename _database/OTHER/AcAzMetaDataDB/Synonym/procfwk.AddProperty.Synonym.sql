IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'AddProperty' AND schema_id = SCHEMA_ID(N'procfwk'))
CREATE SYNONYM [procfwk].[AddProperty] FOR [procfwkHelpers].[AddProperty]
GO
