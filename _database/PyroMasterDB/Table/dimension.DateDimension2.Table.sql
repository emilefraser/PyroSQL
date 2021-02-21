SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dimension].[DateDimension2]') AND type in (N'U'))
BEGIN
CREATE TABLE [dimension].[DateDimension2](
	[CalendarDate] [date] NOT NULL,
	[CalendarDateValue]  AS (CONVERT([int],format([CalendarDate],'yyyyMMdd'))),
	[CalendarDateTime]  AS (CONVERT([datetime2](7),[CalendarDate])),
	[DayOfWeek]  AS (CONVERT([varchar](2),datepart(weekday,[CalendarDate]))),
	[DayOfWeekValue]  AS (CONVERT([tinyint],datepart(weekday,[CalendarDate]))),
	[DayOfWeekName]  AS (CONVERT([varchar](10),datename(weekday,[CalendarDate]))),
	[DayOfWeekAbbreviation]  AS (CONVERT([varchar](3),datename(weekday,[CalendarDate]))),
	[DayOfMonth]  AS (CONVERT([varchar](2),format(datepart(day,[CalendarDate]),'00'))),
	[DayOfMonthValue]  AS (CONVERT([tinyint],datepart(day,[CalendarDate]))),
	[DayOfQuarter]  AS (CONVERT([varchar](2),format(datediff(day,dateadd(quarter,datediff(quarter,(0),[CalendarDate]),(0)),[CalendarDate])+(1),'00'))),
	[DayOfQuarterValue]  AS (CONVERT([tinyint],datediff(day,dateadd(quarter,datediff(quarter,(0),[CalendarDate]),(0)),[CalendarDate])+(1))),
	[DayOfHalfYear]  AS (CONVERT([varchar](3),format(datediff(day,dateadd(month,((datepart(month,[CalendarDate])-(1))/(6))*(6),dateadd(year,datepart(year,[CalendarDate])-(1900),(0))),[CalendarDate]),'000'))),
	[DayOfHalfYearValue]  AS (CONVERT([tinyint],datediff(day,dateadd(quarter,datediff(quarter,(0),[CalendarDate]),(0)),[CalendarDate])+(1))),
	[DayOfYear]  AS (CONVERT([varchar](3),format(datediff(day,dateadd(year,datediff(year,(0),[CalendarDate]),(0)),[CalendarDate])+(1),'000'))),
	[DayOfYearValue]  AS (CONVERT([smallint],datediff(day,dateadd(year,datediff(year,(0),[CalendarDate]),(0)),[CalendarDate])+(1))),
	[DayOfYearCode]  AS (CONVERT([varchar](4),'D'+format(datediff(day,dateadd(year,datediff(year,(0),[CalendarDate]),(0)),[CalendarDate])+(1),'000'))),
	[WeekOfMonth]  AS (CONVERT([varchar](1),format(datediff(week,dateadd(month,datediff(month,(0),[CalendarDate]),(0)),[CalendarDate])+(1),'0'))),
	[WeekOfMonthValue]  AS (CONVERT([tinyint],datediff(week,dateadd(month,datediff(month,(0),[CalendarDate]),(0)),[CalendarDate])+(1))),
	[WeekOfQuarter]  AS (CONVERT([varchar](2),format(datediff(week,dateadd(quarter,datediff(quarter,(0),[CalendarDate]),(0)),[CalendarDate])+(1),'00'))),
	[WeekOfQuarterValue]  AS (CONVERT([tinyint],datediff(week,dateadd(quarter,datediff(quarter,(0),[CalendarDate]),(0)),[CalendarDate])+(1))),
	[WeekOfHalfYear]  AS (CONVERT([varchar](3),format(case when datepart(month,[CalendarDate])<=(6) then datepart(week,[CalendarDate]) else datediff(week,dateadd(month,(6),dateadd(year,datediff(year,(0),[CalendarDate]),(0))),[CalendarDate])+(1) end,'00'))),
	[WeekOfHalfYearValue]  AS (CONVERT([tinyint],case when datepart(month,[CalendarDate])<=(6) then datepart(week,[CalendarDate]) else datediff(week,dateadd(month,(6),dateadd(year,datediff(year,(0),[CalendarDate]),(0))),[CalendarDate])+(1) end)),
	[WeekOfYear]  AS (CONVERT([varchar](3),format(datepart(week,[CalendarDate]),'00'))),
	[WeekOfYearValue]  AS (CONVERT([smallint],datepart(week,[CalendarDate]))),
	[WeekOfYearCode]  AS (CONVERT([varchar](4),'W'+format(datepart(week,[CalendarDate]),'00'))),
	[MonthOfQuarter]  AS (CONVERT([varchar](1),format(datediff(month,dateadd(quarter,datediff(quarter,(0),[CalendarDate]),(0)),[CalendarDate])+(1),'0'))),
	[MonthOfQuarterValue]  AS (CONVERT([tinyint],datediff(month,dateadd(quarter,datediff(quarter,(0),[CalendarDate]),(0)),[CalendarDate])+(1))),
	[MonthOfHalfYear]  AS (CONVERT([varchar](3),format(case when datepart(month,[CalendarDate])<=(6) then datepart(month,[CalendarDate]) else datediff(month,dateadd(month,(6),dateadd(year,datediff(year,(0),[CalendarDate]),(0))),[CalendarDate])+(1) end,'00'))),
	[MonthOfHalfYearValue]  AS (CONVERT([tinyint],case when datepart(month,[CalendarDate])<=(6) then datepart(month,[CalendarDate]) else datediff(month,dateadd(month,(6),dateadd(year,datediff(year,(0),[CalendarDate]),(0))),[CalendarDate])+(1) end)),
	[MonthOfYear]  AS (CONVERT([varchar](3),format(datepart(month,[CalendarDate]),'00'))),
	[MonthOfYearValue]  AS (CONVERT([smallint],datepart(month,[CalendarDate]))),
	[MonthOfYearCode]  AS (CONVERT([varchar](3),'M'+format(datepart(month,[CalendarDate]),'00'))),
	[QuarterOfHalfYear]  AS (CONVERT([varchar](1),format((2)-datepart(quarter,[CalendarDate])%(2),'0'))),
	[QuarterOfHalfYearValue]  AS (CONVERT([tinyint],(2)-datepart(quarter,[CalendarDate])%(2))),
	[QuarterOfYear]  AS (CONVERT([varchar](1),format(datepart(quarter,[CalendarDate]),'0'))),
	[QuarterOfYearValue]  AS (CONVERT([smallint],datepart(quarter,[CalendarDate]))),
	[QuarterOfYearCode]  AS (CONVERT([varchar](2),'Q'+format(datepart(quarter,[CalendarDate]),'0'))),
	[HalfYearOfYear]  AS (CONVERT([varchar](1),format(case when datepart(month,[CalendarDate])<=(6) then (1) else (2) end,'0'))),
	[HalfYearOfYearValue]  AS (CONVERT([smallint],case when datepart(month,[CalendarDate])<=(6) then (1) else (2) end)),
	[HalfYearOfYearCode]  AS (CONVERT([varchar](3),'H'+format(case when datepart(month,[CalendarDate])<=(6) then (1) else (2) end,'0'))),
	[WeekStartDate]  AS (CONVERT([date],dateadd(day, -(datepart(weekday,[CalendarDate])-(1)),[CalendarDate]))),
	[WeekEndDate]  AS (CONVERT([date],dateadd(day,(7)-datepart(weekday,[CalendarDate]),[CalendarDate]))),
	[MonthStartDate]  AS (CONVERT([date],dateadd(day,(1),eomonth([CalendarDate],(-1))))),
	[MonthEndDate]  AS (CONVERT([date],eomonth([CalendarDate]))),
	[QuarterStartDate]  AS (CONVERT([date],dateadd(quarter,datediff(quarter,(0),[CalendarDate]),(0)))),
	[QuarterEndDate]  AS (CONVERT([date],dateadd(day,(-1),dateadd(quarter,datediff(quarter,(0),[CalendarDate])+(1),(0))))),
	[HalfYearStartDate]  AS (CONVERT([date],dateadd(month,((datepart(month,[CalendarDate])-(1))/(6))*(6),dateadd(year,datepart(year,[CalendarDate])-(1900),(0))))),
	[HalfYearEndDate]  AS (CONVERT([date],dateadd(month,((datepart(month,[CalendarDate])-(1))/(6))*(6)+(6),dateadd(year,datepart(year,[CalendarDate])-(1900),(-1))))),
	[YearStartDate]  AS (CONVERT([date],dateadd(year,datediff(year,(0),[CalendarDate]),(0)))),
	[YearEndDate]  AS (CONVERT([date],dateadd(day,(-1),dateadd(year,datediff(year,(0),[CalendarDate])+(1),(0))))),
PRIMARY KEY CLUSTERED 
(
	[CalendarDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
