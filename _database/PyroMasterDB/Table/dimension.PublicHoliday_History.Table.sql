SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dimension].[PublicHoliday_History]') AND type in (N'U'))
BEGIN
CREATE TABLE [dimension].[PublicHoliday_History](
	[HolidayID] [smallint] NOT NULL,
	[HolidayMonthValue] [smallint] NOT NULL,
	[HolidayDayValue] [smallint] NOT NULL,
	[HolidayName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[HolidayStartYear] [smallint] NULL,
	[HolidayEndYear] [smallint] NULL,
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
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dimension].[PublicHoliday_History]') AND name = N'ix_PublicHoliday_History')
CREATE CLUSTERED INDEX [ix_PublicHoliday_History] ON [dimension].[PublicHoliday_History]
(
	[EndDT] ASC,
	[StartDT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
