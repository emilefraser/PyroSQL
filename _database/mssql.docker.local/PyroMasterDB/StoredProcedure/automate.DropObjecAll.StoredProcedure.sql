SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[automate].[DropObjecAll]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [automate].[DropObjecAll] AS' 
END
GO
/*
	-- BE CAREFUL WITH THIS PROC
	-- I REPEAT BE CAREFUL!!!!!!!!!!!!!!!!!!!!!!!!!!!

	EXEC [automate].[DropAllObject] 
						 @DatabaseName = 'PyroMasterDB', 
						 @SchemaName = 'asset', 
						 @IsDropSchema = 1;
*/
ALTER PROCEDURE [automate].[DropObjecAll] 
	@DatabaseName	 SYSNAME = NULL
,	@SchemaName      SYSNAME = NULL
,	@IsDropSchema    BIT     = 0
AS
BEGIN
	DECLARE 
		@sql_debug			BIT = 1
	,	@sql_execute		BIT = 0
		
	DECLARE 
		@sql_statement		 NVARCHAR(MAX)
	,	@sql_parameter		 NVARCHAR(MAX)

	DECLARE 
		@cursor_drop		 CURSOR;

	DECLARE 
		@sql_objectid		BIGINT
	,	@sql_schemaname		SYSNAME
	,	@sql_objectname		SYSNAME
	,	@sql_objecttype		SYSNAME
	,	@sql_processorder	SMALLINT

	SET @sql_statement = '	
		SET @cursor_drop = CURSOR LOCAL FAST_FORWARD
		FOR
			WITH cte_object AS (
				SELECT   
					[ObjectId]				= obj.object_id
				  , [SchemaName]			= sch.name
				  , [ObjectName]			= obj.name
				  , [ObjectTypeDescription] = obj.[type_desc]
				  , [ObjectType]			= obj.[type]
				  , [ParentObjectId]		= obj.[parent_object_id]
				  , [DropDefinition] = CASE
										WHEN obj.type IN(''F'', ''D'', ''UQ'', ''C'')
											THEN ''ALTER TABLE '' + QUOTENAME(sch.name) + ''.'' + QUOTENAME(OBJECT_NAME(obj.parent_object_id)) 
												+ '' DROP CONSTRAINT '' + QUOTENAME(obj.name) + '';''								
										WHEN obj.type IN(''P'', ''PC'')
											THEN ''DROP PROCEDURE '' + QUOTENAME(sch.name) + ''.'' + QUOTENAME(obj.name) + '';''
										WHEN obj.type IN(''FT'', ''FN'', ''TF'', ''AF'', ''FS'', ''IF'')
											THEN ''DROP FUNCTION '' + QUOTENAME(sch.name) + ''.'' + QUOTENAME(obj.name) + '';''
										WHEN obj.type = ''V''
											THEN ''DROP VIEW '' + QUOTENAME(sch.name) + ''.'' + QUOTENAME(obj.name) + '';''
										WHEN obj.type = ''SO''
											THEN ''DROP SEQUENCE '' + QUOTENAME(sch.name) + ''.'' + QUOTENAME(obj.name) + '';''
										WHEN obj.type = ''U''
											THEN ''DROP TABLE '' + QUOTENAME(sch.name) + ''.'' + QUOTENAME(obj.name) + '';''
										WHEN obj.type = ''PG''
											THEN ''EXEC sp_control_plan_guide N''''DROP '''', N'''' + obj.name + '''';''
										WHEN obj.type = ''SQ''
											THEN ''DROP QUEUE '' + QUOTENAME(sch.name) + ''.'' + QUOTENAME(obj.name) + '';''
										WHEN obj.type = ''SN''
											THEN ''DROP SYNONYM '' + QUOTENAME(sch.name) + ''.'' + QUOTENAME(obj.name) + '';''
									END
				, [ProcessOrder] = CASE
					WHEN obj.[type] IN(''P'', ''FN'', ''FT'', ''TF'', ''PC'', ''FS'', ''AF'', ''IF'', ''SN'', ''SQ'')
						THEN 1
					WHEN obj.[type] = ''V''
						THEN 2
					WHEN obj.[type] IN(''F'', ''D'')
						THEN 3
					WHEN obj.[type] = ''SO''
						THEN 4
					WHEN obj.[type] = ''UQ''
						THEN 5
					WHEN obj.[type] = ''PG''
						THEN 6
					WHEN obj.[type] = ''U''
						THEN 7
				END 
				FROM   
					' + QUOTENAME(@DatabaseName) + '.sys.objects AS obj
				INNER JOIN
					' + QUOTENAME(@DatabaseName) + '.sys.schemas AS sch
					ON obj.schema_id = sch.schema_id
				WHERE 
					obj.[type] NOT IN (
						''PK'', ''IT'', ''S'', ''C'', ''SQ''
					)	
				AND 
					sch.name = IIF(@SchemaName IS NULL, sch.name , @SchemaName)
			), cte_combine AS (
				SELECT 
					cte_obj.*
				FROM	
					cte_object AS cte_obj

				UNION ALL

				SELECT 
					[ObjectId]	 = obj.object_id
				,	[SchemaName] = ''''
				,	[ObjectName] = [ass].[name]
				,	''Assembly''
				,	''AS''
				,	[asm].[assembly_id]
				,	[DropDefinition] = ''DROP ASSEMBLY'' + QUOTENAME([ass].[name]) + '';''
				,	[ProcessOrder] = 4
				FROM 
					[sys].[assemblies] AS ass
				INNER JOIN
					[sys].[assembly_modules] AS asm
					ON [ass].[assembly_id] = [asm].[assembly_id]
				INNER JOIN
					[sys].[objects] AS obj
					ON [asm].object_id = obj.object_id
				INNER JOIN 
					cte_object AS cte_obj
					ON cte_obj.[ObjectId] = obj.object_id

				UNION ALL

				SELECT
					[ObjectId]				= -1
				,	[SchemaName]			= sch.name
				,	[ObjectName]			= sch.name
				,	[ObjectTypeDescription] = ''SCHEMA''
				,	[ObjectType]			= ''SC''
				,	[ParentObjectId]		= 0
				,	[DropDefinition]		= ''DROP SCHEMA '' + QUOTENAME(sch.name) + '';''
				,	[ProcessOrder]			= 99
				FROM 
					sys.schemas AS sch
				WHERE
					sch.schema_id > 4 AND sch.schema_id < 16384
				AND
					sch.name = IIF(@SchemaName IS NULL, sch.name , @SchemaName)
			) 
			SELECT 
				[ObjectId]
			,	[SchemaName]
			,	[ObjectName]
			,	[ObjectType]
			,	[ProcessOrder]
			,	[DropDefinition]
			FROM 
				cte_combine
			ORDER BY 
				[ProcessOrder] ASC
			,	[ObjectType] ASC
			,	[SchemaName] ASC;

			OPEN @cursor_drop'

	
	SET @sql_parameter = '@SchemaName SYSNAME, @IsDropSchema BIT, @cursor_drop CURSOR OUTPUT';

	IF(@sql_debug = 1)
	BEGIN
		RAISERROR(@sql_statement, 0 ,1) WITH NOWAIT;
	END

	-- Not in a Execution Wrap
	EXEC sp_executesql @stmt = @sql_statement
	,	@param			= @sql_parameter
	,	@SchemaName		= @SchemaName
	,	@IsDropSchema	= @IsDropSchema
	,	@cursor_drop	= @cursor_drop OUTPUT



	FETCH NEXT FROM @cursor_drop 
	INTO 
		@sql_objectid		
	,	@sql_schemaname		
	,	@sql_objectname		
	,	@sql_objecttype		
	,	@sql_processorder	
	,	@sql_statement

	WHILE(@@FETCH_STATUS = 0)
	BEGIN
		
		IF(@sql_debug = 1)
		BEGIN
			PRINT(@sql_statement);
		END

		--IF(@sql_execute = 1)
		--BEGIN
		--EXEC [sp_executesql] 
		--	 @stmt = @sql_statement;
		--END

		FETCH NEXT FROM @cursor_drop 
		INTO 
			@sql_objectid		
		,	@sql_schemaname		
		,	@sql_objectname		
		,	@sql_objecttype		
		,	@sql_processorder	
		,	@sql_statement
	END;
	
END;
GO
