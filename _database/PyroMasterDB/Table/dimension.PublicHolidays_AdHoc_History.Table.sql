SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dimension].[PublicHolidays_AdHoc_History]') AND type in (N'U'))
BEGIN
CREATE TABLE [dimension].[PublicHolidays_AdHoc_History](
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
END
GO
