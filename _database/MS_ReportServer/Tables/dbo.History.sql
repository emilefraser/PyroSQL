SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[History](
	[HistoryID] [uniqueidentifier] NOT NULL,
	[ReportID] [uniqueidentifier] NOT NULL,
	[SnapshotDataID] [uniqueidentifier] NOT NULL,
	[SnapshotDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
