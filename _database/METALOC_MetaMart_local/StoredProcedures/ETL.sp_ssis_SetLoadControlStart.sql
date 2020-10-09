SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:		Karl Dinkelmann
-- Create date: 31 Oct 2018
-- Description:	Logs the start of processing of a load.
-- =============================================
CREATE PROCEDURE [ETL].[sp_ssis_SetLoadControlStart]
	@LoadControlID INT,
	@ProcessingStartDT DATETIME2(7), -- This is the start DT for the processing/control which gets used in the select statement logic etc. this is used fro data purposes
	@QueuedForProcessingDT DATETIME2(7) -- This is the start DT for the log to determine how long this table was in the queue for
AS

--Log Variables
	DECLARE @ExecutionLogID int
			, @StepStartDT datetime2(7)
			, @StepFinishDT datetime2(7)
			, @StepDuration int
			, @StepAffectedRowCount int 
			, @DatabaseName varchar(100)
			, @SchemaName varchar(100)
			, @ProcName varchar(100)
			, @StepNo int = 0
			, @ExecutionStepNo int
			, @Today DATETIME2(7) = @ProcessingStartDT

--Set the start of the load in the control table
UPDATE [control]
   SET ProcessingStartDT = @Today,
	   ProcessingState = 'Processing'
  FROM ETL.LoadControl [control]
 WHERE [control].LoadControlID = @LoadControlID
 
 /* WS: COMMENTED OUT
--************** START LOGGING **************--
SET		@StepAffectedRowCount = @@ROWCOUNT
SET		@StepFinishDT = CONVERT(datetime2(7), GETDATE())
SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)
SET     @StepNo = @StepNo + 1 

exec DataManager_Local.ETL.sp_insert_ExecutionLogSteps
				@ExecutionLogID = @ExecutionLogID--WS: REMOVE HARDCODE AND ADD: @ExecutionLogID
/*User Input*/	,@StepDescription = 'Get last load date from DataVault.[raw].SAT_ClockHistory_XT_HVD & StageArea.XT.dbo_ClockHistory_HVD_Hist' -- TODO: Check if this also gets injected the same way the proc name gets injected
/*User Input*/	,@AffectedDatabaseName = 'StageArea & DataVault'
/*User Input*/	,@AffectedSchemaName = 'XT' 
/*User Input*/	,@AffectedDataEntityName = 'SAT_ClockHistory_XT_HVD & dbo_ClockHistory_HVD_Hist' -- TODO: Check if this also gets injected the same way the proc name gets injected
/*User Input*/	,@ActionPerformed = 'Select'
				,@StartDT = @QueuedForProcessingDT --TODO WS: This must be the QUEUED DT for the load - inject the queued dt from the LoadControl for logging purposes. Get this DT from SSIS
				,@FinishDT = @StepFinishDT
				,@DurationSeconds = @StepDuration
				,@AffectedRecordCount = @StepAffectedRowCount
				,@ExecutionStepNo = @StepNo
-- Set the start time of the next step 
SET		@StepStartDT = CONVERT(datetime2(7), GETDATE())
--************** END LOGGING **************--
*/
----Log the start of the load in the control table
--INSERT INTO [ETL].[LoadControlEventLog]
--           ([LoadControlID]
--           ,[EventDT]
--           ,[EventDescription]
--           ,[ErrorMessage])
--VALUES (	@LoadControlID,	
--			@Today,
--			'Load started',
--			NULL)

----************** START LOGGING **************--
--SET		@StepAffectedRowCount = @@ROWCOUNT
--SET		@StepFinishDT = CONVERT(datetime2(7), GETDATE())
--SET		@StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)
--SET     @StepNo = @StepNo + 1 

--exec DataManager_Local.ETL.sp_insert_ExecutionLogSteps
--				@ExecutionLogID = @ExecutionLogID
--/*User Input*/	,@StepDescription = 'Get last load date from DataVault.[raw].SAT_ClockHistory_XT_HVD & StageArea.XT.dbo_ClockHistory_HVD_Hist' -- TODO: Check if this also gets injected the same way the proc name gets injected
--/*User Input*/	,@AffectedDBName = 'StageArea & DataVault'
--/*User Input*/	,@AffectedSchemaName = 'XT' -- TODO: Check if this also gets injected the same way the proc name gets injected
--/*User Input*/	,@AffectedDataEntityName = 'SAT_ClockHistory_XT_HVD & dbo_ClockHistory_HVD_Hist' -- TODO: Check if this also gets injected the same way the proc name gets injected
--/*User Input*/	,@ActionPerformed = 'Select'
--				,@StartDT = @StepStartDT
--				,@FinishDT = @StepFinishDT
--				,@DurationSeconds = @StepDuration
--				,@AffectedRecordCount = @StepAffectedRowCount
--				,@ExecutionStepNo = @StepNo
---- Set the start time of the next step 
--SET		@StepStartDT = CONVERT(datetime2(7), GETDATE())
----************** END LOGGING **************--





GO
