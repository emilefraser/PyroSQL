SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [MASTER].[TimeDimension](
	[CalendarDate] [date] NOT NULL,
	[IsWeekend] [bit] NULL,
	[Year] [smallint] NULL,
	[QuarterNo] [tinyint] NULL,
	[MonthNumber] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DayofYear] [smallint] NULL,
	[Day] [tinyint] NULL,
	[Week] [tinyint] NULL,
	[DayofWeekNo] [tinyint] NULL,
	[DayofWeek] [varchar](9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DayofWeekAbbreviation] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Month] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MonthAbbreviation] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FinancialYear] [int] NULL,
	[FinancialPeriodNo] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[YearFinancialPeriod] [varchar](7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FinancialPeriod] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FinancialQuarterNo] [tinyint] NULL,
	[FinancialYearQuarter] [varchar](7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FinancialQuarter] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MonthBeginDate] [date] NULL,
	[MonthEndDate] [date] NULL,
	[WeekBeginDate] [date] NULL,
	[WeekEndDate] [date] NULL,
	[IsToday] [bit] NULL,
	[IsCurrentWeek] [bit] NULL,
	[IsCurrentMonth] [bit] NULL,
	[IsPublicHoliday] [bit] NULL,
	[IsSchoolHoliday] [bit] NULL,
	[IsInLast7Days] [bit] NULL,
	[IsInLast30Days] [bit] NULL,
	[IsInLast7DaysIncludingToday] [bit] NULL,
	[IsInLast30DaysIncludingToday] [bit] NULL
) ON [PRIMARY]

GO
