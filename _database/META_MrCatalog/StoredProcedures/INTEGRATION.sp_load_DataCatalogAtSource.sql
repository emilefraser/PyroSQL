SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- ====================================================================================================
-- Author:      Francois Senekal
-- Create Date: 20 June 2019
-- Description: Generates the DC meta data and inserts it into the DataCatalog egress table.
-- ====================================================================================================

CREATE PROCEDURE [INTEGRATION].[sp_load_DataCatalogAtSource]
@DatabaseName varchar(100),
@DCDatabaseInstanceID int
AS


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
DROP TABLE IF EXISTS [INTEGRATION].[gateway_egress_DataCatalog]
CREATE TABLE [INTEGRATION].[gateway_egress_DataCatalog](
			 [DCDatabaseInstanceID] [int] NULL,
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
) ON [PRIMARY]

INSERT INTO [INTEGRATION].[gateway_egress_DataCatalog]
--This part generates the meta data from sys tables
 SELECT   @DCDatabaseInstanceID AS DCDatabaseInstanceID 
        , @DBDatabaseID AS DatabaseID
        , @DatabaseName AS DatabaseName
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
        , SUM(p.rows) AS RowCounts
        , (SUM(au.used_pages)*8)/1024 usedMB
        ,   (SELECT (CONVERT([decimal](7),size) * 8/1024) 
                FROM sys.database_files df 
                WHERE df.[type_desc] = 'ROWS'
                ) + 
                (SELECT (CONVERT([decimal](7),size) * 8/1024) 
                FROM sys.database_files df1 
                WHERE df1.[type_desc] = 'LOG'
                ) AS Database_Size_MB
        ,1 AS IsActive
        ,c.column_id AS SortOrder

FROM    sys.tables t
        INNER JOIN sys.columns c
            ON c.object_id = t.object_id
        --LEFT JOIN (SELECT parent_object_id FROM sys.key_constraints WHERE type = 'PK') kc
        --  ON kc.parent_object_id = t.object_id
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
    AND t.[name] NOT LIKE 'dt%'
	AND t.[name] NOT LIKE 'gateway_egress_DataCatalog'
        AND ISNULL(i.object_id, 256) > 255
    
                           
GROUP BY t.[name] 
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

--This part makes sure that empty databases also gets added to the DC.

SELECT   @DCDatabaseInstanceID AS DCDatabaseInstanceID 
        ,@DBDatabaseID AS DatabaseID
        ,@DatabaseName AS DatabaseName
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
WHERE (select COUNT(1) from sys.tables ) = 0

GO
