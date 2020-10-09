SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [INTEGRATION].[vw_egress_DynamicReporting] AS
SELECT [ReportID]
      ,[DatabaseName]
      ,[SchemaName]
      ,[DataEntityName]
      ,MAX([FieldID1]) AS [FieldID1]
      ,MAX([FieldName1]) AS [FieldName1]
      ,MAX([DataValue1]) AS [DataValue1]
      ,MAX([FieldID2]) AS [FieldID2]
      ,MAX([FieldName2]) AS [FieldName2]
      ,MAX([DataValue2]) AS [DataValue2]
      ,MAX([FieldID3]) AS [FieldID3]
      ,MAX([FieldName3]) AS [FieldName3]
      ,MAX([DataValue3]) AS [DataValue3]
FROM 
(
SELECT [ReportID]
      ,[DatabaseName]
      ,[SchemaName]
      ,[DataEntityName]
      ,CASE WHEN RowNum = 1 THEN [FieldID] ELSE NULL END AS [FieldID1]
      ,CASE WHEN RowNum = 1 THEN [FieldName] ELSE NULL END AS [FieldName1]
      ,CASE WHEN RowNum = 1 THEN [DataValue] ELSE NULL END AS [DataValue1]
      ,CASE WHEN RowNum = 2 THEN [FieldID] ELSE NULL END AS [FieldID2]
      ,CASE WHEN RowNum = 2 THEN [FieldName] ELSE NULL END AS [FieldName2]
      ,CASE WHEN RowNum = 2 THEN [DataValue] ELSE NULL END AS [DataValue2]
      ,CASE WHEN RowNum = 3 THEN [FieldID] ELSE NULL END AS [FieldID3]
      ,CASE WHEN RowNum = 3 THEN [FieldName] ELSE NULL END AS [FieldName3]
      ,CASE WHEN RowNum = 3 THEN [DataValue] ELSE NULL END AS [DataValue3]
	  ,FieldDataValueGroupID
  FROM
	(SELECT link.[ReportID]
		   ,db.[DatabaseName]
		   ,s.[SchemaName]
		   ,de.[DataEntityName]
		   ,f.FieldID
		   ,f.FieldName
		   ,fdv.DataValue
		   ,ROW_NUMBER() OVER(PARTITION BY fdvg.FieldDataValueGroupID ORDER BY link.LinkReportFieldID) AS RowNum
		   ,fdvg.FieldDataValueGroupID
       FROM DYNREP.LinkReportField link
			INNER JOIN DYNREP.FieldDataValueGroup fdvg ON
					fdvg.ReportID = link.ReportID
			INNER JOIN DYNREP.FieldDataValue fdv ON
					fdv.FieldDataValueGroupID = fdvg.FieldDataValueGroupID AND
					fdv.LinkReportFieldID = link.LinkReportFieldID
			INNER JOIN DC.Field f ON
					f.FieldID = link.FieldID
			INNER JOIN DC.DataEntity de ON
					de.DataEntityID = f.DataEntityID
			INNER JOIN DC.[Schema] s ON
					s.SchemaID = de.SchemaID
			INNER JOIN DC.[Database] db ON
					db.DatabaseID = s.DatabaseID
	) SourceTable
) a
GROUP BY 
	   [ReportID]
      ,[DatabaseName]
      ,[SchemaName]
      ,[DataEntityName]
	  ,[FieldDataValueGroupID]

GO
