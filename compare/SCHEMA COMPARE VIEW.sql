USE [SCHEMA_COMPARE]
GO

/****** Object:  View [DC].[vw_SchemaComparison]    Script Date: 2019/11/17 15:10:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- SELECT * FROM [DC].[vw_SchemaComparison]
ALTER   VIEW [DC].[vw_SchemaComparison]
AS

 -- SCHEMA
 SELECT 
    ISNULL(mast.DatabaseName, cms.DatabaseName_Master) As MasterDatabaseName,
    ISNULL(mast.DatabaseInstanceID, cms.DCDatabaseInstanceID_Master) As MasterDatabaseInstanceID,
    ISNULL(mast.DatabaseID, cms.DatabaseID_Master) As MasterDatabaseID,
	ISNULL(slave.DatabaseName, cms.DatabaseName_Slave) As SlaveDatabaseName,
    ISNULL(slave.DatabaseInstanceID, cms.DCDatabaseInstanceID_Slave) As SlaveDatabaseInstanceID,
    ISNULL(slave.DatabaseID, cms.DatabaseID_Slave) As SlaveDatabaseID,

	'[Database]' AS CompareDimension_Parent,
	'{{DataManager}}' AS CompareDimension_Parent_Value,

    'Schema' As CompareDimension,
    mast.SchemaName AS MasterValue,
    slave.SchemaName As SlaveValue,
    CompareResult = CASE 
                        WHEN mast.SchemaName IS NULL THEN 'Schema does not exists in Master'
                        WHEN slave.SchemaName IS NULL THEN 'Schema does not exists in Slave'
                        ELSE 'No Difference' END,
    CompareStatus = CASE 
                        WHEN mast.SchemaName IS NULL THEN 'Schema Difference' 
                        WHEN slave.SchemaName IS NULL THEN 'Schema Difference'
                        ELSE 'Schema Equal' END
    FROM
    (
        SELECT DISTINCT 
	           vrdfdm.[DatabaseName] AS [DatabaseName]
             , vrdfdm.DatabaseInstanceID
             , vrdfdm.DatabaseID
             , vrdfdm.[SchemaName] AS [SchemaName]
        FROM 
	         [DC].[vw_rpt_DatabaseFieldDetail_MASTER] AS vrdfdm
    ) AS mast

    FULL JOIN 
    
    (
        SELECT DISTINCT
	           vrdfds.[DatabaseName] AS [DatabaseName]
             , vrdfds.DatabaseInstanceID
             , vrdfds.DatabaseID
             , vrdfds.[SchemaName] AS [SchemaName]
        FROM 
	         [DC].[vw_rpt_DatabaseFieldDetail_SLAVE] AS vrdfds
    ) AS slave
    ON
        slave.SchemaName = mast.SchemaName
    CROSS JOIN 
		[INTEGRATION].[vw_compare_MASTER_SLAVE] AS [cms]


UNION ALL



 -- TABLE
 SELECT 
    ISNULL(mast.DatabaseName, cms.DatabaseName_Master) As MasterDatabaseName,
    ISNULL(mast.DatabaseInstanceID, cms.DCDatabaseInstanceID_Master) As MasterDatabaseInstanceID,
    ISNULL(mast.DatabaseID, cms.DatabaseID_Master) As MasterDatabaseID,  
	ISNULL(slave.DatabaseName, cms.DatabaseName_Slave) As SlaveDatabaseName,
    ISNULL(slave.DatabaseInstanceID, cms.DCDatabaseInstanceID_Slave) As SlaveDatabaseInstanceID,
    ISNULL(slave.DatabaseID, cms.DatabaseID_Slave) As SlaveDatabaseID,

	'[Database].[Schema]' AS CompareDimension_Parent,
	'{{DataManager}}.' + QUOTENAME(ISNULL(mast.[SchemaName], slave.[SchemaName])) AS CompareDimension_Parent_Value,

    'Table' As CompareDimension,
    mast.TableName AS MasterValue,
    slave.TableName As SlaveValue,
    CompareResult = CASE 
                        WHEN mast.TableName IS NULL THEN 'Table does not exists in Master'
                        WHEN slave.TableName IS NULL THEN 'Table does not exists in Slave'
                        ELSE 'No Difference' END,
    CompareStatus = CASE 
                        WHEN mast.TableName IS NULL THEN 'Table Difference' 
                        WHEN slave.TableName IS NULL THEN 'Table Difference'
                        ELSE 'Table Equal' END
    FROM
    (
        SELECT DISTINCT 
	           vrdfdm.[DatabaseName] AS [DatabaseName]
             , vrdfdm.DatabaseInstanceID
             , vrdfdm.DatabaseID
             , vrdfdm.[SchemaName] AS [SchemaName]
			 , vrdfdm.[DataEntityName] AS [TableName]
        FROM 
	         [DC].[vw_rpt_DatabaseFieldDetail_MASTER] AS vrdfdm
    ) AS mast

    FULL JOIN 
    
    (
        SELECT DISTINCT
	           vrdfds.[DatabaseName] AS [DatabaseName]
             , vrdfds.DatabaseInstanceID
             , vrdfds.DatabaseID
             , vrdfds.[SchemaName] AS [SchemaName]
			 , vrdfds.[DataEntityName] AS [TableName]
        FROM 
	         [DC].[vw_rpt_DatabaseFieldDetail_SLAVE] AS vrdfds
    ) AS slave
    ON
        slave.SchemaName = mast.SchemaName
	AND
		slave.TableName = mast.TableName
    CROSS JOIN 

		[INTEGRATION].[vw_compare_MASTER_SLAVE] AS [cms]


UNION ALL


  -- FIELD
 SELECT 
    ISNULL(mast.DatabaseName, cms.DatabaseName_Master) As MasterDatabaseName,
    ISNULL(mast.DatabaseInstanceID, cms.DCDatabaseInstanceID_Master) As MasterDatabaseInstanceID,
    ISNULL(mast.DatabaseID, cms.DatabaseID_Master) As MasterDatabaseID,
	ISNULL(slave.DatabaseName, cms.DatabaseName_Slave) As SlaveDatabaseName,
    ISNULL(slave.DatabaseInstanceID, cms.DCDatabaseInstanceID_Slave) As SlaveDatabaseInstanceID,
    ISNULL(slave.DatabaseID, cms.DatabaseID_Slave) As SlaveDatabaseID,

	'[Database].[Schema].[Table]' AS CompareDimension_Parent,
	'{{DataManager}}.' + QUOTENAME(ISNULL(mast.[SchemaName], slave.[SchemaName])) + '.' + QUOTENAME(ISNULL(mast.[TableName], slave.[TableName])) AS CompareDimension_Parent_Value,

    'Field' As CompareDimension,
    mast.FieldName AS MasterValue,
    slave.FieldName As SlaveValue,
    CompareResult = CASE 
                        WHEN mast.FieldName IS NULL THEN 'Field does not exists in Master'
                        WHEN slave.FieldName IS NULL THEN 'Field does not exists in Slave'
                        WHEN mast.FieldName <> slave.FieldName THEN 'Field Difference'
                        ELSE 'No Difference' END,
    CompareStatus = CASE 
                        WHEN mast.FieldName IS NULL THEN 'Field Difference' 
                        WHEN slave.FieldName IS NULL THEN 'Field Difference'
                        WHEN mast.FieldName <> slave.FieldName THEN 'Field Difference'
                        ELSE 'Field Equal' END
    FROM
    (
        SELECT 
	           vrdfdm.[DatabaseName] AS [DatabaseName]
             , vrdfdm.DatabaseInstanceID
             , vrdfdm.DatabaseID
             , vrdfdm.[SchemaName] AS [SchemaName]
	         , vrdfdm.[DataEntityName] AS [TableName]
	         , QUOTENAME(vrdfdm.[FieldName]) AS [FieldName]
        FROM 
	         [DC].[vw_rpt_DatabaseFieldDetail_MASTER] AS vrdfdm
    ) AS mast

    FULL JOIN 
    
    (
        SELECT 
	           vrdfds.[DatabaseName] AS [DatabaseName]
             , vrdfds.DatabaseInstanceID
             , vrdfds.DatabaseID
             , vrdfds.[SchemaName] AS [SchemaName]
	         , vrdfds.[DataEntityName] AS [TableName]
	         , QUOTENAME(vrdfds.[FieldName]) AS [FieldName]
        FROM 
	         [DC].[vw_rpt_DatabaseFieldDetail_SLAVE] AS vrdfds
    ) AS slave
    ON
        slave.SchemaName = mast.SchemaName
            AND slave.TableName = mast.TableName
                AND slave.FieldName = mast.FieldName
    CROSS JOIN 
		[INTEGRATION].[vw_compare_MASTER_SLAVE] AS [cms]
    

UNION ALL


-- Field (DataType)
SELECT 
    ISNULL(mast.DatabaseName, cms.DatabaseName_Master) As MasterDatabaseName,
    ISNULL(mast.DatabaseInstanceID, cms.DCDatabaseInstanceID_Master) As MasterDatabaseInstanceID,
    ISNULL(mast.DatabaseID, cms.DatabaseID_Master) As MasterDatabaseID,
	ISNULL(slave.DatabaseName, cms.DatabaseName_Slave) As SlaveDatabaseName,
    ISNULL(slave.DatabaseInstanceID, cms.DCDatabaseInstanceID_Slave) As SlaveDatabaseInstanceID,
    ISNULL(slave.DatabaseID, cms.DatabaseID_Slave) As SlaveDatabaseID,

	'[Database].[Schema].[Table]' AS CompareDimension_Parent,
	'{{DataManager}}.' + QUOTENAME(ISNULL(mast.[SchemaName], slave.[SchemaName])) + '.' + QUOTENAME(ISNULL(mast.[TableName], slave.[TableName])) AS CompareDimension_Parent_Value,


	'Field (DataType)' As CompareDimension,
    mast.FieldName + ' (' + mast.DataType  + ')' AS MasterValue,
    slave.FieldName+ ' (' + slave.DataType  + ')' AS SlaveValue,
    CompareResult = CASE 
                        WHEN mast.DataType <> slave.DataType THEN 'Field (DataType) Difference'
                        ELSE 'Field (DataType) Equal' END,
    CompareStatus = CASE 
                        WHEN mast.DataType <> slave.DataType THEN 'Field Difference'
                        ELSE 'Field Equal' END
    FROM
    (
        SELECT 
	            vrdfdm.[DatabaseName] AS [DatabaseName]
                , vrdfdm.DatabaseInstanceID
                , vrdfdm.DatabaseID
                , vrdfdm.[SchemaName] AS [SchemaName]
	            , vrdfdm.[DataEntityName] AS [TableName]
	            , QUOTENAME(vrdfdm.[FieldName]) AS [FieldName]
                , UPPER(vrdfdm.[DataType]) AS [DataType]
        FROM 
	            [DC].[vw_rpt_DatabaseFieldDetail_MASTER] AS vrdfdm
    ) AS mast

    FULL JOIN 
    
    (
        SELECT 
	              vrdfds.[DatabaseName] AS [DatabaseName]
                , vrdfds.DatabaseInstanceID
                , vrdfds.DatabaseID
                , vrdfds.[SchemaName] AS [SchemaName]
	            , vrdfds.[DataEntityName] AS [TableName]
	            , QUOTENAME(vrdfds.[FieldName]) AS [FieldName]
                , UPPER(vrdfds.[DataType]) AS [DataType]
        FROM 
	            [DC].[vw_rpt_DatabaseFieldDetail_SLAVE] AS vrdfds
    ) AS slave
    ON
        slave.SchemaName = mast.SchemaName
            AND slave.TableName = mast.TableName
                AND slave.FieldName = mast.FieldName
    CROSS JOIN 
		[INTEGRATION].[vw_compare_MASTER_SLAVE] AS [cms]
    WHERE
        mast.FieldName IS NOT NULL
    AND 
        slave.FieldName IS NOT NULL


 UNION ALL


-- MaxLength
SELECT
    ISNULL(mast.DatabaseName, cms.DatabaseName_Master) As MasterDatabaseName,
    ISNULL(mast.DatabaseInstanceID, cms.DCDatabaseInstanceID_Master) As MasterDatabaseInstanceID,
    ISNULL(mast.DatabaseID, cms.DatabaseID_Master) As MasterDatabaseID,
	ISNULL(slave.DatabaseName, cms.DatabaseName_Slave) As SlaveDatabaseName,
    ISNULL(slave.DatabaseInstanceID, cms.DCDatabaseInstanceID_Slave) As SlaveDatabaseInstanceID,
    ISNULL(slave.DatabaseID, cms.DatabaseID_Slave) As SlaveDatabaseID,

	'[Database].[Schema].[Table]' AS CompareDimension_Parent,
	'{{DataManager}}.' + QUOTENAME(ISNULL(mast.[SchemaName], slave.[SchemaName])) + '.' + QUOTENAME(ISNULL(mast.[TableName], slave.[TableName])) AS CompareDimension_Parent_Value,

	'Field (MaxLength)' As CompareDimension,
    mast.FieldName + ' (' + CONVERT(VARCHAR(6), mast.[MaxLength])  + ')' AS MasterValue,
    slave.FieldName+ ' (' + CONVERT(VARCHAR(6), slave.[MaxLength])  + ')' AS SlaveValue,
    CompareResult = CASE 
                        WHEN mast.[MaxLength] <> slave.[MaxLength] THEN 'Field (MaxLength) Difference'
                        ELSE 'Field (MaxLength) Equal' END,
    CompareStatus = CASE 
                        WHEN mast.[MaxLength] <> slave.[MaxLength] THEN 'Field Difference'
                        ELSE 'Field Equal' END
    FROM
    (
        SELECT 
	            vrdfdm.[DatabaseName] AS [DatabaseName]
                , vrdfdm.DatabaseInstanceID
                , vrdfdm.DatabaseID
                , vrdfdm.[SchemaName] AS [SchemaName]
	            , vrdfdm.[DataEntityName] AS [TableName]
	            , QUOTENAME(vrdfdm.[FieldName]) AS [FieldName]
                , vrdfdm.[MaxLength] AS [MaxLength]
        FROM 
	            [DC].[vw_rpt_DatabaseFieldDetail_MASTER] AS vrdfdm
    ) AS mast

    FULL JOIN 
    
    (
        SELECT 
	            vrdfds.[DatabaseName] AS [DatabaseName]
                , vrdfds.DatabaseInstanceID
                , vrdfds.DatabaseID
                , vrdfds.[SchemaName] AS [SchemaName]
	            , vrdfds.[DataEntityName] AS [TableName]
	            , QUOTENAME(vrdfds.[FieldName]) AS [FieldName]
                , vrdfds.[MaxLength] AS [MaxLength]
        FROM 
	            [DC].[vw_rpt_DatabaseFieldDetail_SLAVE] AS vrdfds
    ) AS slave
    ON
        slave.SchemaName = mast.SchemaName
            AND slave.TableName = mast.TableName
                AND slave.FieldName = mast.FieldName
    CROSS JOIN 
		[INTEGRATION].[vw_compare_MASTER_SLAVE] AS [cms]
    WHERE
        mast.FieldName IS NOT NULL
    AND 
        slave.FieldName IS NOT NULL


UNION ALL


-- Field (Precision)
SELECT
    ISNULL(mast.DatabaseName, cms.DatabaseName_Master) As MasterDatabaseName,
    ISNULL(mast.DatabaseInstanceID, cms.DCDatabaseInstanceID_Master) As MasterDatabaseInstanceID,
    ISNULL(mast.DatabaseID, cms.DatabaseID_Master) As MasterDatabaseID,
	ISNULL(slave.DatabaseName, cms.DatabaseName_Slave) As SlaveDatabaseName,
    ISNULL(slave.DatabaseInstanceID, cms.DCDatabaseInstanceID_Slave) As SlaveDatabaseInstanceID,
    ISNULL(slave.DatabaseID, cms.DatabaseID_Slave) As SlaveDatabaseID,

	'[Database].[Schema].[Table]' AS CompareDimension_Parent,
	'{{DataManager}}.' + QUOTENAME(ISNULL(mast.[SchemaName], slave.[SchemaName])) + '.' + QUOTENAME(ISNULL(mast.[TableName], slave.[TableName])) AS CompareDimension_Parent_Value,

	'Field (Precision)' As CompareDimension,
    mast.FieldName + ' (' + CONVERT(VARCHAR(6), mast.[Precision])  + ')' AS MasterValue,
    slave.FieldName+ ' (' + CONVERT(VARCHAR(6), slave.[Precision])  + ')' AS SlaveValue,
    CompareResult = CASE 
                        WHEN mast.[Precision] <> slave.[Precision] THEN 'Field (Precision) Difference'
                        ELSE 'Field (Precision) Equal' END,
    CompareStatus = CASE 
                        WHEN mast.[Precision] <> slave.[Precision] THEN 'Field Difference'
                        ELSE 'Field Equal' END
    FROM
    (
        SELECT 
	            vrdfdm.[DatabaseName] AS [DatabaseName]
                , vrdfdm.DatabaseInstanceID
                , vrdfdm.DatabaseID
                , vrdfdm.[SchemaName] AS [SchemaName]
	            , vrdfdm.[DataEntityName] AS [TableName]
	            , QUOTENAME(vrdfdm.[FieldName]) AS [FieldName]
                , vrdfdm.[Precision] AS [Precision]
        FROM 
	            [DC].[vw_rpt_DatabaseFieldDetail_MASTER] AS vrdfdm
    ) AS mast

    FULL JOIN 
    
    (
        SELECT 
	            vrdfds.[DatabaseName] AS [DatabaseName]
                , vrdfds.DatabaseInstanceID
                , vrdfds.DatabaseID
                , vrdfds.[SchemaName] AS [SchemaName]
	            , vrdfds.[DataEntityName] AS [TableName]
	            , QUOTENAME(vrdfds.[FieldName]) AS [FieldName]
                , vrdfds.[Precision] AS [Precision]
        FROM 
	            [DC].[vw_rpt_DatabaseFieldDetail_SLAVE] AS vrdfds
    ) AS slave
    ON
        slave.SchemaName = mast.SchemaName
            AND slave.TableName = mast.TableName
                AND slave.FieldName = mast.FieldName
   CROSS JOIN 
		[INTEGRATION].[vw_compare_MASTER_SLAVE] AS [cms]
    WHERE
        mast.FieldName IS NOT NULL
    AND 
        slave.FieldName IS NOT NULL


UNION ALL


-- Field (Scale)
SELECT
    ISNULL(mast.DatabaseName, cms.DatabaseName_Master) As MasterDatabaseName,
    ISNULL(mast.DatabaseInstanceID, cms.DCDatabaseInstanceID_Master) As MasterDatabaseInstanceID,
    ISNULL(mast.DatabaseID, cms.DatabaseID_Master) As MasterDatabaseID,

	ISNULL(slave.DatabaseName, cms.DatabaseName_Slave) As SlaveDatabaseName,
    ISNULL(slave.DatabaseInstanceID, cms.DCDatabaseInstanceID_Slave) As SlaveDatabaseInstanceID,
    ISNULL(slave.DatabaseID, cms.DatabaseID_Slave) As SlaveDatabaseID,

	'[Database].[Schema].[Table]' AS CompareDimension_Parent,
	'{{DataManager}}.' + QUOTENAME(ISNULL(mast.[SchemaName], slave.[SchemaName])) + '.' + QUOTENAME(ISNULL(mast.[TableName], slave.[TableName])) AS CompareDimension_Parent_Value,

	'Field (Scale)' As CompareDimension,
    mast.FieldName + ' (' + CONVERT(VARCHAR(6), mast.[Scale])  + ')' AS MasterValue,
    slave.FieldName+ ' (' + CONVERT(VARCHAR(6), slave.[Scale])  + ')' AS SlaveValue,
	CompareResult = CASE 
                        WHEN mast.[Scale] <> slave.[Scale] THEN 'Field (Scale) Difference'
                        ELSE 'No Difference' END,
    CompareStatus = CASE 
                        WHEN mast.[Scale] <> slave.[Scale] THEN 'Field Difference'
                        ELSE 'Field Equal' END
    FROM
    (
        SELECT 
	            vrdfdm.[DatabaseName] AS [DatabaseName]
                , vrdfdm.DatabaseInstanceID
                , vrdfdm.DatabaseID
                , vrdfdm.[SchemaName] AS [SchemaName]
	            , vrdfdm.[DataEntityName] AS [TableName]
	            , QUOTENAME(vrdfdm.[FieldName]) AS [FieldName]
                , vrdfdm.[Scale] AS [Scale]
        FROM 
	            [DC].[vw_rpt_DatabaseFieldDetail_MASTER] AS vrdfdm
    ) AS mast

    FULL JOIN 
    
    (
        SELECT 
	            vrdfds.[DatabaseName] AS [DatabaseName]
                , vrdfds.DatabaseInstanceID
                , vrdfds.DatabaseID
                , vrdfds.[SchemaName] AS [SchemaName]
	            , vrdfds.[DataEntityName] AS [TableName]
	            , QUOTENAME(vrdfds.[FieldName]) AS [FieldName]
                , vrdfds.[Scale] AS [Scale]
        FROM 
	            [DC].[vw_rpt_DatabaseFieldDetail_SLAVE] AS vrdfds
    ) AS slave
    ON
        slave.SchemaName = mast.SchemaName
            AND slave.TableName = mast.TableName
                AND slave.FieldName = mast.FieldName
    CROSS JOIN 
		[INTEGRATION].[vw_compare_MASTER_SLAVE] AS [cms]
    WHERE
        mast.FieldName IS NOT NULL
    AND 
        slave.FieldName IS NOT NULL

GO


