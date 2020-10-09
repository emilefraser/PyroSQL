SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [procfwk].[PipelineParameters](
	[ParameterId] [int] IDENTITY(1,1) NOT NULL,
	[PipelineId] [int] NOT NULL,
	[ParameterName] [varchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ParameterValue] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
