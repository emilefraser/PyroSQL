USE [MsMaster]
GO

/****** Object:  UserDefinedFunction [dbo].[GetEasterSunday]    Script Date: 2020-06-30 08:22:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

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

	SELECT [dbo].[GetSchoolHoliday]('2020-05-08')
	SELECT [dbo].[GetSchoolHoliday]('2020-10-09')

======================================================================================================================== */
CREATE OR ALTER FUNCTION [dbo].[TestIsSchoolHoliday] ( 
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
			[dbo].[SchoolHolidays]
		WHERE
			@CalendarDate BETWEEN HolidayStartDate AND HolidayEndDate
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
GO


