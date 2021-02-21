SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dimension].[CalendarTypeHistory]') AND type in (N'U'))
BEGIN
CREATE TABLE [dimension].[CalendarTypeHistory](
	[CalendarTypeID] [smallint] NOT NULL,
	[CalendarTypeCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CalendarTypeDescription] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StartDT] [datetime2](7) NOT NULL,
	[EndDT] [datetime2](7) NOT NULL
) ON [PRIMARY]
END
GO
