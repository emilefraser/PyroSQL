SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE PROCEDURE [INTEGRATION].[sp_ODSCrawlerForODSDatabases]
AS
--GET THE DB ID
--select * from sys.databases
--kevrosql01.database.windows.net
--h@U\!En&wV4/M5:K
--CREATE SCHEMA INTEGRATION
TRUNCATE TABLE DataManager.INTEGRATION.ingress_DataCatalog

DECLARE @name varchar(100)
DECLARE db_cursor CURSOR FOR 
	SELECT DatabaseName FROM DC.[Database] 
	WHERE DatabaseName like '%ODS%'

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @name  

WHILE @@FETCH_STATUS = 0  
BEGIN
DECLARE @Text varchar(MAX) =
			'
			USE ['+@name+']

			DECLARE @DatabaseInstanceID int = 1,
					@DatabaseID int = (SELECT database_id FROM sys.databases WHERE name ='''+@name+''' ),
					@DatabaseName varchar(100) = '''+@name+'''
		
			INSERT INTO DataManager.INTEGRATION.ingress_DataCatalog	
			 SELECT   @DatabaseInstanceID AS DCDatabaseInstanceID 
					, @DatabaseID AS DatabaseID
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
					,   (SELECT (CONVERT([decimal](18,3),size) * 8/1024) 
							FROM sys.database_files df 
							WHERE df.[type_desc] = ''ROWS''
							) + 
							(SELECT (CONVERT([decimal](18,3),size) * 8/1024) 
							FROM sys.database_files df1 
							WHERE df1.[type_desc] = ''LOG''
							) AS Database_Size_MB
					,1 AS IsActive
					,c.column_id AS SortOrder
					,''SrcT'' AS DataEntityTypeCode

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
				AND t.[name] NOT LIKE ''ingress_DataCatalog''
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

			 SELECT   @DatabaseInstanceID AS DCDatabaseInstanceID 
					, @DatabaseID AS DatabaseID
					, @DatabaseName AS DatabaseName
					, v.[schema_id] AS SchemaID
					, SCHEMA_NAME(v.[schema_id]) AS SchemaName
					, v.[object_id] AS TableID
					, v.[name] AS TableName
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
					, NULL AS RowCounts
					, NULL AS usedMB
					,   (SELECT (CONVERT([decimal](18,3),size) * 8/1024) 
							FROM sys.database_files df 
							WHERE df.[type_desc] = ''ROWS''
							) + 
							(SELECT (CONVERT([decimal](18,3),size) * 8/1024) 
							FROM sys.database_files df1 
							WHERE df1.[type_desc] = ''LOG''
							) AS Database_Size_MB
					,1 AS IsActive
					,c.column_id AS SortOrder
					,''SrcV'' AS DataEntityTypeCode
			FROM    sys.views v
					INNER JOIN sys.columns c
						ON c.object_id = v.object_id
					INNER JOIN sys.schemas s 
						ON v.schema_id = s.schema_id
					INNER JOIN sys.types typ
						ON typ.user_type_id = c.user_type_id
					LEFT JOIN (SELECT subi.object_id, subi.index_id, subic.column_id
								 FROM sys.indexes subi
									LEFT JOIN sys.index_columns subic
										ON subic.object_id = subi.object_id AND
										   subic.index_id = subi.index_id
								WHERE subi.is_primary_key = 1) i_pk
						ON i_pk.object_id = v.object_id AND
						   i_pk.column_id = c.column_id
					LEFT JOIN (select distinct fk.parent_object_id AS object_id,
									fk.parent_column_id AS column_id
							   from sys.foreign_key_columns  fk
								) AS fkcol
						ON fkcol.object_id = v.object_id AND
						   fkcol.column_id = c.column_id

			WHERE v.is_ms_shipped = 0
				AND v.[name] NOT LIKE ''dt%''
				AND v.[name] NOT LIKE ''ingress_DataCatalog''
                           
			GROUP BY v.[name] 
			, s.[name] 
			, v.[schema_id] 
			, v.[object_id]
			, i_pk.object_id
			, fkcol.object_id
			, c.column_id
			, c.[name] 
			, typ.[name] 
			, c.max_length 
			, c.[precision] 
			, c.scale
			'  
EXEC (@Text)
      FETCH NEXT FROM db_cursor INTO @name 
END 
CLOSE db_cursor  
DEALLOCATE db_cursor 
EXEC INTEGRATION.sp_load_DataCatalog
--Creates the ingress table

UPDATE DC.[Database] SET IsActive = 0
	WHERE LastSeenDT < DATEADD(DAY,-1,GETDATE())
	AND DatabaseID IN 
		(	SELECT DatabaseID FROM DC.[Database] 
			WHERE DatabaseName like '%ODS%'
		)

UPDATE DC.[Schema] SET IsActive = 0
	WHERE LastSeenDT < DATEADD(DAY,-1,GETDATE())
	AND SchemaID IN 
		(	SELECT SchemaID FROM DC.[Schema]
			WHERE DatabaseID IN 
				(SELECT DatabaseID FROM DC.[Database] 
				 WHERE DatabaseName like '%ODS%'
				)
		)

UPDATE DC.DataEntity SET IsActive = 0
	WHERE LastSeenDT < DATEADD(DAY,-1,GETDATE())
	AND DataEntityID IN 
		(SELECT DataEntityID FROM DC.DataEntity
		WHERE SchemaID IN	
			(	SELECT SchemaID FROM DC.[Schema]
				WHERE DatabaseID IN 
					(SELECT DatabaseID FROM DC.[Database] 
					 WHERE DatabaseName like '%ODS%'
					)
			)
		)

UPDATE DC.Field SET IsActive = 0
	WHERE LastSeenDT < DATEADD(DAY,-1,GETDATE())
	AND DataEntityID IN 
		(SELECT DataEntityID FROM DC.DataEntity
		WHERE SchemaID IN	
			(	SELECT SchemaID FROM DC.[Schema]
				WHERE DatabaseID IN 
					(SELECT DatabaseID FROM DC.[Database] 
					 WHERE DatabaseName like '%ODS%'
					)
			)
		)

GO
