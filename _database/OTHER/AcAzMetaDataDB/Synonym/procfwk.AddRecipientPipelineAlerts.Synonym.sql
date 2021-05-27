IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'AddRecipientPipelineAlerts' AND schema_id = SCHEMA_ID(N'procfwk'))
CREATE SYNONYM [procfwk].[AddRecipientPipelineAlerts] FOR [procfwkHelpers].[AddRecipientPipelineAlerts]
GO
