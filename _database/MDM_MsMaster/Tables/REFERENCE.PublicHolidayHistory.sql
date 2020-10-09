SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [REFERENCE].[PublicHolidayHistory](
	[HolidayID] [smallint] NOT NULL,
	[HolidayMonthValue] [smallint] NOT NULL,
	[HolidayDayValue] [smallint] NOT NULL,
	[HolidayName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[HolidayStartDate] [date] NULL,
	[HolidayEndDate] [date] NULL,
	[CountryID] [smallint] NOT NULL,
	[StartDT] [datetime2](7) NOT NULL,
	[EndDT] [datetime2](7) NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)

GO
