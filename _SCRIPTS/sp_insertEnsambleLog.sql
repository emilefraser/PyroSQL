/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [LogID]
      ,[MetricProcedureCalled]
      ,[ConfigID]
      ,[LogStatusTypeID]
      ,[CreatedDT]
  FROM [MetricsVault].[dbo].[Ensamble_Log]

 CREATE PROCEDURE dbo.sp_insert_Ensamble_Log (
	@MetricProcedureCalled	SYSNAME	
,	@ConfigID				SMALLINT
,	@LogStatusTypeID		SMALLINT
)
AS

DECLARE @CurrentDT DATETIME2(7) = GETDATE()

INSERT INTO [MetricsVault].[dbo].[Ensamble_Log] (
	[MetricProcedureCalled]
,	[ConfigID]
,	[LogStatusTypeID]
,	[CreatedDT]
)
SELECT 
	@MetricProcedureCalled
,	@ConfigID
,	@LogStatusTypeID
,	@CurrentDT