SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
 
-- =============================================
-- Author:        Karl Dinkelmann
-- Create date: 31 Oct 2018
-- Description:    Logs the start of processing of a load.
-- =============================================
CREATE PROCEDURE [ETL].[sp_ADF_SetLoadControlStart_Backup]
      @LoadControlID INT
    , @DatabaseName varchar(100)
    , @DataEntityName varchar(100)
    , @SchemaName varchar(100)
    , @StepNo int
    --,@ProcessingStartDT DATETIME2(7) -- This is the start DT for the processing/control which gets used in the select statement logic etc. this is used fro data purposes
     ,@QueuedForProcessingDT DATETIME2(7) -- This is the start DT for the log to determine how long this table was in the queue for
     ,@ExecutionLogID int OUTPUT
     ,@LoadType varchar(50)
     ,@LastProcessingKeyValue varchar(50)
     ,@CurrentProcessingKeyValue varchar(50)
     ,@IsError bit
	 ,@SourceRowCount int
	 ,@SourceTableSizeBytes decimal(18,3)
	 --,@SourceRowCountToCopy int	 
	 ,@InitialTargetRowCount int 
	 ,@InitialTargetTableSizeBytes decimal(18,3)
	 ,@RowsTransferred int
	 ----,@DeletedRowCount int
	 ----,@UpdatedRowCount int
	 ----,@UpdatedRowBytes int 
	 ,@TargetRowCount int
	 ,@TargetTableSizeBytes decimal(18,3)
	 ,@IsSetForReload bit
AS
 
--Log Variables
    DECLARE   
    --@ExecutionLogID int
             @StepStartDT datetime2(7)
            , @StepFinishDT datetime2(7)
            , @StepDuration int
            , @StepAffectedRowCount int 
            --, @DatabaseName varchar(100)
            --, @DataEntityName varchar(100)
            --, @SchemaName varchar(100)
            --, @ProcName varchar(100)
            , @ExecutionStepNo int
            , @Today DATETIME2(7) = GETDATE()
 
/***********************************************************************************************
Insert all logging pertaining to the initialization of an ADF Load
************************************************************************************************/
IF @StepNo = 1
BEGIN
 
    --Set the start of the load in the control table
    UPDATE [control]
       SET ProcessingStartDT = @Today,
           ProcessingState = 'Processing'
      FROM ETL.LoadControl [control]
     WHERE [control].LoadControlID = @LoadControlID
 
 
     --Insert the first ExecutionLog
    INSERT INTO ETL.ExecutionLog
        (LoadConfigID
         ,DatabaseName
         ,SchemaName
         ,DataEntityName
         ,QueuedForProcessingDT
         ,StartDT
		 ,IsReload
         )
    SELECT   LoadConfigID
            ,@DatabaseName
            ,@SchemaName
            ,@DataEntityName
            ,@QueuedForProcessingDT
            ,GETDATE()
			,@IsSetForReload
    FROM ETL.LoadControl lc
    WHERE LoadControlID = @LoadControlID
 
    SET @ExecutionLogID =@@IDENTITY
    --Insert the first ExecutionLogStep
    INSERT INTO ETL.ExecutionLogSteps
    ( ExecutionLogID
     ,ExecutionStepNo
     ,StepDescription
     ,AffectedDatabaseName
     ,AffectedSchemaName
     ,AffectedDataEntityName
     ,[Action]
     ,StartDT
     )
     SELECT  @ExecutionLogID
            ,@StepNo
            ,'An ADF Load has started. ADF is currently finding the LastProcessingKeyValue'
            ,@DatabaseName
            ,@SchemaName
            ,@DataEntityName
            ,'In Progress'
            ,GETDATE()
 
END
 
--Log End of step 1 and log step 2 and 3
IF @StepNo = 2 AND @IsError = 0 AND @LoadType = 'IncrementalWithHistoryUpdate'
BEGIN
 
    UPDATE ETL.ExecutionLogSteps
    SET FinishDT = GETDATE()
       ,Action = 'Success'
	   ,DurationSeconds = DATEDIFF(SECOND , StartDT , GETDATE())
    WHERE ExecutionLogID = @ExecutionLogID
        AND ExecutionStepNo = @StepNo - 1
 
    INSERT INTO ETL.ExecutionLogSteps
    ( ExecutionLogID
     ,ExecutionStepNo
     ,StepDescription
     ,AffectedDatabaseName
     ,AffectedSchemaName
     ,AffectedDataEntityName
     ,[Action]
     ,StartDT
     ,FinishDT
	 ,DurationSeconds
     )
     SELECT  @ExecutionLogID
            ,@StepNo
            ,'ADF has returned the LastProcessingKeyValue: ' + @LastProcessingKeyValue
            ,@DatabaseName
            ,@SchemaName
            ,@DataEntityName
            ,'Success'
            ,GETDATE()
            ,GETDATE()
			,0
 
--Step 3
    INSERT INTO ETL.ExecutionLogSteps
    ( ExecutionLogID
     ,ExecutionStepNo
     ,StepDescription
     ,AffectedDatabaseName
     ,AffectedSchemaName
     ,AffectedDataEntityName
     ,[Action]
     ,StartDT
     )
     SELECT  @ExecutionLogID
            ,@StepNo + 1
            ,'ADF will now connect to the Source Database to get the RowCounts and then copy the source data into the Target Stage table.'
            ,@DatabaseName
            ,@SchemaName
            ,@DataEntityName
            ,'In Progress'
            ,GETDATE()
 
END        
 
--Log error after lookup fails
IF @StepNo = 2 AND @IsError = 1 AND @LoadType = 'IncrementalWithHistoryUpdate'
BEGIN
    UPDATE ETL.ExecutionLogSteps
    SET FinishDT = GETDATE()
       ,Action = 'Failed'
	   ,DurationSeconds = DATEDIFF(SECOND , StartDT , GETDATE())
    WHERE ExecutionLogID = @ExecutionLogID
        AND ExecutionStepNo = @StepNo - 1
 
    INSERT INTO ETL.ExecutionLogSteps
    ( ExecutionLogID
     ,ExecutionStepNo
     ,StepDescription
     ,AffectedDatabaseName
     ,AffectedSchemaName
     ,AffectedDataEntityName
     ,[Action]
     ,StartDT
	 ,FinishDT
	 ,DurationSeconds
		
     )
     SELECT  @ExecutionLogID
            ,@StepNo + 1
            ,'The FromTargetTable LatestRecord Lookup failed'
            ,@DatabaseName
            ,@SchemaName
            ,@DataEntityName
            ,'Failed'
            ,GETDATE()
			,GETDATE()
			,0

    
    UPDATE ETL.ExecutionLog
    SET FinishDT = GETDATE(),
        Result = 'Failed',
        ErrorMessage = 'The ADF could not find the latest record date in the ODS table',
        IsError = 1
    WHERE ExecutionLogID = @ExecutionLogID
 
    UPDATE ETL.LoadControl
    SET ProcessingFinishedDT = GETDATE(),
		IsLastRunFailed = 1
    WHERE LoadControlID = @LoadControlID
 
END
 
IF @StepNo = 3 AND @IsError = 1 AND @LoadType = 'IncrementalWithHistoryUpdate'
BEGIN
    UPDATE ETL.ExecutionLogSteps
    SET FinishDT = GETDATE()
       ,Action = 'Failed'
	   ,DurationSeconds = DATEDIFF(SECOND , StartDT , GETDATE())
    WHERE ExecutionLogID = @ExecutionLogID
        AND ExecutionStepNo = @StepNo
 
    INSERT INTO ETL.ExecutionLogSteps
    ( ExecutionLogID
     ,ExecutionStepNo
     ,StepDescription
     ,AffectedDatabaseName
     ,AffectedSchemaName
     ,AffectedDataEntityName
     ,[Action]
     ,StartDT
	 ,FinishDT
	 ,DurationSeconds
     )
     SELECT  @ExecutionLogID
            ,@StepNo + 1
            ,'The GetSourceRowCount Lookup Failed'
            ,@DatabaseName
            ,@SchemaName
            ,@DataEntityName
            ,'Failed'
            ,GETDATE()
			,GETDATE()
			,0
    
    UPDATE ETL.ExecutionLog
    SET FinishDT = GETDATE(),
        Result = 'Failed',
        ErrorMessage = 'The GetSourceRowCount Lookup Failed',
        IsError = 1
    WHERE ExecutionLogID = @ExecutionLogID
 
    UPDATE ETL.LoadControl
    SET ProcessingFinishedDT = GETDATE(),
		IsLastRunFailed = 1
    WHERE LoadControlID = @LoadControlID
END
 
IF @StepNo = 4 AND @IsError = 0 AND @LoadType = 'IncrementalWithHistoryUpdate'
BEGIN
 
    UPDATE ETL.ExecutionLogSteps
    SET FinishDT = GETDATE()
       ,Action = 'Success'
	   ,AffectedRecordCount = @RowsTransferred
	   ,DurationSeconds = DATEDIFF(SECOND , StartDT , GETDATE())
    WHERE ExecutionLogID = @ExecutionLogID
        AND ExecutionStepNo = @StepNo - 1
 
    INSERT INTO ETL.ExecutionLogSteps
    ( ExecutionLogID
     ,ExecutionStepNo
     ,StepDescription
     ,AffectedDatabaseName
     ,AffectedSchemaName
     ,AffectedDataEntityName
     ,[Action]
     ,StartDT
     ,FinishDT
	 ,AffectedRecordCount
	 ,DurationSeconds
     )
     SELECT  @ExecutionLogID
            ,@StepNo
            ,'Copy to stage table has completed successfully'
            ,@DatabaseName
            ,@SchemaName
            ,@DataEntityName
            ,'Success'
            ,GETDATE()
            ,GETDATE()
			,@RowsTransferred
			,0
 
--Step 4
    INSERT INTO ETL.ExecutionLogSteps
    ( ExecutionLogID
     ,ExecutionStepNo
     ,StepDescription
     ,AffectedDatabaseName
     ,AffectedSchemaName
     ,AffectedDataEntityName
     ,[Action]
     ,StartDT
     )
     SELECT  @ExecutionLogID
            ,@StepNo + 1
            ,'The Stage table merge will now initiate.'
            ,@DatabaseName
            ,@SchemaName
            ,@DataEntityName
            ,'In Progress'
            ,GETDATE()
END
 
 
--Log error after copy fails
IF @StepNo = 4 AND @IsError = 1 AND @LoadType = 'IncrementalWithHistoryUpdate'
BEGIN
    UPDATE ETL.ExecutionLogSteps
    SET FinishDT = GETDATE()
       ,Action = 'Failed'
	   ,DurationSeconds = DATEDIFF(SECOND , StartDT , GETDATE())
    WHERE ExecutionLogID = @ExecutionLogID
        AND ExecutionStepNo = @StepNo - 1
 
    INSERT INTO ETL.ExecutionLogSteps
    ( ExecutionLogID
     ,ExecutionStepNo
     ,StepDescription
     ,AffectedDatabaseName
     ,AffectedSchemaName
     ,AffectedDataEntityName
     ,[Action]
     ,StartDT
	 ,FinishDT
	 ,DurationSeconds
     )
     SELECT  @ExecutionLogID
            ,@StepNo
            ,'The Stage table copy failed'
            ,@DatabaseName
            ,@SchemaName
            ,@DataEntityName
            ,'Failed'
            ,GETDATE()
			,GETDATE()
			,0
    
    UPDATE ETL.ExecutionLog
    SET FinishDT = GETDATE(),
        Result = 'Failed',
        ErrorMessage = 'The ADF could not copy the data to the Stage table',
        IsError = 1
    WHERE ExecutionLogID = @ExecutionLogID
 
    UPDATE ETL.LoadControl
    SET ProcessingFinishedDT = GETDATE(),
		IsLastRunFailed = 1
    WHERE LoadControlID = @LoadControlID
 
END
 
 
 
 
 
IF @StepNo = 5 AND @IsError = 0 AND @LoadType = 'IncrementalWithHistoryUpdate'
BEGIN
 
    UPDATE ETL.ExecutionLogSteps
    SET FinishDT = GETDATE()
       ,Action = 'Success'
	   ,DurationSeconds = DATEDIFF(SECOND , StartDT , GETDATE())
    WHERE ExecutionLogID = @ExecutionLogID
        AND ExecutionStepNo = @StepNo 
 
    INSERT INTO ETL.ExecutionLogSteps
    ( ExecutionLogID
     ,ExecutionStepNo
     ,StepDescription
     ,AffectedDatabaseName
     ,AffectedSchemaName
     ,AffectedDataEntityName
     ,[Action]
     ,StartDT
     ,FinishDT
	 ,DurationSeconds
     )
     SELECT  @ExecutionLogID
            ,@StepNo + 1
            ,'Stage table merge has completed successfully'
            ,@DatabaseName
            ,@SchemaName
            ,@DataEntityName
            ,'Success'
            ,GETDATE()
            ,GETDATE()
			,0
 
--Step 5
    UPDATE [control]
       SET ProcessingFinishedDT = @Today,
           ProcessingState = 'Completed',
           LastProcessingTransactionNo = @CurrentProcessingKeyValue,
		   IsLastRunFailed = 0
 
      FROM ETL.LoadControl [control]
     WHERE [control].LoadControlID = @LoadControlID
 
     UPDATE el
        SET  FinishDT = GETDATE()
            ,LastProcessingKeyValue = @CurrentProcessingKeyValue
            ,Result = 'Success'
            ,IsError = 0
			,SourceRowCount = @SourceRowCount
			,SourceTableSizeBytes = @SourceTableSizeBytes
			--,SourceRowCountToCopy = @SourceRowCountToCopy
			,InitialTargetRowCount = @InitialTargetRowCount  
			,InitialTargetTableSizeBytes = @InitialTargetTableSizeBytes 
			,RowsTransferred = @RowsTransferred 
			--,DeletedRowCount = @DeletedRowCount 
			--,UpdatedRowCount = @UpdatedRowCount 
			--,UpdatedRowBytes = @UpdatedRowBytes  
			,TargetRowCount = @TargetRowCount 
			,TargetTableSizeBytes = @TargetTableSizeBytes 

    
     FROM ETL.ExecutionLog el
     WHERE ExecutionLogID = @ExecutionLogID
END
 
IF @StepNo = 5 AND @IsError = 1 AND @LoadType = 'IncrementalWithHistoryUpdate'
BEGIN
    UPDATE ETL.ExecutionLogSteps
    SET FinishDT = GETDATE()
       ,Action = 'Failed'
	   ,DurationSeconds = DATEDIFF(SECOND , StartDT , GETDATE())
    WHERE ExecutionLogID = @ExecutionLogID
        AND ExecutionStepNo = @StepNo - 1
 
    INSERT INTO ETL.ExecutionLogSteps
    ( ExecutionLogID
     ,ExecutionStepNo
     ,StepDescription
     ,AffectedDatabaseName
     ,AffectedSchemaName
     ,AffectedDataEntityName
     ,[Action]
     ,StartDT
	 ,FinishDT
	 ,DurationSeconds
     )
     SELECT  @ExecutionLogID
            ,@StepNo + 1
            ,'The Stage table copy failed'
            ,@DatabaseName
            ,@SchemaName
            ,@DataEntityName
            ,'Failed'
            ,GETDATE()
			,GETDATE()
			,0
    
    UPDATE ETL.ExecutionLog
    SET FinishDT = GETDATE(),
        Result = 'Failed',
        ErrorMessage = 'The ADF could not copy the data to the Stage table',
        IsError = 1
    WHERE ExecutionLogID = @ExecutionLogID
 
    UPDATE ETL.LoadControl
    SET ProcessingFinishedDT = GETDATE(),
		IsLastRunFailed = 1
    WHERE LoadControlID = @LoadControlID
 
END
 
 
 
 
/* WS: COMMENTED OUT
--************** START LOGGING **************--
SET        @StepAffectedRowCount = @@ROWCOUNT
SET        @StepFinishDT = CONVERT(datetime2(7), GETDATE())
SET        @StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)
SET     @StepNo = @StepNo + 1 
 
exec DataManager_Local.ETL.sp_insert_ExecutionLogSteps
                @ExecutionLogID = @ExecutionLogID--WS: REMOVE HARDCODE AND ADD: @ExecutionLogID
/*User Input*/    ,@StepDescription = 'Get last load date from DataVault.[raw].SAT_ClockHistory_XT_HVD & StageArea.XT.dbo_ClockHistory_HVD_Hist' -- TODO: Check if this also gets injected the same way the proc name gets injected
/*User Input*/    ,@AffectedDatabaseName = 'StageArea & DataVault'
/*User Input*/    ,@AffectedSchemaName = 'XT' 
/*User Input*/    ,@AffectedDataEntityName = 'SAT_ClockHistory_XT_HVD & dbo_ClockHistory_HVD_Hist' -- TODO: Check if this also gets injected the same way the proc name gets injected
/*User Input*/    ,@ActionPerformed = 'Select'
                ,@StartDT = @QueuedForProcessingDT --TODO WS: This must be the QUEUED DT for the load - inject the queued dt from the LoadControl for logging purposes. Get this DT from SSIS
                ,@FinishDT = @StepFinishDT
                ,@DurationSeconds = @StepDuration
                ,@AffectedRecordCount = @StepAffectedRowCount
                ,@ExecutionStepNo = @StepNo
-- Set the start time of the next step 
SET        @StepStartDT = CONVERT(datetime2(7), GETDATE())
--************** END LOGGING **************--
*/
----Log the start of the load in the control table
--INSERT INTO [ETL].[LoadControlEventLog]
--           ([LoadControlID]
--           ,[EventDT]
--           ,[EventDescription]
--           ,[ErrorMessage])
--VALUES (    @LoadControlID,    
--            @Today,
--            'Load started',
--            NULL)
 
----************** START LOGGING **************--
--SET        @StepAffectedRowCount = @@ROWCOUNT
--SET        @StepFinishDT = CONVERT(datetime2(7), GETDATE())
--SET        @StepDuration = DATEDIFF(SECOND,@StepStartDT, @StepFinishDT)
--SET     @StepNo = @StepNo + 1 
 
--exec DataManager_Local.ETL.sp_insert_ExecutionLogSteps
--                @ExecutionLogID = @ExecutionLogID
--/*User Input*/    ,@StepDescription = 'Get last load date from DataVault.[raw].SAT_ClockHistory_XT_HVD & StageArea.XT.dbo_ClockHistory_HVD_Hist' -- TODO: Check if this also gets injected the same way the proc name gets injected
--/*User Input*/    ,@AffectedDBName = 'StageArea & DataVault'
--/*User Input*/    ,@AffectedSchemaName = 'XT' -- TODO: Check if this also gets injected the same way the proc name gets injected
--/*User Input*/    ,@AffectedDataEntityName = 'SAT_ClockHistory_XT_HVD & dbo_ClockHistory_HVD_Hist' -- TODO: Check if this also gets injected the same way the proc name gets injected
--/*User Input*/    ,@ActionPerformed = 'Select'
--                ,@StartDT = @StepStartDT
--                ,@FinishDT = @StepFinishDT
--                ,@DurationSeconds = @StepDuration
--                ,@AffectedRecordCount = @StepAffectedRowCount
--                ,@ExecutionStepNo = @StepNo
---- Set the start time of the next step 
--SET        @StepStartDT = CONVERT(datetime2(7), GETDATE())
----************** END LOGGING **************--
 
 
 
 

GO
