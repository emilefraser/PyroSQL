USE [MetricsVault]
GO

/****** Object:  View [dbo].[vw_EnsambleMetric_RowCount]    Script Date: 2020/05/27 6:58:31 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER   VIEW [dbo].[vw_EnsambleMetric_RowCount]
AS

SELECT 
	sq.[ElementID]
,	ee.[ElementFullyQualified]
,	ee.[ElementServerName]
,	ee.[ElementDatabaseName]
,	ee.[ElementSchemaName]
,	ee.[ElementEntityName]
,	sq.[MetricTypeID]
,	emt.[MetricTypeCode]
,	ec.[TimeGrainID]
,	etg.[TimeGrainCode]
,	etg.[TimeGrainDescription]
,	sq.[DateValue]
,	sq.[Row_Count]
FROM (
		SELECT 
			[ElementID]
		,	[MetricTypeID]
		,	[ConfigID]
		,	[DateValue]
		,	[Row_Count]
		,	[CreatedDT]
		,	DENSE_RANK() OVER (PARTITION BY em_rc.[ElementID] , em_rc.[MetricTypeID], em_rc.[ConfigID]  ORDER BY em_rc.[CreatedDT] DESC) AS rn
		  FROM [MetricsVault].[dbo].[EnsambleMetric_RowCount] AS em_rc
) AS sq
INNER JOIN 
	[dbo].[Ensamble_Element] AS ee
	ON ee.[ElementID] = sq.[ElementID]
INNER JOIN
	[dbo].[Ensamble_MetricType] AS emt
	ON emt.[MetricTypeID] = sq.[MetricTypeID]
INNER JOIN 
	[dbo].[Ensamble_Config] AS ec
	ON ec.[ConfigID] = sq.[ConfigID]
INNER JOIN 
	[dbo].[Ensamble_Timegrain] AS etg
	ON etg.[TimeGrainID] = ec.[TimeGrainID]
WHERE
	sq.rn = 1

  
GO


