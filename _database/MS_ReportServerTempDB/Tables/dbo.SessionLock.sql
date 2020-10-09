SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SessionLock](
	[SessionID] [varchar](32) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LockVersion] [int] NOT NULL
) ON [PRIMARY]

GO
