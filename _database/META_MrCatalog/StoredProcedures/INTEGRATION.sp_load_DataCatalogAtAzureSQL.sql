SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- ====================================================================================================
-- Author:      Francois Senekal
-- Create Date: 20 June 2019
-- Description: Generates the DC meta data and inserts it into the DataCatalog egress table.
-- ====================================================================================================

CREATE PROCEDURE [INTEGRATION].[sp_load_DataCatalogAtAzureSQL]
@DatabaseName varchar(100),
@DCDatabaseInstanceID int,
--SQL UserName (user@database)
@CredentialIdentity varchar(50),
--SQL Password
@CredentialPW varchar(50),
--Azure DMgr db name (name.database.windows.net)
@MasterDatabaseConnection varchar(100),
--Master DB name (DataManager_DEV)
@MasterDatabaseName varchar(100)

AS
--DECLARE @DatabaseName varchar(100) = 'QA_StageArea'
--DECLARE @DCDatabaseInstanceID int = 1
-- --SQL UserName (user@database)
--DECLARE @CredentialIdentity varchar(50) = 'sqladmin'
-- --SQL Password
--DECLARE @CredentialPW varchar(50) = 'h@U\!En&wV4/M5:K'
-- --Azure DMgr db name (name.database.windows.net)
--DECLARE @MasterDatabaseConnection varchar(100) = 'kevrosql01.database.windows.net'
-- --Master DB name (DataManager_DEV)
--DECLARE @MasterDatabaseName varchar(100) = 'DataManager'

DECLARE @CreateEgressTable varchar(MAX)
DECLARE @InsertEgressTable varchar(MAX)
DECLARE @DBDatabaseID INT = (SELECT database_id 
						   from sys.databases db 
						   WHERE db.name = @DatabaseName)

--Create the schema for INTEGRATION
IF (NOT EXISTS (SELECT name 
				FROM sys.schemas 
				WHERE name = 'INTEGRATION'
				)
	)
BEGIN
	EXEC('CREATE SCHEMA [INTEGRATION]')
END

--Creates the ingress table
SET @CreateEgressTable = 
(
SELECT '
IF EXISTS (SELECT * FROM sys.external_tables WHERE [name] = ''ingress_DataCatalog_'+@DatabaseName+''')
DROP EXTERNAL TABLE [INTEGRATION].[ingress_DataCatalog_'+@DatabaseName+']

IF EXISTS (SELECT * FROM sys.external_data_sources WHERE [name] = ''ExtDsrc_'+@DatabaseName+''')
DROP EXTERNAL DATA SOURCE ExtDsrc_'+@DatabaseName+';

IF EXISTS (SELECT * FROM sys.database_credentials WHERE [name] = ''dsc_'+@DatabaseName+''')
DROP DATABASE SCOPED CREDENTIAL dsc_'+@DatabaseName+';

IF EXISTS (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101)
DROP MASTER KEY;
       
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101)
CREATE MASTER KEY ENCRYPTION BY PASSWORD = ''P@ssw0rd'';

CREATE DATABASE SCOPED CREDENTIAL dsc_'+@DatabaseName+' WITH IDENTITY = '''+@CredentialIdentity+''',

SECRET = '''+@CredentialPW+''';

CREATE EXTERNAL DATA SOURCE ExtDsrc_'+@DatabaseName+'

WITH

	(TYPE=RDBMS,
	LOCATION='''+@MasterDatabaseConnection+''',
	DATABASE_NAME='''+@MasterDatabaseName+''',
	CREDENTIAL= dsc_'+@DatabaseName+'
	);


CREATE EXTERNAL TABLE  [INTEGRATION].[ingress_DataCatalog_'+@DatabaseName+']
			([DCDatabaseInstanceID] [int] NULL,
			 [DatabaseID] [int] NULL,
			 [DatabaseName] [varchar](500) NULL,
			 [SchemaID] [int] NULL,
			 [SchemaName] [sysname] NULL,
			 [DataEntityID] [int] NULL,
			 [DataEntityName] [sysname] NULL,
			 [ColumnID] [int] NULL,
			 [ColumnName] [sysname] NULL,
			 [DataType] [sysname] NULL,
			 [MaxLength] [smallint] NULL,
			 [Precision] [tinyint] NULL,
			 [Scale] [tinyint] NULL,
			 [IsPrimaryKey] [int] NULL,
			 [IsForeignKey] [int] NULL,
			 [DefaultValue] [nvarchar](4000) NULL,
			 [IsSystemGenerated] [int] NULL,
			 [RowCount] [int] NULL,
			 [DataEntitySize] [decimal](18, 3) NULL,
			 [DatabaseSize] [decimal](18, 3) NULL,
			 [IsActive] [bit] NULL,
			 [FieldSortOrder] [int] NULL
			)
			
			WITH

			(

			DATA_SOURCE = ExtDsrc_'+@DatabaseName+',

			SCHEMA_NAME = ''INTEGRATION'',

			OBJECT_NAME = ''ingress_DataCatalog_'+@DatabaseName+'''

			);'
)

--EXEC(@CreateEgressTable)

SET @InsertEgressTable = 
(
SELECT
'INSERT INTO [INTEGRATION].[ingress_DataCatalog_'+@DatabaseName+']
 SELECT   '+CONVERT(varchar,@DCDatabaseInstanceID)+' AS DCDatabaseInstanceID 
        , '+CONVERT(varchar,@DBDatabaseID)+' AS DatabaseID
        , '''+@DatabaseName+''' AS DatabaseName
        , t.[schema_id] AS SchemaID
        , SCHEMA_NAME(t.[schema_id]) AS SchemaName
        , t.[object_id] AS TableID
        , t.[name] AS TableName
        , c.column_id AS ColumnID
        , c.[name] AS ColumnName
        , typ.[name] AS DataTypename
        , c.max_length AS [MaxLength]
        , c.[precision] AS [Precision]
        , c.scale AS [Scale]
        , CASE WHEN i_pk.object_id IS NOT NULL THEN 1 ELSE 0 END AS IsPrimaryKey
        , CASE WHEN fkcol.object_id IS NOT NULL THEN 1 ELSE 0 END AS IsForeignKey
        , NULL AS DefaultValue 
        , NULL AS IsSystemGenerated
        , p.rows AS RowCounts
        , (SUM(au.used_pages)*8)/1024 usedMB
        ,   (SELECT (CONVERT([decimal](7),size) * 8/1024) 
                FROM sys.database_files df 
                WHERE df.[type_desc] = ''ROWS''
                ) + 
                (SELECT (CONVERT([decimal](7),size) * 8/1024) 
                FROM sys.database_files df1 
                WHERE df1.[type_desc] = ''LOG''
                ) AS Database_Size_MB
        ,1 AS IsActive
        ,c.column_id AS SortOrder

FROM    sys.tables t
        INNER JOIN sys.columns c
            ON c.object_id = t.object_id
        INNER JOIN sys.schemas s 
            ON t.schema_id = s.schema_id
        INNER JOIN sys.types typ
            ON typ.user_type_id = c.user_type_id
        INNER JOIN sys.indexes i 
            ON i.object_id = t.object_id
        LEFT JOIN (SELECT subi.object_id, subi.index_id, subic.column_id
                     FROM sys.indexes subi
                        LEFT JOIN sys.index_columns subic
                            ON subic.object_id = subi.object_id AND
                               subic.index_id = subi.index_id
                    WHERE subi.is_primary_key = 1) i_pk
            ON i_pk.object_id = t.object_id AND
               i_pk.column_id = c.column_id
        LEFT JOIN (select distinct fk.parent_object_id AS object_id,
                        fk.parent_column_id AS column_id
                   from sys.foreign_key_columns  fk
                    ) AS fkcol
            ON fkcol.object_id = t.object_id AND
               fkcol.column_id = c.column_id
        INNER JOIN sys.partitions p 
            ON p.object_id = t.object_id 
                AND p.index_id = i.index_id
        INNER JOIN sys.allocation_units au 
            ON au.container_id = p.partition_id

WHERE t.is_ms_shipped = 0
    AND t.[name] NOT LIKE ''dt%''
	AND t.[name] NOT LIKE ''ingress_DataCatalog_'+@DatabaseName+'''
        AND ISNULL(i.object_id, 256) > 255
    
                           
GROUP BY t.[name] 
, p.[rows] 
, s.[name] 
, t.[schema_id] 
, t.[object_id]
, i_pk.object_id
, fkcol.object_id
, c.column_id
, c.[name] 
, typ.[name] 
, c.max_length 
, c.[precision] 
, c.scale

UNION ALL

SELECT   '+CONVERT(varchar,@DCDatabaseInstanceID)+' AS DCDatabaseInstanceID 
        ,'+CONVERT(varchar,@DBDatabaseID)+' AS DatabaseID
        ,'''+@DatabaseName+''' AS DatabaseName
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL 
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
        ,NULL
WHERE (select COUNT(1) from sys.tables ) = 0'
)

--EXEC(@InsertEgressTable)
select @InsertEgressTable

GO
