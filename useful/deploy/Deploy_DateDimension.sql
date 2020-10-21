

USE [DATAMANAGER]
GO
-- Metadata --
/* ========================================================================================================================
	Created by	:	Emile Fraser
	Dreated on	:	2020-01-31
	Function	:	Standard Stored Procedure Pattern (with error handling)
	Description	:	Desription of what this procedure does and how
				
			-- Features:
			-- Auto update Today, 1 week, 1 month flags
			-- Auto create the Public Holiday items
			-- Creates both Calendar and Financial Calendars
			-- Specify first day of the week
			-- Creates indexes to make yoy mom wow calcs easy
			-- Week numbers
			-- CREATES FROM TABLES WITH SCHOOL HOLIDAYS
			-- THIS IS THE MAIN SCRIPT THAT ONLY CREATES THE STRUCTURE OF THE 
			-- deployment package and has the logic for the function and the 
			-- schema for the tables
			-- THIS IS ONLY FOR STANDARD CALENDARS, those starting on first of a month, ending on the
			-- last day of that month
======================================================================================================================== */

-- Changelog & TODO --
/* ========================================================================================================================
	 2020-04-01	:	Ruan van Jaarsveld initial script with holidays and Easter function

	 TODO		:	Check if the if the helper tables exist 

======================================================================================================================== */

-- Execution & Testing --
/* ========================================================================================================================
    DECLARE @Param1 INT = 10
    DECLARE @Param2 INT = 20
    DECLARE @Param3 INT
    EXEC MASTER.StoredProcedure_Template_WithError
			    @Param1 = @Param1
		    ,	@Param2 = @Param2 
            ,	@Param3 = @Param3 OUTPUT
    PRINT(CONVERT(VARCHAR(MAX), @Param3))
    SELECT * FROM dbo.ActionTable
    truncate table  dbo.ActionTable
======================================================================================================================== */

CREATE OR ALTER PROCEDURE [MASTER].[Create_DateDimension]

	@StartOfDateDimension			DATE
,	@EndDateOfDateDimension			DATE
,	@FirstMonthOfFinancialPeriod	SMALLINT	=	1
,	@FirstDayOfWeekName				VARCHAR(10)	=	'Monday'

AS
BEGIN

	/* Checks if the 3 helper tables exists */
	-- Drops existing dimension
	DROP TABLE IF EXISTS [MASTER].[DateDimension]

	-- year quarter
	-- year month
	-- year day
	-- index date
	-- auto incoude public holidays
	-- way to generate financial calendar
	-- wat to specify first day of the week
	CREATE TABLE [MASTER].[DateDimension] (

		-- Primary Key and only value we will populate, the rest will be calculated
		[CalendarDate]                     DATE NOT NULL	PRIMARY KEY CLUSTERED

		-- 5, 05
,		[DayOfMonth]                       TINYINT NULL
,		[DayOfMonthAlternate]              VARCHAR(2) NULL

		-- 3, Wednesday, Wed
,		[DayOfWeek]                        TINYINT NULL
,		[DayOfWeekName]                    VARCHAR(9) NULL
,		[DayOfWeekNameAbbreviation]        VARCHAR(3) NULL

		-- 6, 06, Week 6, Week 06, W6, W06
,		[Week]                             TINYINT NULL
,		[WeekAlternate]                    VARCHAR(2) NULL
,		[WeekName]                         VARCHAR(7) NULL
,		[WeekNameAlternate]                VARCHAR(8) NULL
,		[WeekNameAbbreviation]             VARCHAR(3) NULL
,		[WeekNameAbbreviationAlternate]    VARCHAR(3) NULL

		-- 9, 09, September, Sep
,		[Month]                            TINYINT NULL
,		[MonthAlternate]                   VARCHAR(2) NULL
,		[MonthName]                        VARCHAR(9) NULL
,		[MonthNameAbbreviation]            VARCHAR(3) NULL

		-- 3, Quarter 3, Q03, Q3
,		[Quarter]                          TINYINT NULL
,		[QuarterName]                      VARCHAR(8) NULL
,		[QuarterNameAbbreviation]          VARCHAR(2) NULL
,		[QuarterNameAbbreviationAlternate] VARCHAR(2) NULL

		-- 2020, CY2020, CY20
,		[Year]                             SMALLINT NULL
,		[YearName]                         VARCHAR(6) NULL
,		[YearAbbreviation]                 VARCHAR(4) NULL

		-- All the remaining Day Of
,		[DayOfQuarter]                     TINYINT NULL
,		[DayOfYear]                        TINYINT NULL

		-- Start and End Dates
,		[MonthBeginDate]                   DATE NULL
,		[MonthEndDate]                     DATE NULL
,		[WeekBeginDate]                    DATE NULL
,		[WeekEndDate]                      DATE NULL

		-- Previous & Next Year Dates
,		[PreviousYear]						INT NULL
,		[PreviousYearDate]					DATE NULL
,		[NextYear]							INT NULL
,		[NextYearDate]						DATE NULL

		-- Combatronics
		-- Year & Day
		-- 2020075, CY2020D075, 2020-075
,		[YearDay]							INT NULL
,		[YearDayName]						VARCHAR(9) NULL		
,		[YearDayAlternate]					VARCHAR(8)

		-- Year & Week
		-- 202009, 20209, CY2020W09
,		[YearWeek]							INT NULL
,		[YearWeekAlternate]					INT NULL
,		[YearWeekName]						VARCHAR(8)

		-- Year & Month
		-- 202009, CY2020M09, 2020-09
,		[YearMonth]							INT NULL
,		[YearMonthName]						VARCHAR(8) NULL		
,		[YearMonthAlternate]				VARCHAR(7) NULL

		-- Year & Quarter
		-- 202003, CY2020Q03, 2020-03
,		[YearQuarter]						INT NULL
,		[YearQuarterName]					VARCHAR(8) NULL		
,		[YearQuarterAlternate]				VARCHAR(7) NULL

		-- Quarter & Day
		-- Q01D075, Q01-D075
,		[QuarterDayName]					VARCHAR(7) NULL		
,		[QuarterDayNameAlternate]			VARCHAR(8) NULL	

		-- Quarter & Month
		-- Q01M01, Q01-M02
,		[QuarterMonthName]					VARCHAR(6) NULL		
,		[QuarterMonthNameAlternate]			VARCHAR(7) NULL	

		-- Quarter & Week
		-- Q01W01, Q01-W02
,		[QuarterWeekName]					VARCHAR(6) NULL		
,		[QuarterWeekNameAlternate]			VARCHAR(7) NULL	

		-- Month & Week
		-- M01W01, M01-W02
,		[MonthWeekName]						VARCHAR(6) NULL		
,		[MonthWeekNameAlternate]			VARCHAR(7) NULL	


		-- Indexes for relative period calculations
,		[DayIndex]							INT NULL
,		[WeekIndex]							INT NULL
,		[MonthIndex]						INT NULL
,		[QuarterIndex]						INT NULL
,		[YearIndex]							INT NULL

		-- FOR Now Financial Period will just carry value, and that is relative start days + or -
,		FinancialPeriod_Adjustor			INT NULL

		-- Finally all the boolean fields
,		[IsToday]							BIT NULL
,		[IsWeekend]							BIT NULL
,		[IsPublicHoliday]					BIT NULL
,		[IsCurrentWeek]						BIT NULL
,		[IsCurrentCalendarMonth]			BIT NULL

,		[IsSchoolHoliday]					BIT NULL

,		[IsInLast7Days]						BIT NULL
,		[IsInLast30Days]					BIT NULL

)




CREATE TABLE [dbo].[Calendar](
	[CalendarDate] [date] NOT NULL,
	[CalendarDay]  AS (datepart(day,[CalendarDate])),
	[CalendarMonth]  AS (datepart(month,[CalendarDate])),
	[CalMonth]  AS (datename(month,[CalendarDate])),
	[CalendarWeek]  AS (datepart(week,[CalendarDate])),
	[CalendarDayOfWeek]  AS (datepart(weekday,[CalendarDate])),
	[CalendarQuarter]  AS (datepart(quarter,[CalendarDate])),
	[CalendarYear]  AS (datepart(year,[CalendarDate])),
	[isHoliday] [bit] NULL,
	[HolidayName] [varchar](100) NULL,
	[isWeekend] [bit] NULL,
	[CalendarDayOfYear] [int] NULL,
	[CalendarDateTime] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[CalendarDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO




---- =============================================
---- Author:      RE van Jaarsveld
---- Create Date: 30/03/2020
---- Description: Generates Easter SUnday date for year provided
---- =============================================
--CREATE FUNCTION dbo.GetEasterSunday 
--( @Y INT ) 
--RETURNS SMALLDATETIME 
--AS 
--BEGIN 
--    DECLARE     @EpactCalc INT,  
--        @PaschalDaysCalc INT, 
--        @NumOfDaysToSunday INT, 
--        @EasterMonth INT, 
--        @EasterDay INT 
--    SET @EpactCalc = (24 + 19 * (@Y % 19)) % 30 
--    SET @PaschalDaysCalc = @EpactCalc - (@EpactCalc / 28) 
--    SET @NumOfDaysToSunday = @PaschalDaysCalc - ( 
--        (@Y + @Y / 4 + @PaschalDaysCalc - 13) % 7 
--    ) 
--    SET @EasterMonth = 3 + (@NumOfDaysToSunday + 40) / 44 
--    SET @EasterDay = @NumOfDaysToSunday + 28 - ( 
--        31 * (@EasterMonth / 4) 
--    ) 
--    RETURN 
--    ( 
--        SELECT CONVERT 
--        (  SMALLDATETIME, 
--                 RTRIM(@Y)  
--            + RIGHT('0'+RTRIM(@EasterMonth), 2)  
--            + RIGHT('0'+RTRIM(@EasterDay), 2)  
--        ) 
--    ) 
--END 
--GO
--CREATE OR ALTER PROCEDURE dbo.Set_DateDimension
--AS
---- Drops existing dimension
--DROP TABLE IF EXISTS [dbo].[DateDimension]
---- year quarter
---- year month
---- year day
---- index date
---- auto incoude public holidays
---- way to generate financial calendar
---- wat to specify first day of the week
--CREATE TABLE [dbo].[DateDimension](
--	[CalendarDate] [date] NOT NULL,
--	[IsWeekend] [bit] NULL,
--	[Year] [smallint] NULL,
--	[QuarterNo] [tinyint] NULL,
--	[MonthNumber] [varchar](2) NULL,
--	[DayofYear] [smallint] NULL,
--	[Day] [tinyint] NULL,
--	[Week] [tinyint] NULL,
--	[DayofWeekNo] [tinyint] NULL,
--	[DayofWeek] [varchar](9) NULL,
--	[DayofWeekAbbreviation] [varchar](3) NULL,
--	[Month] [varchar](20) NULL,
--	[MonthAbbreviation] [varchar](5) NULL,
--	[FinancialYear] [int] NULL,
--	[FinancialPeriodNo] [varchar](2) NULL,
--	[YearFinancialPeriod] [varchar](7) NULL,
--	[FinancialPeriod] [varchar](3) NULL,
--	[FinancialQuarterNo] [tinyint] NULL,
--	[FinancialYearQuarter] [varchar](7) NULL,
--	[FinancialQuarter] [varchar](2) NULL,
--	[MonthBeginDate] [date] NULL,
--	[MonthEndDate] [date] NULL,
--	[WeekBeginDate] [date] NULL,
--	[WeekEndDate] [date] NULL,
--	[PreviousYear] [int] NULL,
--	[PreviousYearDate] [date] NULL,
--	[IsToday] [bit] NULL,
--	[IsCurrentWeek] [bit] NULL,
--	[IsCurrentMonth] [bit] NULL,
--	[IsPublicHoliday] [bit] NULL,
--	[IsSchoolHoliday] [bit] NULL,
--	[IsInLast7Days] [bit] NULL,
--	[IsInLast30Days] [bit] NULL,
--PRIMARY KEY CLUSTERED 
--(
--	[CalendarDate] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
--) ON [PRIMARY]
--GO