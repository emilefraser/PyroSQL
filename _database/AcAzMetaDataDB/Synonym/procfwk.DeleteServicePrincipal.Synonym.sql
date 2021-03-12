IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'DeleteServicePrincipal' AND schema_id = SCHEMA_ID(N'procfwk'))
CREATE SYNONYM [procfwk].[DeleteServicePrincipal] FOR [procfwkHelpers].[DeleteServicePrincipal]
GO
