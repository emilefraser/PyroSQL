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
    DECLARE @CalendarDate	DATE	= '2020-01-01'
	SELECT [dbo].[TestIsPublicHoliday](@CalendarDate)
======================================================================================================================== */
CREATE       FUNCTION [REFERENCE].[TestIsPublicHoliday] (
    @CalendarDate DATE
)
RETURNS BIT
AS
BEGIN
	DECLARE @returnValue BIT

	-- Get Monday's index
	DECLARE @MondayIndex TINYINT 
	SET @MondayIndex = [config].[GetDayOfWeekIndex]('Monday')

	-- TEST TO SEE WHETHER THE Date is currently a public holiday
	IF EXISTS (
		SELECT 
			1
		FROM 
			[REFERENCE].PublicHoliday AS ph
		WHERE (
				DATEPART(MONTH, @CalendarDate) = ph.HolidayMonthValue
			AND 
				DATEPART(DAY, @CalendarDate) = ph.HolidayDayValue
			AND
				@CalendarDate BETWEEN ph.HolidayStartDate AND ph.HolidayEndDate
		)
	)
	BEGIN
		SET @returnValue = 1
	END
	ELSE
	BEGIN
		-- TEST FOR OBSERVED HOLIDAYS
		-- IF Previous day public holiday and today is MONDAY
		-- NEED TO CHANGE THE INDEX
		IF EXISTS (
			SELECT 
				1
			FROM 
				[REFERENCE].PublicHoliday AS ph
			WHERE (
					DATEPART(MONTH, DATEADD(DAY, -1, @CalendarDate)) = ph.HolidayMonthValue
				AND 
					DATEPART(DAY, DATEADD(DAY, -1, @CalendarDate)) = ph.HolidayDayValue
				AND
					@CalendarDate BETWEEN ph.HolidayStartDate AND ph.HolidayEndDate
				AND
					DATEPART(WEEKDAY, @CalendarDate) = @MondayIndex
			)
		)
		BEGIN
			SET @returnValue = 1
		END
		ELSE
		BEGIN

			-- TEST FOR Easter Friday and Family Day
			IF (
				DATEADD(DAY, 1, [REFERENCE].[GetEasterSunday](YEAR(@CalendarDate))) = @CalendarDate
					OR 
				DATEADD(DAY, -2, [REFERENCE].[GetEasterSunday](YEAR(@CalendarDate))) = @CalendarDate
			)
			BEGIN
				SET @returnValue = 1
			END
			ELSE
			BEGIN
		
				-- TEST FOR VOTING DAY
				IF([REFERENCE].[GetPublicHolidays_AdHoc](@CalendarDate)) = 1
				BEGIN
					SET @returnValue = 1		
				END
				ELSE
				BEGIN
					SET @returnValue = 0
				END
			END

		END

	END

	RETURN @returnValue

END
GO
