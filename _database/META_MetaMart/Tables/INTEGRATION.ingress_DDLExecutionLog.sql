SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [INTEGRATION].[ingress_DDLExecutionLog](
	[DDLExecutionLogID] [int] IDENTITY(1,1) NOT NULL,
	[DDLQueryText] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DDLExecutionQueueID] [int] NOT NULL,
	[Result] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ErrorID] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ErrorMessage] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
