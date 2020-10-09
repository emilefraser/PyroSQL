SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE PROCEDURE [ETL].[sp_ssis_LoadControlLog]
	@LoadControlID INT
	,@IsStart BIT
	,@IsError BIT=0
	,@MaxUpdateFilter varchar(max)=NULL
	,@MaxInsertFilter varchar(max)=NULL
AS
BEGIN

	IF (@IsStart=1)
	BEGIN
		--// Set the start of the load in the control table
		UPDATE [control] WITH (ROWLOCK)
		SET ProcessingStartDT = GETDATE(),
			ProcessingState = 'Processing'
		FROM ETL.LoadControl [control] WITH (ROWLOCK)
		WHERE [control].LoadControlID = @LoadControlID
	END
	ELSE
	BEGIN
		--// Set the end of the load in the control table
		SET @MaxInsertFilter=IIF(@MaxInsertFilter='',NULL,@MaxInsertFilter)
		SET @MaxUpdateFilter=IIF(@MaxUpdateFilter='',NULL,@MaxUpdateFilter)

		UPDATE [control] WITH (ROWLOCK)
		SET ProcessingFinishedDT = GETDATE()
			,ProcessingState = 'Idle'
			,IsLastRunFailed=@IsError
			,[LastProcessingPrimaryKey]=IIF(@IsError=0, IIF(lc.NewDataFilterType='PrimaryKey', @MaxInsertFilter,NULL), [LastProcessingPrimaryKey])
			,[LastProcessingTransactionNo]=IIF(@IsError=0, IIF(lc.NewDataFilterType='TransactionNo', @MaxInsertFilter,NULL), [LastProcessingTransactionNo])
			,[LastProcessingCreateDT]=IIF(@IsError=0, IIF(lc.NewDataFilterType='CreateDateTime', @MaxInsertFilter,NULL), [LastProcessingCreateDT])
			,[LastProcessingUpdateDT]=IIF(@IsError=0, @MaxUpdateFilter, [LastProcessingUpdateDT])
			,[QueuedForProcessingDT]=NULL
		FROM 
			ETL.LoadControl [control] WITH (ROWLOCK)
			INNER JOIN
				ETL.LoadConfig lc WITH (NOLOCK)
				ON lc.LoadConfigID=[control].LoadConfigID
				AND [control].LoadControlID = @LoadControlID

		--// Set the IsSetForReloadOnNextRun to 0 if it was 1 
		UPDATE lc WITH (ROWLOCK)
		SET IsSetForReloadOnNextRun = 0
		FROM 
			ETL.LoadConfig lc WITH (ROWLOCK)
			INNER JOIN
				ETL.LoadControl [control] WITH (NOLOCK)
				ON [control].LoadConfigID=lc.LoadConfigID
				AND [control].LoadControlID = @LoadControlID
				AND	lc.IsSetForReloadOnNextRun = 1
				AND @IsError=0
		END
 
END

GO
