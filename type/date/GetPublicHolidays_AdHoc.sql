
-- Metadata --
/* ========================================================================================================================
	Created by	:	Emile Fraser
	Dreated on	:	2020-06-30
	Function	:	Test if the Date is an ad hoc holiday		

======================================================================================================================== */

-- Changelog & TODO --
/* ========================================================================================================================
	 2020-06-30	:	Test if the Date is an ad hoc holiday

	 TODO		:	

======================================================================================================================== */

-- Execution & Testing --
/* ========================================================================================================================

	SELECT [dbo].[GetPublicHolidays_AdHoc]('2019-05-08')
	SELECT [dbo].[GetPublicHolidays_AdHoc]('2019-05-09')

======================================================================================================================== */
CREATE   FUNCTION [dbo].[GetPublicHolidays_AdHoc] ( 
	@CalendarDate DATE 
) 
RETURNS BIT 
AS 
BEGIN 
    DECLARE @returnValue BIT 

    IF EXISTS (
		SELECT 
			1
		FROM 
			[dbo].[PublicHolidays_AdHoc]
		WHERE
			[HolidayDate] = @CalendarDate
	)
	BEGIN
		SET @returnValue = 1
	END
	ELSE
	BEGIN
		SET @returnValue = 0
	END

	RETURN @returnValue

END 
