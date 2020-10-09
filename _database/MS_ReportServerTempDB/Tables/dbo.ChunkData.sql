SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ChunkData](
	[ChunkID] [uniqueidentifier] NOT NULL,
	[SnapshotDataID] [uniqueidentifier] NOT NULL,
	[ChunkFlags] [tinyint] NULL,
	[ChunkName] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ChunkType] [int] NULL,
	[Version] [smallint] NULL,
	[MimeType] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Content] [image] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
