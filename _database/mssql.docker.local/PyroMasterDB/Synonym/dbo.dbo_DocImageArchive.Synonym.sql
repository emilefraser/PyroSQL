IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'dbo_DocImageArchive' AND schema_id = SCHEMA_ID(N'dbo'))
CREATE SYNONYM [dbo].[dbo_DocImageArchive] FOR [asset].[TestAssetLargeArchive]
GO
