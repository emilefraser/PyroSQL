SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[adf].[vw_DataType]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [adf].[vw_DataType]
AS
	SELECT
		[dt].[DataTypeId]
	  , [dt].[TechnologyTypeId]
	  , [tt].[TechnologyCode]
	  , [tt].[TechnologyName]
	  , [dt].[DataTypeCode]
	  , [dt].[DataTypeName]
	  , [dt].[DataTypeMaxLength]
	  , [dt].[DataTypePrecision]
	  , [dt].[DataTypeScale]
	  , [dt].[DataTypeIsNullable]
	  , [dt].[DataTypeFormat]
	FROM
		[adf].[DataType] AS [dt]
	INNER JOIN
		[adf].[TechnologyType] AS [tt]
		ON [tt].[TechnologyTypeID] = [dt].[TechnologyTypeId]
' 
GO
