SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [MASTERDATA].[CalendarTypeHistory](
	[CalendarTypeID] [smallint] NOT NULL,
	[CalendarTypeCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CalendarTypeDescription] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StartDT] [datetime2](7) NOT NULL,
	[EndDT] [datetime2](7) NOT NULL
) ON [PRIMARY]

GO
