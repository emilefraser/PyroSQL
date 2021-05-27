SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[automate].[TransferObjectAllToSchema]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [automate].[TransferObjectAllToSchema] AS' 
END
GO

/*
	CREATED BY: 		Emile Fraser
	DATE: 			    2021-01-18
	DECSRIPTION: 	    Transfers all objects to another schema
	TODO:				Use the Object Type Inclusion and Exclusion Specifications
	
	EXECUTION:
					EXEC [automate].[TransferObjectAllToSchema] 
								@SourceSchemaName	= 'TEMPLATE'
							,	@TargetSchemaName	= 'templates'
							,	@ObjectTypeInclude	= NULL
							--,	@ObjectTypeExclude	= NULL
*/
ALTER   PROCEDURE [automate].[TransferObjectAllToSchema]
	@SourceSchemaName		SYSNAME
,	@TargetSchemaName		SYSNAME
,	@ObjectTypeInclude		NVARCHAR(MAX) = NULL
--,	@ObjectTypeExclude		NVARCHAR(MAX) = NULL
AS
BEGIN

	-- Preamble

	-- Variables for Proc Control
	DECLARE
		@sql_debug 			    BIT = 1
	,   @sql_execute 		    BIT = 1
	,	@sql_log  				TINYINT = 1  -- (0 =  no, 1 = yes, 2 = yes without drop)

	-- Dynamic Procedure Variables
	DECLARE
		@sql_statement 	    NVARCHAR(MAX)
	,	@sql_parameter 		NVARCHAR(MAX)
	,	@sql_message 	    NVARCHAR(MAX)
	,   @sql_tab		    NVARCHAR(1) = CHAR(9)
	,	@sql_crlf 			NVARCHAR(2) = CHAR(13) + CHAR(10)
	,	@cursor_exec 		CURSOR

	-- Optional RowCount Variable
	DECLARE
		@sql_rowcount       INT
	,   @sql_returncode     INT

	-- Time Parameters
	DECLARE
		 @sql_starttime         DATETIME2(7)
	,    @sql_endtime           DATETIME2(7)
	,    @sql_runtime_seconds   INT

	-- Optional string filters
	DECLARE
		@filter_include     NVARCHAR(MAX)
	,   @equality_include   NVARCHAR(MAX)
	,   @filter_exclude     NVARCHAR(MAX)
	,   @equality_exclude   NVARCHAR(MAX)

	-- Sql Variables used for object identification
	DECLARE
		 @servername		SYSNAME
	,    @databasename      SYSNAME
	,    @schemaname        SYSNAME
	,    @objectname		SYSNAME
	,    @objecttype	    SYSNAME
	,    @indexname		    SYSNAME
	,    @indextype			SYSNAME

	-- Log Variables
	DECLARE
		 @log_stepname             NVARCHAR(MAX)
	,    @log_stepdefinition       NVARCHAR(MAX)
	,    @log_stepparameter_out    NVARCHAR(MAX)
	,	 @log_parameter_out		   NVARCHAR(MAX)

	-- Need to log the steps
	--select @sql_log
	--IF (@sql_log != 0)
	--BEGIN

		-- Create Temp Logging table
		DECLARE @log TABLE (
				LogID					INT IDENTITY(1,1)
			,	StepName			    NVARCHAR(100)
			,	StepDefinition	        NVARCHAR(MAX)
			,	StepParameter_Out       NVARCHAR(MAX)
			,	StepReturnCode		    INT
			,   StepStartDT             DATETIME2(7)
			,   StepEndDT               DATETIME2(7)
			,   StepRunTime             INT
			,   StepErrorMessage        NVARCHAR(MAX)
		)

	--END

	-- Cursor declaration
	SET @cursor_exec = CURSOR LOCAL FAST_FORWARD FOR
	SELECT
		sch.name
	,	obj.name
	FROM
		sys.objects AS obj
	INNER JOIN
		sys.schemas AS sch
		ON sch.schema_id = obj.schema_id
	WHERE
		obj.name = IIF(@filter_include IS NULL, obj.name , @filter_include)
	AND
		sch.name = @SourceSchemaName
	AND
		obj.type in ('U', 'V', 'P', 'FN', 'IF', 'SO', 'R', 'SQ', 'X')
	AND
		obj.is_ms_shipped = 0

	-- Opening Cursor and Initial Fetch
	OPEN @cursor_exec

	FETCH NEXT FROM @cursor_exec
	INTO @schemaname, @objectname

	-- Cursor Loop
	WHILE(@@FETCH_STATUS = 0)
	BEGIN

		-- Initializes start time
		SET @sql_starttime = GETDATE()

		-- Dynamic statement generation
		SET @sql_statement = 'ALTER SCHEMA ' + QUOTENAME(@TargetSchemaName) + ' TRANSFER ' + QUOTENAME(@schemaname) + '.' + QUOTENAME(@objectname)  + ';' + @sql_crlf
		SET @sql_parameter = '@sql_rowcount INT OUTPUT'

		-- Debug Prints if flag on
		IF (@sql_debug = 1)
		BEGIN
			SET @sql_message = @sql_statement + @sql_crlf + '{{' + @sql_parameter + '}}'
			RAISERROR(@sql_message, 0, 1) WITH NOWAIT
		END

		-- Execute Part
		IF (@sql_execute = 1)
		BEGIN
			BEGIN TRY
				EXEC @sql_returncode = sp_executesql
							 @stmt           = @sql_statement
						  ,  @param          = @sql_parameter
						  ,  @sql_rowcount   = @sql_rowcount OUTPUT

				-- Log the result if flag specified
				IF (@sql_log != 0)
				BEGIN

					-- Log variables init
					SET @log_stepname         = CONCAT_WS('|', @schemaname, @objectname,  @indexname, '(' + @indextype + ')')
					SET @log_stepdefinition   = @sql_statement + '{{' + @sql_parameter + '}}'
					SET @log_parameter_out    = @sql_rowcount

					-- Deinitializes time
					SET @sql_endtime = GETDATE()
					SET @sql_runtime_seconds = DATEDIFF(SECOND, @sql_starttime, @sql_endtime)


					-- Logs success into @log
					INSERT INTO @log (
						  StepName
						, StepDefinition
						, StepParameter_Out
						, StepReturnCode
						, StepStartDT
						, StepEndDT
						, StepRunTime
						, StepErrorMessage
					)
					SELECT 
						  @log_stepname
					,     @log_stepdefinition
					,     @log_stepparameter_out
					,     @sql_returncode
					,     @sql_starttime
					,     @sql_endtime
					,     @sql_runtime_seconds
					, NULL
				END
			END TRY
        
			BEGIN CATCH
        
				-- Debug Prints if flag on
				IF (@sql_debug = 1)
				BEGIN
					SET @sql_message = ERROR_MESSAGE() + @sql_crlf
					RAISERROR(@sql_message, 0, 1) WITH NOWAIT
				END
        
        
				-- Logs failure
				IF (@sql_log != 0)
				BEGIN

					-- Log variables init
					SET @log_stepname          = CONCAT_WS('|', @schemaname, @objectname,  @indexname, '(' + @indextype + ')')
					SET @log_stepdefinition    = @sql_statement + '{{' + @sql_parameter + '}}'
					SET @log_parameter_out     = @sql_rowcount

					-- Deinitializes time
					SET @sql_endtime = GETDATE()
					SET @sql_runtime_seconds = DATEDIFF(SECOND, @sql_starttime, @sql_endtime)

					-- Logs failure into @log
					INSERT INTO @log (
						  StepName
						, StepDefinition
						, StepParameter_Out
						, StepReturnCode
						, StepStartDT
						, StepEndDT
						, StepRunTime
						, StepErrorMessage
					)
					SELECT 
						  @log_stepname
					,     @log_stepdefinition
					,     @log_stepparameter_out
					,     @sql_returncode
					,     @sql_starttime
					,     @sql_endtime
					,     @sql_runtime_seconds
					,     ERROR_MESSAGE()

				  END

			END CATCH

	-- Feches next from cursor
	FETCH NEXT FROM @cursor_exec
	INTO @schemaname, @objectname

	END


	END
	
	-- Selects value to screen
	IF (@sql_log != 0)
	BEGIN
		SELECT * FROM @log
	END

END
GO
