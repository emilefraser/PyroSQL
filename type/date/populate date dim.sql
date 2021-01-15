-- =============================================
-- Author:      RE van Jaarsveld
-- Create Date: 30/03/2020
-- Description: Populate Time Dimension Table
-- =============================================
ALTER PROCEDURE [sp_Populate_TimeDim]
(
    @StartDate Date,
    @EndDate Date   
)
AS
BEGIN
    IF @StartDate > (SELECT MAX([CalendarDate]) FROM [dbo].[Calendar_TimeDim] )
    BEGIN
    DECLARE @CurrentDate Date = @StartDate
    WHILE @CurrentDate != DATEADD(DAY,1,@EndDate)
    BEGIN
    INSERT INTO [dbo].Calendar_TimeDim ([CalendarDate],[Year],[Month],[MonthName],[DayNoOfMonth],[DayNoOfWeek],[DayNameOfWeek],[DayNoOfYear]
                                        ,[WeekNoOfYear],[WeekNoOfMonth],[DelNoteDayNo],[SemesterNo],[TrimesterNo],[QuarterNo],[IsWeekend],[IsHoliday]
                                        ,[IsLeapYear],[IsWeekEnding])
        VALUES (
                --Current Date
                @CurrentDate,
                --Get Date Year
                YEAR(@CurrentDate),
                --Get Date Month
                MONTH(@CurrentDate),
                --Get Date Month Name
                DATENAME(MONTH,@CurrentDate),
                --Get Date Day of Month
                DAY(@CurrentDate),
                --Get Date Day of Week
                (DATEPART(WEEKDAY,@CurrentDate)+5)%7+1,
                --Get Date Day Name
                DATENAME(WEEKDAY,@CurrentDate),
                --Get Date Day No of Year
                DATEPART(DAYOFYEAR,@CurrentDate),
                --Get Date Week No of Year
                DATEPART(ISO_Week,@CurrentDate),
                --Get Date Week No of Month
                (DATEPART(WEEK, @CurrentDate) - DATEPART(WEEK, DATEADD(day, 1, EOMONTH(@CurrentDate, -1)))) + 1,
                --Get Date Delivery Note Day No
                (DATEPART(WEEKDAY,@CurrentDate)+5)%7+1,
                --Get Date Semester No
                ((DATEPART(QUARTER,@CurrentDate)-1)/2)+1,
                --Get Date Trimester No
                ((DATEPART(MONTH,@CurrentDate)-1)/4)+1,
                --Get Date Quarter No
                DATEPART(QUARTER,@CurrentDate),
                --Get Date Is Weekend
                (SELECT CASE 
                        WHEN (DATEPART(WEEKDAY,@CurrentDate)+5)%7+1>5 THEN 1
                        WHEN (DATEPART(WEEKDAY,@CurrentDate)+5)%7+1<6 THEN 0 
                END),
                --Get Date Is Holiday
                0,
                --Get Date Is Leap Year
                (SELECT CASE DATEPART(MM, DATEADD(DD, 1, CAST((CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '0228') AS DATETIME))) 
                        WHEN 2 THEN 1 
                        ELSE 0 
                END),
                --Get Date Is Week Ending
                (SELECT CASE WHEN (DATEPART(WEEKDAY,@CurrentDate)+5)%7+1 =7 
                        THEN 1 WHEN DAY(@CurrentDate) = DAY(EOMONTH(@CurrentDate)) 
                        THEN 1 
                        ELSE 0 
                END))
                --Increase Current Date by one day
                SET @CurrentDate = DATEADD(DAY,1,@CurrentDate)
            END
            END
    DECLARE @Year VARCHAR(4) = CONVERT(VARCHAR, YEAR(@StartDate))
    EXEC [sp_Flag_Holidays] @Year
EN



[4/18 2:14 PM] Emile Fraser
    2) (DATEPART(MONTH,@CurrentDate)-1)/4)+1 
vir die dele highlighted...  is daar actually 'n pretty dinamiese manier om die nie te hoe te done nie:


    
      DECLARE @FirstDayOfWeek INT = 7 
-- Sunday is first day of week
SET DATEFIRST @FirstDayOfWeek
SELECT DATEPART(WEEKDAY, getdate()) AS DOW
-- Monday is first day of week
SET @FirstDayOfWeek = 1
SET DATEFIRST @FirstDayOfWeek
SELECT 
    DATEPART(WEEKDAY, GETDATE()) AS DOW
    
    
  
  

[4/18 1:38 PM] Emile Fraser
    2) dan in proc het jy net 1 update statement, wat 3 checks doen, check of datum = table date in daai range, jou easter function en dan of "gister" vakansie dag was en vandag maandag is DATAEPART(WEEKDAY, DATEADD(DAY, - 1, Calendate)) = Sunday en gister was public hokiday


[4/18 1:38 PM] Emile Fraser
    2) dan in proc het jy net 1 update statement, wat 3 checks doen, check of datum = table date in daai range, jou easter function en dan of "gister" vakansie dag was en vandag maandag is DATAEPART(WEEKDAY, DATEADD(DAY, - 1, Calendate)) = Sunday en gister was public hokiday


