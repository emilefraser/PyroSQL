SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[monitor].[CPUStatsHistory]') AND type in (N'U'))
BEGIN
CREATE TABLE [monitor].[CPUStatsHistory](
	[CPUStatsHistoryID] [int] IDENTITY(1,1) NOT NULL,
	[SQLProcessPercent] [int] NULL,
	[SystemIdleProcessPercent] [int] NULL,
	[OtherProcessPerecnt] [int] NULL,
	[DateStamp] [datetime] NOT NULL,
 CONSTRAINT [PK_CPUStatsHistory] PRIMARY KEY CLUSTERED 
(
	[CPUStatsHistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[monitor].[DF_CPUStatsHistory_DateStamp]') AND type = 'D')
BEGIN
ALTER TABLE [monitor].[CPUStatsHistory] ADD  CONSTRAINT [DF_CPUStatsHistory_DateStamp]  DEFAULT (getdate()) FOR [DateStamp]
END
GO
