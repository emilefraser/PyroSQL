SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



--/****** Object:  View [INTEGRATION].[vw_egress_ETLLoadConfig]    Script Date: 2020/03/16 12:00:44 PM ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO







----create view ETL.egress_ETLLoadConfig
----AS
CREATE view [INTEGRATION].[vw_egress_ETLLoadConfig]
AS

select  lc.[LoadConfigID]
	   ,src.SourceServerName AS [SourceServerName]
	   ,CASE WHEN src.IsSourceDefaultInstance = 1 THEN 'Default' ELSE src.SourceDatabaseInstanceName END AS SourceDatabaseInstanceName
       ,src.SourceDatabaseName AS [SourceDatabaseName]
       ,src.SourceSchemaName AS [SourceSchemaName]
       ,src.SourceDataEntityName AS [SourceDataEntityName]
       ,src2.TargetServerName AS [TargetServerName]
	   ,CASE WHEN src2.IsTargetDefaultInstance = 1 THEN 'Default' ELSE src2.TargetDatabaseInstanceName END AS TargetDatabaseInstanceName
       ,src2.TargetDatabaseName AS [TargetDatabaseName]
       ,src2.TargetSchemaName AS [TargetSchemaName]
       ,src2.TargetDataEntityName AS [TargetDataEntityName]
       ,[DC].[udf_FieldListForSelectNoSpaces](lc.SourceDataEntityID) AS [FieldList]
	   ,lt.LoadTypeCode AS LoadType
       ,lc.[IsSetForReloadOnNextRun]
       ,lc.[OffsetDays]
       ,lc.[NewDataFilterType]
       ,'['+lc.[PrimaryKeyField]+']' AS PrimaryKeyField
       ,lc.[TransactionNoField]
       ,lc.[CreatedDTField]
	   ,ISNULL(CASE 
			WHEN lc.NewDataFilterType = 'CreateDateTime' 
				THEN [DC].[udf_GetDataTypeFromDEIDAndFieldName] (src.DataEntityID,lc.CreatedDTField)
			WHEN lc.NewDataFilterType = 'PrimaryKey'
				THEN [DC].[udf_GetDataTypeFromDEIDAndFieldName] (src.DataEntityID,lc.CreatedDTField)
			WHEN lc.NewDataFilterType = 'TransactionNo' 
				THEN [DC].[udf_GetDataTypeFromDEIDAndFieldName] (src.DataEntityID,lc.CreatedDTField)
			ELSE NULL 
		END ,'datetime') AS CreatedDTFieldDataType
       ,lc.[UpdatedDTField]
	   ,ISNULL(CASE 
			WHEN lc.NewDataFilterType = 'CreateDateTime' 
				THEN [DC].[udf_GetDataTypeFromDEIDAndFieldName] (src.DataEntityID,lc.UpdatedDTField)
			WHEN lc.NewDataFilterType = 'PrimaryKey'
				THEN [DC].[udf_GetDataTypeFromDEIDAndFieldName] (src.DataEntityID,lc.UpdatedDTField)
			WHEN lc.NewDataFilterType = 'TransactionNo' 
				THEN [DC].[udf_GetDataTypeFromDEIDAndFieldName] (src.DataEntityID,lc.UpdatedDTField)
			ELSE NULL 
		END ,'datetime') AS UpdatedDTFieldDataType  
	   ,lc.isActive
       ,[DC].[udf_FieldListForSelectNoSpacesNoSpecialDataType](lc.SourceDataEntityID) AS IndexFieldList
	   ,CASE WHEN [DC].[udf_FieldListForSelectNoSpacesNoSpecialDataType](lc.SourceDataEntityID) != [DC].[udf_FieldListForSelectNoSpaces](lc.SourceDataEntityID)
			THEN 0
			ELSE 1
		END
			AS IsClustered
FROM ETL.LoadConfig lc
join
(SELECT   de.DataEntityID
		 ,sr.ServerName AS [SourceServerName]
		 ,dbi.DatabaseInstanceName AS [SourceDatabaseInstanceName]
		 ,dbi.IsDefaultInstance AS IsSourceDefaultInstance
		 ,db.DatabaseName AS [SourceDatabaseName]
		 ,s.schemaName AS [SourceSchemaName]
		 ,de.DataEntityName AS [SourceDataEntityName]
FROM DC.DataEntity de
	JOIN DC.[Schema] s
		ON s.SchemaID = de.SchemaID
	join DC.[Database] db
		ON db.DatabaseID = s.DatabaseID
	join DC.DatabaseInstance dbi
		ON db.DatabaseInstanceID = dbi.DatabaseInstanceID
	join DC.[Server] sr
		ON sr.ServerId = dbi.ServerID
) AS src
ON src.DataEntityID = lc.SourceDataEntityID
join ETL.LoadType lt
	on lt.LoadTypeID = lc.LoadTypeID
join 
(SELECT  de.DataEntityID
		,sr.ServerName AS [TargetServerName]
		,dbi.DatabaseInstanceName AS [TargetDatabaseInstanceName]
		,dbi.IsDefaultInstance AS IsTargetDefaultInstance
		,db.DatabaseName AS [TargetDatabaseName]
		,s.schemaName AS [TargetSchemaName]
		,de.DataEntityName AS[TargetDataEntityName]
FROM DC.DataEntity de
	JOIN DC.[Schema] s
		ON s.SchemaID = de.SchemaID
	join DC.[Database] db
		ON db.DatabaseID = s.DatabaseID
	join DC.DatabaseInstance dbi
		ON db.DatabaseInstanceID = dbi.DatabaseInstanceID
	join DC.[Server] sr
		ON sr.ServerId = dbi.ServerID
)AS src2
ON src2.DataEntityID = lc.TargetDataEntityID
and lc.IsActive = 1

GO
