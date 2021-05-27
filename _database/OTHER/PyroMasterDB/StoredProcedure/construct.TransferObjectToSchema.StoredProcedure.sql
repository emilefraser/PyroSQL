SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[TransferObjectToSchema]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [construct].[TransferObjectToSchema] AS' 
END
GO


/*
	CREATED BY: 		Emile Fraser
	DATE: 			    2021-01-18
	DECSRIPTION: 	    Transfers all objects to another schema
	TODO:				Use the Object Type Inclusion and Exclusion Specifications
	
	EXECUTION:
						EXEC [tool].[TransferObjectToSchema] 
								@SourceSchemaName	= 'tool'
							,	@SourceObjectName	= 'printall'
							,	@TargetSchemaName	= 'printer'
*/
ALTER    PROCEDURE [construct].[TransferObjectToSchema]
	@SourceSchemaName		SYSNAME
,	@SourceObjectName		SYSNAME
,	@TargetSchemaName		SYSNAME
AS
BEGIN

	-- Variables for Proc Control
	DECLARE
		@sql_debug 			    BIT = 1
	,   @sql_execute 		    BIT = 1

	-- Dynamic Procedure Variables
	DECLARE
		@sql_statement 	    NVARCHAR(MAX)
	,	@sql_message 	    NVARCHAR(MAX)
	,   @sql_tab		    NVARCHAR(1) = CHAR(9)
	,	@sql_crlf 			NVARCHAR(2) = CHAR(13) + CHAR(10)
	
	-- Does Target Schema Exists ?
	IF NOT EXISTS (
		SELECT
			1
		FROM
			sys.schemas AS sch
		WHERE
			sch.name = @TargetSchemaName
	)
	BEGIN
		SET @sql_message = 'Target Schema does not exits'
		RAISERROR(@sql_message, 0, 1) WITH NOWAIT
		RETURN -1
	END

	-- Does source object already exists in Target
	IF EXISTS (
		SELECT
			1
		FROM
			sys.objects AS obj
		INNER JOIN
			sys.schemas AS sch
			ON sch.schema_id = obj.schema_id
		WHERE
			obj.name = @SourceObjectName
		AND
			sch.name = @TargetSchemaName
		AND
			obj.type in ('U', 'V', 'P', 'FN', 'IF', 'SO', 'R', 'SQ', 'X')
		AND
			obj.is_ms_shipped = 0
	)
	BEGIN
		SET @sql_message = 'The object already exists in the Target Schema'
		RAISERROR(@sql_message, 0, 1) WITH NOWAIT
		RETURN -1
	END

	-- Does Source object NOT Exists
	IF NOT EXISTS (
	SELECT
		1
	FROM
		sys.objects AS obj
	INNER JOIN
		sys.schemas AS sch
		ON sch.schema_id = obj.schema_id
	WHERE
		obj.name = @SourceObjectName
	AND
		sch.name = @SourceSchemaName
	AND
		obj.type in ('U', 'V', 'P', 'FN', 'IF', 'SO', 'R', 'SQ', 'X')
	AND
		obj.is_ms_shipped = 0
	) 
	BEGIN
		SET @sql_message = 'Source object does not exists in the Source Schema'
		RAISERROR(@sql_message, 0, 1) WITH NOWAIT
		RETURN -1
	END
	ELSE -- Do transfer
	BEGIN
		-- Dynamic statement generation
		SET @sql_statement = 'ALTER SCHEMA ' + QUOTENAME(@TargetSchemaName) + @sql_crlf +
							 'TRANSFER ' + QUOTENAME(@SourceSchemaName) + '.' + QUOTENAME(@SourceObjectName)  + ';' + @sql_crlf

		-- Debug Prints if flag on
		IF (@sql_debug = 1)
		BEGIN
			SET @sql_message = @sql_statement + @sql_crlf
			RAISERROR(@sql_message, 0, 1) WITH NOWAIT
		END

		-- Execute Part
		IF (@sql_execute = 1)
		BEGIN
			BEGIN TRY
				EXEC sp_executesql @stmt = @sql_statement
			END TRY
        
			BEGIN CATCH
				;THROW
			END CATCH
		END -- @sql-execute = 1
	END -- IF STATEMENT
	
END
GO
