SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[adf].[CurrentRunStatus]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [adf].[CurrentRunStatus] AS

SELECT 
	LoadConfigID
,	CdcCreatedDateValue_Last + CdcCreatedTimeValue_Last AS LastestCreatedDateTimeValue
,	CdcUpdatedDateValue_Last + CdcUpdatedTimeValue_Last AS LastestUpdatedDateTimeValue
,	IIF(CdcUpdatedDateValue_Last + CdcUpdatedTimeValue_Last > CdcCreatedDateValue_Last + CdcCreatedTimeValue_Last, CdcUpdatedDateValue_Last + CdcUpdatedTimeValue_Last, CdcCreatedDateValue_Last + CdcCreatedTimeValue_Last) AS WaterMarkCutOffTopRangeDtValue
FROM 
	[adf].[LoadConfig]
WHERE 
	[LoadTypeCode] = ''INCR''
AND
	[IsActive] = 1
' 
GO
