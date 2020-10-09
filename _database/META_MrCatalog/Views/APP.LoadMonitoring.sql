SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [APP].[LoadMonitoring]
AS
SELECT DISTINCT lch.LoadGroupControlID,lcd.SourceDataEntityID	
	  ,'[' + dfd.ServerName + '].[' + dfd.DatabaseName + '].[' + dfd.DataEntityName + ']'  as [Source]
	  ,'[' + dfd1.ServerName + '].[' + dfd1.DatabaseName + '].[' + dfd1.DataEntityName + ']'  as [Target]
	  ,LoadStatus 
	  ,IsLastRunFailed
	  ,(CASE 
	   WHEN IsStoredProc = 1 
			THEN 'Yes' 
	   WHEN IsStoredProc = 0 
			THEN 'No' 
	   END) AS IsThisAStoredProcedure
	  ,ProcessingFinishedDT AS LastTimeRan
  FROM [ETL].[LoadGroupControlHeader] lch 
  INNER JOIN etl.LoadGroupControlDetail lcd ON 
  lch.LoadScheduleID = lcd.LoadGroupControlID
  INNER JOIN [DC].[vw_rpt_DatabaseFieldDetail] dfd ON
  dfd.DataEntityID = lcd.SourceDataEntityID
  INNER JOIN [DC].[vw_rpt_DatabaseFieldDetail] dfd1 ON
  dfd1.DataEntityID = lcd.TargetDataEntityID



GO
