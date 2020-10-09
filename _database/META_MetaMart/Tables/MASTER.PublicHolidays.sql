SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [MASTER].[PublicHolidays](
	[HolidayDate] [datetime] NOT NULL,
	[HolidayName] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
