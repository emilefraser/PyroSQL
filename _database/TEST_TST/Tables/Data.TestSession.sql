SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Data].[TestSession](
	[TestSessionId] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TestSessionStart] [datetime] NOT NULL,
	[TestSessionFinish] [datetime] NULL
) ON [PRIMARY]

GO
