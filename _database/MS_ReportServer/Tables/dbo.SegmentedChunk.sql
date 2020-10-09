SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SegmentedChunk](
	[ChunkId] [uniqueidentifier] NOT NULL,
	[SnapshotDataId] [uniqueidentifier] NOT NULL,
	[ChunkFlags] [tinyint] NOT NULL,
	[ChunkName] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[ChunkType] [int] NOT NULL,
	[Version] [smallint] NOT NULL,
	[MimeType] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SegmentedChunkId] [bigint] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]

GO
