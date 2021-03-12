SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tool].[TransferEntitiesToSchema]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [tool].[TransferEntitiesToSchema] AS' 
END
GO
-- EXEC tool.TransferEntitiesToSchema @SourceSchemaName = 'BP', @TargetSchemaName = 'temptr'
ALTER   PROCEDURE [tool].[TransferEntitiesToSchema]
	@SourceSchemaName SYSNAME
,	@TargetSchemaName SYSNAME
AS

BEGIN

	DECLARE 
		@sql_execute BIT = 1
	,	@sql_debug BIT = 1
	,	@sql_log BIT = 1
	,   @sql_rc INT = 0
	,	@sql_statement NVARCHAR(MAX)
	,	@sql_message NVARCHAR(MAX)
	,	@sql_crlf NVARCHAR(2) = CHAR(13) + CHAR(10)
	,	@cursor_exec CURSOR
	,	@entity_name SYSNAME
	,	@schema_name SYSNAME


    DECLARE @log TABLE (
		LogID			INT IDENTITY(1,1)
	,	StepAction		NVARCHAR(100)
	,	StepName		NVARCHAR(100)
	,	StepDefinition	NVARCHAR(MAX)
	,	StepResult		BIT
	,	StepMessage		NVARCHAR(MAX)
	)

	SET @cursor_exec = CURSOR FOR 
	SELECT 
		s.name
	,	o.name
	FROM 
		sys.objects AS o
	INNER JOIN 
		sys.schemas	AS s
		ON s.schema_id = o.schema_id 
	WHERE 
		s.name = @SourceSchemaName
	AND
		o.is_ms_shipped = 0
	AND
		o.type IN ('U', 'V')

	OPEN @cursor_exec
	FETCH NEXT FROM @cursor_exec
	INTO @schema_name, @entity_name

	WHILE(@@FETCH_STATUS = 0)
	BEGIN

		-- Insert the table into the Entity Lineage table 
		SET @sql_statement =  'ALTER SCHEMA' + QUOTENAME(@TargetSchemaName)  + @sql_crlf
		SET @sql_statement += 'TRANSFER ' + QUOTENAME(@SourceSchemaName) + '.' + QUOTENAME(@entity_name)  + @sql_crlf + @sql_crlf

			IF (@sql_debug = 1)
			BEGIN
				SET @sql_message = @sql_statement
				RAISERROR(@sql_message, 0, 1) WITH NOWAIT
			END

			IF (@sql_execute = 1)
			BEGIN
				BEGIN TRY
					EXEC @sql_rc = sp_executesql 
									@stmt = @sql_statement
					
					-- Write the successful transfer of an object to the log file
					IF (@sql_log = 1)
					BEGIN
						INSERT INTO @log (StepAction, StepName, StepDefinition, StepResult, StepMessage)
						SELECT 'TRANSFER', QUOTENAME(@schema_name) + '.' + QUOTENAME(@entity_name) , @sql_statement, @sql_rc, NULL
					END

				END TRY
				BEGIN CATCH
					-- Write the error in transfer of an object to the log file
					IF (@sql_log = 1)
					BEGIN
						INSERT INTO @log (StepAction, StepName, StepDefinition, StepResult, StepMessage)
						SELECT 'TRANSFER', QUOTENAME(@schema_name) + '.' + QUOTENAME(@entity_name) , @sql_statement, @sql_rc, ERROR_MESSAGE()
					END
				END CATCH
		END
		

	FETCH NEXT FROM @cursor_exec
	INTO @schema_name, @entity_name


	END

	SELECT * FROM @log

END
GO
