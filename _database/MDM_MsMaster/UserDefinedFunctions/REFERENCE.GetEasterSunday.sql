SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- Metadata --
/* ========================================================================================================================
	Created by	:	RE van Jaarsveld
	Dreated on	:	30/03/2020
	Function	:	Generates Easter Sunday date for year provided			

======================================================================================================================== */

-- Changelog & TODO --
/* ========================================================================================================================
	 2020-03-30	:	Ruan van Jaarsveld initial script with holidays and Easter function

	 TODO		:	

======================================================================================================================== */

-- Execution & Testing --
/* ========================================================================================================================

	SELECT [dbo].[GetEasterSunday](2020)

======================================================================================================================== */
CREATE   FUNCTION [REFERENCE].[GetEasterSunday] ( 
	@YearValue INT 
) 
RETURNS SMALLDATETIME 
AS 
BEGIN 
    DECLARE     
		@EpactCalc			INT 
    ,	@PaschalDaysCalc	INT
    ,	@NumOfDaysToSunday	INT
    ,	@EasterMonth		INT
    ,	@EasterDay			INT 

    SET @EpactCalc = (24 + 19 * (@YearValue % 19)) % 30 

    SET @PaschalDaysCalc = @EpactCalc - (@EpactCalc / 28) 

    SET @NumOfDaysToSunday = @PaschalDaysCalc - ((@YearValue + @YearValue / 4 + @PaschalDaysCalc - 13) % 7) 
    SET @EasterMonth = 3 + (@NumOfDaysToSunday + 40) / 44 
    SET @EasterDay = @NumOfDaysToSunday + 28 - (31 * (@EasterMonth / 4)) 
  
	RETURN ( 
        SELECT CONVERT( SMALLDATETIME, RTRIM(@YearValue)
			+ RIGHT('0'+RTRIM(@EasterMonth), 2)  
            + RIGHT('0'+RTRIM(@EasterDay), 2)  
        ) 
    ) 
END

GO
