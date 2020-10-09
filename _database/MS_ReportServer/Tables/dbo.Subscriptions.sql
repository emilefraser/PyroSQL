SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Subscriptions](
	[SubscriptionID] [uniqueidentifier] NOT NULL,
	[OwnerID] [uniqueidentifier] NOT NULL,
	[Report_OID] [uniqueidentifier] NOT NULL,
	[Locale] [nvarchar](128) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[InactiveFlags] [int] NOT NULL,
	[ExtensionSettings] [ntext] COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ModifiedByID] [uniqueidentifier] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[Description] [nvarchar](512) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LastStatus] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EventType] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[MatchData] [ntext] COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LastRunTime] [datetime] NULL,
	[Parameters] [ntext] COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DataSettings] [ntext] COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DeliveryExtension] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Version] [int] NOT NULL,
	[ReportZone] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
