SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[sp_Update_StorageStats_Object]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dba].[sp_Update_StorageStats_Object] AS' 
END
GO

/*
	-- FETCHES A BATCHID FOR USE IN THE ENTIRE RUN AND KICKS OFF PROCESSES FROM HIGHEST TO LOWEST LEVEL
	DECLARE @BatchID INT = 1
	EXEC dba.sp_Update_StorageStats_Object @BatchID
*/
ALTER       PROCEDURE [dba].[sp_Update_StorageStats_Object]
	@BatchID INT = NULL
AS
BEGIN

	-- GETS PageSize for type, version as well as flavour of SQL we are dealing with
	DECLARE @PageSize FLOAT = (SELECT v.low / 1024.0 FROM master.dbo.spt_values v WHERE v.number = 1 AND v.type = 'E')
	DECLARE @sql_statement NVARCHAR(MAX) = NULL
	DECLARE @DatabaseID INT = NULL
	DECLARE @DatabaseName NVARCHAR(128) = NULL

	-- If the table for Storage tracking doesnt exists for so
	IF OBJECT_ID('dba.StorageStats_Object', 'U') IS NULL
	BEGIN 

		CREATE TABLE dba.[StorageStats_Object](
			[StorageStats_Table_ID] [int] NOT NULL,
			[BatchID] [int] NOT NULL,
			[object_id] [int] NOT NULL,
			[object_type] [char](2) NULL,
			[object_type_desc] [nvarchar](60) NULL,
			[large_value_types_out_of_row] [bit] NULL,
			[durability] [tinyint] NULL,
			[durability_desc] [nvarchar](60) NULL,
			[temporal_type] [tinyint] NULL,
			[temporal_type_desc] [nvarchar](60) NULL,
			[is_external] [bit] NOT NULL,
			[history_retention_period] [int] NULL,
			[column_count] [int] NOT NULL,
			[row_count] [bigint] NULL,
			[text_in_row_limit] [int] NULL,
			[size_table_total] [bigint] NULL,
			[size_table_used] [bigint] NULL,
			[size_table_unused] [bigint] NULL,
			[allocation_type] [tinyint] NOT NULL,
			[allocation_type_desc] [nvarchar](60) NULL,
			[schema_id] [int] NULL,
			[database_id] INT NOT NULL,
			[CreatedDT] DATETIME2(7) NOT NULL DEFAULT GETDATE()
		) 

	END


	DECLARE @DatabaseCursor CURSOR 
	SET @DatabaseCursor = CURSOR READ_ONLY FOR  
	SELECT 
		d.database_id, d.name 
	FROM 
		sys.databases AS d  

	OPEN @DatabaseCursor  

	FETCH NEXT FROM @DatabaseCursor 
	INTO @DatabaseID, @DatabaseName  
	
	WHILE @@FETCH_STATUS = 0  
	BEGIN 

		set @sql_statement = '
		INSERT INTO dba.StorageStats_Object
		(
				[BatchID]
			  ,	[object_id]
			  ,	[object_type]
			  ,	[object_type_desc]
			  ,	[large_value_types_out_of_row]
			  ,	[durability]
			  ,	[durability_desc]
			  ,	[temporal_type]
			  ,	[temporal_type_desc]
			  ,	[is_external]
			  ,	[history_retention_period]
			  ,[column_count]
			  ,[row_count]
			  ,[text_in_row_limit]
			  ,[size_table_total]
			  ,[size_table_used]
			  ,[size_table_unused]
			  ,[allocation_type]
			  ,[allocation_type_desc]
			  ,[schema_id]
			  ,[database_id]
			  ,[CreatedDT]
	  )
			SELECT 
				' + CONVERT(VARCHAR(10), @BatchID) + ' AS BatchID
			,	t.object_id AS table_id
			,	t.type AS object_type
			,	t.type_desc AS object_type_desc			
			,	t.large_value_types_out_of_row
			,	t.durability
			,	t.durability_desc
			,	t.temporal_type
			,	t.temporal_type_desc
			,	t.is_external
			,	t.history_retention_period
			,	t.max_column_id_used AS column_count
			,	p.rows AS row_count
			,	t.text_in_row_limit
			,	(a.total_pages) * ' + CONVERT(VARCHAR(10), @PageSize) + ' AS size_table_total
			,	(a.used_pages) * ' + CONVERT(VARCHAR(10), @PageSize) + ' AS size_table_used
			,	((a.total_pages) - (a.used_pages)) * ' + CONVERT(VARCHAR(10), @PageSize) + ' AS size_table_unused
			,	a.type AS allocation_type
			,	a.type_desc AS allocation_type_desc
			,	s.schema_id
			,	' + CONVERT(VARCHAR(10),@DatabaseID) + ' AS DatabaseID
			,	GETDATE() AS CreatedDT
			FROM
				' + QUOTENAME(@DatabaseName) + '.sys.objects AS o
			INNER JOIN 
				' + QUOTENAME(@DatabaseName) + '.sys.tables AS t
			ON t.object_id = o.object_id
			INNER JOIN 
				' + QUOTENAME(@DatabaseName) + '.sys.indexes AS i
			ON t.object_id = i.object_id
			INNER JOIN 
				' + QUOTENAME(@DatabaseName) + '.sys.partitions AS p
			ON i.object_id = p.object_id AND i.index_id = p.index_id
			INNER JOIN 
				' + QUOTENAME(@DatabaseName) + '.sys.allocation_units AS a
			ON p.partition_id = a.container_id
			LEFT OUTER JOIN 
				' + QUOTENAME(@DatabaseName) + '.sys.schemas AS s
			ON t.schema_id = s.schema_id
		WHERE
			i.type = 0'
		
		EXEC sp_executesql @stmt = @sql_statement

	FETCH NEXT FROM @DatabaseCursor 
	INTO @DatabaseID, @DatabaseName  

END 

END

GO
