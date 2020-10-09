SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



CREATE VIEW [INTEGRATION].[vw_egress_TimeDimension] AS
SELECT [CalendarDate]
      ,[IsWeekend]
      ,[Year]
      ,[QuarterNo]
      ,[MonthNumber]
      ,[DayofYear]
      ,[Day]
      ,[Week]
      ,[DayofWeekNo]
      ,[DayofWeek]
      ,[DayofWeekAbbreviation]
      ,[Month]
      ,[MonthAbbreviation]
      ,[FinancialYear]
      ,[FinancialPeriodNo]
      ,[YearFinancialPeriod]
      ,[FinancialPeriod]
      ,[FinancialQuarterNo]
      ,[FinancialYearQuarter]
      ,[FinancialQuarter]
      ,[MonthBeginDate]
      ,[MonthEndDate]
      ,[WeekBeginDate]
      ,[WeekEndDate]
      ,[IsToday]
      ,[IsCurrentWeek]
      ,[IsCurrentMonth]
      ,[IsPublicHoliday]
      ,[IsSchoolHoliday]
      ,[IsInLast7Days]
      ,[IsInLast30Days]
  FROM [MASTER].[TimeDimension]

GO
