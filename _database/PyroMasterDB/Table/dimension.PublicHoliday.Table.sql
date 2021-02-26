SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dimension].[PublicHoliday]') AND type in (N'U'))
BEGIN
CREATE TABLE [dimension].[PublicHoliday](
	[HolidayID] [smallint] IDENTITY(1,1) NOT NULL,
	[HolidayMonthValue] [smallint] NOT NULL,
	[HolidayDayValue] [smallint] NOT NULL,
	[HolidayName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[HolidayStartYear] [smallint] NULL,
	[HolidayEndYear] [smallint] NULL,
	[CountryID] [smallint] NOT NULL,
	[StartDT] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[EndDT] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[HolidayID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([StartDT], [EndDT])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [dimension].[PublicHoliday_History] )
)
END
GO
