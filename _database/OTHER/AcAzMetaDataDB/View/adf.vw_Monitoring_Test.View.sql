SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[adf].[vw_Monitoring_Test]'))
EXEC dbo.sp_executesql @statement = N'CREATE    VIEW [adf].[vw_Monitoring_Test]
AS
SELECT [Montoring_TestId]
	,[LoadEntityName] =  QUOTENAME([SchemaName]) + ''.'' +  QUOTENAME([EntityName])
      ,[SchemaName]
      ,[EntityName]
	  ,[EntityType]
      ,[ObjectType]
      ,[ReturnValue]
      ,[ReturnMessage]
      ,[LoadCycleID]
	  ,CONVERT(BIT, 0) AS [IsCurrentLoadCyle]
      ,[CreatedDT]
  FROM [adf].[Monitoring_Test]
' 
GO
