SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [MASTER].[PublicHolidays_FixedDate](
	[HolidayID] [int] IDENTITY(1,1) NOT NULL,
	[HolidayMonthNo] [smallint] NOT NULL,
	[HolidayMonthDayNo] [smallint] NOT NULL,
	[HolidayName] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[HolidayStartDate] [date] NULL,
	[HolidayEndDate] [date] NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY]

GO
