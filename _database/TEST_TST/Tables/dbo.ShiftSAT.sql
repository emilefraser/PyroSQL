SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ShiftSAT](
	[ShiftVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[EndTime] [time](7) NOT NULL,
	[Name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StartTime] [time](7) NOT NULL
) ON [PRIMARY]

GO
