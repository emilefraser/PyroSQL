SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [config].[CalendarHistory](
	[CalendarID] [int] NOT NULL,
	[CalendarCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CalendarDescription] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CalendarType] [smallint] NOT NULL,
	[FirstPeriodStarDate] [date] NOT NULL,
	[StartDT] [datetime2](7) NOT NULL,
	[EndDT] [datetime2](7) NOT NULL
) ON [PRIMARY]

GO
