USE DataManager_Gateway
 SELECT 0 AS DCDatabaseInstanceID 
        , 0 AS DatabaseID
        , 'DataManager_Gateway' AS DatabaseName
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
        , case when kc1.CONSTRAINT_NAME is not null then 1 else 0 end AS IsPrimaryKey
        , case when kc2.CONSTRAINT_NAME is not null then 1 else 0 end AS IsForeignKey
        , iif(scs.COLUMN_DEFAULT is null,'No', COLUMN_DEFAULT) AS DefaultValue 
        , null AS IsSystemGenerated
        , tsize.rowcounts AS RowCounts
        , tsize.usedMB usedMB
        , (SELECT total_size_mb = CAST(sum(size)*8. / 1024 AS decimal(8,2)) FROM sys.master_files WITH(NOWAIT) WHERE database_id = 0 and [type] = 0 GROUP BY database_id) AS DatabaseSize
		,null as IsActive
		,scs.Ordinal_position as OrdinalPosition 
		FROM    sys.tables t
        INNER JOIN sys.columns c
			ON c.object_id = t.object_id
        INNER JOIN sys.schemas s 
            ON t.schema_id = s.schema_id
        INNER JOIN sys.types typ
			ON typ.user_type_id = c.user_type_id
        left join information_schema.columns scs
			ON scs.COLUMN_NAME = c.[name]
				and scs.TABLE_NAME = t.[name]
				and scs.TABLE_SCHEMA = s.name
		
        LEFT JOIN (select distinct 
					kcu.CONSTRAINT_NAME
					,t.[name]
					,kcu.COLUMN_NAME
					,kcu.ORDINAL_POSITION
					from INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
						join sys.tables t
							on t.[name] = kcu.TABLE_NAME
					where CONSTRAINT_NAME like '%pk%') AS kc1
						on kc1.COLUMN_NAME = c.[name]
							and  kc1.[name] = t.[name] 
		LEFT JOIN(select distinct 
					kcu.CONSTRAINT_NAME
					,t.[name]
					,kcu.COLUMN_NAME
					,kcu.ORDINAL_POSITION
					from INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
						join sys.tables t
							on t.[name] = kcu.TABLE_NAME
					where CONSTRAINT_NAME like '%fk%') AS kc2
						on kc2.COLUMN_NAME = c.[name]
							and kc2.[name] = t.[name]	
        LEFT JOIN 
			(
				SELECT	t.[object_id] AS ObjectID
						,p.[rows] AS rowcounts
						,CAST(ROUND((SUM(a.used_pages)/128.00),2) AS numeric(36 , 2)) AS usedMB
				FROM sys.tables t
					INNER JOIN sys.indexes i 
						ON t.[object_id] = i.[object_id]
					INNER JOIN sys.partitions p 
						ON i.[object_id] = p.[object_id] 
							and i.index_id = p.index_id
					INNER JOIN sys.allocation_units a 
						ON p.[partition_id] = a.container_id
					INNER JOIN sys.schemas s 
						ON t.[schema_id] = s.[schema_id]
				GROUP BY  s.name , p.rows ,t.[object_id]
        ) tsize ON t.[object_id] = tsize.ObjectID
 
        WHERE t.is_ms_shipped = 0
			       
GROUP BY t.[name] ,tsize.rowcounts, s.[name] ,tsize.usedMB, t.[schema_id] ,t.[object_id],c.column_id,c.[name] 
,typ.[name] ,c.max_length ,c.[precision] ,c.scale,kc1.COLUMN_NAME,kc1.CONSTRAINT_NAME,COLUMN_DEFAULT,kc2.CONSTRAINT_NAME,scs.ordinal_position

union all
 SELECT 0 AS DCDatabaseInstanceID 
		, dbs.database_id AS DatabaseID
		, convert(varchar(500), name) AS DatabaseName
        ,null
        ,null
        ,null
        ,null
        ,null
        ,null
        ,null
        ,null
        ,null
        ,null
        ,null
        ,null
        ,null 
        ,null
        ,null
        ,null
        ,null
		,null
		,null
		from sys.databases dbs
		where database_id = 0
		and (select COUNT(1) from sys.tables ) = 0 

union all
 SELECT 0 AS DCDatabaseInstanceID 
        , 0 AS DatabaseID
        , 'DataManager_Gateway' AS DatabaseName
		,t.[schema_id] AS SchemaID
        ,SCHEMA_NAME(t.[schema_id]) AS SchemaName
        ,t.[object_id] AS TableID
        ,isv.TABLE_Name AS TableName
        ,c.column_id AS ColumnID
        ,c.[name] AS ColumnName
        ,typ.[name] AS DataTypename
        ,c.max_length AS [MaxLength]
        ,c.[precision] AS [Precision]
        ,c.scale AS [Scale]
        ,NULL
        ,NULL
        ,NULL
        ,null AS IsSystemGenerated
        ,null
        ,null
        ,null
		,null
		,null
		from INFORMATION_SCHEMA.VIEWS isv
		INNER JOIN sys.schemas s ON
			s.name = isv.TABLE_SCHEMA
		INNER JOIN sys.tables t ON
			t.schema_id = s.schema_id
		INNER JOIN sys.columns c ON
			c.object_id = t.object_id
		INNER JOIN sys.types typ ON
			typ.user_type_id = c.user_type_id
			