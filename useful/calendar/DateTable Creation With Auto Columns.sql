USE [Core_DW]
GO

/****** Object:  Table [dbo].[Calendar]    Script Date: 2018-05-21 03:13:43 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

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


