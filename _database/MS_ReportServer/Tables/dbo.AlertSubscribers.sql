SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AlertSubscribers](
	[AlertSubscriptionID] [bigint] IDENTITY(1,1) NOT NULL,
	[AlertType] [nvarchar](50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UserID] [uniqueidentifier] NOT NULL,
	[ItemID] [uniqueidentifier] NOT NULL
) ON [PRIMARY]

GO
