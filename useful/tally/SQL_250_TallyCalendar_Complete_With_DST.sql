--#################################################################################################
--TallyCalendar Table, with functions and logic to populate various holidays
--assembled from multiple resources by lowell *at* stormrage dot com
--final table structure is as follows:
-- modified 12/28/2016 adding with schemabinding to functions
--dates from 1900-01-01 to 3000-12-31

 --CREATE TABLE [dbo].[TallyCalendar] ( 
 --[TheDate]            datetime                         NOT NULL,
 --[DayOfWeek]          varchar(50)                          NULL,
 --[IsHoliday]          bit                                  NULL DEFAULT ((0)),
 --[IsWorkHoliday]      bit                                  NULL DEFAULT ((0)),
 --[IsWeekDay]          bit                                  NULL DEFAULT ((0)),
 --[IsWeekEnd]          bit                                  NULL DEFAULT ((0)),
 --[IsDaylightSavings]  bit                                  NULL DEFAULT ((0)),
 --[HolidayName]        varchar(100)                         NULL,
 --[LunarPhase]         varchar(50)                          NULL,
 --[IsoWeek]            int                                  NULL,
 --[IsWorkDay]          AS (CASE WHEN [IsWorkHoliday]=(1) OR ([DayOfWeek]='Sunday' OR [DayOfWeek]='Saturday') THEN (0) ELSE (1) END) PERSISTED,
 --[JulianDay]          AS (datediff(day,dateadd(year,datediff(year,(0),[TheDate]),(0)),[TheDate])+(1)) PERSISTED,
 --[YearNumber]         AS (datepart(year,[TheDate])) PERSISTED,
 --[MonthNumber]        AS (datediff(month,dateadd(year,datediff(year,(0),[TheDate]),(0)),[TheDate])+(1)) PERSISTED,
 --[DayNumber]          AS (datediff(day,dateadd(month,datediff(month,(0),[TheDate]),(0)),[TheDate])+(1)) PERSISTED,
 --CONSTRAINT   [PK__TallyCal__5CB7C64E1A14E395]    PRIMARY KEY CLUSTERED    (TheDate))
 --GO
--CREATE INDEX [IX_TallyCalendar]                  ON [TallyCalendar] (DayOfWeek, TheDate) INCLUDE (IsHoliday, IsWorkHoliday, HolidayName)

--Assumed you are database compatibility 100
--#################################################################################################
--function Get_LocalDateTimeITVF is schemabound to the TallyCalendar table, so drop it early
--just in case
IF OBJECT_ID('Get_LocalDateTimeITVF') IS NOT NULL
  DROP FUNCTION dbo.Get_LocalDateTimeITVF
GO
IF OBJECT_ID('sp_LunarPhaseITVF') IS NOT NULL
  DROP FUNCTION dbo.sp_LunarPhaseITVF
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
CREATE FUNCTION dbo.sp_LunarPhaseITVF(@TheDate DATETIME)
RETURNS TABLE
  WITH SCHEMABINDING
AS
RETURN(
  --initialize our vars
  WITH cteDtSplit  AS  (
                        SELECT
                          YEAR(@TheDate)  AS TheYear,
                          MONTH(@TheDate) AS TheMonth,
                          DAY(@TheDate)   AS TheDay
                        ),
       cteDates    AS  (
                        SELECT 
                          TheYear - FLOOR( ( 12 - TheMonth ) / 10 ) AS yy,      
                          CASE 
                            WHEN (TheMonth + 9) >= 12
                            THEN (TheMonth + 9) - 12
                            ELSE  TheMonth + 9
                          END AS mm,
                          TheDay AS dd
                        FROM cteDtSplit
                        ),
       ctePre    AS   (
                        SELECT  
                          dd,
                          FLOOR( 365.25 * ( yy + 4712 ) ) AS k1,
                          FLOOR( 30.6 * mm + 0.5 ) AS k2,
                          FLOOR( FLOOR( ( yy / 100 ) + 49 ) * 0.75 ) - 38  AS k3
                        FROM cteDates
                        ),
      cteAdj      AS   (
                        SELECT 
                          CASE 
                            WHEN (k1 + k2 + dd + 59) > 2299160
                            THEN (k1 + k2 + dd + 59) - k3  
                            ELSE  k1 + k2 + dd + 59
                          END  AS jd  -- % for dates in Julian calendar
                        FROM ctePre
                        ),
     
      cteFin     AS   (
                        SELECT 
                          ((( jd - 2451550.1 ) / 29.530588853) - CAST((FLOOR( ( jd - 2451550.1 ) / 29.530588853 )) AS DECIMAL(38,16))) * 29.53 AS AG
                        FROM  cteAdj
                        )
   
SELECT CASE
  WHEN ag <  1.84566       THEN  'New Moon'
    WHEN ag <  5.53699     THEN  'Waxing crescent'
    WHEN ag <  9.22831     THEN  'First quarter'
    WHEN ag < 12.91963     THEN  'Waxing near full moon' -- the web calls this "Gibbous ", WTH is that?
    WHEN ag < 16.61096     THEN  'Full Moon '
    WHEN ag < 20.30228     THEN  'Waning near full moon' -- the web calls this "Gibbous ", WTH is that?
    WHEN ag < 23.99361     THEN  'Last quarter'
    WHEN ag < 27.68493     THEN  'Waning crescent'
    ELSE  'New Moon'
  END AS Phase 
 FROM cteFin
) --END Return
GO
--#################################################################################################
IF OBJECT_ID('FindChanukah') IS NOT NULL
  DROP FUNCTION dbo.FindChanukah
GO  
IF OBJECT_ID('TishaBAv') IS NOT NULL
  DROP FUNCTION dbo.TishaBAv
GO 
IF OBJECT_ID('TuBishvat') IS NOT NULL
  DROP FUNCTION dbo.TuBishvat
GO 
IF OBJECT_ID('YomHaAtzmaut') IS NOT NULL
  DROP FUNCTION dbo.YomHaAtzmaut
GO
IF OBJECT_ID('Passover') IS NOT NULL
  DROP FUNCTION dbo.Passover
GO  
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
CREATE FUNCTION dbo.Passover(@Yr INT)
RETURNS DATETIME
WITH SCHEMABINDING
AS
BEGIN
   DECLARE @HYear INT, @Matonic INT, @LeapException INT, @Leap INT, @DOW INT, @Century INT 
   DECLARE @fDay FLOAT(20), @fFracDay FLOAT(20) 
   DECLARE @Mo INT, @Day INT
   SET @HYear=@Yr+3760
   SET @Matonic=(12*@HYear+17) % 19
   SET @Leap=@HYear % 4
   SET @fDay=32+4343/98496.+@Matonic+@Matonic*(272953/492480.)+@Leap/4.
   SET @fDay=@fDay-@HYear*(313/98496.)
   SET @fFracDay=@fDay-FLOOR(@fDay)
   SET @DOW=CAST (3*@HYear+5*@Leap+FLOOR(@fDay)+5 AS INT) % 7
   IF @DOW=2 OR @DOW=4 OR @DOW=6 
      SET @fDay=@fDay+1
   IF @DOW=1 AND @Matonic>6 AND @fFracDay>=1367/2160.
      SET @fDay=@fDay+2
   IF @DOW=0 AND @Matonic>11 AND @fFracDay>=23269/25920.
      SET @fDay=@fDay+1
   SET @Century=FLOOR(@Yr/100.)
   SET @LeapException=FLOOR((3*@Century-5)/4.)
   IF @Yr>1582 
      SET @fDay=@fDay+@LeapException
   SET @Day=FLOOR(@fDay)
   SET @Mo=3
   IF @Day>153 
      BEGIN
         SET @Mo=8
         SET @Day=@Day-153
      END
   IF @Day>122
      BEGIN
         SET @Mo=7
         SET @Day=@Day-122
      END
   IF @Day>92
      BEGIN
         SET @Mo=6
         SET @Day=@Day-92
      END
   IF @Day>61 
      BEGIN
         SET @Mo=5
         SET @Day=@Day-61
      END
   IF @Day>31 
      BEGIN
         SET @Mo=4
         SET @Day=@Day-31
      END
   RETURN CAST(STR(@Mo)+'/'+STR(@Day)+'/'+STR(@Yr) AS DATETIME)
/* Based on mathematical algorithms first devised by the German mathematician Carl Friedrich Gauss (1777-1855).  
I have used the date of Passover to determine most of the other Jewish holidays.*/
END
GO
IF OBJECT_ID('FindChanukah') IS NOT NULL
  DROP FUNCTION dbo.FindChanukah
GO  
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
CREATE FUNCTION dbo.FindChanukah (@Yr AS INT)
RETURNS DATETIME
WITH SCHEMABINDING
AS
BEGIN
RETURN CASE DATEDIFF(dd,dbo.Passover(@Yr),dbo.Passover(@Yr+1))
          WHEN 355 THEN DATEADD(dd,246,dbo.Passover(@Yr)) 
          WHEN 385 THEN DATEADD(dd,246,dbo.Passover(@Yr)) 
          ELSE  DATEADD(dd,245,dbo.Passover(@Yr)) END
END
GO
--#################################################################################################
GO
IF OBJECT_ID('TishaBAv') IS NOT NULL
  DROP FUNCTION dbo.TishaBAv
GO 
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
CREATE FUNCTION dbo.TishaBAv (@Yr AS INT)
RETURNS DATETIME
WITH SCHEMABINDING
AS  
BEGIN 
   RETURN  CASE DATEPART(weekday,dbo.Passover(@Yr)) 
                 WHEN 7 THEN DATEADD(dd,113,dbo.Passover(@Yr))
                 ELSE DATEADD(dd,112,dbo.Passover(@Yr)) END
END 
--#################################################################################################
GO
IF OBJECT_ID('TuBishvat') IS NOT NULL
  DROP FUNCTION dbo.TuBishvat
GO 
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
CREATE FUNCTION dbo.TuBishvat (@Yr AS INT)
RETURNS DATETIME
WITH SCHEMABINDING
AS
BEGIN
RETURN CASE WHEN DATEDIFF(dd,dbo.Passover(@Yr-1),dbo.Passover(@Yr))>355
          THEN DATEADD(dd,-89,dbo.Passover(@Yr)) 
          ELSE  DATEADD(dd,-59,dbo.Passover(@Yr)) END
END
--#################################################################################################
GO
IF OBJECT_ID('YomHaAtzmaut') IS NOT NULL
  DROP FUNCTION dbo.YomHaAtzmaut
GO 
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
CREATE FUNCTION dbo.YomHaAtzmaut (@Yr AS INT)
RETURNS DATETIME
WITH SCHEMABINDING
AS
--The "rule" for this date isn't always observed! In 2004 the holiday was observed on 4/27 instead of 4/26!  
BEGIN 
   DECLARE @Date AS DATETIME
   IF @Yr=2004 
      SET @Date=CAST('2004-04-27' AS DATETIME)
   ELSE 
      SET @Date=  CASE DATEPART(weekday,dbo.Passover(@Yr)) 
                 WHEN 1 THEN DATEADD(dd,18,dbo.Passover(@Yr))
                 WHEN 7 THEN DATEADD(dd,19,dbo.Passover(@Yr))
                 ELSE DATEADD(dd,20,dbo.Passover(@Yr)) END
   RETURN @Date
END
GO
--#################################################################################################
IF OBJECT_ID('fcn_FindEasterSunday') IS NOT NULL
  DROP FUNCTION dbo.fcn_FindEasterSunday
GO  
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
--function to calculate Easter for a given year:
--most difficult to calculate!
--the first Sunday after the full moon that occurs 
--on or next after the vernal equinox (fixed at March 21) 
--and is therefore celebrated between March 22 and April 25 inclusive.
CREATE FUNCTION dbo.fcn_FindEasterSunday(@inYear INT)
  RETURNS DATETIME
  WITH SCHEMABINDING
AS
BEGIN
  DECLARE @dtNow DATETIME
  DECLARE @inCurDay INT
  DECLARE @inCurMonth INT
  DECLARE @inCurYear INT
  DECLARE @inCurCent INT
  DECLARE @inYear19 INT
  DECLARE @inYearTmp INT
  DECLARE @inTemp2 INT
  DECLARE @inTemp3 INT
  DECLARE @inTemp4 INT
  DECLARE @inEastDay INT
  DECLARE @inEastMonth INT
  DECLARE @dtEasterSunday DATETIME

  SET @dtNow = CONVERT(DATETIME,CAST(@inYear AS CHAR(4))+'-01-01')

  SET @inCurDay=DAY(@dtNow)
  SET @inCurMonth=MONTH(@dtNow)
  SET @inCurYear=YEAR(@dtNow)
  SET @inCurCent=FLOOR(@inCurYear/100)

  SET @inYear19=@inCurYear%19

  SET @inYearTmp=FLOOR((@inCurCent-17)/25)
  SET @inTemp2=(@inCurCent-FLOOR(@inCurCent/4)-FLOOR((@inCurCent-@inYearTmp)/3)+(19*@inYear19)+15)%30
  SET @inTemp2=@inTemp2-FLOOR(@inTemp2/28)*(1 - FLOOR(@inTemp2/28)*FLOOR(29/(@inTemp2+1))*FLOOR((21-@inYear19)/11))

  SET @inTemp3 = (@inCurYear+FLOOR(@inCurYear/4)+@inTemp2+2-@inCurCent+FLOOR(@inCurCent/4))%7
  SET @inTemp4 = @inTemp2-@inTemp3

  SET @inEastMonth = 3+FLOOR((@inTemp4+40)/44)
  SET @inEastDay = @inTemp4+28-31*FLOOR(@inEastMonth/4)
  SET @inEastMonth = @inEastMonth - 1

  SET @dtEasterSunday = CONVERT(DATETIME,CAST(@inCurYear AS VARCHAR(4))+'-'+RIGHT(CAST('00' AS VARCHAR(2))+CAST(@inEastMonth+1 AS VARCHAR(2)),2)+'-'+RIGHT(CAST('00' AS VARCHAR(2))+CAST(@inEastDay AS VARCHAR(2)),2)+' 00:00:00')
  RETURN @dtEasterSunday
END
--#################################################################################################
GO
IF OBJECT_ID('fnGetNthWeekdayOfMonth') IS NOT NULL
  DROP FUNCTION dbo.fnGetNthWeekdayOfMonth
GO  
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
CREATE FUNCTION dbo.fnGetNthWeekdayOfMonth (@theDate DATETIME,@theWeekday TINYINT,@theNth SMALLINT)
  RETURNS DATETIME
  WITH SCHEMABINDING
BEGIN
  RETURN  
  (
   SELECT  
     theDate
   FROM (
         SELECT DATEADD(DAY, 7 * @theNth - 7 * SIGN(SIGN(@theNth) + 1) +(@theWeekday + 6 - DATEDIFF(DAY, '17530101', DATEADD(MONTH, DATEDIFF(MONTH, @theNth, @theDate), '19000101')) % 7) % 7, DATEADD(MONTH, DATEDIFF(MONTH, @theNth, @theDate), '19000101')) AS theDate
         WHERE @theWeekday BETWEEN 1 AND 7
           AND @theNth IN (-5, -4, -3, -2, -1, 1, 2, 3, 4, 5)
        ) AS d
   WHERE DATEDIFF(MONTH, theDate, @theDate) = 0
  )
END
--#################################################################################################
GO
--drop table TallyCalendar
IF OBJECT_ID('TallyCalendar') IS NOT NULL
  DROP TABLE dbo.TallyCalendar
GO  
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
CREATE TABLE dbo.TallyCalendar (
[TheDate]           DATETIME NOT NULL PRIMARY KEY,
[DayOfWeek]         VARCHAR(50),
[IsHoliday]         BIT DEFAULT 0,
[IsWorkHoliday]     BIT DEFAULT 0,
[IsWeekDay]         BIT DEFAULT 0,
[IsWeekEnd]         BIT DEFAULT 0,
[IsDaylightSavings] BIT DEFAULT 0,
[HolidayName]       VARCHAR(100),
[LunarPhase]        VARCHAR(50) )

CREATE NONCLUSTERED INDEX [IX_TallyCalendar]
ON [dbo].[TallyCalendar] ([DayOfWeek],[TheDate])
INCLUDE ([IsHoliday],[IsWorkHoliday],[HolidayName])
DECLARE @NumberOfYears INT
--delete from [TallyCalendar]
SET @NumberOfYears = 100 --x years before and after todays date:
--now i want from SQLdate 0 (1900-01-01 to 100+years in the future
;WITH TallyNumbers AS 
  (
   SELECT  convert(datetime,RW) AS N
   FROM (
         SELECT TOP (  datediff(dd,0, dateadd(year,1101,0)) ) 
           ROW_NUMBER() OVER (ORDER BY sc1.id) -1  AS RW 
         FROM Master.dbo.SysColumns sc1
           CROSS JOIN Master.dbo.SysColumns sc2
        ) X
  )
  INSERT INTO dbo.TallyCalendar(TheDate,[DayOfWeek])
    SELECT 
      TallyNumbers.N,
      DATENAME(dw,TallyNumbers.N)
    FROM TallyNumbers

/*
--old code went x number of years before and after the current date.
;WITH TallyNumbers AS 
  (
   SELECT  DATEADD( dd,(-365 * @NumberOfYears) + RW ,DATEADD(dd, DATEDIFF(dd,0,GETDATE()), 0)) AS N
   FROM (
         SELECT TOP (730 * @NumberOfYears) 
           ROW_NUMBER() OVER (ORDER BY sc1.id) AS RW 
         FROM Master.dbo.SysColumns sc1
           CROSS JOIN Master.dbo.SysColumns sc2
        ) X
  )
  INSERT INTO dbo.TallyCalendar(TheDate,[DayOfWeek])
    SELECT 
      TallyNumbers.N,
      DATENAME(dw,TallyNumbers.N)
    FROM TallyNumbers
    */
--#################################################################################################
--fix the IsWeekDay/IsWeekEnd columns: 
UPDATE TallyCalendar SET IsWeekDay = 1  WHERE [DayOfWeek] NOT IN('Saturday','Sunday')
UPDATE TallyCalendar SET IsWeekEnd = 1  WHERE [DayOfWeek]     IN('Saturday','Sunday')
--#################################################################################################
--now add some holidays: --update tallycalendar set holidayname = null
  SET DATEFIRST 1; --monday
--#################################################################################################
--Christmas Eve : December 24
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 1,HolidayName = COALESCE(HolidayName + ',','') + 'Christmas Eve' 
  WHERE MONTH(theDate) = 12 AND DAY(Thedate) = 24
--#################################################################################################
--Christmas Day : December 25
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 1,HolidayName = COALESCE(HolidayName + ',','') + 'Christmas Day' 
  WHERE MONTH(theDate) = 12 AND DAY(Thedate) = 25
--#################################################################################################
--New Years Eve : December 31
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 1,HolidayName = COALESCE(HolidayName + ',','') + 'New Years Eve' 
  WHERE MONTH(theDate) = 12 AND DAY(Thedate) = 31
--#################################################################################################
--New Years Day : January 1
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 1,HolidayName = COALESCE(HolidayName + ',','') + 'New Years Day' 
  WHERE MONTH(theDate) = 1 AND DAY(Thedate) = 1
--#################################################################################################
--Fourth of July : July 4
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 1,HolidayName = COALESCE(HolidayName + ',','') + 'Fourth of July' 
  WHERE MONTH(theDate) = 7 AND DAY(Thedate) = 4
--#################################################################################################
--harder ones: 
--#################################################################################################
--Memorial Day : last Monday in May: 
--The last Monday of the month is nothing more than the first Monday of next month minus 7 days. 
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 1,HolidayName = COALESCE(HolidayName + ',','') + 'Memorial Day' 
  WHERE TheDate IN (
                    SELECT DATEADD(dd,-7,thedate) FROM (SELECT * FROM TallyCalendar
                                    WHERE TheDate = DATEADD(wk,DATEDIFF(wk,0,DATEADD(dd,6 - DATEPART(DAY,TheDate),TheDate)), 0) 
                                      AND MONTH(TheDate) = 6) x 
                   )
--#################################################################################################
--Presidents Day : third Monday of February
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 1,HolidayName = COALESCE(HolidayName + ',','') + 'Presidents Day' 
  WHERE TheDate = DATEADD(wk,2,DATEADD(wk,DATEDIFF(wk,0,DATEADD(dd,6 - DATEPART(DAY,TheDate),TheDate)), 0) )
    AND MONTH(TheDate) = 2
--#################################################################################################
--Labor Day : first Monday in September
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 1,HolidayName = COALESCE(HolidayName + ',','') + 'Labor Day' 
  WHERE TheDate = DATEADD(wk,DATEDIFF(wk,0,DATEADD(dd,6 - DATEPART(DAY,TheDate),TheDate)), 0)
    AND  MONTH(theDate) = 9
--#################################################################################################
--Martin Luther King Day : third Monday of Jan
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 1,HolidayName = COALESCE(HolidayName + ',','') + 'Martin Luther King Day' 
  WHERE TheDate = DATEADD(wk,2,DATEADD(wk,DATEDIFF(wk,0,DATEADD(dd,6 - DATEPART(DAY,TheDate),TheDate)), 0) )
    AND MONTH(TheDate) = 1
--#################################################################################################
--Thanksgiving : fourth Thursday of November

  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 1,HolidayName = COALESCE(HolidayName + ',','') + 'Thanksgiving Day' 
  WHERE TheDate = dbo.fnGetNthWeekdayOfMonth(TheDate,4,4)
    AND MONTH(TheDate) = 11
--• Black Friday - the day after Thanksgiving, traditional start of Christmas shopping deals.
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') + 'Black Friday' 
  WHERE TheDate = DATEADD(dd,1,dbo.fnGetNthWeekdayOfMonth(TheDate,4,4))
    AND MONTH(TheDate) = 11
--• Cyber Monday - Monday after Black Friday, the online internet version of Black Friday deals.
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') + 'Cyber Monday' 
  WHERE TheDate = DATEADD(dd,4,dbo.fnGetNthWeekdayOfMonth(TheDate,4,4))
    AND MONTH(TheDate) = 11

--#################################################################################################
--Columbus Day : October 12, but observed the second Monday of October
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 1,HolidayName = COALESCE(HolidayName + ',','') + 'Columbus Day' 
  WHERE TheDate = DATEADD(wk,1,DATEADD(wk,DATEDIFF(wk,0,DATEADD(dd,6 - DATEPART(DAY,TheDate),TheDate)), 0) )
    AND MONTH(TheDate) = 10
--#################################################################################################
--Veterans Day : November 11, but used to be the fourth Monday of October
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 1,HolidayName = COALESCE(HolidayName + ',','') + 'Veterans Day' 
  WHERE MONTH(theDate) = 11 AND DAY(Thedate) = 11
--#################################################################################################
--Easter Sunday:
--most difficult to calculate!
--the first Sunday after the full moon that occurs on or next after the vernal equinox (fixed at March 21) and is therefore celebrated between March 22 and April 25 inclusive.
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 1,HolidayName = COALESCE(HolidayName + ',','') + 'Easter Sunday' 
  WHERE TheDate = dbo.fcn_FindEasterSunday(YEAR(TheDate))
--#################################################################################################
--other days related to Easter:
--Palm Sunday one week before Easter
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') + 'Palm Sunday' 
  WHERE TheDate = DATEADD(wk,-1,dbo.fcn_FindEasterSunday(YEAR(TheDate)))
--#################################################################################################
--Ash Wednesday 7th Wednesday before Easter, or -4 days hten -6 weeks
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') + 'Ash Wednesday' 
  WHERE TheDate = DATEADD(wk,-6,DATEADD(dd,-4,dbo.fcn_FindEasterSunday(YEAR(TheDate))))
--#################################################################################################
--Good Friday the Friday preceding Easter Sunday
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') + 'Good Friday' 
  WHERE TheDate = DATEADD(dd,-2,dbo.fcn_FindEasterSunday(YEAR(TheDate)))
--#################################################################################################
--Kwanzaa December 26 - Jan 1 [every year]
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') + 'Kwanzaa(First of 7 days)' 
  WHERE MONTH(theDate) = 12 AND DAY(Thedate) = 26
 
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') + 'Kwanzaa(Second of 7 days)' 
  WHERE MONTH(theDate) = 12 AND DAY(Thedate) = 27
 
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') + 'Kwanzaa(Third of 7 days)' 
  WHERE MONTH(theDate) = 12 AND DAY(Thedate) = 28
  
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') + 'Kwanzaa(Fourth of 7 days)' 
  WHERE MONTH(theDate) = 12 AND DAY(Thedate) = 29
 
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') + 'Kwanzaa(Fifth of 7 days)' 
  WHERE MONTH(theDate) = 12 AND DAY(Thedate) = 30
  
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 1,HolidayName = COALESCE(HolidayName + ',','') + 'Kwanzaa(Sixth of 7 days)' 
  WHERE MONTH(theDate) = 12 AND DAY(Thedate) = 31
 
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 1,HolidayName = COALESCE(HolidayName + ',','') + 'Kwanzaa(Seventh of 7 days)' 
  WHERE MONTH(theDate) = 1 AND DAY(Thedate) = 1
  
--#################################################################################################
--non-work holidays
--#################################################################################################
--Valentines Day : February 14
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') + 'Valentines Day' 
  WHERE MONTH(theDate) = 2 AND DAY(Thedate) = 14
--#################################################################################################
--September 11 Nine-Eleven Day
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') + 'September 11 Nine-Eleven ' 
  WHERE MONTH(theDate) = 9 AND DAY(Thedate) = 11 
--#################################################################################################
--Saint Patricks Day : March 17 
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') + 'Saint Patricks Day' 
  WHERE MONTH(theDate) = 3 AND DAY(Thedate) = 17
--#################################################################################################
--Halloween Day : October 31
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') + 'Halloween' 
  WHERE MONTH(theDate) = 10 AND DAY(Thedate) = 31
--#################################################################################################
--Cinco de Mayo : May 5
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') + 'Cinco de Mayo' 
  WHERE MONTH(theDate) = 5 AND DAY(Thedate) = 5
--#################################################################################################
--Groundhog Day : Feb 2
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') + 'Groundhog Day' 
  WHERE MONTH(theDate) = 2 AND DAY(Thedate) = 2
--#################################################################################################
--April Fools Day : Feb 2
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') + 'April Fools Day' 
  WHERE MONTH(theDate) = 4 AND DAY(Thedate) = 1
--#################################################################################################
--Fathers Day third Sunday of June 
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') + 'Fathers Day' 
    WHERE TheDate IN( SELECT 
                        DATEADD(wk,2,DATEADD(DAY, (8-DATEPART(weekday, 
                        DATEADD(MONTH, 1 + DATEDIFF(MONTH, 0, TheDate), 0)))%7,  
                        DATEADD(MONTH, 1 + DATEDIFF(MONTH, 0, TheDate), 0)) )
                      FROM tallycalendar
                      WHERE MONTH(TheDate) = 5 ) --calculation is first sunday of next month) 
 
--#################################################################################################
--Mothers Day Second Sunday of May
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') + 'Mothers Day' 
  WHERE TheDate IN( SELECT 
                        DATEADD(wk,1,DATEADD(DAY, (8-DATEPART(weekday, 
                        DATEADD(MONTH, 1 + DATEDIFF(MONTH, 0, TheDate), 0)))%7,  
                        DATEADD(MONTH, 1 + DATEDIFF(MONTH, 0, TheDate), 0)) )
                      FROM tallycalendar
                      WHERE MONTH(TheDate) = 5 ) --calculation is first sunday of next month) 
--#################################################################################################                      
--Grandparents' Day [first sunday after Labor Day], which is the first Monday in September
--so it's labor day plus six days
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') + 'Grandparents Day' 
  WHERE TheDate = DATEADD(dd,6,DATEADD(wk,DATEDIFF(wk,0,DATEADD(dd,6 - DATEPART(DAY,TheDate),TheDate)), 0))
    AND  MONTH(theDate) = 9

--#################################################################################################
--Guy Fawkes Day November 5
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') + 'Guy Fawkes Day' 
  WHERE MONTH(theDate) = 11 AND DAY(Thedate) = 5
--#################################################################################################
--Mardi Gras : Ash Wednesday is always 46 days before Easter 
--and Mardi Gras/Fat Tuesday is always the day before Ash Wednesday
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') + 'Mardi Gras/Fat Tuesday' 
  WHERE TheDate = DATEADD(dd,-47,dbo.fcn_FindEasterSunday(YEAR(TheDate)))
--#################################################################################################
--Election Day [first tuesday after first monday in Nov]
--finding the first monday, adding 1 day to it
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') + 'Election Day' 
  WHERE TheDate = DATEADD(dd,1,DATEADD(wk,DATEDIFF(wk,0,DATEADD(dd,6 - DATEPART(DAY,TheDate),TheDate)), 0))
    AND  MONTH(theDate) = 11
--#################################################################################################
--Hannukkah
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') + 'Hannukkah/Chanukah' 
  WHERE TheDate = dbo.FindChanukah(YEAR(TheDate))
--#################################################################################################
--Passover
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') + 'Passover' 
  WHERE TheDate = dbo.Passover(YEAR(TheDate))
--#################################################################################################
-- Rosh Hashanah occurs 163 days after the first day of Passover
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') + 'Rosh Hashanah' 
  WHERE TheDate = DATEADD(dd,163,dbo.Passover(YEAR(TheDate)))
--#################################################################################################
--Yom Kippur : ten days after Rosh Hashanah
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') + 'Yom Kippur' 
  WHERE TheDate = DATEADD(dd,173,dbo.Passover(YEAR(TheDate)))
--#################################################################################################
--Lunar Phases from Function
  UPDATE TallyCalendar
    SET TallyCalendar.LunarPhase = myAlias.Phase
  FROM (SELECT * 
        FROM TallyCalendar 
        CROSS APPLY dbo.sp_LunarPhaseITVF(TheDate) 
        ) myAlias
  WHERE TallyCalendar.TheDate = myAlias.TheDate  
  --#################################################################################################
  
--#################################################################################################
--helper function for getting the DST and offset , at least for now, for just EST.
--#################################################################################################
GO
IF OBJECT_ID('Get_LocalDateTimeITVF') IS NOT NULL
  DROP FUNCTION dbo.Get_LocalDateTimeITVF
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
CREATE FUNCTION dbo.Get_LocalDateTimeITVF (@UTCDateTime DATETIME, @Zone VARCHAR(3))
RETURNS TABLE
  WITH SCHEMABINDING
AS
RETURN(SELECT CASE 
                WHEN @Zone = 'EST'
                --starting at 8am, then subtracting either 5 or 4 hours depending on the DST or not.
                THEN DATEADD(hh,5 - TallyCalendar.IsDaylightSavings ,DATEADD(hh,8,DATEADD(dd,DATEDIFF(dd,0,@UTCDateTime), 0)))
                ELSE --no logic was included for CST/PST/other timezones; leaves the value at NULL!
                     --logically expects that only EST will ever be used/passed.?!?
                     DATEADD(hh,- 5 + TallyCalendar.IsDaylightSavings ,DATEADD(dd, DATEDIFF(dd,0,@UTCDateTime), 0))
              END AS TheDate
       FROM dbo.TallyCalendar WHERE DATEADD(dd, DATEDIFF(dd,0,@UTCDateTime), 0) = TheDate
       )
GO
--#################################################################################################
--assign DST for 2006 and before.  sp_kill perfect900
--first sunday in April thru the last sunday in October.
--#################################################################################################
UPDATE n
  SET n.HolidayName       = COALESCE(n.HolidayName + ',','')  + 'DST Begins',
      n.IsDaylightSavings = 1
--select DATEPART(weekday, TheDate),* 
FROM TallyCalendar n 
WHERE n.TheDate= dbo.fnGetNthWeekdayOfMonth(n.TheDate,7,1) --@p1 1 =monday, 7 = sunday,@p2 1 = first,
  AND MONTH(n.TheDate) = 4
  AND n.TheDate < '2007-01-01 00:00:00' 
--#################################################################################################
--assign DST for 2007 and After.
--second Sunday in March to the first Sunday in November
--#################################################################################################
UPDATE n
  SET n.HolidayName       = COALESCE(n.HolidayName + ',','')  + 'DST Begins',
      n.IsDaylightSavings = 1
--select DATEPART(weekday, TheDate),* 
FROM TallyCalendar n 
WHERE n.TheDate= dbo.fnGetNthWeekdayOfMonth(n.TheDate,7,2) --@p2 1 =monday, 7 = sunday,@p3 2 = second,
  AND MONTH(n.TheDate) = 3
  AND TheDate >= '2007-01-01 00:00:00' 
--#################################################################################################
--assign DST ENDS for 2006 and before.
--DST Ends: --first sunday in April thru the last sunday in October.
--#################################################################################################
--that is nothing more than the first sunday in november minus 7 days...reuse the above logic.
UPDATE TallyCalendar
SET TallyCalendar.HolidayName       = COALESCE(TallyCalendar.HolidayName + ',','')  + 'DST Ends',
    TallyCalendar.IsDaylightSavings = 0
FROM (
      SELECT * 
      FROM TallyCalendar n 
      WHERE n.TheDate= dbo.fnGetNthWeekdayOfMonth(n.TheDate,7,1) --1 = sunday,1 = first,
        AND MONTH(n.TheDate) = 11
        AND TheDate < '2007-01-01 00:00:00' ) FirstSunOfNov
WHERE TallyCalendar.TheDate = DATEADD(DAY,-7,FirstSunOfNov.TheDate)
--#################################################################################################
--assign DST ENDS for 2007 and after.
--DST Ends: second Sunday in March to the first Sunday in November
--#################################################################################################
UPDATE n
  SET n.HolidayName       = COALESCE(n.HolidayName + ',','')  + 'DST Ends',
      n.IsDaylightSavings = 0
--select DATEPART(weekday, TheDate),* 
FROM TallyCalendar n 
WHERE n.TheDate= dbo.fnGetNthWeekdayOfMonth(n.TheDate,7,1) --@p2 1 =monday, 7 = sunday,@p3 1= first,
  AND MONTH(n.TheDate) = 11
  AND TheDate >= '2007-01-01 00:00:00' 
--################################################################################################# 
--now assign our boolean flags if needed.
--#################################################################################################
  ;WITH myAlias AS (
  SELECT 
    x.sYear,
    x.DSTBegins,
    y.DSTEnds
  FROM
   (SELECT YEAR(TheDate) AS  sYear,TheDate AS DSTBegins
    FROM TallyCalendar 
    WHERE HolidayName LIKE '%DST Begins%' 
    ) X
  INNER JOIN
   (SELECT YEAR(TheDate) AS  sYear,DATEADD(DAY,-1,TheDate) AS DSTEnds 
    FROM TallyCalendar 
    WHERE HolidayName LIKE '%DST Ends%' 
    ) Y
  ON X.sYear = Y.sYear)
  
  UPDATE TallyCalendar
  SET IsDaylightSavings = 1
  FROM myAlias
  WHERE TheDate BETWEEN myAlias.DSTBegins AND myAlias.DSTEnds
  
--#################################################################################################
--some additional helpful columns
--ALTER TABLE TallyCalendar DROP COLUMN JulianDay
--ALTER TABLE TallyCalendar DROP COLUMN YearNumber
--ALTER TABLE TallyCalendar DROP COLUMN MonthNumber
--ALTER TABLE TallyCalendar DROP COLUMN DayNumber
--ALTER TABLE TallyCalendar DROP COLUMN IsoWeek
--#################################################################################################
--ISO Week, can be different than the built in week of SQL server
ALTER TABLE TallyCalendar 
ADD IsoWeek INT
GO
--now assign the values.

UPDATE TallyCalendar
SET    IsoWeek = ( YEAR(Thedate) * 100 ) 
       + CASE
			 -- Exception where TheDate is part of week 52 (or 53) of the previous year
			 WHEN TheDate < CASE ( DATEPART(dw, CAST(YEAR(TheDate) AS CHAR(4)) + '-01-04') + @@DATEFIRST - 1 ) % 7
							  WHEN 1
							  THEN CAST(YEAR(TheDate) AS CHAR(4)) + '-01-04'
							  WHEN 2
							  THEN DATEADD(d, -1, CAST(YEAR(TheDate) AS CHAR(4)) + '-01-04')
							  WHEN 3
							  THEN DATEADD(d, -2, CAST(YEAR(TheDate) AS CHAR(4)) + '-01-04')
							  WHEN 4
							  THEN DATEADD(d, -3, CAST(YEAR(TheDate) AS CHAR(4)) + '-01-04')
							  WHEN 5
							  THEN DATEADD(d, -4, CAST(YEAR(TheDate) AS CHAR(4)) + '-01-04')
							  WHEN 6
							  THEN DATEADD(d, -5, CAST(YEAR(TheDate) AS CHAR(4)) + '-01-04')
							  ELSE DATEADD(d, -6, CAST(YEAR(TheDate) AS CHAR(4)) + '-01-04')
							END
			 THEN ( DATEDIFF(d, CASE ( DATEPART(dw, CAST(YEAR(TheDate) - 1 AS CHAR(4)) + '-01-04') + @@DATEFIRST - 1 ) % 7
								  WHEN 1
								  THEN CAST(YEAR(TheDate) - 1 AS CHAR(4)) + '-01-04'
								  WHEN 2
								  THEN DATEADD(d, -1, CAST(YEAR(TheDate) - 1 AS CHAR(4)) + '-01-04')
								  WHEN 3
								  THEN DATEADD(d, -2, CAST(YEAR(TheDate) - 1 AS CHAR(4)) + '-01-04')
								  WHEN 4
								  THEN DATEADD(d, -3, CAST(YEAR(TheDate) - 1 AS CHAR(4)) + '-01-04')
								  WHEN 5
								  THEN DATEADD(d, -4, CAST(YEAR(TheDate) - 1 AS CHAR(4)) + '-01-04')
								  WHEN 6
								  THEN DATEADD(d, -5, CAST(YEAR(TheDate) - 1 AS CHAR(4)) + '-01-04')
								  ELSE DATEADD(d, -6, CAST(YEAR(TheDate) - 1 AS CHAR(4)) + '-01-04')
								END, TheDate) / 7 ) + 1
			 -- Exception where TheDate is part of week 1 of the following year
			 WHEN TheDate >= CASE ( DATEPART(dw, CAST(YEAR(TheDate) + 1 AS CHAR(4)) + '-01-04') + @@DATEFIRST - 1 ) % 7
							   WHEN 1
							   THEN CAST(YEAR(TheDate) + 1 AS CHAR(4)) + '-01-04'
							   WHEN 2
							   THEN DATEADD(d, -1, CAST(YEAR(TheDate) + 1 AS CHAR(4)) + '-01-04')
							   WHEN 3
							   THEN DATEADD(d, -2, CAST(YEAR(TheDate) + 1 AS CHAR(4)) + '-01-04')
							   WHEN 4
							   THEN DATEADD(d, -3, CAST(YEAR(TheDate) + 1 AS CHAR(4)) + '-01-04')
							   WHEN 5
							   THEN DATEADD(d, -4, CAST(YEAR(TheDate) + 1 AS CHAR(4)) + '-01-04')
							   WHEN 6
							   THEN DATEADD(d, -5, CAST(YEAR(TheDate) + 1 AS CHAR(4)) + '-01-04')
							   ELSE DATEADD(d, -6, CAST(YEAR(TheDate) + 1 AS CHAR(4)) + '-01-04')
							 END
			 THEN 1
			 ELSE
		   -- Calculate the ISO week number for all dates that are not part of the exceptions above
		   ( DATEDIFF(d, CASE ( DATEPART(dw, CAST(YEAR(TheDate) AS CHAR(4)) + '-01-04') + @@DATEFIRST - 1 ) % 7
						   WHEN 1
						   THEN CAST(YEAR(TheDate) AS CHAR(4)) + '-01-04'
						   WHEN 2
						   THEN DATEADD(d, -1, CAST(YEAR(TheDate) AS CHAR(4)) + '-01-04')
						   WHEN 3
						   THEN DATEADD(d, -2, CAST(YEAR(TheDate) AS CHAR(4)) + '-01-04')
						   WHEN 4
						   THEN DATEADD(d, -3, CAST(YEAR(TheDate) AS CHAR(4)) + '-01-04')
						   WHEN 5
						   THEN DATEADD(d, -4, CAST(YEAR(TheDate) AS CHAR(4)) + '-01-04')
						   WHEN 6
						   THEN DATEADD(d, -5, CAST(YEAR(TheDate) AS CHAR(4)) + '-01-04')
						   ELSE DATEADD(d, -6, CAST(YEAR(TheDate) AS CHAR(4)) + '-01-04')
						 END, TheDate) / 7 ) + 1
		   END 
GO
--#################################################################################################
--Calculated isWorkDay [ISWORKDAY]          AS (case when [IsWorkHoliday]=(1) OR ([DayOfWeek]='Sunday' OR [DayOfWeek]='Saturday') then (0) else (1) end) PERSISTED,
ALTER TABLE TallyCalendar 
ADD IsWorkDay AS (case when [IsWorkHoliday]=(1) OR ([DayOfWeek]='Sunday' OR [DayOfWeek]='Saturday') then (0) else (1) end) PERSISTED
--#################################################################################################
--Julian day of year
ALTER TABLE TallyCalendar 
ADD JulianDay  AS DATEDIFF(dd,DATEADD(yy, DATEDIFF(yy,0,TheDate), 0),TheDate) + 1 PERSISTED
--#################################################################################################
--year
ALTER TABLE TallyCalendar 
ADD YearNumber  AS year(Thedate) PERSISTED
--#################################################################################################
--month
ALTER TABLE TallyCalendar 
ADD MonthNumber  AS DATEDIFF(mm,DATEADD(yy, DATEDIFF(yy,0,TheDate), 0),TheDate) + 1 PERSISTED
--#################################################################################################
--day
ALTER TABLE TallyCalendar 
ADD DayNumber   AS DATEDIFF(dd,DATEADD(mm, DATEDIFF(mm,0,TheDate), 0),TheDate) + 1 PERSISTED
GO
--#################################################################################################

--#################################################################################################
-- Repeating Dates like 11-11-11 only 34 over 100 years
  UPDATE TallyCalendar SET IsHoliday = 1,IsWorkHoliday = 0,HolidayName = COALESCE(HolidayName + ',','') 
  + 'Repeating Date ' + CONVERT(varchar,(YearNumber % 100))  + '-' + CONVERT(varchar,MonthNumber) + '-' + CONVERT(varchar,daynumber)
  WHERE (YearNumber % 100) = MonthNumber
    AND MonthNumber = daynumber
--#################################################################################################

/*
select * from TallyCalendar where year(Thedate) = 2011 and isholiday = 1  ORDER BY THEDATE OR HolidayName IS NOT NULL

--all the holidays
select * from TallyCalendar where HolidayName IS NOT NULL

--two holidays on the same day
select * from TallyCalendar 
where (LEN(HolidayName) - LEN(REPLACE(HolidayName,',','')) > = 1)
ORDER BY THEDATE

--old way to get lunar phases...now a perm column instead.
select * from TallyCalendar
cross apply dbo.sp_LunarPhaseITVF(TheDate)

--all the future friday the 13ths that are also a full moon
select * from (
select * from TallyCalendar
cross apply dbo.sp_LunarPhaseITVF(thedate)
) X
where DAY(thedate) = 13
and [DayOfWeek]='Friday'
and phase='Full Moon'
and TheDate > GETDATE()

--all the future holloweens are also a full moon
select * from (
select * from TallyCalendar
cross apply dbo.sp_LunarPhaseITVF(thedate)
) X
WHERE HolidayName = 'Halloween'
GO
--another example snippet
select * from TallyCalendar where year(TheDate) = 2011 and HolidayName is not null
cross apply dbo.sp_LunarPhaseITVF(TheDate)

*/

--SELECT * FROM TallyCalendar WHERE month(thedate) = 2

/*Cleanup if needed:
DROP FUNCTION [TishaBAv]
DROP FUNCTION [TuBishvat]
DROP FUNCTION [YomHaAtzmaut]
DROP FUNCTION [fcn_FindEasterSunday]
DROP FUNCTION [fnGetNthWeekdayOfMonth]
DROP FUNCTION [Get_LocalDateTimeITVF]
DROP FUNCTION [sp_LunarPhaseITVF]
DROP FUNCTION [FindChanukah]
DROP FUNCTION [Passover]
DROP TABLE [TallyCalendar]
*/

