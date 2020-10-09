SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:		Frans Germishuizen
-- Create date: 2019-04-15
-- Description:	Insert a log entry into the ETL.ExecutionLog_StoredProcedures table
-- =============================================
CREATE PROCEDURE [ETL].[sp_insert_ExecutionLog] 
	@DatabaseName varchar(100)
	,@SchemaName varchar(100)
	--,@StoredProcedureName varchar(500)-- = NULL
	,@swStart_FinishLogEntry int --This is to determine if the log entry is being started or finished when calling the stored procedure
	,@ExecutionLogID_In int-- = NULL -- The execution log entry that is passed in to update when it is finished executing
	,@ExecutionLogID_Out int OUTPUT
	,@LoadConfigID int
	,@QueuedForProcessingDT datetime2(7) = NULL
	,@IsReload bit --null
	,@ErrorMessage varchar(500) = NULL
	,@DataEntityName varchar(100)
	--,@SourceRowCount int = null
	--,@TargetRowCount int = null
	,@NewRowCount BIGINT = null
	,@IsError BIT  = NULL
	,@ErrorNumber  INT = NULL
    ,@ErrorSeverity  INT = NULL
    ,@ErrorState  INT = NULL
    ,@ErrorLine  INT = NULL
	,@LastProcessingKeyValue varchar(max) = NULL
	,@DeletedRowCount BIGINT = null
	,@SourceRowCount BIGINT = null
	,@SourceTableSizeBytes BIGINT = null
	,@TargetRowCount BIGINT = null
	,@TargetTableSizeBytes BIGINT = null
	,@UpdatedRowBytes BIGINT = null
	,@UpdatedRowCount BIGINT = null
	,@NewRowsBytes BIGINT = null
	,@RowsTransferred BIGINT = null
	,@InitialTargetRowCount BIGINT = null
	,@InitialTargetTableSizeBytes BIGINT = null
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRANSACTION

--WS: Code to log when a load failed
DECLARE @ERRORVAR INT
DECLARE @ERRORSTRING VARCHAR(50)
DECLARE @ExecutionLogID_return TABLE (ExecutionLogID INT)

DECLARE @LoadType VARCHAR(50)

SET @ERRORVAR = (
					SELECT 
						COUNT(*) 
					FROM 
						etl.vw_mat_ExecutionLogSteps
					WHERE 
						LOWER([Action]) LIKE '%error%' 
					AND 
						[Execution Log ID] = @ExecutionLogID_Out 
				)

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
						  ,[QueuedForProcessingDT]
						  ,[StartDT]
						  ,[LastProcessingKeyValue]
						  ,[IsReload]
						  ,[Result]
						  ,[ErrorMessage]
						  ,[ErrorNumber]
						  ,[ErrorSeverity] 
						  ,[ErrorState]  
						  ,[ErrorLine]  
						  ,[DataEntityname]
						  ,[IsLastRunOfConfigID]
						  )
				OUTPUT 
					INSERTED.ExecutionLogID INTO @ExecutionLogID_return
				 VALUES
					   (   
						    @LoadConfigID
						  , @DatabaseName
						  , @SchemaName
						  , @QueuedForProcessingDT
						  , @StartDT
						  , @LastProcessingKeyValue
						  , @IsReload
						  , @ERRORSTRING --ws
						  , @ErrorMessage						  
						  , @ErrorNumber
						  , @ErrorSeverity
						  , @ErrorState
						  , @ErrorLine
						  , @DataEntityName
						  , 1
						)
				
	
			-- EF CHANGE TO get the OUTPUT paramater of this proc to keep it properly scoped
			SET @ExecutionLogID_Out = (SELECT ExecutionLogID FROM @ExecutionLogID_return)

			--Insert log entry into the Analytics table
			INSERT INTO [ETL].[ExecutionLogAnalysis]
			   ([ExecutionLogID])
			VALUES (
			    @ExecutionLogID_Out
			)

			-- Update the IsLastRunForConfigID for this specific LoadConfigID to 0 for allother loadconfigs
			-- EF: Used in the PBI Report to identify LastLoad 
			UPDATE 
				el
			SET
				el.IsLastRunOfConfigID = 0
			FROM
				[ETL].[ExecutionLog] AS el
			WHERE
				el.ExecutionLogID != @ExecutionLogID_Out
			AND
				el.LoadConfigID = @LoadConfigID
			AND
				el.IsLastRunOfConfigID = 1

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
						, ErrorMessage = @ErrorMessage
						  ,[ErrorNumber] = @ErrorNumber
						  ,[ErrorSeverity] = @ErrorSeverity
						  ,[ErrorState]  = @ErrorState
						  ,[ErrorLine]  = @ErrorLine
                        , TargetTableSizeBytes  = @TargetTableSizeBytes
                        , UpdatedRowBytes  = @UpdatedRowBytes
                        , UpdatedRowCount  = @UpdatedRowCount
                        , NewRowsBytes  = @NewRowsBytes
	                    , InitialTargetRowCount = @InitialTargetRowCount 
	                    , InitialTargetTableSizeBytes = @InitialTargetTableSizeBytes 
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
