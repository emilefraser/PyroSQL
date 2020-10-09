SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [STORE].[vw_StorageStats_Batch]
AS
SELECT  bat.[BatchID] AS [Batch ID]
      , bat.[HasStorageStatsRun_Machine] AS [Has ServerStats Run]
      , bat.[HasStorageStatsRun_Database] AS [Has DatabaseStats Run]
      , bat.[HasStorageStatsRun_DatabaseFile] AS [Has DatabaseFileStats Run]
      , bat.[HasStorageStatsRun_Object] AS [Has ObjectStats Run]
      , bat.[HasStorageStatsRun_Index] AS [Has IndexStats Run]
      ,CONVERT(DATE, bat.[CreatedDT]) AS [Batch Date]
	 ,	IIF(batcurr.CurrentBatchID IS NULL, 'No', 'Yes') AS [Is Current Batch]
  FROM [STORE].[StorageStats_Batch] AS bat
  LEFT JOIN (
	SELECT MAX(BatchID) AS CurrentBatchID
	FROM [STORE].[StorageStats_Batch] AS batcurr
) AS batcurr
ON batcurr.CurrentBatchID = bat.BatchID

GO
