SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CPUStatsHistory](
	[CPUStatsHistoryID] [int] IDENTITY(1,1) NOT NULL,
	[SQLProcessPercent] [int] NULL,
	[SystemIdleProcessPercent] [int] NULL,
	[OtherProcessPerecnt] [int] NULL,
	[DateStamp] [datetime] NOT NULL
) ON [PRIMARY]

GO
