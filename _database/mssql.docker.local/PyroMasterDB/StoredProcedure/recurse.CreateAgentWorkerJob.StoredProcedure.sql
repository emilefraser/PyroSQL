SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[recurse].[CreateAgentWorkerJob]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [recurse].[CreateAgentWorkerJob] AS' 
END
GO
/*
	EXEC [recurse].[CreateAgentWorkerJob] 
						@AgentWorkerJobName				= 'TestAsyncRecursion'
					,	@AgentWorkerJobCount			= 4
					,	@AgentWorkerExecutionDefinition = '[PyroMasterDB].[recurse].[CursorExampleWithLoadLock] @Top = |>BATCHSIZE<|'
					,	@AgentWorkerBatchSize			= 100
					,	@AgentWorkerCompletionTest		='[recurse].[AssertTestRecursionComplete]()'
*/

ALTER   PROCEDURE [recurse].[CreateAgentWorkerJob] 
									@AgentWorkerJobName					SYSNAME
								,	@AgentWorkerJobCount				SMALLINT		= 1
								,	@AgentWorkerExecutionDefinition		NVARCHAR(MAX)
								,	@AgentWorkerBatchSize				INT				= NULL
								,	@AgentWorkerCompletionTest			NVARCHAR(MAX)	= NULL
AS 
BEGIN
	
	DECLARE 
		@sql_execute			BIT = 1
	,	@sql_debug				BIT = 1
	,	@sql_log				BIT
	,	@sql_statement			NVARCHAR(MAX)
	,	@sql_parameter			NVARCHAR(MAX)
	,	@sql_message			NVARCHAR(MAX)
	,	@sql_crlf				NVARCHAR(2) = CHAR(13) + CHAR(10)
	,	@cursor_exec			CURSOR

	DECLARE 
		@procedure_name		SYSNAME
	,	@job_name			SYSNAME
	,	@job_n				SMALLINT
	,	@job_id				UNIQUEIDENTIFIER
	,	@job_definition		NVARCHAR(MAX)
	,	@step_name			SYSNAME
	
	-- Spin up to a maximum of 8 workers
	IF (@AgentWorkerJobCount > 8)
	BEGIN
		SET @AgentWorkerJobCount = 8
	END

	-- If Batch Sizes specified, use them
	IF (@AgentWorkerBatchSize IS NOT NULL)
	BEGIN
		SET @AgentWorkerExecutionDefinition = REPLACE(@AgentWorkerExecutionDefinition, '|>BATCHSIZE<|', @AgentWorkerBatchSize)
	END

	--RAISERROR(@AgentWorkerExecutionDefinition, 0, 1) WITH NOWAIT

	-- Create jobs iteratively
	SET @job_n = 1
	WHILE (@job_n <= @AgentWorkerJobCount)
	BEGIN

		-- Sets a unique worker job name
		SET @job_name = CONCAT(@AgentWorkerJobName, '__', @job_n)
		--SELECT @job_name

		-- Deletes the worker job if eixts
		IF EXISTS (
			SELECT 
				1 
			FROM 
				msdb.dbo.sysjobs
			WHERE 
				name = @job_name
		)
		BEGIN
			EXEC msdb.dbo.sp_delete_job 
							@job_name = @job_name
		END

		-- Adds the worker jobs
		EXEC msdb.dbo.sp_add_job
					@job_name = @job_name
				,	@enabled  = 1
			--	,	@job_id   = @job_id OUTPUT

		SET @job_id = (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = @job_name)

		-- Checks whether the job has completion criteria/test
		-- If so, loop until complete
		--SELECT @AgentWorkerCompletionTest
		IF(ISNULL(@AgentWorkerCompletionTest, '') != '')
		BEGIN
			SET @job_definition  = 'WHILE (' + @AgentWorkerCompletionTest + ' = 0) ' + @sql_crlf +
								  'BEGIN' + @sql_crlf
			SET @job_definition += CONCAT('EXECUTE ' , @AgentWorkerExecutionDefinition , ' @AgentJobId = ''' , 
										@job_id , ''';' , @sql_crlf )
			SET @job_definition += 'END'

		END
		ELSE
		BEGIN
			SET @job_definition = CONCAT('EXECUTE ',  @AgentWorkerExecutionDefinition , ' @AgentJobId = ''' ,
										@job_id , ''';')
		END

		--RAISERROR(@AgentWorkerExecutionDefinition, 0, 1) WITH NOWAIT
	
		-- Adds the Worker Agent Step
		SET @step_name = CONCAT(@job_name, '__', 'Step')
		--SELECT @step_name

		EXEC msdb.dbo.sp_add_jobstep 
					@job_name			= @job_name
				,	@step_name			= @step_name
				,	@subsystem			= N'TSQL'
				,	@command			= @job_definition
				,	@retry_attempts		= 1
				,	@retry_interval		= 1
				,	@on_success_action  = 1
				,	@on_fail_action     = 2

		-- Goes to the next worker job
		SET @job_n += 1
	END
END	
	
GO
