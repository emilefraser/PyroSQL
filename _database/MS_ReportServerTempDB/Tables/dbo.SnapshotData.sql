SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SnapshotData](
	[SnapshotDataID] [uniqueidentifier] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ParamsHash] [int] NULL,
	[QueryParams] [ntext] COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EffectiveParams] [ntext] COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Description] [nvarchar](512) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DependsOnUser] [bit] NULL,
	[PermanentRefcount] [int] NOT NULL,
	[TransientRefcount] [int] NOT NULL,
	[ExpirationDate] [datetime] NOT NULL,
	[PageCount] [int] NULL,
	[HasDocMap] [bit] NULL,
	[Machine] [nvarchar](512) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[PaginationMode] [smallint] NULL,
	[ProcessingFlags] [int] NULL,
	[IsCached] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
