SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON





-- =============================================
-- Author:		Frans Germishuizen
-- Create date: 2019-04-15
-- Description:	Insert a step log entry into the ETL.ExecutionLogSteps_StoredProcedures table
-- =============================================
CREATE PROCEDURE [ETL].[sp_insert_ExecutionLogSteps_MP]
	@ExecutionLogID int
	,@StepDescription varchar(1000)
	,@AffectedDatabaseName varchar(100)
	,@AffectedSchemaName varchar(100)
	,@AffectedDataEntityName varchar(100)
	,@ActionPerformed varchar(150)
	,@StartDT datetime2(7)
	,@FinishDT datetime2(7)
	,@DurationSeconds int=-1
	,@AffectedRecordCount int=0
	,@ExecutionStepNo int=0
AS
BEGIN
	SET NOCOUNT ON;


	--//	init variables
	SET @DurationSeconds=IIF(@DurationSeconds<=-1,DATEDIFF(second, @StartDT, @FinishDT),@DurationSeconds)
	IF (@ExecutionStepNo<=0)
	BEGIN
		SELECT @ExecutionStepNo= ISNULL(MAX(executionstepno),0)+1
		FROM etl.ExecutionLogSteps WITH (NOLOCK)
		WHERE ExecutionLogID = @ExecutionLogID
	END

	--Insert step log entry to start the execution of the step in the stored procedure 
	INSERT INTO [ETL].[ExecutionLogSteps] WITH (ROWLOCK)
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
				  ,ISNULL(@ExecutionStepNo,1)
				  ,@StepDescription 
				  ,PARSENAME(@AffectedDatabaseName,1)
				  ,PARSENAME(@AffectedSchemaName,1)
				  ,PARSENAME(@AffectedDataEntityName,1)
				  ,UPPER(@ActionPerformed)
				  ,CONVERT(varchar(25), @StartDT, 121)
				  ,CONVERT(varchar(25), @FinishDT, 121)
				  ,@DurationSeconds
				  ,@AffectedRecordCount)
	

END




GO
