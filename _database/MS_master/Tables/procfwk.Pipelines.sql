SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [procfwk].[Pipelines](
	[PipelineId] [int] IDENTITY(1,1) NOT NULL,
	[DataFactoryId] [int] NOT NULL,
	[StageId] [int] NOT NULL,
	[PipelineName] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LogicalPredecessorId] [int] NULL,
	[Enabled] [bit] NOT NULL
) ON [PRIMARY]

GO
