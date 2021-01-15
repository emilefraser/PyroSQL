
-- Metadata --
/* ========================================================================================================================
	Created by	:	Emile Fraser
	Dreated on	:	2020-06-30
	Function	:	Test if the date falls outside of the school terms

======================================================================================================================== */

-- Changelog & TODO --
/* ========================================================================================================================
	 2020-06-30	:	Test if the date falls outside of the school terms

	 TODO		:	

======================================================================================================================== */

-- Execution & Testing --
/* ========================================================================================================================

	SELECT [dbo].[TestIsSchoolHoliday]('2020-05-08')
	SELECT [dbo].[TestIsSchoolHoliday]('2020-10-09')

======================================================================================================================== */
CREATE   FUNCTION [dbo].[TestIsSchoolHoliday] ( 
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
			[REFERENCE].[SchoolTerm]
		WHERE
			@CalendarDate BETWEEN TermStartDate AND TermEndDate
	)
	BEGIN
		SET @returnValue = 0
	END
	ELSE
	BEGIN
		SET @returnValue = 1
	END

	RETURN @returnValue

END 
