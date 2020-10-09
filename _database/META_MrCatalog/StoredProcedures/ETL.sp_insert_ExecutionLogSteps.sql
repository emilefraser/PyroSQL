SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE   PROCEDURE [ETL].[sp_insert_ExecutionLogSteps]
	@ExecutionLogID int
,	@StepDescription varchar(1000)
,	@AffectedDatabaseName varchar(100)
,	@AffectedSchemaName varchar(100)
,	@AffectedDataEntityName varchar(100)
,	@ActionPerformed varchar(150)
,	@StartDT datetime2(7)
,	@FinishDT datetime2(7)
,	@DurationSeconds int
,	@AffectedRecordCount int
,	@ExecutionStepNo int 
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRANSACTION

	--WS
	DECLARE @ExecutionTotal INT

	SET @ExecutionTotal = (
		SELECT 
			ISNULL(MAX(els.[ExecutionStepNo]),1)
		FROM 
			etl.ExecutionLogSteps AS els
		WHERE 
			els.ExecutionLogID = @ExecutionLogID
	)

	--Insert step log entry to start the execution of the step in the stored procedure 
	INSERT INTO [ETL].[ExecutionLogSteps]
			      (
					[ExecutionLogID]
				  ,	[ExecutionStepNo]
				  ,	[StepDescription]
				  ,	[AffectedDatabaseName]
				  ,	[AffectedSchemaName]
				  ,	[AffectedDataEntityName]
				  ,	[Action]
				  ,	[StartDT]
				  ,	[FinishDT]
				  ,	[DurationSeconds]
				  ,	[AffectedRecordCount])
		 VALUES
			   (
					@ExecutionLogID
				  ,	CASE 
						WHEN @ExecutionStepNo = NULL 
							THEN 1 
						WHEN @ExecutionStepNo = 1 
							THEN 1 
						WHEN @ExecutionStepNo = '' 
							THEN 1 
							ELSE @ExecutionTotal + 1 
					END
				  ,	@StepDescription 
				  ,	@AffectedDatabaseName
				  ,	@AffectedSchemaName
				  ,	@AffectedDataEntityName
				  ,	@ActionPerformed
				  ,	@StartDT
				  ,	@FinishDT
				  ,	@DurationSeconds
				  ,	@AffectedRecordCount
				)
	
	COMMIT TRANSACTION
END

GO
