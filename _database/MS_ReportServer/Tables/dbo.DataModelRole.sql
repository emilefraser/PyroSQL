SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DataModelRole](
	[DataModelRoleID] [bigint] IDENTITY(1,1) NOT NULL,
	[ItemID] [uniqueidentifier] NOT NULL,
	[ModelRoleID] [uniqueidentifier] NOT NULL,
	[ModelRoleName] [nvarchar](255) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL
) ON [PRIMARY]

GO
