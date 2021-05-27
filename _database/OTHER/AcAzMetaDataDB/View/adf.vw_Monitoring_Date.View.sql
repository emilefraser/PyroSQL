SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[adf].[vw_Monitoring_Date]'))
EXEC dbo.sp_executesql @statement = N'CREATE   VIEW [adf].[vw_Monitoring_Date]
AS
SELECT 
	   [Monitoring_DateId]
	  ,[LoadEntityName] =  QUOTENAME([SchemaName]) + ''.'' +  QUOTENAME([EntityName])
      ,[SchemaName]
      ,[EntityName]
	  ,[EntityType]
      ,[EnsambleName]
      ,[DateType]
      ,[DateValue]
      ,[LoadCycleID]
      ,[CreatedDT]
	  ,CONVERT(BIT, 0) AS [IsCurrentLoadCyle]   
  FROM [adf].[Monitoring_Date]
' 
GO
