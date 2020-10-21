USE [MsMaster]
GO

/****** Object:  UserDefinedFunction [dbo].[TestIsPublicHoliday]    Script Date: 2020-06-30 08:01:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

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
CREATE OR ALTER     FUNCTION [dbo].[TestIsPublicHoliday] (
    @CalendarDate DATE
)
RETURNS BIT
AS
BEGIN
	DECLARE @returnValue BIT

	-- TEST TO SEE WHETHER THE Date is currently a public holiday
	IF EXISTS (
		SELECT 
			1
		FROM 
			dbo.PublicHolidays AS ph
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
		IF EXISTS (
			SELECT 
				1
			FROM 
				dbo.PublicHolidays AS ph
			WHERE (
					DATEPART(MONTH, DATEADD(DAY, -1, @CalendarDate)) = ph.HolidayMonthValue
				AND 
					DATEPART(DAY, DATEADD(DAY, -1, @CalendarDate)) = ph.HolidayDayValue
				AND
					@CalendarDate BETWEEN ph.HolidayStartDate AND ph.HolidayEndDate
				AND
					DATEPART(WEEKDAY, @CalendarDate) = 2 --Monday
			)
		)
		BEGIN
			SET @returnValue = 1
		END
		ELSE
		BEGIN

			-- TEST FOR Easter Friday and Family Day
			IF (
				DATEADD(DAY, 1, [dbo].[GetEasterSunday](YEAR(@CalendarDate))) = @CalendarDate
					OR 
				DATEADD(DAY, -2, [dbo].[GetEasterSunday](YEAR(@CalendarDate))) = @CalendarDate
			)
			BEGIN
				SET @returnValue = 1
			END
			ELSE
			BEGIN
		
				-- TEST FOR VOTING DAY
				IF([dbo].[GetPublicHolidays_AdHoc](@CalendarDate)) = 1
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


