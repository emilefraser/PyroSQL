SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dimension].[CalendarHistory]') AND type in (N'U'))
BEGIN
CREATE TABLE [dimension].[CalendarHistory](
	[CalendarID] [int] NOT NULL,
	[CalendarCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CalendarDescription] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CalendarType] [smallint] NOT NULL,
	[FirstPeriodStarDate] [date] NOT NULL,
	[StartDT] [datetime2](7) NOT NULL,
	[EndDT] [datetime2](7) NOT NULL
) ON [PRIMARY]
END
GO
