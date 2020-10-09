SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ActiveSubscriptions](
	[ActiveID] [uniqueidentifier] NOT NULL,
	[SubscriptionID] [uniqueidentifier] NOT NULL,
	[TotalNotifications] [int] NULL,
	[TotalSuccesses] [int] NOT NULL,
	[TotalFailures] [int] NOT NULL
) ON [PRIMARY]

GO
