SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [procfwk].[ErrorLog](
	[LogId] [int] IDENTITY(1,1) NOT NULL,
	[LocalExecutionId] [uniqueidentifier] NOT NULL,
	[AdfPipelineRunId] [uniqueidentifier] NOT NULL,
	[ActivityRunId] [uniqueidentifier] NOT NULL,
	[ActivityName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ActivityType] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ErrorCode] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ErrorType] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ErrorMessage] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
