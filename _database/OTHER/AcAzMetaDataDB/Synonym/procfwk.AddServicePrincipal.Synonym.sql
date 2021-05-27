IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'AddServicePrincipal' AND schema_id = SCHEMA_ID(N'procfwk'))
CREATE SYNONYM [procfwk].[AddServicePrincipal] FOR [procfwkHelpers].[AddServicePrincipal]
GO
