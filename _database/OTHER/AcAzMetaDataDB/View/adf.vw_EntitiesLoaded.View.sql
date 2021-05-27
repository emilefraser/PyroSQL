SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[adf].[vw_EntitiesLoaded]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [adf].[vw_EntitiesLoaded]
AS
SELECT [LoadConfigID]
      ,[LoadTypeCode]
      ,[SourceServerName]
      ,[SourceDatabaseName]
      ,[SourceEntityName]
      ,[TargetDatabaseName]
      ,[TargetSchemaName]
      ,[TargetEntityName]  
  FROM [adf].[LoadConfig]
  WHERE LoadEnvironmentID = 5
  AND TargetEntityName IS NOT NULL
' 
GO
