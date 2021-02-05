SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [REFERENCE].[PublicHolidays_AdHoc_History](
	[HolidayID] [smallint] NOT NULL,
	[HolidayName] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[HolidayDate] [date] NULL,
	[CountryID] [smallint] NOT NULL,
	[StartDT] [datetime2](7) NOT NULL,
	[EndDT] [datetime2](7) NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)

GO
