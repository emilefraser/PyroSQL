SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Catalog](
	[ItemID] [uniqueidentifier] NOT NULL,
	[Path] [nvarchar](425) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Name] [nvarchar](425) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[ParentID] [uniqueidentifier] NULL,
	[Type] [int] NOT NULL,
	[Content] [varbinary](max) NULL,
	[Intermediate] [uniqueidentifier] NULL,
	[SnapshotDataID] [uniqueidentifier] NULL,
	[LinkSourceID] [uniqueidentifier] NULL,
	[Property] [ntext] COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Description] [nvarchar](512) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Hidden] [bit] NULL,
	[CreatedByID] [uniqueidentifier] NOT NULL,
	[CreationDate] [datetime] NOT NULL,
	[ModifiedByID] [uniqueidentifier] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[MimeType] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SnapshotLimit] [int] NULL,
	[Parameter] [ntext] COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PolicyID] [uniqueidentifier] NOT NULL,
	[PolicyRoot] [bit] NOT NULL,
	[ExecutionFlag] [int] NOT NULL,
	[ExecutionTime] [datetime] NULL,
	[SubType] [nvarchar](128) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ComponentID] [uniqueidentifier] NULL,
	[ContentSize] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
