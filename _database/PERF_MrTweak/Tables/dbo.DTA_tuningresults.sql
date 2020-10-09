SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DTA_tuningresults](
	[SessionID] [int] NOT NULL,
	[StopTime] [datetime] NOT NULL,
	[FinishStatus] [tinyint] NOT NULL,
	[LastPartNumber] [int] NULL
) ON [PRIMARY]

GO
