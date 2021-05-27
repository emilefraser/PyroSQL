SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[automate].[TransferListObjectToSchema]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [automate].[TransferListObjectToSchema] AS' 
END
GO

/*
	CREATED BY: 		Emile Fraser
	DATE: 			    2021-01-18
	DECSRIPTION: 	    Transfers all objects to another schema
	TODO:				Use the Object Type Inclusion and Exclusion Specifications
	
	drop schema MASTERDATA
	EXECUTION:
		EXEC [tool].[TransferListObjectToSchema]
							@SourceObjectHeader		= 'schemaname.objectname'
						,	@SourceObjectList 		= 'tool.TruncateSchema|tool.TransferEntitiesToSchema'
						,	@TargetSchemaName		= 'automate'
*/
ALTER   PROCEDURE [automate].[TransferListObjectToSchema]
	@SourceObjectHeader		NVARCHAR(MAX)
,	@SourceObjectList 		NVARCHAR(MAX)
,	@TargetSchemaName		SYSNAME
AS
BEGIN
	-- Variables for Proc Control
	DECLARE
		@sql_debug 			    BIT = 1
	,   @sql_execute 		    BIT = 1

	DECLARE
		@SourceHeaderAndValuesList	NVARCHAR(MAX)	 = @SourceObjectHeader + '|' + @SourceObjectList
	,	@EndOfLineCharcter			CHAR			= '|'

	-- Dynamic Procedure Variables
	DECLARE
		@sql_statement 	    NVARCHAR(MAX)
	,	@sql_parameter 		NVARCHAR(MAX)
	,	@sql_message 	    NVARCHAR(MAX)
	,   @sql_tab		    NVARCHAR(1) = CHAR(9)
	,	@sql_crlf 			NVARCHAR(2) = CHAR(13) + CHAR(10)
	,	@cursor_object		CURSOR

	-- Dyna params
	DECLARE
		@schemaname	SYSNAME
	,	@objectname	SYSNAME

	EXEC [string].[SplitStringIntoTable]
				@StringToSplit			= @SourceHeaderAndValuesList
			,	@EndOfLineCharcter		= @EndOfLineCharcter
			,	@cursor_table			= @cursor_object OUTPUT

	FETCH NEXT FROM @cursor_object
	INTO @schemaname, @objectname

	-- Cursor Loop
	WHILE(@@FETCH_STATUS = 0)
	BEGIN
		-- Dynamic statement generation
		SET @sql_statement = 'ALTER SCHEMA ' + QUOTENAME(@TargetSchemaName) + ' TRANSFER ' + QUOTENAME(@schemaname) + '.' + QUOTENAME(@objectname)  + ';' + @sql_crlf
		
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
				EXEC sp_executesql @stmt  = @sql_statement
			END TRY
			BEGIN CATCH
				;THROW
			END CATCH
		END -- IF

		-- Feches next from cursor
		FETCH NEXT FROM @cursor_object
		INTO @schemaname, @objectname

	END -- WHILE 
END -- BEGIN
GO
