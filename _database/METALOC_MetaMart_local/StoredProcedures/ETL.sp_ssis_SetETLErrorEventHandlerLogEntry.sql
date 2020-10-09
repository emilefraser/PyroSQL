SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON




-- =============================================
-- Author:		Karl Dinkelmann
-- Create date: 31 Oct 2018
-- Description:	Logs the failed load of an ETL run
-- =============================================

CREATE PROCEDURE [ETL].[sp_ssis_SetETLErrorEventHandlerLogEntry]
	@LoadControlID INT,
	@IsError BIT,
	@ErrorMessage VARCHAR(4000) = NULL,
	@ErrorMessage_SSIS VARCHAR(4000) = NULL
AS

DECLARE @Today DATETIME2(7) = GETDATE()

--Log the failed completion of the load in the control event log table
INSERT INTO [ETL].[LoadControlEventLog] WITH (ROWLOCK)
           ([LoadControlID]
           ,[EventDT]
           ,[EventDescription]
           ,[ErrorMessage])
VALUES (	@LoadControlID,	
			@Today,
			CASE WHEN ISNULL(@IsError, 0) = 0 THEN 'Event completed' ELSE 'Event error' END,
			@ErrorMessage+'::'+@ErrorMessage_SSIS
		)
			--CASE WHEN @ErrorMessage IS NULL THEN @ErrorMessage_SSIS 
			--	ELSE 'Custom Error Message:' + CHAR(10) + CHAR(13) + 
			--			@ErrorMessage + CHAR(10) + CHAR(13) + 
			--			'SSIS Error Message:' + CHAR(10) + CHAR(13) +
			--			@ErrorMessage_SSIS END)

-- Call [ETL].[sp_ssis_SetLoadControlFinished] to mark load as finished and error occurred
--EXECUTE [ETL].[sp_ssis_SetLoadControlFinished] 
--   @LoadControlID
--  ,NULL
--  ,NULL
--  ,NULL
--  ,NULL
--  ,NULL
--  ,@IsError
--  ,@ErrorMessage



GO
