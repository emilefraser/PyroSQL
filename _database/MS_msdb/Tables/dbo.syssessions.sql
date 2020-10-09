SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[syssessions](
	[session_id] [int] IDENTITY(1,1) NOT NULL,
	[agent_start_date] [datetime] NOT NULL
) ON [PRIMARY]

GO
