SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Roles](
	[RoleID] [uniqueidentifier] NOT NULL,
	[RoleName] [nvarchar](260) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Description] [nvarchar](512) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TaskMask] [nvarchar](32) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[RoleFlags] [tinyint] NOT NULL
) ON [PRIMARY]

GO
