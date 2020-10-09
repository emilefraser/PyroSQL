SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [raw].[REF_Date](
	[HK_DATE] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LoadDT] [datetime2](7) NULL,
	[RecSrcDataEntityID] [int] NULL,
	[CalendarDate] [date] NULL,
	[LastSeenDT] [datetime2](7) NULL
) ON [PRIMARY]

GO
