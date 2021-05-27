SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[asset].[ImportAsset]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [asset].[ImportAsset] AS' 
END
GO

ALTER PROCEDURE [asset].[ImportAsset] (
     @AssetName NVARCHAR (100)
   , @AssetFolderPath NVARCHAR (200)
   , @AssetFileName NVARCHAR (200)
   )
AS
BEGIN
   DECLARE @Path2OutFile NVARCHAR (2000);
   DECLARE @tsql NVARCHAR (2000);
   SET NOCOUNT ON
   SET @Path2OutFile = CONCAT (
         @AssetFolderPath
         ,'\'
         , @AssetFileName
         );
   SET @tsql = 'INSERT INTO asset.AssetRegister  (AssetName, AssetFileName, AssetDataVarBinary) ' +
               ' SELECT ' + '''' + @AssetName + '''' + ',' + '''' + @AssetFileName + '''' + ', * ' + 
               'FROM Openrowset( Bulk ' + '''' + @Path2OutFile + '''' + ', Single_Blob) as img'
   EXEC (@tsql)
   SET NOCOUNT OFF
END
GO
