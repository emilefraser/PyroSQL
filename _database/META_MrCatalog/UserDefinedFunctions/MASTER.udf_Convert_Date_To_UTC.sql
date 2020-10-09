SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [MASTER].[udf_Convert_Date_To_UTC]
(
	@TransactionDT datetime2(7)
)
RETURNS datetime2(7)
AS 
	BEGIN

	-- convert local date to utc date
	DECLARE @UTCDate datetime2(7)
	SET @UTCDate = DATEADD(Hour, DATEDIFF(Hour, GETUTCDATE(), GETDATE()), @TransactionDT)


	RETURN @UTCDate
	END

GO
