IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'DeleteRecipientAlerts' AND schema_id = SCHEMA_ID(N'procfwk'))
CREATE SYNONYM [procfwk].[DeleteRecipientAlerts] FOR [procfwkHelpers].[DeleteRecipientAlerts]
GO
