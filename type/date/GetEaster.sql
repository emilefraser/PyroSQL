
-- =============================================
-- Author:      RE van Jaarsveld
-- Create Date: 30/03/2020
-- Description: Generates Easter SUnday date for year provided
-- =============================================
CREATE FUNCTION dbo.GetEasterSunday 
( @Y INT ) 
RETURNS SMALLDATETIME 
AS 
BEGIN 
    DECLARE     @EpactCalc INT,  
        @PaschalDaysCalc INT, 
        @NumOfDaysToSunday INT, 
        @EasterMonth INT, 
        @EasterDay INT 
    SET @EpactCalc = (24 + 19 * (@Y % 19)) % 30 
    SET @PaschalDaysCalc = @EpactCalc - (@EpactCalc / 28) 
    SET @NumOfDaysToSunday = @PaschalDaysCalc - ( 
        (@Y + @Y / 4 + @PaschalDaysCalc - 13) % 7 
    ) 
    SET @EasterMonth = 3 + (@NumOfDaysToSunday + 40) / 44 
    SET @EasterDay = @NumOfDaysToSunday + 28 - ( 
        31 * (@EasterMonth / 4) 
    ) 
    RETURN 
    ( 
        SELECT CONVERT 
        (  SMALLDATETIME, 
                 RTRIM(@Y)  
            + RIGHT('0'+RTRIM(@EasterMonth), 2)  
            + RIGHT('0'+RTRIM(@EasterDay), 2)  
        ) 
    ) 
END 
GO