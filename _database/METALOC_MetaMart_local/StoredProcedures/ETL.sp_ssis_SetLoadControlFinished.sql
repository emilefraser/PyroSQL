SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =============================================
-- Author:		Karl Dinkelmann
-- Create date: 31 Oct 2018
-- Description:	Logs the completion of processing of a load.
-- =============================================
CREATE PROCEDURE [ETL].[sp_ssis_SetLoadControlFinished]
	@LoadControlID INT,
	@LastProcessingKeyValue VARCHAR(50) = NULL,
	@NewRowCount INT,
	@UpdateRowCount INT = NULL,
	@DeleteRowCount INT = NULL,
	@NewRowBytes INT,
	@UpdatedRowBytes INT = NULL,
	@IsError BIT,
	@ErrorMessage VARCHAR(4000) = NULL,
	@ExecutionLogID INT,              
	@AffectedDatabaseName VARCHAR(100),
	@AffectedSchemaName VARCHAR(100),
	@AffectedDataEntityName VARCHAR(100)
	
AS

DECLARE @Today DATETIME2(7) = GETDATE()

--As the load has now completed, create an entry in the LoadControlLog

INSERT INTO [ETL].[LoadControlLog]
           ([LoadControlID]
           ,[QueuedForProcessingDT]
           ,[ProcessingStartDT]
           ,[ProcessingFinishedDT]
           ,[LastProcessingKeyValue]
           ,[NewRowCount]
           ,[UpdatedRowCount]
		   ,[DeletedRowCount]
           ,[NewRowBytes]
           ,[UpdatedRowBytes]
		   ,[IsReload]
           ,[IsError]
           ,[ErrorMessage])
SELECT [control].LoadControlID,
	   [control].QueuedForProcessingDT,
	   [control].ProcessingStartDT,
	   @Today AS ProcessingFinishedDT,
	   @LastProcessingKeyValue AS [LastProcessingKeyValue],
	   @NewRowCount AS [NewRowCount],
	   @UpdateRowCount AS [UpdatedRowCount],
	   @DeleteRowCount AS [DeletedRowCount],
	   @NewRowBytes AS [NewRowBytes],
	   @UpdatedRowBytes AS [UpdatedRowBytes],
	   [config].IsSetForReloadOnNextRun,
	   @IsError AS [IsError],
	   @ErrorMessage AS [ErrorMessage]
  FROM ETL.LoadControl [control]
	   INNER JOIN ETL.LoadConfig [config] ON
			[config].LoadConfigID = [control].LoadConfigID
 WHERE [control].LoadControlID = @LoadControlID
 
 --********************** START LOGGING****************
   DECLARE @Startlogtime DATETIME2(7) = GETDATE()
--********************** START LOGGING*****************

--Set the end of the load in the control table
UPDATE [control]
   SET ProcessingFinishedDT = @Today,
	   QueuedForProcessingDT = NULL,
	   ProcessingState = 'Idle',
	   LastProcessingPrimaryKey = CASE WHEN [config].NewDataFilterType = 'PrimaryKey' THEN @LastProcessingKeyValue ELSE NULL END,
	   LastProcessingTransactionNo = CASE WHEN [config].NewDataFilterType = 'TransactionNo' THEN @LastProcessingKeyValue ELSE NULL END,
	   IsLastRunFailed = CASE WHEN @IsError = 1 THEN 1 ELSE 0 END
  FROM ETL.LoadControl [control]
	   INNER JOIN ETL.LoadConfig [config] ON
			[config].LoadConfigID = [control].LoadConfigID
 WHERE [control].LoadControlID = @LoadControlID

 --*********************** END LOGGING ****************
DECLARE @Finishlogtime DATETIME2(7) = GETDATE()
DECLARE @Durationsec INT = DATEDIFF(second, @Startlogtime, @Finishlogtime)

EXECUTE ETL.sp_insert_ExecutionLogSteps
 @ExecutionLogID = @ExecutionLogID
 ,@StepDescription = 'End of the load is recorded'
 ,@AffectedDatabaseName = 'DataManager_Local'
 ,@AffectedSchemaName = 'ETL'
 ,@AffectedDataEntityName = 'LoadControl'
 ,@ActionPerformed = 'Update'
 ,@StartDT = @Startlogtime
 ,@FinishDT = @Finishlogtime
 ,@DurationSeconds = @Durationsec
 ,@AffectedRecordCount = 0
 ,@ExecutionStepNo = 1000 --To increment in stored proc
 --********************* END LOGGING ********************


 --********************** START LOGGING****************
  SET @Startlogtime = GETDATE()
--********************** START LOGGING*****************

--Set the IsSetForReloadOnNextRun to 0 if it was 1
UPDATE [config]
   SET IsSetForReloadOnNextRun = 0
  FROM ETL.LoadConfig [config]
 WHERE [config].LoadConfigID = @LoadControlID AND
	   [config].IsSetForReloadOnNextRun = 1

--*********************** END LOGGING ****************
SET @Finishlogtime  = GETDATE()
SET @Durationsec = DATEDIFF(second, @Startlogtime, @Finishlogtime)

EXECUTE ETL.sp_insert_ExecutionLogSteps
 @ExecutionLogID = @ExecutionLogID
 ,@StepDescription = 'IsSetForReloadOnNextRun set to 0'
 ,@AffectedDatabaseName = 'DataManager_Local'
 ,@AffectedSchemaName = 'ETL'
 ,@AffectedDataEntityName = 'LoadConfig'
 ,@ActionPerformed = 'Update'
 ,@StartDT = @Startlogtime
 ,@FinishDT = @Finishlogtime
 ,@DurationSeconds = @Durationsec
 ,@AffectedRecordCount = 0
 ,@ExecutionStepNo = 1000 --To increment in stored proc
 --********************* END LOGGING ********************

--Log the completion of the load in the control table
INSERT INTO [ETL].[LoadControlEventLog]
           ([LoadControlID]
           ,[EventDT]
           ,[EventDescription]
           ,[ErrorMessage])
VALUES (	@LoadControlID,	
			@Today,
			CASE WHEN ISNULL(@IsError, 0) = 0 THEN 'Load completed' ELSE 'Load error' END,
			@ErrorMessage)

/*

--********************** START LOGGING****************
   DECLARE @Startlogtime DATETIME2(7) = GETDATE()
--********************** START LOGGING****************




--*********************** END LOGGING ****************
DECLARE @Finishlogtime DATETIME2(7) = GETDATE()
DECLARE @Durationsec INT = DATEDIFF(second, @Startlogtime, @Finishlogtime)

EXECUTE ETL.sp_insert_ExecutionLogSteps
 @ExecutionLogID = @ExecutionLogID
 ,@StepDescription = 'Load Complete'
 ,@AffectedDatabaseName = @AffectedDatabaseName
 ,@AffectedSchemaName = @AffectedSchemaName
 ,@AffectedDataEntityName = @AffectedDataEntityName
 ,@ActionPerformed = 'Bulk Load'
 ,@StartDT = @Startlogtime
 ,@FinishDT = @Finishlogtime
 ,@DurationSeconds = @Durationsec
 ,@AffectedRecordCount = 0
 ,@ExecutionStepNo = 1000 --To increment in stored proc
 --********************* END LOGGING ********************
 */

GO
