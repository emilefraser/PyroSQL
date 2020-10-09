SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SubscriptionResults](
	[SubscriptionResultID] [uniqueidentifier] NOT NULL,
	[SubscriptionID] [uniqueidentifier] NOT NULL,
	[ExtensionSettingsHash] [int] NOT NULL,
	[ExtensionSettings] [nvarchar](max) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[SubscriptionResult] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
