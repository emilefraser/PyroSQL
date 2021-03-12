IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'AddServicePrincipalWrapper' AND schema_id = SCHEMA_ID(N'procfwk'))
CREATE SYNONYM [procfwk].[AddServicePrincipalWrapper] FOR [procfwkHelpers].[AddServicePrincipalWrapper]
GO
