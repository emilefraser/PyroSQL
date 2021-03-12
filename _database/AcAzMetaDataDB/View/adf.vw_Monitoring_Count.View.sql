SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[adf].[vw_Monitoring_Count]'))
EXEC dbo.sp_executesql @statement = N'CREATE   VIEW [adf].[vw_Monitoring_Count]
AS
SELECT [Monitoring_CountId]
,[LoadEntityName] =  QUOTENAME([SchemaName]) + ''.'' +  QUOTENAME([EntityName])
      ,[SchemaName]
      ,[EntityName]
      ,[EnsambleName]
	  ,[EntityType]
      ,[CountType]
      ,[CountValue]
      ,[LoadCycleID]
	  ,CONVERT(BIT, 0) AS [IsCurrentLoadCyle]
      ,[CreatedDT] 
  FROM [adf].[Monitoring_Count]
' 
GO
