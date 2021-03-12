SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[adf].[vw_Monitoring_LoadStatus]'))
EXEC dbo.sp_executesql @statement = N'
CREATE   VIEW [adf].[vw_Monitoring_LoadStatus]
AS
SELECT [Monitoring_LoadStatusId]
,[LoadEntityName] =  QUOTENAME([SchemaName]) + ''.'' +  QUOTENAME([EntityName])
      ,[SchemaName]
      ,[EntityName]
      ,[EntityType]
      ,[LoadSchemaName]
      ,[LoadProcedureName]
      ,[ReturnValue]
      ,[ReturnMessage]
      ,[LoadCycleID]
	  ,CONVERT(BIT, 0) AS [IsCurrentLoadCyle]	
	  ,CONVERT(BIT, 0) AS [IsCurrentlyRunning]
	  ,CONVERT(VARCHAR(30), ''Completed'') AS [LoadStatus]
      ,[CreatedDT]
  FROM [adf].[Monitoring_LoadStatus]
' 
GO
