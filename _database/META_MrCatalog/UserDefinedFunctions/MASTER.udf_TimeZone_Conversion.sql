SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [MASTER].[udf_TimeZone_Conversion]
(
	@TransactionPerson varchar(80)
)
RETURNS Int
AS
	BEGIN 
	DECLARE @CurrentTimeZone varchar(100) = (SELECT TimeZone FROM [GOV].[Person] WHERE [Email] = @TransactionPerson)
	DECLARE @CurrentTimeZone_From_Company varchar(100) = (SELECT TOP 1 TimeZone FROM [CONFIG].[Company])
	DECLARE @TIMEZONEID int = (SELECT TIMEZONEID FROM [MASTER].[TimeZone] WHERE TimeZone = ISNULL(@CurrentTimeZone,@CurrentTimeZone_From_Company))
	DECLARE @TIMEZONE char(32) = (SELECT TimeZone FROM [MASTER].[TimeZone] WHERE TimezoneID = @TIMEZONEId)
	DECLARE @UTC_Offset char(8) = (SELECT [Current_UTC_Offset] FROM [MASTER].[TimeZone] WHERE [TimeZone] = @TIMEZONE)
	DECLARE @NEWDATE int = Left(@UTC_Offset,3)

	RETURN @NEWDATE

	END

GO
