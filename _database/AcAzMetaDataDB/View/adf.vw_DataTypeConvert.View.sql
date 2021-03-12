SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[adf].[vw_DataTypeConvert]'))
EXEC dbo.sp_executesql @statement = N'
CREATE    VIEW [adf].[vw_DataTypeConvert]
AS
SELECT
  dtc.DataTypeConvertId
, SourceTechnologyId = dtc.SourceTechnologyId
, SourceTechnologyCode = tts.TechnologyCode
, SourceTechnologyName = tts.TechnologyName
, SourceDataTypeId = dtc.SourceDataTypeId
, SourceDataTypeCode = dts.DataTypeCode
, SourceDataTypeMaxLength = dts.DataTypeMaxLength
, SourceDataTypePrecision = dts.DataTypePrecision
, SourceDataTypeScale = dts.DataTypeScale
, SourceDataTypeIsNullable = dts.DataTypeIsNullable
, SourceDataTypeFormat = dts.DataTypeFormat
, TargetTechnologyId = dtc.TargetTechnologyId
, TargetTechnologyCode = ttt.TechnologyCode
, TargetTechnologyName = ttt.TechnologyName
, TargetDataTypeId = dtc.TargetDataTypeId
, TargetDataTypeCode = dtt.DataTypeCode
, TargetDataTypeMaxLength = dtt.DataTypeMaxLength
, TargetDataTypePrecision = dtt.DataTypePrecision
, TargetDataTypeScale = dtt.DataTypeScale
, TargetDataTypeIsNullable = dtt.DataTypeIsNullable
, TargetDataTypeFormat = dtt.DataTypeFormat
FROM
	[adf].[DataTypeConvert] AS dtc
INNER JOIN
	adf.DataType AS dts
	ON dts.DataTypeID = dtc.SourceDataTypeID
INNER JOIN
	adf.DataType AS dtt
	ON dtt.DataTypeID = dtc.TargetDataTypeID
INNER JOIN
	adf.TechnologyType AS tts
	ON tts.[TechnologyTypeID] = dtc.[SourceTechnologyId]
INNER JOIN
	adf.TechnologyType AS ttt
	ON ttt.[TechnologyTypeID] = dtc.[TargetTechnologyId]
' 
GO
