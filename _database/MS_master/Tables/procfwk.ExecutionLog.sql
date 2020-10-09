SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [procfwk].[ExecutionLog](
	[LogId] [int] IDENTITY(1,1) NOT NULL,
	[LocalExecutionId] [uniqueidentifier] NOT NULL,
	[StageId] [int] NOT NULL,
	[PipelineId] [int] NOT NULL,
	[CallingDataFactoryName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ResourceGroupName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DataFactoryName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PipelineName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StartDateTime] [datetime] NULL,
	[PipelineStatus] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EndDateTime] [datetime] NULL,
	[AdfPipelineRunId] [uniqueidentifier] NULL,
	[PipelineParamsUsed] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
