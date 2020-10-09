SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DTA_reports_index](
	[IndexID] [int] IDENTITY(1,1) NOT NULL,
	[TableID] [int] NOT NULL,
	[IndexName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IsClustered] [bit] NOT NULL,
	[IsUnique] [bit] NOT NULL,
	[IsHeap] [bit] NOT NULL,
	[IsExisting] [bit] NOT NULL,
	[IsFiltered] [bit] NOT NULL,
	[Storage] [float] NOT NULL,
	[NumRows] [bigint] NOT NULL,
	[IsRecommended] [bit] NOT NULL,
	[RecommendedStorage] [float] NOT NULL,
	[PartitionSchemeID] [int] NULL,
	[SessionUniquefier] [int] NULL,
	[FilterDefinition] [nvarchar](1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
