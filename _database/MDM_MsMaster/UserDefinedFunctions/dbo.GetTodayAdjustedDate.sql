SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- Metadata --
/* ========================================================================================================================
	Created by	:	Emile Fraser
	Dreated on	:	2020-06-30
	Description	:	Returns the config value to be used be the creation of the Date Dimension
				
======================================================================================================================== */

-- Changelog & TODO --
/* ========================================================================================================================
	 2020-06-30	:	

	 TODO		:	

======================================================================================================================== */

-- Execution & Testing --
/* ========================================================================================================================

	EXEC [dbo].[GetTodayAdjustedDate]

======================================================================================================================== */
CREATE    FUNCTION [CONFIG].[GetTodayAdjustedDate] (
)
RETURNS DATETIME2(7)
AS
BEGIN

	-- Gets the Abbreviated first day of the month
	DECLARE @returnValue DATETIME2(7)

	-- Gets the Values for GETDATE and then adjusts it where neccessary with the factor according to config as per config table
	-- If we run loads at 19:00 and users use reeports the next day only, they mgiht want the Today value to reflect as tomorrow
	-- Thus the adjustment
	DECLARE @TodayAdjustmentDays SMALLINT = (SELECT [config].[GetConfigValue]('TodayReportingAdjustmentDays'))
	SET @returnValue = DATEADD(DAY, ISNULL(@TodayAdjustmentDays, 0), GETDATE())

	RETURN @returnValue

END

GO
