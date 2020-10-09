SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [procfwk].[PipelineDependencies](
	[DependencyId] [int] IDENTITY(1,1) NOT NULL,
	[PipelineId] [int] NOT NULL,
	[DependantPipelineId] [int] NOT NULL
) ON [PRIMARY]

GO
