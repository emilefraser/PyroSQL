
-- Metadata --
/* ========================================================================================================================
	Created by	:	Emile Fraser
	Dreated on	:	2020-06-30
	Description	:	Returns the start of the week value based on this table

					Value	First day of the week is
					1		Monday
					2		Tuesday
					3		Wednesday
					4		Thursday
					5		Friday
					6		Saturday
					7		Sunday
				
======================================================================================================================== */

-- Changelog & TODO --
/* ========================================================================================================================
	 2020-06-30	:	

	 TODO		:	

======================================================================================================================== */

-- Execution & Testing --
/* ========================================================================================================================
    
	DECLARE @FirstDayOfWeekName			VARCHAR(10)		= 'Monday'
	SELECT [dbo].[GetFirstDayOfWeek](@FirstDayOfWeekName)

======================================================================================================================== */
CREATE       FUNCTION [dbo].[GetFirstDayOfWeek] (
    @FirstDayOfWeekName VARCHAR(10)
)
RETURNS SMALLINT
AS
BEGIN
	
	DECLARE @returnValue SMALLINT	

	-- Gets the Abbreviated first day of the month
	DECLARE @FirstDayOfWeekNameAbbreviation VARCHAR(3)	= UPPER(SUBSTRING(@FirstDayOfWeekName, 1, 3))
	SET @returnValue 									= CHARINDEX(@FirstDayOfWeekNameAbbreviation, 'MON TUE WED THU FRI SAT SUN')/ 4.00 + 1

	RETURN @returnValue

END		
