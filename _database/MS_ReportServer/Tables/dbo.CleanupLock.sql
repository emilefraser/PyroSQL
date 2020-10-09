SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CleanupLock](
	[ID] [int] NOT NULL,
	[MachineName] [nvarchar](256) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LockDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
