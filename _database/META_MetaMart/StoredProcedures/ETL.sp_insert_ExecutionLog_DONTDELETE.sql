SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON




-- =============================================
-- Author:		Frans Germishuizen
-- Create date: 2019-04-15
-- Description:	Insert a log entry into the ETL.ExecutionLog_StoredProcedures table
-- =============================================
CREATE PROCEDURE [ETL].[sp_insert_ExecutionLog_DONTDELETE] 
	@DatabaseName varchar(100)
	,@SchemaName varchar(100)
	--,@StoredProcedureName varchar(500)-- = NULL
	,@swStart_FinishLogEntry int --This is to determine if the log entry is being started or finished when calling the stored procedure
	,@ExecutionLogID_In int-- = NULL -- The execution log entry that is passed in to update when it is finished executing
	,@ExecutionLogID_Out int OUTPUT

	,@LoadConfigID int
	,@QueuedForProcessingDT datetime2(7)
	--,@LastProcessingKeyValue varchar(500)  --null TODO:Update Based on control log
	,@IsReload bit --null
	,@ErrorMessage varchar(500) --null
	,@DataEntityName varchar(100)
	--,@SourceRowCount int = null
	--,@TargetRowCount int = null
	,@NewRowCount int = null
	,@IsError int = null
	,@LastProcessingKeyValue varchar(max) 
	,@DeletedRowCount int = null
	,@SourceRowCount int = null
	,@SourceTableSizeBytes int = null
	,@TargetRowCount int = null
	,@TargetTableSizeBytes int = null
	,@UpdatedRowBytes int = null
	,@UpdatedRowCount int = null
	,@NewRowsBytes int = null
	,@RowsTransferred int = null
	,@InitialTargetRowCount int = null
	,@InitialTargetTableSizeBytes int = null



AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRANSACTION

--WS: Code to log when a load failed
DECLARE @ERRORVAR INT
DECLARE @ERRORSTRING VARCHAR(50)

DECLARE @LoadType VARCHAR(50)

SET @ERRORVAR = (SELECT COUNT(*) 
				 FROM etl.vw_mat_ExecutionLogSteps
				 where [Action] LIKE '%error%' and [Execution Log ID] = @ExecutionLogID_Out /*stick dynamic here*/ )

--SET @LoadType = (SELECT LoadType FROM ETL.LoadConfig WHERE LoadConfigID = @LoadConfigID)

IF @ERRORVAR != 0 OR @IsError = 1
BEGIN
  SET @ERRORSTRING = 'Execution Failed'
END
ELSE IF @swStart_FinishLogEntry = 1	
BEGIN
 SET @ERRORSTRING = 'Execution In Progress'
END
ELSE 
BEGIN
 SET @ERRORSTRING = 'Execution Finished'
END
--END OF WS CODE



	IF @swStart_FinishLogEntry = 1
		BEGIN
			DECLARE @StartDT datetime2(7) = CONVERT(datetime2(7), GETDATE())

			--Insert entry to start the execution of the stored procedure and to generate the ExecutionLogID
			INSERT INTO [ETL].[ExecutionLog]
					      (
						   [LoadConfigID]
						  ,[DatabaseName]
						  ,[SchemaName]
						 -- ,[StoredProcedureName]
						  ,[QueuedForProcessingDT]
						  ,[StartDT]
						  ,[LastProcessingKeyValue]
						  ,[IsReload]
						  ,[Result]
						  ,[ErrorMessage]
						  ,[DataEntityname])
						 -- ,[LoadType])
				 VALUES
					   (   
						   @LoadConfigID  -- replace with what was orignally here
						  ,@DatabaseName
						  ,@SchemaName
						 -- ,@StoredProcedureName
						  ,@QueuedForProcessingDT
						  ,@StartDT
						  ,@LastProcessingKeyValue
						  ,@IsReload
						  ,@ERRORSTRING --ws
						  ,@ErrorMessage
						  ,@DataEntityName)
						 -- ,@LoadType)
	
			--Get the ExecutionLogID to be used in the [ETL].[ExecutionLogStep_StoredProcedure] sp
			SELECT @ExecutionLogID_Out = @@IDENTITY

			--Insert log entry into the Analytics table
			INSERT INTO [ETL].[ExecutionLogAnalysis]
			   ([ExecutionLogID])
			VALUES (
			    @ExecutionLogID_Out
			)

		END
		ELSE 
			BEGIN

				DECLARE @FinishDT datetime2(7) = CONVERT(datetime2(7), GETDATE())

				UPDATE	[ETL].[ExecutionLog]
				SET		FinishDT = @FinishDT
						, Result = @ERRORSTRING --ws
						, RowsTransferred = @RowsTransferred
						, SourceRowCount = @SourceRowCount
						, TargetRowCount = @TargetRowCount
	                    , NewRowCount  = @NewRowCount
                        , DeletedRowCount  = @DeletedRowCount
                        , SourceTableSizeBytes  = @SourceTableSizeBytes
                        , IsError  = @IsError
                        , TargetTableSizeBytes  = @TargetTableSizeBytes
                        , UpdatedRowBytes  = @UpdatedRowBytes
                        , UpdatedRowCount  = @UpdatedRowCount
                        , NewRowsBytes  = @NewRowsBytes
	                    ,InitialTargetRowCount = @InitialTargetRowCount 
	                    ,InitialTargetTableSizeBytes = @InitialTargetTableSizeBytes 
				WHERE	ExecutionLogID = @ExecutionLogID_In --Wrong code: (Select MAX(ExecutionLogID) from  [ETL].[ExecutionLog])

				--Calculate Analysis for this log entry
				UPDATE	a
				SET		[DurationSeconds] = DATEDIFF(SECOND, [log].StartDT, [log].FinishDT)
						,[QueueSeconds] = DATEDIFF(SECOND, [log].QueuedForProcessingDT, [log].StartDT)
						,[TotalExecutionTime] = DATEDIFF(SECOND, [log].QueuedForProcessingDT, [log].FinishDT)
						,[IsDataIntegrityError] = CASE WHEN [log].SourceRowCount != [log].TargetRowCount THEN 1 ELSE 0 END
				FROM	[ETL].[ExecutionLogAnalysis] a
						INNER JOIN [ETL].[ExecutionLog] AS [log] ON
							[log].ExecutionLogID = a.ExecutionLogID
				WHERE	[log].ExecutionLogID = @ExecutionLogID_In

			END
	COMMIT TRANSACTION
END

GO
