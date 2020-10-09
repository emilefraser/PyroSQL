SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/*
	-- FETCHES A BATCHID FOR USE IN THE ENTIRE RUN AND KICKS OFF PROCESSES FROM HIGHEST TO LOWEST LEVEL
	DECLARE @BatchID INT = 1
	EXEC STORE.sp_Update_StorageStats_Index @BatchID
*/
CREATE     PROCEDURE [STORE].[sp_Update_StorageStats_Index]
	@BatchID INT = NULL
AS
BEGIN

	-- GETS PageSize for type, version as well as flavour of SQL we are dealing with
	DECLARE @PageSize FLOAT = (SELECT v.low / 1024.0 FROM master.dbo.spt_values v WHERE v.number = 1 AND v.type = 'E')
	DECLARE @sql_statement NVARCHAR(MAX) = NULL
	DECLARE @DatabaseID INT = NULL
	DECLARE @DatabaseName NVARCHAR(128) = NULL

	-- If the table for Storage tracking doesnt exists for so
	IF OBJECT_ID('STORE.StorageStats_Index', 'U') IS NULL
	BEGIN 

		 CREATE TABLE 
			STORE.[StorageStats_Index]
			(
				[StorageStats_IndexID] [int] IDENTITY(1,1) NOT NULL,
				[BatchID] [int] NOT NULL,
				[index_id] [int] NOT NULL,
				[index_type] [tinyint] NOT NULL,
				[type_desc] [nvarchar](60) NULL,
				[fill_factor] [tinyint] NULL,
				[is_unique] [bit] NULL,
				[is_padded] [bit] NULL,
				[size_index_total] FLOAT NULL,
				[size_index_used] FLOAT NULL,
				[size_index_unused] FLOAT NULL,
				[object_id] [int] NOT NULL,
				[schema_id] [int] NOT NULL,
				[database_id] INT NOT NULL,
				[CreatedDT] [datetime] NOT NULL DEFAULT GETDATE()
			)

	END


	DECLARE @DatabaseCursor CURSOR 
	SET @DatabaseCursor = CURSOR READ_ONLY FOR  
	SELECT 
		d.database_id, d.name 
	FROM 
		sys.databases AS  d

	OPEN @DatabaseCursor  

	FETCH NEXT FROM @DatabaseCursor 
	INTO @DatabaseID, @DatabaseName
	
	WHILE @@FETCH_STATUS = 0  
	BEGIN 

		-- Test results against sp_spaceused 'HUB_Site'
		-- 8KB difference between sp_spaceused and HEAP index table is as result of column headers
		set @sql_statement = '
		INSERT INTO
			STORE.StorageStats_Index
			(
      			[BatchID]
			  ,	[index_id]
			  ,	[index_type]
			  ,	[type_desc]
			  ,	[fill_factor]
			  ,	[is_unique]
			  ,	[is_padded]
			  ,	[size_index_total]
			  ,	[size_index_used]
			  ,	[size_index_unused]
			  ,	[table_id]
			  ,	[schema_id]
			  ,	[database_id]
			  ,	[CreatedDT]
			)
		SELECT
				' + CONVERT(VARCHAR(10), @BatchID) + ' AS BatchID
			,	o.object_id AS index_id
			,	i.type AS index_type
			,	i.type_desc
			,	i.fill_factor
			,	i.is_unique
			,	i.is_padded
			,	(a.total_pages * ' + CONVERT(VARCHAR(2), @PageSize) + ') AS size_index_total
			,	(a.used_pages * ' + CONVERT(VARCHAR(2), @PageSize) + ') AS size_index_used
			,	((a.total_pages - a.used_pages) * ' + CONVERT(VARCHAR(2), @PageSize) + ') AS size_index_unused
			,	t.object_id AS table_id
			,	o.schema_id
			,	' + CONVERT(VARCHAR(10),@DatabaseID) + ' AS DatabaseID
			,	GETDATE() AS CreatedDT
		FROM 
			' + QUOTENAME(@DatabaseName) + '.sys.objects o
		INNER JOIN 
			' + QUOTENAME(@DatabaseName) + '.sys.indexes i
			ON i.object_id = o.object_id
		INNer JOIN 
			' + QUOTENAME(@DatabaseName) + '.sys.tables AS t
			ON t.object_id = o.object_id
		INNER JOIN 
			' + QUOTENAME(@DatabaseName) + '.sys.partitions AS p 
			ON p.object_id = i.object_id 
			AND p.index_id = i.index_id
		INNER JOIN 
			' + QUOTENAME(@DatabaseName) + '.sys.allocation_units AS a 
			ON a.container_id = p.partition_id
		WHERE 
			o.is_ms_shipped <> 1
		AND 
			i.index_id > 0
		ORDER BY 
			i.[name]'


		EXEC sp_executesql @stmt = @sql_statement

	FETCH NEXT FROM @DatabaseCursor 
	INTO @DatabaseID, @DatabaseName  

END 


END

GO
