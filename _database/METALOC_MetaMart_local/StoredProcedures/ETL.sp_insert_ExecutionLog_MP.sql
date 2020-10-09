SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON







-- =============================================
-- Author:		Frans Germishuizen
-- Create date: 2019-04-15
-- Description:	Insert a log entry into the ETL.ExecutionLog_StoredProcedures table



-- =============================================
CREATE PROCEDURE [ETL].[sp_insert_ExecutionLog_MP] 

	@DatabaseName varchar(100) = NULL
	,@SchemaName varchar(100) = null
	,@swStart_FinishLogEntry int -- NULL --This is to determine if the log entry is being started or finished when calling the stored procedure
	,@ExecutionLogID_In int-- = NULL -- The execution log entry that is passed in to update when it is finished executing
	,@ExecutionLogID_Out int OUTPUT
	,@LoadConfigID int = NULL
	,@QueuedForProcessingDT datetime2(7)  = NULL
	,@ErrorProcedureName varchar(128) = NULL
	,@ErrorNumber INT = NULL
	,@ErrorState INT = NULL
	,@ErrorLine INT = NULL
	,@ErrorSeverity INT = NULL
	,@IsReload bit = 0
	,@ErrorMessage varchar(500) = NULL
	,@ProcedureName VARCHAR(255) = NULL
	,@DataEntityName varchar(100) =NULL
	,@NewRowCount int = null
	,@IsError int = null
	,@LastProcessingKeyValue varchar(max) = NULL
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
	
	--BEGIN TRANSACTION

--WS: Code to log when a load failed

DECLARE @ERRORVAR INT=0
DECLARE @ERRORSTRING VARCHAR(50)
DECLARE @LoadType VARCHAR(50)
DECLARE @FinishDT datetime2(7) = CONVERT(datetime2(7), GETDATE())

--SET @LoadType = (SELECT LoadType FROM ETL.LoadConfig WHERE LoadConfigID = @LoadConfigID)
SET @IsError=IIF(@swStart_FinishLogEntry=1,0,ISNULL(@IsError,-1))
IF (@IsError<0)
BEGIN
	SELECT @ERRORVAR=COUNT(*) 
	FROM ETL.ExecutionLogSteps WITH (NOLOCK)
	where [ExecutionLogID] = @ExecutionLogID_Out AND [Action] LIKE '%error%'  /*stick dynamic here*/ 
END

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


--SELECT 'AFTER @ERRORVAR'

-- REMOVE the [] around the entities used as Parameters
SET @DatabaseName = PARSENAME(@DatabaseName, 1)
SET @SchemaName = PARSENAME(@SchemaName, 1)
SET @DataEntityName = PARSENAME(@DataEntityName, 1)
SET @LastProcessingKeyValue=IIF(@LastProcessingKeyValue='',NULL,@LastProcessingKeyValue)


--SELECT 'AFTER PARSENAME'


	IF @swStart_FinishLogEntry = 1
		BEGIN
			DECLARE @StartDT datetime2(7) = CONVERT(datetime2(7), GETDATE())

			--Insert entry to start the execution of the stored procedure and to generate the ExecutionLogID
			INSERT INTO [ETL].[ExecutionLog] WITH (ROWLOCK)
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
						  ,[DataEntityname])
				 VALUES
					   (   
			 
						   @LoadConfigID -- as lc  -- replace with what was orignally here
						  ,@DatabaseName --as dbn
						  ,@SchemaName --as sc
						 -- ,@StoredProcedureName
						  ,@QueuedForProcessingDT --as qued
						  ,@StartDT --as startdt
						  ,@LastProcessingKeyValue --as lastpro
						  ,@IsReload --as isreload
						  ,@ERRORSTRING -- as errorst
						  ,@ErrorMessage --as errmes
						  ,@DataEntityName-- as dename
						  )
						  --)
						 -- ,@LoadType)
	
	--SELECT '00'

			--Get the ExecutionLogID to be used in the [ETL].[ExecutionLogStep_StoredProcedure] sp
			--SELECT @ExecutionLogID_Out = @@IDENTITY
			
			SELECT @ExecutionLogID_Out = SCOPE_IDENTITY()

			--Insert log entry into the Analytics table
			INSERT INTO [ETL].[ExecutionLogAnalysis] WITH (ROWLOCK)
			   ([ExecutionLogID])
			VALUES (
			    @ExecutionLogID_Out
			)

		END
		ELSE 
			BEGIN

				
				UPDATE	[ETL].[ExecutionLog] WITH (ROWLOCK)
				SET		FinishDT = @FinishDT
						, Result = @ERRORSTRING --ws
						, RowsTransferred = @RowsTransferred
						, SourceRowCount = @SourceRowCount
						, TargetRowCount = @TargetRowCount
	                    , NewRowCount  = @NewRowCount
                        , DeletedRowCount  = @DeletedRowCount
                        , SourceTableSizeBytes  = @SourceTableSizeBytes
						, LastProcessingKeyValue = NULLIF(@LastProcessingKeyValue,'Statement is blank')
                        , IsError  = @IsError
						,ErrorMessage=ISNULL(@ErrorMessage,ErrorMessage)
                        , TargetTableSizeBytes  = @TargetTableSizeBytes
                        , UpdatedRowBytes  = @UpdatedRowBytes
                        , UpdatedRowCount  = @UpdatedRowCount
                        , NewRowsBytes  = @NewRowsBytes
	                    ,InitialTargetRowCount = @InitialTargetRowCount 
	                    ,InitialTargetTableSizeBytes = @InitialTargetTableSizeBytes 
						,[IsDataIntegrityError] = IIF(@SourceRowCount!=@TargetRowCount,1,0)
				WHERE	ExecutionLogID = @ExecutionLogID_In --Wrong code: (Select MAX(ExecutionLogID) from  [ETL].[ExecutionLog])

				--Calculate Analysis for this log entry
				UPDATE	a WITH (ROWLOCK)
				SET		[DurationSeconds] = DATEDIFF(SECOND, [log].StartDT, [log].FinishDT)
						,[QueueSeconds] = DATEDIFF(SECOND, [log].QueuedForProcessingDT, [log].StartDT)
						,[TotalExecutionTime] = DATEDIFF(SECOND, [log].QueuedForProcessingDT, [log].FinishDT)
						,[IsDataIntegrityError] = [log].IsDataIntegrityError
				FROM	[ETL].[ExecutionLogAnalysis] a WITH (ROWLOCK)
						INNER JOIN [ETL].[ExecutionLog] AS [log] WITH (NOLOCK) ON
							[log].ExecutionLogID = a.ExecutionLogID
							AND [log].ExecutionLogID = @ExecutionLogID_In

			END
	--COMMIT TRANSACTION
END


GO
