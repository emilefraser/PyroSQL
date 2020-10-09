SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Notifications](
	[NotificationID] [uniqueidentifier] NOT NULL,
	[SubscriptionID] [uniqueidentifier] NOT NULL,
	[ActivationID] [uniqueidentifier] NULL,
	[ReportID] [uniqueidentifier] NOT NULL,
	[SnapShotDate] [datetime] NULL,
	[ExtensionSettings] [ntext] COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Locale] [nvarchar](128) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Parameters] [ntext] COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ProcessStart] [datetime] NULL,
	[NotificationEntered] [datetime] NOT NULL,
	[ProcessAfter] [datetime] NULL,
	[Attempt] [int] NULL,
	[SubscriptionLastRunTime] [datetime] NOT NULL,
	[DeliveryExtension] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[SubscriptionOwnerID] [uniqueidentifier] NOT NULL,
	[IsDataDriven] [bit] NOT NULL,
	[BatchID] [uniqueidentifier] NULL,
	[ProcessHeartbeat] [datetime] NULL,
	[Version] [int] NOT NULL,
	[ReportZone] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
