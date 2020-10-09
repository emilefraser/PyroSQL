SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW BALANCE.vw_AR_Summary
AS
SELECT CustomerNo
      ,SUM([Current])  AS [Current]
      ,SUM([30 Days])  AS [30days]
      ,SUM([60 Days])  AS [60days]
      ,SUM([90 Days]) AS [90days]
      ,SUM([120 Days]) AS [120days]
      ,SUM([Total])  AS [Total]
  FROM [ODS_ATSDAT].[BALANCE].[AR_Summary]
  WHERE CustomerNo = 'KEV100'
  GROUP BY CustomerNo
GO