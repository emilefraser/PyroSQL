SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dimension].[vw_DimDate]'))
EXEC dbo.sp_executesql @statement = N'

-- =========================================================================
-- Created By		: Emile Fraser
-- Created Date		: 2020-09-05
-- Description		: Standard Date Dimension
-- Changelog		: Init of the Date Dimension (2020-09-05)
-- ==========================================================================
CREATE   VIEW [dimension].[vw_DimDate]
AS 
SELECT 
       [CalendarDateValue] AS DateKey
	  ,[CalendarDate]
      ,[CalendarDateTime]
      ,[DayOfWeek]
      ,[DayOfWeekValue]
      ,[DayOfWeekName]
      ,[DayOfWeekNameAbbreviation]
      ,[DayOfMonth]
      ,[DayOfMonthValue]
      ,[DayOfQuarter]
      ,[DayOfQuarterValue]
      ,[DayOfYear]
      ,[DayOfYearValue]
      ,[DayOfYearName]
      ,[WeekOfYear]
      ,[WeekOfYearValue]
      ,[WeekOfYearName]
      ,[WeekOfMonth]
      ,[MonthOfYear]
      ,[MonthOfYearValue]
      ,[MonthOfYearName]
      ,[MonthOfYearAbbreviation]
      ,[QuarterOfYear]
      ,[QuarterOfYearValue]
      ,[QuarterOfYearName]
      ,[HalOfYear]
      ,[HalfOfYearValue]
      ,[HalfOfYearName]
      ,[Year]
      ,[YearValue]
      ,[YearName]
      ,[WeekStartDate]
      ,[MonthStartDate]
      ,[MonthEndDate]
      ,[QuarterStartDate]
      ,[QuarterEndDate]
      ,[YearStartDate]
      ,[YearEndDate]
      ,[PreviousYear]
      ,[SameCalendarDatePreviousYear]
      ,[NextYear]
      ,[SameCalendarDateNextYear]
      ,[DayOfYearIndex]
      ,[WeekIndex]
      ,[MonthIndex]
      ,[QuarterIndex]
      ,[YearIndex]
      ,[YearDayOfYear]
      ,[YearWeekOfYear]
      ,[YearMonthOfYear]
      ,[YearQuarterOfYear]
      ,[YearMonthOfYearValue]      
      ,[IsWeekend]
      ,[IsPublicHoliday]
      ,[IsWorkDay]
      ,[IsSchoolHoliday]
	  ,[IsToday]
	  ,[IsInLast7Days]
	  ,[IsInLast7DaysIncludingToday]
	  ,[IsInLast30Days]
	  ,[IsInLast30DaysIncludingToday]
	  ,[IsPastDate]
	  ,[IsFutureDate]
  FROM [dimension].[DateDimension2]
' 
GO
