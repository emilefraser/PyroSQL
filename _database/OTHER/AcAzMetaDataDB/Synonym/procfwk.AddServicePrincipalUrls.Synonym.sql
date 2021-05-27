IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'AddServicePrincipalUrls' AND schema_id = SCHEMA_ID(N'procfwk'))
CREATE SYNONYM [procfwk].[AddServicePrincipalUrls] FOR [procfwkHelpers].[AddServicePrincipalUrls]
GO
