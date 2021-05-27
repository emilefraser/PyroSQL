IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'DEV_DataVault__ODS_CAMS__DocImage' AND schema_id = SCHEMA_ID(N'dbo'))
CREATE SYNONYM [dbo].[DEV_DataVault__ODS_CAMS__DocImage] FOR [asset].[TestAssetLarge]
GO
