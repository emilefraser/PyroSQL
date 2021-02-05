SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- Metadata --
/* ========================================================================================================================
	Created by	:	Emile Fraser
	Dreated on	:	2020-06-30
	Description	:	Returns whether the date is a public holiday or not
				
======================================================================================================================== */

-- Changelog & TODO --
/* ========================================================================================================================
	 2020-06-30	:	Created the Function

	 TODO		:	

======================================================================================================================== */

-- Execution & Testing --
/* ========================================================================================================================
    DECLARE @CalendarDate	DATE		= '2020-01-01'
	DECLARE @DatePart		VARCHAR(20) = 'DAY'
	SELECT [dbo].[GetCalendarIndex](@CalendarDate, @DatePart)
======================================================================================================================== */
CREATE     FUNCTION CONFIG.GetCalendarIndex (
    @CalendarDate		DATE
,	@DatePart			VARCHAR(20)
)
RETURNS INT
AS
BEGIN
	DECLARE @returnValue INT
	DECLARE @CalendarDateStart	DATE = (SELECT MIN(CalendarDate) FROM DIMENSION.[DateDimension])

	SET @returnValue = 
		CASE @DatePart 
			WHEN 'DAY'
				THEN DATEDIFF(DAY, @CalendarDateStart,  @CalendarDate)
			WHEN 'WEEK'
				THEN DATEDIFF(WEEK, @CalendarDateStart,  @CalendarDate)
			WHEN 'MONTH'
				THEN DATEDIFF(MONTH, @CalendarDateStart,  @CalendarDate)
			WHEN 'QUARTER'
				THEN DATEDIFF(QUARTER, @CalendarDateStart,  @CalendarDate)
			WHEN 'YEAR'
				THEN DATEDIFF(YEAR, @CalendarDateStart,  @CalendarDate)
			ELSE
				0
		END



	RETURN @returnValue

END
GO
