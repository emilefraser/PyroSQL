SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Event](
	[EventID] [uniqueidentifier] NOT NULL,
	[EventType] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[EventData] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TimeEntered] [datetime] NOT NULL,
	[ProcessStart] [datetime] NULL,
	[ProcessHeartbeat] [datetime] NULL,
	[BatchID] [uniqueidentifier] NULL
) ON [PRIMARY]

GO
