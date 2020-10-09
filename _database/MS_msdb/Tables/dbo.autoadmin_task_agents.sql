SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[autoadmin_task_agents](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[task_assembly_name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[task_assembly_path] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[className] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
