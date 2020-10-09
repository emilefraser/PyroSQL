SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysjobstepslogs](
	[log_id] [int] IDENTITY(1,1) NOT NULL,
	[log] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[date_created] [datetime] NOT NULL,
	[date_modified] [datetime] NOT NULL,
	[log_size] [bigint] NOT NULL,
	[step_uid] [uniqueidentifier] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
