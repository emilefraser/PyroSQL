SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[asset].[VarBinaryToBase64_JSON]'))
EXEC dbo.sp_executesql @statement = N'
-- JSON To BASE64
CREATE VIEW [asset].[VarBinaryToBase64_JSON]
AS
SELECT AssetBase64 = AssetDataVarBinary
FROM OPENJSON (
	(
		SELECT AssetDataVarBinary
		FROM asset.AssetRegister
		FOR JSON AUTO
	)
) WITH (AssetDataVarBinary VARCHAR(MAX))
' 
GO
