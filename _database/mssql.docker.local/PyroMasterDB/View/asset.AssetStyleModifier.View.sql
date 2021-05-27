SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[asset].[AssetStyleModifier]'))
EXEC dbo.sp_executesql @statement = N'
-- Different Variations of the STYLE MODIFIER
CREATE VIEW [asset].[AssetStyleModifier]
AS
SELECT 
	CONVERT(VARCHAR(MAX), AssetDataVarBinary, 0) AS AssetVarCharMax_0,
	CONVERT(VARCHAR(MAX), AssetDataVarBinary, 1) AS AssetVarCharMax_1,
	CONVERT(VARCHAR(MAX), AssetDataVarBinary, 2) AS AssetVarCharMax_2
from asset.AssetRegister ' 
GO
