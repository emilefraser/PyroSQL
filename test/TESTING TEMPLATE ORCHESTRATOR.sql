SET STATISTICS TIME ON
GO
SET STATISTICS IO ON 
GO
--SET SHOWPLAN_ALL ON
---- XML?
--GO

USE [PERFORMANCE]
GO

CREATE OR ALTER PROCEDURE PERFTEST.sp_Execute_TestOrchestrator
	@TestClass				SYSNAME,
	@TestName				VARCHAR(255),
	@TestIterationName		VARCHAR(255),
	@SourceObject			SYSNAME,
	@TargetObject			SYSNAME = NULL,
	@IsReloadTestData		BIT = 0,
	@TestRowsNeeded			INT = 1000,
	@IterationCount			INT = 1,
	@IsTruncateRunLogs		BIT = 0,
	@IsDebug				BIT = 0,
	@sql_params				NVARCHAR(MAX) = '',
	@sql_declare			NVARCHAR(MAX) = '',
	@sql_values				NVARCHAR(MAX) = ''
AS
BEGIN
	SET NOCOUNT ON;

	-- DynaSQL Declarations
	DECLARE   @sql_statement NVARCHAR(MAX)
			, @sql_message NVARCHAR(MAX)

	-- Orchestrators varaiables
	DECLARE
		@CurrentIteration INT,
		@LogID INT,
		@c CURSOR,
		@TargetData_Rows INT,
		@EndTime DATETIME2(7)

	IF(@IsTruncateRunLogs = 1)
	BEGIN
		TRUNCATE TABLE PERFTEST.RunTimeLog
		TRUNCATE TABLE PERFTEST.MetricsLog
		
		IF(@IsDebug = 1)
		BEGIN
			SET @sql_message = 'TRUNCATED TABLES : PERFTEST.RunTimeLog and PERFTEST.MetricsLog.'
			RAISERROR(@sql_message, 0 , 1) WITH NOWAIT
		END
	END
	
	-- Get all Metadata Needed for Logging
	DECLARE @TestProcedureName VARCHAR(MAX) = QUOTENAME(@TestClass) + '.' + QUOTENAME('sp_' + @TestName + '__' + @TestIterationName)
	DECLARE @TestDefinition NVARCHAR(MAX) = (SELECT PERFTEST.udf_Get_ObjectDefinition(@TestProcedureName, NULL))

	-- Determine if Test Data Needs to be recreated
	--IF(@IsReloadTestData = 1)
	--BEGIN
	--	EXEC PERFTEST.sp_Create_TestDataInSource	
	--			@SourceObject = @SourceObject
	--		,	@TestRowsNeeded =@TestRowsNeeded

		--	IF(@IsDebug = 1)
		--BEGIN
		--	SET @sql_message = 'TRUNCATED TABLES : PERFTEST.RunTimeLog and PERFTEST.MetricsLog'
		--END
	--END

	DECLARE @SourceData_Rows INT = (SELECT PERFTEST.udf_Get_TableRowCount(@SourceObject))
	IF(@IsDebug = 1)
	BEGIN
		SET @sql_message = 'Source Row Count on ' + @SourceObject + ' is ' + CONVERT(VARCHAR, @SourceData_Rows) + ' rows.'
		RAISERROR(@sql_message, 0 , 1) WITH NOWAIT
	END
 
	-- Clean Everything before Runnign Procedures
	IF(@TargetObject IS NOT NULL)
	BEGIN
		EXEC PERFTEST.sp_Execute_Cleanup 
				@TargetObject = @TargetObject

		SET @sql_message = 'Target Object ' + @TargetObject + ' has been cleard.'
		RAISERROR(@sql_message, 0 , 1) WITH NOWAIT
	END

	DECLARE @TestRunNumber INT = (SELECT MAX(TestRunNumber) FROM PERFTEST.RunTimeLog 
	WHERE TestClass = @TestClass
	AND TestName = @TestName AND TestIterationName = @TestIterationName)

	IF(@TestRunNumber IS NULL)
	BEGIN
		SET @TestRunNumber = 1
	END

	SET @sql_message = 'Test Run Number of  ' + CONVERT(VARCHAR, @TestRunNumber) + ' assigned to ' + @TestClass + '.' + @TestName + '.' + @TestIterationName
	RAISERROR(@sql_message, 0 , 1) WITH NOWAIT

	-- START TEST

	SET @sql_message = 'Test Starting .... ' + CONVERT(VARCHAR, @IterationCount) + ' scheduled.'
	RAISERROR(@sql_message, 0 , 1) WITH NOWAIT

	SET @c = CURSOR FORWARD_ONLY LOCAL STATIC FORWARD_ONLY READ_ONLY
		FOR
			SELECT n FROM PERFTEST.Numbers
			WHERE n BETWEEN 1 AND @IterationCount
 
	OPEN @c
 
	FETCH NEXT FROM @c INTO @CurrentIteration
 
	WHILE @@FETCH_STATUS = 0
	BEGIN

			-- INSERT INTIAL LOGID AND KEEP LOG ID FOR FUTHER UPDATES
			INSERT PERFTEST.RunTimeLog(
				Spid
			,	TestClass
			,	TestName
			,	TestIterationName
			,	TestRunNumber
			,	SourceObject
			,	SourceRows
			,	TargetObject
			,	TestDefinition
			,	StartDate
			)
				SELECT
				  @@SPID
				, @TestClass
				, @TestName
				, @TestIterationName
				, @TestRunNumber
				, @SourceObject
				, @SourceData_Rows
				, @TargetObject
				, @TestDefinition
				, GETDATE()
 
			-- GET AND KEEP LOGID
			SET @LogID = SCOPE_IDENTITY();

			SET @sql_message = 'Log Id of ' + CONVERT(VARCHAR, @LogID) + ' creatd in PERFTEST.RunTimeLog.'
			RAISERROR(@sql_message, 0 , 1) WITH NOWAIT


				BEGIN TRANSACTION
				

					SET @sql_statement = N'EXEC ' + @TestProcedureName + ' ' + @sql_params
										
					SET @sql_message = 'Executing the following code: ' + CHAR(13)
					SET @sql_message += 'Statement: ' + @sql_statement + CHAR(13)
					SET @sql_message += 'Params: ' + @sql_declare + CHAR(13)
					SET @sql_message += 'Param Values: ' + @sql_values + CHAR(13)
					RAISERROR(@sql_message, 0 , 1) WITH NOWAIT

					EXEC sp_executeSQL @sql_statement, @sql_declare, @Today = '11/12/2019', @IsReload = 0, @IsTest = 0
					--, @sql_values
				
					IF @@ERROR <> 0
					BEGIN
						ROLLBACK TRANSACTION
					END
					ELSE
					BEGIN
						COMMIT TRANSACTION
					END

					-- GET STATS AFTER PROC DONE
					SET @EndTime = SYSUTCDATETIME()
					SET @TargetData_Rows = (SELECT PERFTEST.udf_Get_TableRowCount(@TargetObject))

					
					SET @sql_message = 'Test completed and' + CONVERT(VARCHAR, @TargetData_Rows) + ' rows were transferred.'
					RAISERROR(@sql_message, 0 , 1) WITH NOWAIT

					-- update the log entry
					UPDATE 
						PERFTEST.RunTimeLog 
					SET 
						EndDate = @EndTime
					,	TargetRows = @TargetData_Rows
					WHERE 
						LogID = @LogID

					SET @sql_message = 'RunTimeLog Updated with RowCount and EndTime'
					RAISERROR(@sql_message, 0 , 1) WITH NOWAIT

					-- NOW AND WRITE THE QUERY STATS AND WRITE TO MetricLog
					EXEC [PERFTEST].[sp_Update_MetricsLog] @LogID

					SET @sql_message = 'Metrics Log Updated'
					RAISERROR(@sql_message, 0 , 1) WITH NOWAIT

					SET @sql_message = 'RUN ' + CONVERT(VARCHAR, @CurrentIteration) + ' COMPLETED SUCCESSFULLY'
					RAISERROR(@sql_message, 0 , 1) WITH NOWAIT
		
		FETCH NEXT FROM @c INTO @CurrentIteration
					
		END

		SET @sql_message = 'TEST FOR ITERATION ' + @TestClass + '.' + @TestName + '.' + @TestIterationName + ' COMPLETED SUCCESSFULLY'
		RAISERROR(@sql_message, 0 , 1) WITH NOWAIT
 END

-- SET ALL GATHERERS AS OFF
SET STATISTICS TIME OFF
GO
SET STATISTICS IO OFF 
GO
SET SHOWPLAN_ALL OFF
GO