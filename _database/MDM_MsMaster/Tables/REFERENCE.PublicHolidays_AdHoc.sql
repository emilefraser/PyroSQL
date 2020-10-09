SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [REFERENCE].[PublicHolidays_AdHoc](
	[HolidayID] [smallint] IDENTITY(1,1) NOT NULL,
	[HolidayName] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[HolidayDate] [date] NULL,
	[CountryID] [smallint] NOT NULL,
	[StartDT] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[EndDT] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	PERIOD FOR SYSTEM_TIME ([StartDT], [EndDT])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [REFERENCE].[PublicHolidays_AdHoc_History] )
)

GO
