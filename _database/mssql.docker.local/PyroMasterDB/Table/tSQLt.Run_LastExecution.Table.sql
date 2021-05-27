SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tSQLt].[Run_LastExecution]') AND type in (N'U'))
BEGIN
CREATE TABLE [tSQLt].[Run_LastExecution](
	[TestName] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SessionId] [int] NULL,
	[LoginTime] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
