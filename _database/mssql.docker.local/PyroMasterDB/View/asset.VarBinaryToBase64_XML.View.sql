SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[asset].[VarBinaryToBase64_XML]'))
EXEC dbo.sp_executesql @statement = N'-- XML to BASE64 UPLOAD THE 
CREATE VIEW [asset].[VarBinaryToBase64_XML]
AS
SELECT AssetName, AssetDataVarBinary
	, AssetBase64 = CAST('''' AS XML).value(
			''xs:base64Binary(sql:column("AssetRegister.AssetDataVarBinary"))'', ''VARCHAR(MAX)''
	)
FROM asset.AssetRegister' 
GO
