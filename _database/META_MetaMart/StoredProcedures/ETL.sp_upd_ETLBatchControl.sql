SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [ETL].[sp_upd_ETLBatchControl]
	@BatchID int
	, @LastTransactionDate datetime
	, @ExecutionStartDate datetime
	, @ExecutionEndDate datetime
	, @ExecutionStatus varchar(50)
	, @TransferRowCount int

AS
BEGIN

SET		@LastTransactionDate = NULL
SET		@ExecutionEndDate = GETDATE()

Update	ETL.ETLBatchControl
SET		LastTransactionDate = @LastTransactionDate
		, ExecutionEndDate = @ExecutionEndDate
		, ExecutionStatus = @ExecutionStatus
		, TransferRowCount = @TransferRowCount
where	BatchID = @BatchID

END

GO
