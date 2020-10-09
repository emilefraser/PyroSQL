SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[User](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FirstName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Surname] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[WorkflowRoleID] [int] NULL,
	[Email] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
