SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON




-- =============================================
-- Author:		Frans Germishuizen
-- Create date: 2019-04-15
-- Description:	Insert a step log entry into the ETL.ExecutionLogSteps_StoredProcedures table
-- =============================================
CREATE PROCEDURE [ETL].[sp_insert_ExecutionLogSteps]
	@ExecutionLogID int
	,@StepDescription varchar(1000)
	,@AffectedDatabaseName varchar(100)
	,@AffectedSchemaName varchar(100)
	,@AffectedDataEntityName varchar(100)
	,@ActionPerformed varchar(150)
	,@StartDT datetime2(7)
	,@FinishDT datetime2(7)
	,@DurationSeconds int
	,@AffectedRecordCount int
	,@ExecutionStepNo int 
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRANSACTION

	--WS
	DECLARE @ExecutionTotal INT

	--SELECT 'EL'
	--SELECT @ExecutionLogID

	SET @ExecutionTotal = (
	Select ISNULL(MAX(executionstepno),1)
	from etl.ExecutionLogSteps 
	WHERE ExecutionLogID = @ExecutionLogID
	)


	--Insert step log entry to start the execution of the step in the stored procedure 
	INSERT INTO [ETL].[ExecutionLogSteps]
			      (
				   [ExecutionLogID]
				  ,[ExecutionStepNo]
				  ,[StepDescription]
				  ,[AffectedDatabaseName]
				  ,[AffectedSchemaName]
				  ,[AffectedDataEntityName]
				  ,[Action]
				  ,[StartDT]
				  ,[FinishDT]
				  ,[DurationSeconds]
				  ,[AffectedRecordCount])
		 VALUES
			   (
				   @ExecutionLogID
				  ,CASE WHEN @ExecutionStepNo = NULL THEN 1 WHEN @ExecutionStepNo = 1 THEN 1 WHEN @ExecutionStepNo = '' THEN 1 ELSE @ExecutionTotal + 1 END
				  ,@StepDescription 
				  ,@AffectedDatabaseName
				  ,@AffectedSchemaName
				  ,@AffectedDataEntityName
				  ,@ActionPerformed
				  ,@StartDT
				  ,@FinishDT
				  ,@DurationSeconds
				  ,@AffectedRecordCount)
	
	COMMIT TRANSACTION
END




GO
