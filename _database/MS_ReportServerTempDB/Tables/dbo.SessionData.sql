SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SessionData](
	[SessionID] [varchar](32) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CompiledDefinition] [uniqueidentifier] NULL,
	[SnapshotDataID] [uniqueidentifier] NULL,
	[IsPermanentSnapshot] [bit] NULL,
	[ReportPath] [nvarchar](464) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Timeout] [int] NOT NULL,
	[AutoRefreshSeconds] [int] NULL,
	[Expiration] [datetime] NOT NULL,
	[ShowHideInfo] [image] NULL,
	[DataSourceInfo] [image] NULL,
	[OwnerID] [uniqueidentifier] NOT NULL,
	[EffectiveParams] [ntext] COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreationTime] [datetime] NOT NULL,
	[HasInteractivity] [bit] NULL,
	[SnapshotExpirationDate] [datetime] NULL,
	[HistoryDate] [datetime] NULL,
	[PageHeight] [float] NULL,
	[PageWidth] [float] NULL,
	[TopMargin] [float] NULL,
	[BottomMargin] [float] NULL,
	[LeftMargin] [float] NULL,
	[RightMargin] [float] NULL,
	[AwaitingFirstExecution] [bit] NULL,
	[EditSessionID] [varchar](32) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DataSetInfo] [varbinary](max) NULL,
	[SitePath] [nvarchar](440) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SiteZone] [int] NOT NULL,
	[ReportDefinitionPath] [nvarchar](464) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
