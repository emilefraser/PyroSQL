SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[systaskids](
	[task_id] [int] IDENTITY(1,1) NOT NULL,
	[job_id] [uniqueidentifier] NOT NULL
) ON [PRIMARY]

GO
