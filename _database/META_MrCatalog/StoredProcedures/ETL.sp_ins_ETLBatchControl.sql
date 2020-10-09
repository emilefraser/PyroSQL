SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [ETL].[sp_ins_ETLBatchControl]
	@ETLStepID int
	, @LastTransactionDate datetime
	, @ExecutionStartDate datetime
	, @ExecutionEndDate datetime
	, @ExecutionStatus varchar(50)
	, @BatchID int
	, @PackageName varchar(50)
	, @DataEntityID int

AS
BEGIN

--SET		@ETLStepID = NULL
SET		@LastTransactionDate = NULL
SET		@ExecutionStartDate = GETDATE()

INSERT INTO [ETL].[ETLBatchControl]
           ([ETLStepID]
           ,[LastTransactionDate]
           ,[ExecutionStartDate]
		   ,[ExecutionEndDate]
           ,[ExecutionStatus]
		   ,[PackageName]
		   ,[DataEntityID])
SELECT	@ETLStepID, @LastTransactionDate, @ExecutionStartDate, @ExecutionEndDate, @ExecutionStatus, @PackageName, @DataEntityID

Select	@BatchID = @@IDENTITY

Select	@BatchID as BatchID

END

GO
