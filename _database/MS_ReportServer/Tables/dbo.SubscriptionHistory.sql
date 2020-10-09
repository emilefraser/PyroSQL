SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SubscriptionHistory](
	[SubscriptionHistoryID] [bigint] IDENTITY(1,1) NOT NULL,
	[SubscriptionID] [uniqueidentifier] NOT NULL,
	[Type] [tinyint] NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[Status] [tinyint] NULL,
	[Message] [nvarchar](1500) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Details] [nvarchar](4000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
) ON [PRIMARY]

GO
