SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =============================================
-- Author:		Frans Germishuizen
-- Create date: 2018-11-14
-- Description:	Add an event to the LoadControlEventLog table
-- =============================================
CREATE PROCEDURE [ETL].[sp_ssis_CreateLoadControlEventLogEntry] 
	@LoadControlID INT
	, @EventDescription varchar(50)
	, @ErrorMessage varchar(4000) = NULL
AS

DECLARE @Today DATETIME2(7) = CONVERT(datetime2(7), GETDATE())

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	SET NOCOUNT ON;

	--Log the start of the load in the control table
	INSERT INTO [ETL].[LoadControlEventLog] WITH (ROWLOCK)
				([LoadControlID]
				,[EventDT]
				,[EventDescription]
				,[ErrorMessage])
	VALUES (	@LoadControlID,	
				@Today,
				@EventDescription,
				NULL)
END

GO
