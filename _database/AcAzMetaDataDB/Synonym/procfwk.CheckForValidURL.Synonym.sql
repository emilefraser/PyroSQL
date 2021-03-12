IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'CheckForValidURL' AND schema_id = SCHEMA_ID(N'procfwk'))
CREATE SYNONYM [procfwk].[CheckForValidURL] FOR [procfwkHelpers].[CheckForValidURL]
GO
