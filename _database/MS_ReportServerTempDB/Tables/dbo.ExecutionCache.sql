SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ExecutionCache](
	[ExecutionCacheID] [uniqueidentifier] NOT NULL,
	[ReportID] [uniqueidentifier] NOT NULL,
	[ExpirationFlags] [int] NOT NULL,
	[AbsoluteExpiration] [datetime] NULL,
	[RelativeExpiration] [int] NULL,
	[SnapshotDataID] [uniqueidentifier] NOT NULL,
	[LastUsedTime] [datetime] NOT NULL,
	[ParamsHash] [int] NOT NULL
) ON [PRIMARY]

GO
